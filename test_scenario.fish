set template (cat template.tmpl.json)

for i in (seq 1 100)
  # set seed (psql ops_dev -At -c "select hash from seeds order by inserted_at desc limit 1")

  echo $template | fakedata -l 1 | jq -c -M '.' > /dev/null

  # psql ops_dev -c 'COPY signed_declarations (data) FROM /Users/gmile/work/ops.api/output.json'
  # psql ops_dev -c 'COPY declarations (data) FROM /Users/gmile/work/ops.api/output_ids.json'
end

#!/usr/bin/env ruby

require 'pg'

conn = PG.connect( dbname: 'sales' )

conn.exec( "SELECT * FROM pg_stat_activity" ) do |result|
  puts "     PID | User             | Query"
  result.each do |row|
    puts " %7d | %-16s | %s " %
      row.values_at('procpid', 'usename', 'current_query')
  end
end
