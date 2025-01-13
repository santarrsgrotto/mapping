CREATE TABLE IF NOT EXISTS ratings (
   work_key TEXT,
   edition_key TEXT,
   rating INTEGER,
   date DATE
);

TRUNCATE TABLE ratings;

CREATE TEMPORARY TABLE tmp_csv (LIKE ratings);
\copy tmp_csv FROM 'ol_ratings.csv' WITH (FORMAT csv);

INSERT INTO ratings (work_key, edition_key, rating, date)
SELECT work_key, edition_key, rating, date FROM tmp_csv;

CREATE INDEX ratings_work_idx ON ratings (work_key);
CREATE INDEX ratings_edition_idx ON ratings (edition_key);

DROP TABLE tmp_csv;
