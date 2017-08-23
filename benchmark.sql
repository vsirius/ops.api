 SELECT seeds.day,
        seeds.existing_hash = declarations.calculated_hash AS day_is_valid
   FROM (
          SELECT DISTINCT DATE(inserted_at) as day
            FROM seeds
        ) AS days
   JOIN (
            SELECT DATE(inserted_at) AS day,
                   digest(array_to_string(array_agg(
                     concat(
                       id,
                       employee_id,
                       start_date,
                       end_date,
                       signed_at,
                       created_by,
                       is_active,
                       scope,
                       division_id,
                       legal_entity_id,
                       inserted_at,
                       declaration_request_id,
                       signed_data,
                       seed
                     ) ORDER BY id ASC
                   ), ''), 'sha512')::bytea AS calculated_hash
              FROM declarations
          GROUP BY DATE(inserted_at)
        ) AS declarations ON declarations.day = days.day
   JOIN (
          SELECT DATE(inserted_at) AS day,
                 hash AS existing_hash
            FROM seeds
        ) AS seeds ON seeds.day = days.day
