\echo 'Loading authors data...'
\i goodreads_authors_load.sql

\echo 'Loading editions data...'
\i goodreads_editions_load.sql

\echo 'Loading series data...'
\i goodreads_series_load.sql

\echo 'Loading works data...'
\i goodreads_works_load.sql

\echo 'Loading OL ratings data...'
\i ol_ratings_load.sql

\echo 'Setting up necessary indexes...'
\i goodreads_indexes.sql

\echo 'Loading complete!'
