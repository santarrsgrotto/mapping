-- Hacky way of saving if the table already exists or not
CREATE TEMPORARY TABLE setup_state (table_existed boolean);
INSERT INTO setup_state SELECT to_regclass('goodreads_works') IS NOT NULL;

CREATE TABLE IF NOT EXISTS goodreads_works (
    edition_id INTEGER,
    work_id INTEGER,
    work_ol TEXT,
);

CREATE TEMPORARY TABLE tmp_csv (LIKE goodreads_works);

\copy tmp_csv (edition_id, work_id, work_ol) FROM 'goodreads_works.csv' WITH (FORMAT csv, HEADER true);

DO $$
BEGIN
    -- If table already exists we load with conflict handling (which uses the index)
    IF (SELECT table_existed FROM setup_state) THEN
        INSERT INTO goodreads_works (edition_id, work_id, work_ol)
        SELECT edition_id, work_id, work_ol FROM tmp_csv
        ON CONFLICT (id) DO NOTHING;
    -- Otherwise we do faster bulk insert and then set the index up after  
    ELSE
        INSERT INTO goodreads_works (edition_id, work_id, work_ol)
        SELECT edition_id, work_id, work_ol FROM tmp_csv

        ALTER TABLE goodreads_works ADD CONSTRAINT goodreads_works_pkey PRIMARY KEY (edition_id);
        CREATE INDEX goodreads_works_ol_idx ON goodreads_works (work_ol);
    END IF;
END $$;

DROP TABLE tmp_csv;
DROP TABLE setup_state;
