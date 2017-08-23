   SELECT seeds.existing_hash,
          declarations.calculated_hash,
          seeds.debug_seed,
          declarations.debug_calculated_hash,
          digest(seeds.debug_seed, 'sha512') as re_hash,
          digest(declarations.debug_calculated_hash, 'sha512') as re_calculated_hash,
          length(seeds.debug_seed),
          length(declarations.debug_calculated_hash)
     FROM (
            SELECT DISTINCT DATE(inserted_at) as day
              FROM seeds
             WHERE DATE(inserted_at) = '2014-01-03'
          ) AS days
     JOIN (
              SELECT DATE(inserted_at) AS day,
                     digest(array_to_string(array_agg(
                       concat_ws(
                         ',',
                         id,
                         inserted_at
                       ) ORDER BY id ASC
                     ), 'zzz'), 'sha512')::bytea AS calculated_hash,

                     array_to_string(array_agg(
                       concat_ws(
                         ',',
                         id,
                         inserted_at
                       ) ORDER BY id ASC
                     ), 'zzz') AS debug_calculated_hash
                FROM declarations
            GROUP BY DATE(inserted_at)
          ) AS declarations ON declarations.day = days.day
     JOIN (
            SELECT DATE(inserted_at) AS day,
                   debug AS debug_seed,
                   hash AS existing_hash
              FROM seeds
          ) AS seeds ON seeds.day = days.day
