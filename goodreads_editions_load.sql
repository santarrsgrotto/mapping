-- Hacky way of saving if the table already exists or not
CREATE TEMPORARY TABLE setup_state (table_existed boolean);
INSERT INTO setup_state SELECT to_regclass('goodreads_editions') IS NOT NULL;

CREATE TABLE IF NOT EXISTS goodreads_editions (
    id INTEGER,
    ol TEXT
);

CREATE TEMPORARY TABLE tmp_csv (LIKE goodreads_editions);

\copy tmp_csv (id, ol) FROM 'goodreads_editions.csv' WITH (FORMAT csv, HEADER true);

DO $$
BEGIN
    -- If table already exists we load with conflict handling (which uses the index)
    IF (SELECT table_existed FROM setup_state) THEN
        INSERT INTO goodreads_editions (id, ol)
        SELECT id, ol FROM tmp_csv
        ON CONFLICT (id) DO NOTHING;
    -- Otherwise we do faster bulk insert and then set the index up after  
    ELSE
        INSERT INTO goodreads_editions (id, ol)
        SELECT id, ol FROM tmp_csv;

        ALTER TABLE goodreads_editions ADD CONSTRAINT goodreads_editions_pkey PRIMARY KEY (id);
        CREATE INDEX goodreads_editions_ol_idx ON goodreads_editions (ol);
    END IF;
END $$;

DROP TABLE tmp_csv;
DROP TABLE setup_state;
