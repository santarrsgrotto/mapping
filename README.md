This repository contains mapping CSVs between Goodreads IDs and Open Library IDs.

Its primary use case is for loading into a PostgreSQL database via psql, and it assumes https://github.com/LibrariesHacked/openlibrary-search is already installed.

The command to set up the tables and load the data is:

psql -f load.sql -h localhost -p 5432 -U openlibrary -d openlibrary

Adjust as required.
