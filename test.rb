require 'pg'
require 'json'

template_file = File.read('output_nice.json')
template = JSON.parse(template_file)

conn = PG.connect(dbname: 'ops_dev')

DAYS = 14
PER_DAY = 5..10

conn.exec("
  DELETE FROM seeds;
  DELETE FROM declarations;

  INSERT INTO seeds (hash, debug, inserted_at) VALUES (digest('Слава Україні!', 'sha512'), 'Слава Україні!', '2014-01-01 23:59:59');
")

DAYS.times do |day|
  yesterday = (Date.new(2014, 1, 1) + day).to_s
  today = (Date.new(2014, 1, 1) + day + 1).to_s

  seed = conn.exec("SELECT hash FROM seeds ORDER BY inserted_at DESC LIMIT 1").map { |row| row["hash"] }[0]
  samples = PER_DAY.to_a.sample

  samples.times do |_declaration|
    conn.exec("
      INSERT INTO declarations (
        id,
        employee_id,
        person_id,
        start_date,
        end_date,
        status,
        signed_at,
        created_by,
        updated_by,
        is_active,
        scope,
        division_id,
        legal_entity_id,
        inserted_at,
        updated_at,
        declaration_request_id,
        signed_data,
        seed
      ) VALUES (
        uuid_generate_v4(),
        '#{template["employee"]["id"]}',
        '#{template["person"]["id"]}',
        '#{template["start_date"]}',
        '#{template["end_date"]}',
        '#{template["status"]}',
        now(),
        'CCC6C85B-C4DC-43FC-8E75-BA9B855EA597',
        'FB7FF889-4D20-4F00-BAF5-B9E2D3618341',
        'true',
        '#{template["scope"]}',
        '#{template["division"]["id"]}',
        '#{template["legal_entity"]["id"]}',
        '#{today}',
        '#{today}',
        '3BA18EA0-09A7-4D5D-9330-029E02DD29AB',
        '#{template_file}',
        '#{seed}'
      )"
    )
  end

  # TODO: include new column here
  conn.exec("
    INSERT INTO seeds (hash, debug, inserted_at) VALUES (
      (SELECT
        digest(
          ARRAY_TO_STRING(ARRAY_AGG(
            CONCAT(
              id,
              employee_id
            ) ORDER BY inserted_at ASC
          ), ''),
          'sha512'
        ) FROM declarations WHERE DATE(inserted_at) = '#{today}'
      ),
      (SELECT
        ARRAY_TO_STRING(ARRAY_AGG(
          CONCAT(
            id,
            employee_id
          ) ORDER BY inserted_at ASC
        ), '') FROM declarations WHERE DATE(inserted_at) = '#{today}'
      ),
      '#{today} 23:59:59'
    )
  ")

  puts "Day #{today}: generated #{samples} declarations."
end

# Verify

sql = "
  SELECT hash AS expected_hash,
         digest(
           ARRAY_TO_STRING(ARRAY_AGG(
             concat(
               d.id
             ) ORDER BY d.inserted_at ASC
           ), ''),
           'sha512'
         ) AS actual_hash,
         count(1)
    FROM seeds s
    JOIN declarations d ON d.seed = s.hash
GROUP BY hash
"

conn.exec(sql)
