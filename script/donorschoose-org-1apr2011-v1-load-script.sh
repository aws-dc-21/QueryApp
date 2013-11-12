#!/bin/sh
# Uses the -U $DBUSER -h $DBHOST -d $DBNAME environment variables.

(
  # \COPY opendata_projects FROM PSTDIN WITH CSV HEADER
  cat donorschoose-org-1apr2011-v1-projects.csv
  echo '\.'

  # \COPY opendata_resources FROM PSTDIN WITH CSV HEADER
  cat donorschoose-org-1apr2011-v1-resources.csv
  echo '\.'

  # \COPY opendata_essays FROM PSTDIN WITH CSV HEADER
  cat donorschoose-org-1apr2011-v1-essays.csv
  echo '\.'

  # \COPY opendata_donations FROM PSTDIN WITH CSV HEADER
  cat donorschoose-org-1apr2011-v1-donations.csv
  echo '\.'

  # \COPY opendata_giftcards FROM PSTDIN WITH CSV HEADER
  cat donorschoose-org-1apr2011-v1-giftcards.csv
  echo '\.'
) \
| psql -U $DBUSER -h $DBHOST -d $DBNAME -f donorschoose-org-1apr2011-load-script.sql
