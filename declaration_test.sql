CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TEMPORARY TABLE json_sample (values jsonb) ON COMMIT DROP;
COPY json_sample FROM '/Users/gmile/work/ops.api/output.json';

DROP TABLE declarations;
DROP TABLE signed_declarations;

CREATE TABLE declarations (
  id int,
  data jsonb
);

CREATE TABLE signed_declarations (
  id int,
  raw_data bytea
);

INSERT INTO declarations (id, data)
SELECT x, (SELECT * FROM json_sample) FROM generate_series(1, 100000) as x;

INSERT INTO signed_declarations (id, raw_data)
SELECT id, digest(data::text, 'sha512') FROM declarations;

-- select count(1) from declarations d join signed_declarations sd on sd.id = d.id and digest(data::text, 'sha512') = sd.raw_data;

-- PREPARE:

-- STRATEGY:
-- 

-- TODO:
-- generate completely random data
-- explore add indexes

-- Notices:
-- To output raw, use:
--   cat file.json | jq -c -M
