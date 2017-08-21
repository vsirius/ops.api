require 'pg'
require 'json'

template_file = File.read('output_nice.json')
template = JSON.parse(template_file)

conn = PG.connect(dbname: 'ops_dev')

DAYS = 14
PER_DAY = 100..200

DAYS.times do |_day|
  seed = conn.exec("SELECT hash FROM seeds ORDER BY inserted_at DESC LIMIT 1").map { |row| row["hash"] }[0]

  samples = PER_DAY.to_a.sample

  samples.times do |_declaration|
    # TODO: drop this table and instead add a column to declarations table
    conn.exec("
      INSERT INTO signed_declarations (
        id,
        signed_data
      ) VALUES (
        uuid_generate_v4(),
        '#{template_file}'
      );
    ")

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
        now(),
        now(),
        '3BA18EA0-09A7-4D5D-9330-029E02DD29AB',
        '#{seed}'
      )"
    )

    conn.exec("INSERT INTO signed_declarations (id, signed_data) VALUES (uuid_generate_v4(), '#{template}')")
  end

  conn.exec("
    INSERT INTO seeds VALUES (
      uuid_generate_v4(),
      (SELECT
        DIGEST(
          ARRAY_AGG(
            CONCAT(
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
              declaration_request_id
            )
          )::text,
          'sha512'
        ) FROM declarations),
        now()
      )
    "
  )

  puts "Day #{_day + 1}: generated #{samples} declarations."
end
