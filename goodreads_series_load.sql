-- Hacky way of saving if the table already exists or not
CREATE TEMPORARY TABLE setup_state (table_existed boolean);
INSERT INTO setup_state SELECT to_regclass('goodreads_series') IS NOT NULL;

CREATE TABLE IF NOT EXISTS goodreads_series (
    work_id INTEGER,
    series_id INTEGER,
    position INTEGER,
    title TEXT
);

CREATE TEMPORARY TABLE tmp_csv (LIKE goodreads_series);

\copy tmp_csv (work_id, series_id, position, title) FROM 'goodreads_series.csv' WITH (FORMAT csv, HEADER true, FORCE_NULL (position))

DO $$
BEGIN
    -- If table already exists we load with conflict handling (which uses the index)
    IF (SELECT table_existed FROM setup_state) THEN
        INSERT INTO goodreads_series (work_id, series_id, position, title)
        SELECT work_id, series_id, position, title FROM tmp_csv
        ON CONFLICT (work_id) DO NOTHING;
    -- Otherwise we do faster bulk insert and then set the index up after
    ELSE
        INSERT INTO goodreads_series (work_id, series_id, position, title)
        SELECT work_id, series_id, position, title FROM tmp_csv;

        ALTER TABLE goodreads_series ADD CONSTRAINT goodreads_series_pkey PRIMARY KEY (work_id);
    END IF;
END $$;

DROP TABLE tmp_csv;
DROP TABLE setup_state;
