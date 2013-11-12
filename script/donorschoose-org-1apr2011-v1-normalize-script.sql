DROP TABLE normalized_giftcard;
DROP TABLE normalized_donation;
DROP TABLE normalized_project;
DROP TABLE normalized_school;
DROP TABLE normalized_teacher;
DROP TABLE normalized_account;
DROP TABLE normalized_city;
DROP TABLE normalized_essay;
DROP TABLE normalized_resource;

DROP SEQUENCE rownum;

\qecho
\qecho NORMALIZE CITIES ...

CREATE TEMP SEQUENCE rownum;

CREATE TABLE normalized_city
(
  id integer NOT NULL,
  city text,
  state character(2)
);

INSERT INTO normalized_city
(id,
 city,
 state
)
select nextval('rownum') as id, city, state
from (
select distinct city,
       state
  from (select CASE WHEN school_city IS NULL
                    THEN NULL
                    WHEN trim(school_city) = ''
                    THEN NULL
                    ELSE trim(school_city)
                END as city,
               CASE WHEN school_state IS NULL
                    THEN NULL
                    WHEN trim(school_state) = ''
                    THEN NULL
                    ELSE trim(school_state)
                END as state
          from donorschoose_projects
         UNION
        select CASE WHEN donor_city IS NULL
                    THEN NULL
                    WHEN trim(donor_city) = ''
                    THEN NULL
                    ELSE trim(donor_city)
                END as city,
               CASE WHEN donor_state IS NULL
                    THEN NULL
                    WHEN trim(donor_state) = ''
                    THEN NULL
                    ELSE trim(donor_state)
                END as state
          from donorschoose_donations
         UNION
        select CASE WHEN buyer_city IS NULL
                    THEN NULL
                    WHEN trim(buyer_city) = ''
                    THEN NULL
                    ELSE trim(buyer_city)
                END as city,
               CASE WHEN buyer_state IS NULL
                    THEN NULL
                    WHEN trim(buyer_state) = ''
                    THEN NULL
                    ELSE trim(buyer_state)
                END as state
          from donorschoose_giftcards
         UNION
        select CASE WHEN recipient_city IS NULL
                    THEN NULL
                    WHEN trim(recipient_city) = ''
                    THEN NULL
                    ELSE trim(recipient_city)
                END as city,
               CASE WHEN recipient_state IS NULL
                    THEN NULL
                    WHEN trim(recipient_state) = ''
                    THEN NULL
                    ELSE trim(recipient_state)
                END as state
          from donorschoose_giftcards
       ) union_cities
 where state is not null or city is not null
 order by state, city
) distinct_cities;

DROP SEQUENCE rownum;

ALTER TABLE normalized_city
      ADD CONSTRAINT pk_normalized_city PRIMARY KEY(id);

VACUUM ANALYZE normalized_city;


\qecho
\qecho NORMALIZE ACCOUNTS ...

CREATE TABLE normalized_account
(
  _acctid text NOT NULL,
  cityid integer,
  zip text
);


INSERT INTO normalized_account
(_acctid,
 cityid,
 zip
)
select union_accounts._acctid,
       c.id as cityid,
       union_accounts.zip
  from (-------------------------
        select coalesce(no_address._acctid, with_address._acctid) as _acctid,
               coalesce(no_address.city, with_address.city) as city,
               coalesce(no_address.state, with_address.state) as state,
               coalesce(no_address.zip, with_address.zip) as zip,
               coalesce(no_address.date_activity, with_address.date_activity) as date_activity
          from (select _donor_acctid as _acctid,
                       donor_city as city,
                       donor_state as state,
                       donor_zip as zip,
                       max(donation_timestamp) as date_activity
                  from donorschoose_donations
                 where donor_city is not null
                    or donor_state is not null
                    or donor_zip is not null
                 group by _donor_acctid, donor_city, donor_state, donor_zip
               ) with_address
          full outer
          join (select _donor_acctid as _acctid,
                       NULL::text as city,
                       NULL::text as state,
                       NULL::text as zip,
                       max(donation_timestamp) as date_activity
                  from donorschoose_donations
                 where donor_city is null
                   and donor_state is null
                   and donor_zip is null
                 group by _donor_acctid
               ) no_address
         using (_acctid)
         UNION--------------------
        select _buyer_acctid as _acctid,
               buyer_city as city,
               buyer_state as state,
               buyer_zip as zip,
               max(date_purchased)::timestamp without time zone as date_activity
          from donorschoose_giftcards
          left join donorschoose_donations on _donor_acctid = _buyer_acctid
         where _donor_acctid IS NULL
         group by _buyer_acctid, buyer_city, buyer_state, buyer_zip
         UNION--------------------
        select r._recipient_acctid as _acctid,
               r.recipient_city as city,
               r.recipient_state as state,
               r.recipient_zip as zip,
               max(r.date_redeemed)::timestamp without time zone as date_activity
          from donorschoose_giftcards r
          left join donorschoose_donations on _donor_acctid = r._recipient_acctid
          left join donorschoose_giftcards b on r._recipient_acctid = b._buyer_acctid
         where _donor_acctid IS NULL
           and b._buyer_acctid IS NULL
           and r._recipient_acctid IS NOT NULL
         group by r._recipient_acctid, r.recipient_city, r.recipient_state, r.recipient_zip
         UNION--------------------
        select _teacher_acctid as _acctid,
               school_city as city,
               school_state as state,
               CASE WHEN length(school_zip) > 3 THEN SUBSTRING(school_zip,1,3) || '**' ELSE NULL END as zip,
               CASE WHEN date_thank_you_packet_mailed > date_posted
                    THEN date_thank_you_packet_mailed
                    WHEN date_completed > date_posted
                    THEN date_completed
                    ELSE date_posted
                END::timestamp without time zone as date_activity
           from donorschoose_projects
          where _projectid in
                (select max(_projectid)
                   from donorschoose_projects
                   join (
                         select _teacher_acctid  as _acctid,
                                max(CASE WHEN date_thank_you_packet_mailed > date_posted
                                         THEN date_thank_you_packet_mailed
                                         WHEN date_completed > date_posted
                                         THEN date_completed
                                         ELSE date_posted
                                     END) AS date_activity
                           from donorschoose_projects
                           left join donorschoose_donations
                             on _donor_acctid = _teacher_acctid
                           left join donorschoose_giftcards
                             on _buyer_acctid = _teacher_acctid
                             or _recipient_acctid = _teacher_acctid
                          where _donor_acctid IS NULL
                            and _buyer_acctid IS NULL
                            and _recipient_acctid IS NULL
--and _teacher_acctid in ('2b896810cd1ad0ce1d4b2975d9ed08a9','635382e4eb3ea4edf05b314550f06075','71f49ace4a0acb6049e847c9e999f3e2','98a18eb86063239cadb7b9fa3bfdfb54','d8f151a88a6d298fe5e6de3633a9cd75','f7591fa61711c1fb01debb4278ce64c1','31b0e2ce922e8fea24767d710831ea76')
                          group by _teacher_acctid
                        ) most_recent_activity
                     on _teacher_acctid = _acctid
                    AND (date_thank_you_packet_mailed = date_activity
                      OR date_completed = date_activity
                      OR date_posted = date_activity)
                  group by _teacher_acctid
                )
        -------------------------
       ) union_accounts
  left join normalized_city c
         on CASE WHEN union_accounts.city IS NULL
                 THEN NULL
                 WHEN trim(union_accounts.city) = ''
                 THEN NULL
                 ELSE trim(union_accounts.city)
             END = c.city
        and CASE WHEN union_accounts.state IS NULL
                 THEN NULL
                 WHEN trim(union_accounts.state) = ''
                 THEN NULL
                 ELSE trim(union_accounts.state)
             END = c.state
 order by union_accounts.date_activity;

ALTER TABLE normalized_account
      ADD CONSTRAINT pk_normalized_account PRIMARY KEY(_acctid);

VACUUM ANALYZE normalized_account;

ALTER TABLE normalized_account ADD CONSTRAINT FK_account_city
  FOREIGN KEY (cityid) REFERENCES normalized_city (id);


\qecho
\qecho NORMALIZE TEACHERS ...

CREATE TABLE normalized_teacher
(
  _teacher_acctid text NOT NULL,
  teacher_prefix text,
  teacher_teach_for_america boolean,
  teacher_ny_teaching_fellow boolean
);

INSERT INTO normalized_teacher
(_teacher_acctid,
 teacher_prefix,
 teacher_teach_for_america,
 teacher_ny_teaching_fellow
)
select _teacher_acctid,
       teacher_prefix,
       teacher_teach_for_america,
       teacher_ny_teaching_fellow
  from donorschoose_projects
 group by _teacher_acctid,
          teacher_prefix,
          teacher_teach_for_america,
          teacher_ny_teaching_fellow
 order by max(CASE WHEN date_thank_you_packet_mailed > date_posted
                   THEN date_thank_you_packet_mailed
                   WHEN date_completed > date_posted
                   THEN date_completed
                   ELSE date_posted
               END);

ALTER TABLE normalized_teacher
      ADD CONSTRAINT pk_normalized_teacher PRIMARY KEY(_teacher_acctid);

VACUUM ANALYZE normalized_teacher;

ALTER TABLE normalized_teacher ADD CONSTRAINT FK_teacher_account
  FOREIGN KEY (_teacher_acctid) REFERENCES normalized_account (_acctid);




\qecho
\qecho NORMALIZE SCHOOLS ...

CREATE TABLE normalized_school
(
 -- IDs
  _schoolid text NOT NULL,
  ncesid text,

 -- School Location
  latitude numeric(11,6),
  longitude numeric(11,6),
  cityid integer NOT NULL,
  zip text,
  metro text,
  district text,
  county text,

 -- School Types
  charter boolean,
  magnet boolean,
  year_round boolean,

 -- Charter Network Affiliation
  nlns boolean,
  kipp boolean,
  charter_ready_promise boolean
);

INSERT INTO normalized_school
(
  _schoolid,
  ncesid,
  latitude,
  longitude,
  cityid,
  zip,
  metro,
  district,
  county,
  charter,
  magnet,
  year_round,
  nlns,
  kipp,
  charter_ready_promise
)
select
  _schoolid,
  school_ncesid AS ncesid,
  school_latitude AS latitude,
  school_longitude AS longitude,
  c.id AS cityid,
  school_zip AS zip,
  school_metro AS metro,
  school_district AS district,
  school_county AS county,
  school_charter AS charter,
  school_magnet AS magnet,
  school_year_round AS year_round,
  school_nlns AS nlns,
  school_kipp AS kipp,
  school_charter_ready_promise AS charter_ready_promise
from donorschoose_projects
  left join normalized_city c
         on CASE WHEN school_city IS NULL
                 THEN NULL
                 WHEN trim(school_city) = ''
                 THEN NULL
                 ELSE trim(school_city)
             END = c.city
        and CASE WHEN school_state IS NULL
                 THEN NULL
                 WHEN trim(school_state) = ''
                 THEN NULL
                 ELSE trim(school_state)
             END = c.state
group by _schoolid,
  school_ncesid,
  school_latitude,
  school_longitude,
  c.id,
  school_zip,
  school_metro,
  school_district,
  school_county,
  school_charter,
  school_magnet,
  school_year_round,
  school_nlns,
  school_kipp,
  school_charter_ready_promise
 order by max(CASE WHEN date_thank_you_packet_mailed > date_posted
                   THEN date_thank_you_packet_mailed
                   WHEN date_completed > date_posted
                   THEN date_completed
                   ELSE date_posted
               END);

ALTER TABLE normalized_school
      ADD CONSTRAINT pk_normalized_school PRIMARY KEY(_schoolid);

VACUUM ANALYZE normalized_school;

ALTER TABLE normalized_school ADD CONSTRAINT FK_school_city
  FOREIGN KEY (cityid) REFERENCES normalized_city (id);


\qecho
\qecho NORMALIZE PROJECTS ...

CREATE TABLE normalized_project
(
 -- IDs
  _projectid text NOT NULL,
  _teacher_acctid text NOT NULL,
  _schoolid text NOT NULL,

 -- Project Categories
  primary_focus_subject text,
  primary_focus_area text,
  secondary_focus_subject text,
  secondary_focus_area text,
  resource_usage text,
  resource_type text,
  poverty_level text,
  grade_level text,

 -- Project Pricing and Impact
  vendor_shipping_charges numeric(10,2),
  sales_tax numeric(10,2),
  payment_processing_charges numeric(10,2),
  fulfillment_labor_materials numeric(10,2),
  total_price_excluding_optional_support numeric(10,2),
  total_price_including_optional_support numeric(10,2),
  students_reached integer,
  used_by_future_students boolean,

 -- Project Donations
  total_donations numeric(10,2),
  num_donors integer,
  eligible_double_your_impact_match boolean,
  eligible_almost_home_match boolean,

 -- Project Status
  funding_status text,
  date_posted date,
  date_completed date,
  date_thank_you_packet_mailed date,
  date_expiration date
);

INSERT INTO normalized_project
(
  _projectid,
  _teacher_acctid,
  _schoolid,
  primary_focus_subject,
  primary_focus_area,
  secondary_focus_subject,
  secondary_focus_area,
  resource_usage,
  resource_type,
  poverty_level,
  grade_level,
  vendor_shipping_charges,
  sales_tax,
  payment_processing_charges,
  fulfillment_labor_materials,
  total_price_excluding_optional_support,
  total_price_including_optional_support,
  students_reached,
  used_by_future_students,
  total_donations,
  num_donors,
  eligible_double_your_impact_match,
  eligible_almost_home_match,
  funding_status,
  date_posted,
  date_completed,
  date_thank_you_packet_mailed,
  date_expiration
)
select
  _projectid,
  _teacher_acctid,
  _schoolid,
  primary_focus_subject,
  primary_focus_area,
  secondary_focus_subject,
  secondary_focus_area,
  resource_usage,
  resource_type,
  poverty_level,
  grade_level,
  vendor_shipping_charges,
  sales_tax,
  payment_processing_charges,
  fulfillment_labor_materials,
  total_price_excluding_optional_support,
  total_price_including_optional_support,
  students_reached,
  used_by_future_students,
  total_donations,
  num_donors,
  eligible_double_your_impact_match,
  eligible_almost_home_match,
  funding_status,
  date_posted,
  date_completed,
  date_thank_you_packet_mailed,
  date_expiration
from donorschoose_projects;

ALTER TABLE normalized_project
      ADD CONSTRAINT pk_normalized_project PRIMARY KEY(_projectid);

VACUUM ANALYZE normalized_project;

ALTER TABLE normalized_project ADD CONSTRAINT FK_project_teacher
  FOREIGN KEY (_teacher_acctid) REFERENCES normalized_teacher (_teacher_acctid);

ALTER TABLE normalized_project ADD CONSTRAINT FK_project_school
  FOREIGN KEY (_schoolid) REFERENCES normalized_school (_schoolid);




\qecho
\qecho NORMALIZE DONATIONS ...

CREATE TABLE normalized_donation
(
 -- IDs
  _donationid text NOT NULL,
  _projectid text NOT NULL,
  _donor_acctid text NOT NULL,
  _cartid text,

 -- Donation Times and Amounts
  donation_timestamp timestamp without time zone,
  dollar_amount text,
  donation_included_optional_support boolean,

 ---Payment Types
  payment_method text,
  payment_included_acct_credit boolean,
  payment_included_campaign_gift_card boolean,
  payment_included_web_purchased_gift_card boolean,

 ---Donation Types
  via_giving_page boolean,
  for_honoree boolean,
  thank_you_packet_mailed boolean
);

INSERT INTO normalized_donation
(
  _donationid,
  _projectid,
  _donor_acctid,
  _cartid,
  donation_timestamp,
  dollar_amount,
  donation_included_optional_support,
  payment_method,
  payment_included_acct_credit,
  payment_included_campaign_gift_card,
  payment_included_web_purchased_gift_card,
  via_giving_page,
  for_honoree,
  thank_you_packet_mailed
)
select
  _donationid,
  _projectid,
  _donor_acctid,
  _cartid,
  donation_timestamp,
  dollar_amount,
  donation_included_optional_support,
  payment_method,
  payment_included_acct_credit,
  payment_included_campaign_gift_card,
  payment_included_web_purchased_gift_card,
  via_giving_page,
  for_honoree,
  thank_you_packet_mailed
from donorschoose_donations;

ALTER TABLE normalized_donation
      ADD CONSTRAINT pk_normalized_donation PRIMARY KEY(_donationid);

VACUUM ANALYZE normalized_donation;

ALTER TABLE normalized_donation ADD CONSTRAINT FK_donation_project
  FOREIGN KEY (_projectid) REFERENCES normalized_project (_projectid);

ALTER TABLE normalized_donation ADD CONSTRAINT FK_donation_account
  FOREIGN KEY (_donor_acctid) REFERENCES normalized_account (_acctid);





\qecho
\qecho NORMALIZE GIFTCARDS ...

CREATE TABLE normalized_giftcard
(
  _giftcardid text NOT NULL,
  dollar_amount text,

  _buyer_acctid text NOT NULL,
  date_purchased date,
  _buyer_cartid text,

  _recipient_acctid text,
  redeemed boolean,
  date_redeemed date,
  _redeemed_cartid text
);

INSERT INTO normalized_giftcard
(
  _giftcardid,
  dollar_amount,
  _buyer_acctid,
  date_purchased,
  _buyer_cartid,
  _recipient_acctid,
  redeemed,
  date_redeemed,
  _redeemed_cartid
)
select
  _giftcardid,
  dollar_amount,
  _buyer_acctid,
  date_purchased,
  _buyer_cartid,
  _recipient_acctid,
  redeemed,
  date_redeemed,
  _redeemed_cartid
from donorschoose_giftcards;

ALTER TABLE normalized_giftcard
      ADD CONSTRAINT pk_normalized_giftcard PRIMARY KEY(_giftcardid);

VACUUM ANALYZE normalized_giftcard;

ALTER TABLE normalized_giftcard ADD CONSTRAINT FK_giftcard_buyer_account
  FOREIGN KEY (_buyer_acctid) REFERENCES normalized_account (_acctid);

ALTER TABLE normalized_giftcard ADD CONSTRAINT FK_giftcard_recipient_account
  FOREIGN KEY (_recipient_acctid) REFERENCES normalized_account (_acctid);



\qecho
\qecho NORMALIZE ESSAYS ...

CREATE TABLE normalized_essay
(
  _projectid text NOT NULL,
  title text,
  short_description text,
  need_statement text,
  essay text,
  paragraph1 text,
  paragraph2 text,
  paragraph3 text,
  paragraph4 text
);

INSERT INTO normalized_essay
(
  _projectid,
  title,
  short_description,
  need_statement,
  essay,
  paragraph1,
  paragraph2,
  paragraph3,
  paragraph4
)
select
  _projectid,
  title,
  short_description,
  need_statement,
  essay,
  paragraph1,
  paragraph2,
  paragraph3,
  paragraph4
from donorschoose_essays;

ALTER TABLE normalized_essay
      ADD CONSTRAINT pk_normalized_essay PRIMARY KEY(_projectid);

VACUUM ANALYZE normalized_essay;

ALTER TABLE normalized_essay ADD CONSTRAINT FK_essay_project
  FOREIGN KEY (_projectid) REFERENCES normalized_project (_projectid);



\qecho
\qecho NORMALIZE RESOURCES ...

CREATE TABLE normalized_resource
(
  _resourceid text NOT NULL,
  _projectid text NOT NULL,
  vendorid integer,
  vendor_name text,
  project_resource_type text,
  item_name text,
  item_number text,
  item_unit_price text,
  item_quantity text
);

INSERT INTO normalized_resource
(
  _resourceid,
  _projectid,
  vendorid,
  vendor_name,
  project_resource_type,
  item_name,
  item_number,
  item_unit_price,
  item_quantity
)
select
  _resourceid,
  _projectid,
  vendorid,
  vendor_name,
  project_resource_type,
  item_name,
  item_number,
  item_unit_price,
  item_quantity
from donorschoose_resources;

ALTER TABLE normalized_resource
      ADD CONSTRAINT pk_normalized_resource PRIMARY KEY(_resourceid);

VACUUM ANALYZE normalized_resource;

ALTER TABLE normalized_resource ADD CONSTRAINT FK_resource_project
  FOREIGN KEY (_projectid) REFERENCES normalized_project (_projectid);