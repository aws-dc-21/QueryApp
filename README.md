DonorsChoose
============

https://s3.amazonaws.com/chrisb/hackathon.html#donors

> # DonorsChoose.org
>
> ## POC: Vlad Dubovskiy
>
> ### Overview
>
> About us: DonorsChoose.org is an educational online marketplace, where donors can donate money to teachers, students and schools.
>
> Goal: make our open data more accessible and interactive to researchers and developers.
>
> Current state of affairs: researchers and developers currently have to download big files in CSV format, then import them into Excel or a Database, then run Database scripts to re-join the tables before getting to data analysis. The aim is to reduce researchers time to insight generation from our data.
>
> Project details: the project includes creating a relational database and automating the loading of the latest open data CSV extracts (from S3) into a database. An interface would be a simple single webpage that acts as a console for executing queries, returning the data on-screen for display, and/or via CSV for download. A researcher/developer wanting to play with our data would just launch this automation and soon thereafter would have their own instance up and humming. Bonus points if you can find a smart and easy way for researchers to start from the latest CSV files, and be able to pre-load an RDS instance (owned by the researchers) with them, including all the relations in the database.
>
> Impact: DonorsChoose.org data is used by researchers at Stanford, Columbia, Texas A&M, and other top research institutions. We participate in numerous hackathons and data scientist hack our open data to better American educational system. Making it easy and user-friendly to interact and understand is a massive opportunity to grow a community of researchers and wonderful insights into this one-of-a-kind dataset. The impact on the education sector would be very significant, even with a relatively small project like this one.
>
> ## Desired data schema
>
> Each CSV file represents a denormalized table. There's a project table, a donations table, a resources table, etc. Use all CSV files to build the database. Here's [http://developer.donorschoose.org/the-data/data-schema the schema for these 5 denormalized tables]. Using this script one could go from 5 csv files / tables to 9 partially normalized tables. The webpage provides information on how to convert 5 csv files to 9 tables in the database. Here’s the detailed explanation:
>
>   * Run the database script provided to turn 5 files into 9 partially-normalized tables.
>   * Load the data from the CSVs into a relational db and run the db script to partially re-normalize the data.
>
> ## The Data
>
> ### Projects
>
> All classroom projects that have been posted to the site, including lots of school info such as its NCES ID (government-issued), lat/long, and city/state/zip. Data file (73.6 MB)
>
> ### Donations
>
> All donations, including donor city, state, and partial-zip (when available). Data file (272.9 MB)
>
> ### Gift cards
>
> All website-purchased gift cards, including donor and recipient city, state, and partial-zip (when available). Data file (17.5 MB)
>
> ### Project resources
>
> All materials/resources requested for the classroom projects, including vendor name. Data file (175.7 MB)
>
> ### Project written requests
>
> Full text of the teacher-written requests accompanying all classroom projects. Data file(73.6 MB)
>
> ## FAQ
>
>   * What's the shape of the data in the CSV files? Shape of the data (project table example): http://developer.donorschoose.org/the-data/project-data. No transformations are required. Tables already split by CSV, relations defined in the schema.
>   * Where are these CSV files located? What’s data size? There is ~3GB of data in CSV files. Some tables have ~ 2M rows. These files can be downloaded from a public EBS volume.
>   * How to design frontend console for querying data? Once the database instance is setup on researchers AWS, your team will prove that you've succeed using a front-end to run a few queries with joins against the data. The interface is up to your creativity. Use a data interface that's easy to keep secure (such as [http://en.wikipedia.org/wiki/Open_Data_Protocol OData]). In the actual interface, a field for putting in SQL query and “Run Query” button must be present. For bonus points, include a dropdown (or drag and drop) of dimensions/measures into filters. For example: filter on donation created date range. Pivots are extra points. Results will be shown below (limited at 500 rows) and can be downloaded (full result, not just limit 500) as a csv.
>
>     SAMPLE query:
>     How much donation amount is each project type generating each week for the past 6 months?
>
>          SELECT pt.name, DATE(DATE_TRUNC('week', dn.created)) as week, SUM(amounttotal) as total_amount
>          FROM donations dn
>          LEFT JOIN project p USING (proposalid)
>          LEFT JOIN project_type pt USING (proposaltypeid)
>          WHERE dn.created BETWEEN CURRENT_TIMESTAMP - INTERVAL '6 month' AND CURRENT_TIMESTAMP
>          GROUP BY pt.name, week
>          ORDER BY pt.name ASC
>
>     Some examples for inspiration: Example1 and Example2.
>   * Would the researcher be using their own AWS account and run a custom AMI/CloudFormation template that provides the service to them? Is the general public allowed to access the data and run queries? The analogy here is cloning a github repo. The researcher would click clone and fire up an instance of populated database on their own AWS account. This way the researcher gets their own copy of data to manipulate. Their database – their choices. The general public can definitely have access to data and run queries. The general public will be asked to create an Amazon account so they can fire up their DB instance and then query it.
>
> ## Technical Resources
>
> Really, there are two main resources:
>
>   1. 5 csv files for each table stored in S3
>   2. A pretty extensive documentation here.
>
> The last resource is our Data Scientist, Vladimir Dubovskiy, who will be present at re:invent throughout the day. Give him a text message at 720.310.0259 to have Vlad answer any questions in person. He’s uber friendly, and would encourage interaction and design reviews.
