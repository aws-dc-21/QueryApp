DROP TABLE donorschoose_resources;
DROP TABLE donorschoose_donations;
DROP TABLE donorschoose_essays;
DROP TABLE donorschoose_projects;
DROP TABLE donorschoose_giftcards;

\qecho
\qecho LOAD PROJECTS TABLE ...

CREATE TABLE donorschoose_projects
(
  -- IDs
  _projectid text NOT NULL,
  _teacher_acctid text NOT NULL,
  _schoolid text NOT NULL,
  school_ncesid text,

  -- School Location
  school_latitude numeric(11,6),
  school_longitude numeric(11,6),
  school_city text,
  school_state character(2),
  school_zip text,
  school_metro text,
  school_district text,
  school_county text,

  -- School Types
  school_charter boolean,
  school_magnet boolean,
  school_year_round boolean,
  school_nlns boolean,
  school_kipp boolean,
  school_charter_ready_promise boolean,

  -- Teacher Attributes
  teacher_prefix text,
  teacher_teach_for_america boolean,
  teacher_ny_teaching_fellow boolean,

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
)
WITHOUT OIDS;


\COPY donorschoose_projects FROM PSTDIN WITH CSV HEADER
\qecho ... DONE

-------------------------------

\qecho
\qecho LOAD RESOURCES TABLE ...

CREATE TABLE donorschoose_resources
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
)
WITHOUT OIDS;


\COPY donorschoose_resources FROM PSTDIN WITH CSV HEADER
\qecho ... DONE

-------------------------------

\qecho
\qecho LOAD ESSAYS TABLE ...

CREATE TABLE donorschoose_essays
(
  _projectid text NOT NULL,
  _teacher_acctid text NOT NULL,

  title text,
  short_description text,
  need_statement text,
  essay text,
  paragraph1 text,
  paragraph2 text,
  paragraph3 text,
  paragraph4 text
)
WITHOUT OIDS;


\COPY donorschoose_essays FROM PSTDIN WITH CSV HEADER
\qecho ... DONE

-------------------------------

\qecho
\qecho LOAD DONATIONS TABLE ...

CREATE TABLE donorschoose_donations
(
  -- IDs
  _donationid text NOT NULL,
  _projectid text NOT NULL,
  _donor_acctid text NOT NULL,
  _cartid text,

  -- Donor Info
  donor_city text,
  donor_state character(2),
  donor_zip text,
  is_teacher_acct boolean,

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
)
WITHOUT OIDS;


\COPY donorschoose_donations FROM PSTDIN WITH CSV HEADER
\qecho ... DONE

-------------------------------

\qecho
\qecho LOAD GIFTCARDS TABLE ...

CREATE TABLE donorschoose_giftcards
(
  _giftcardid text NOT NULL,
  dollar_amount text,

  _buyer_acctid text NOT NULL,
  buyer_city text,
  buyer_state character(2),
  buyer_zip text,

  date_purchased date,
  _buyer_cartid text,

  _recipient_acctid text,
  recipient_city text,
  recipient_state character(2),
  recipient_zip text,

  redeemed boolean,
  date_redeemed date,
  _redeemed_cartid text
)
WITHOUT OIDS;


\COPY donorschoose_giftcards FROM PSTDIN WITH CSV HEADER
\qecho ... DONE

-------------------------------


\qecho
\qecho ALTER PROJECTS TABLE ...
ALTER TABLE donorschoose_projects
      ADD CONSTRAINT pk_donorschoose_projects PRIMARY KEY(_projectid);

CREATE INDEX donorschoose_projects_teacher_acctid
  ON donorschoose_projects
  USING btree
  (_teacher_acctid);

CREATE INDEX donorschoose_projects_schoolid
  ON donorschoose_projects
  USING btree
  (_schoolid);


VACUUM ANALYZE donorschoose_projects;
\qecho ... DONE


\qecho
\qecho ALTER RESOURCES TABLE ...
ALTER TABLE donorschoose_resources
      ADD CONSTRAINT pk_donorschoose_resources PRIMARY KEY(_resourceid);

CREATE INDEX donorschoose_resources_projectid
  ON donorschoose_resources
  USING btree
  (_projectid);


VACUUM ANALYZE donorschoose_resources;

ALTER TABLE donorschoose_resources ADD CONSTRAINT FK_donorschoose_resources_projects
  FOREIGN KEY (_projectid) REFERENCES donorschoose_projects (_projectid);
\qecho ... DONE


\qecho
\qecho ALTER ESSAYS TABLE ...
ALTER TABLE donorschoose_essays
      ADD CONSTRAINT pk_donorschoose_essays PRIMARY KEY(_projectid);

CREATE INDEX donorschoose_essays_teacher_acctid
  ON donorschoose_essays
  USING btree
  (_teacher_acctid);


VACUUM ANALYZE donorschoose_essays;

ALTER TABLE donorschoose_essays ADD CONSTRAINT FK_donorschoose_essays_projects
  FOREIGN KEY (_projectid) REFERENCES donorschoose_projects (_projectid);
\qecho ... DONE


\qecho
\qecho ALTER DONATIONS TABLE ...
ALTER TABLE donorschoose_donations
      ADD CONSTRAINT pk_donorschoose_donations PRIMARY KEY(_donationid);

CREATE INDEX donorschoose_donations_donor_acctid
  ON donorschoose_donations
  USING btree
  (_donor_acctid);

CREATE INDEX donorschoose_donations_projectid
  ON donorschoose_donations
  USING btree
  (_projectid);

CREATE INDEX donorschoose_donations_cartid
  ON donorschoose_donations
  USING btree
  (_cartid);


VACUUM ANALYZE donorschoose_donations;

ALTER TABLE donorschoose_donations ADD CONSTRAINT FK_donorschoose_donations_projects
  FOREIGN KEY (_projectid) REFERENCES donorschoose_projects (_projectid);
\qecho ... DONE


\qecho
\qecho ALTER GIFTCARDS TABLE ...
ALTER TABLE donorschoose_giftcards
      ADD CONSTRAINT pk_donorschoose_giftcards PRIMARY KEY(_giftcardid);

CREATE INDEX donorschoose_giftcards_buyer_acctid
  ON donorschoose_giftcards
  USING btree
  (_buyer_acctid);

CREATE INDEX donorschoose_giftcards_recipient_acctid
  ON donorschoose_giftcards
  USING btree
  (_recipient_acctid);

CREATE INDEX donorschoose_giftcards_buyer_cartid
  ON donorschoose_giftcards
  USING btree
  (_buyer_cartid);

CREATE INDEX donorschoose_giftcards_redeemed_cartid
  ON donorschoose_giftcards
  USING btree
  (_redeemed_cartid);


VACUUM ANALYZE donorschoose_giftcards;
\qecho ... DONE
