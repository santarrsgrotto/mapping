-- For use by indexes
CREATE OR REPLACE FUNCTION immutable_json_timestamp(jsonb)
RETURNS timestamptz AS $$
BEGIN
    RETURN ($1->'created'->>'value')::timestamptz;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

DO $$
BEGIN
    -- BTREE index for work created at timestamp
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_work_created_time') THEN
       CREATE INDEX idx_work_created_time ON works (immutable_json_timestamp(data));
    END IF;

    -- GIN trigram index for author name
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_author_name_trigram') THEN
        CREATE INDEX idx_author_name_trigram ON authors USING GIN ((lower(data->>'name')) gin_trgm_ops);
    END IF;

    -- Secondary ts_vector index for author name
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_author_name_ts_vector') THEN
        CREATE INDEX idx_author_name_ts_vector ON authors USING GIN ((to_tsvector('simple', data->>'name')));
    END IF;

    -- GIN trigram index for work title
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_work_title_trigram') THEN
        CREATE INDEX idx_work_title_trigram ON works USING GIN ((lower(data->>'tile')) gin_trgm_ops);
    END IF;

    -- Secondary ts_vector index for work title
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_work_title_ts_vector') THEN
        CREATE INDEX idx_work_title_ts_vector ON works USING GIN ((to_tsvector('simple', data->>'title')));
    END IF;

    -- BTREE index for works revision
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_works_revision') THEN
        CREATE INDEX idx_works_revision ON works (revision DESC);
    END IF;

    -- BTREE index for editions revision
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_editions_revision') THEN
        CREATE INDEX idx_editions_revision ON editions (revision DESC);
    END IF;
END
$$;

