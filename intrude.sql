WITH cte AS (
  SELECT id
  FROM declarations
  ORDER BY random()
  LIMIT 1
  FOR UPDATE
)
UPDATE declarations SET start_date = '2014-01-10' FROM cte WHERE cte.id = declarations.id;
