require 'pg'
require 'json'

template = JSON.parse(File.read('output_nice.json'))

conn = PG.connect(dbname: 'ops_dev')

2.times do |i|
  seed = "1234"
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
