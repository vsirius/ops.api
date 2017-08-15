insert into seeds (hash, inserted_at) values ('Слава Украине!', now());

for i in 1..365 do
  seed = select hash from seeds order by inserted_at desc limit 1;

  generate up to 10_000 declarations via lucapette/fakedata in a FILE
  (make sure "seed" is in each of 10_000 declarations, use it during generation)

  put declaration into "declarations" table (only IDs, design after current declaration table) - with seed
  create create_signed_content via openssl, put signed_content into declaration_signed table - with seed

  if i == 1 do
    verify day(1)
  end

  if new_day?
    calculate_new_hash (take all non-changing declaration fields, (except updated_at, updated_by, status!))
    # verify last day?
  end
end

def verify day do
  select count(1) = 0
    from declarations d
    join signed_declarations sd on sd.id = d.id
     and digest(data::text, 'sha512') = sd.raw_data where date(d.inserted_at) = day;
end
  
# 3. load file into a temp_table
#      seed = if i == 0 ?  : 
#      declarations = select * from temp_table limit 1000 offset i * 1000; 
# 
#      for each declaration in declarations 
#        insert a record, seed  (if i == 0  else )
#        insert a record 
# generate 1k declarations + generate 1M signed declarations
# seed = (1 signed declaration + seed)

https://raymii.org/s/tutorials/Sign_and_verify_text_files_to_public_keys_via_the_OpenSSL_Command_Line.html
