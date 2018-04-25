require 'mysql2'

load "./local_env.rb" if File.exists?("./local_env.rb")

client = Mysql2::Client.new(
    :host => ENV['host'],
    :port => ENV['port'],
    :username => ENV['username'],
    :password => ENV['password'],
    :database => ENV['database']
)

# --------------------------------------------
# ------------- Drop & Create-----------------
# --------------------------------------------

drop testing table if it exists
client.query("drop table if exists testing")

create the testing table
client.query(
    "create table portfoliojv.testing (
        id smallint not null auto_increment,
        photo varchar(50) null,
        constraint PK_species primary key (id)
    )"
) 
  
# Other examples here:
# - 1_drop_and_create_table_reports.rb

# --------------------------------------------
# ---------------- Read ----------------------
# --------------------------------------------

results = client.query("select * from testing")

results.each do |result|
    puts "row: #{result}"
end

# Result:
row: {"id"=>1, "photo"=>"nemo.png"}

# --------------------------------------------

# Parameterized select statements:

bird1 = "Accipitridae"
bird2 = "Fringillidae"
bird3 = "no match"

statement = client.prepare("select common_name, scientific_name, s_order from species_details where s_family = ?")
results1 = statement.execute(bird1)
results2 = statement.execute(bird2)
results3 = statement.execute(bird3)

puts "results1--------------"

results1.each do |result|
    puts "row: #{result}"
end

puts "results2--------------"

results2.each do |result|
    puts "row: #{result}"
end

puts "results3--------------"

results3.each do |result|
    puts "row: #{result}"
end

# Result:
results1--------------
row: {"common_name"=>"Red-Tailed Hawk", "scientific_name"=>"Buteo jamaicensis", "s_order"=>"Accipitriformes"}
results2--------------
row: {"common_name"=>"American Goldfinch", "scientific_name"=>"Spinus tristis", "s_order"=>"Passeriformes"}
row: {"common_name"=>"House Finch", "scientific_name"=>"Haemorhous mexicanus", "s_order"=>"Passeriformes"}
results3--------------

# --------------------------------------------
# ---------------- Write- --------------------
# --------------------------------------------

client.query("insert into testing (photo) values ('butterfly.png')")

results = client.query("select * from testing")

results.each do |result|
    puts "row: #{result}"
end

# Result:
row: {"id"=>1, "photo"=>"nemo.png"}
row: {"id"=>2, "photo"=>"butterfly.png"}

# --------------------------------------------

# Parameterized insert statements:

value1 = "redfish.png"
value2 = "bluefish.png"

statement = client.prepare("insert into testing (photo) values (?)")
statement.execute(value1)
statement.execute(value2)

results = client.query("select * from testing")

results.each do |result|
    puts "row: #{result}"
end

# Result:
row: {"id"=>1, "photo"=>"redfish.png"}
row: {"id"=>2, "photo"=>"bluefish.png"}

# --------------------------------------------
# ---------------- Update --------------------
# --------------------------------------------

client.query("update testing set photo = 'anole.png' where id = 2")

results = client.query("select * from testing")

results.each do |result|
    puts "row: #{result}"
end

# Result:
row: {"id"=>1, "photo"=>"nemo.png"}
row: {"id"=>2, "photo"=>"anole.png"}

# --------------------------------------------

# Parameterized update statements:

value1 = "oldfish.png"
value2 = "newfish.png"

statement = client.prepare("update testing set photo = ? where id = ?")
statement.execute(value1, 1)
statement.execute(value2, 2)

results = client.query("select * from testing")

results.each do |result|
    puts "row: #{result}"
end

# Result:
row: {"id"=>1, "photo"=>"oldfish.png"}
row: {"id"=>2, "photo"=>"newfish.png"}

# --------------------------------------------

# Same but with ID values swapped

value1 = "oldfish.png"
value2 = "newfish.png"

statement = client.prepare("update testing set photo = ? where id = ?")
statement.execute(value1, 2)
statement.execute(value2, 1)

results = client.query("select * from testing")

results.each do |result|
    puts "row: #{result}"
end

# Result:
row: {"id"=>1, "photo"=>"newfish.png"}
row: {"id"=>2, "photo"=>"oldfish.png"}

# --------------------------------------------
# ---------------- Delete --------------------
# --------------------------------------------

client.query("delete from testing where photo = 'anole.png'")

results = client.query("select * from testing")

results.each do |result|
    puts "row: #{result}"
end

# Result:
row: {"id"=>1, "photo"=>"nemo.png"}

# --------------------------------------------

# Parameterized delete statements:

# Initial data set
row: {"id"=>1, "photo"=>"newfish.png"}
row: {"id"=>2, "photo"=>"oldfish.png"}
row: {"id"=>3, "photo"=>"redfish.png"}
row: {"id"=>4, "photo"=>"bluefish.png"}

value1 = "oldfish.png"
value2 = "redfish.png"

statement = client.prepare("delete from testing where photo = ?")
statement.execute(value1)
statement.execute(value2)

results = client.query("select * from testing")

results.each do |result|
    puts "row: #{result}"
end

# Result:
row: {"id"=>1, "photo"=>"newfish.png"}
row: {"id"=>4, "photo"=>"bluefish.png"}

# --------------------------------------------