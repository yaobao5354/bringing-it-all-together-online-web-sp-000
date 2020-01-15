class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(id = nil, attribute)
    @name = attribute[:name]
    @breed = attribute[:breed]
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES(?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    self
  end

  def self.create(attribute)
    new_dog = self.new(attribute)
    new_dog.save
  end

  def self.new_from_db(row)
    attribute_hash = {
      :name => row[1],
      :breed => row[2]
    }
    new_dog = self.new(row[0],attribute_hash)
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
     SELECT *
     FROM dogs
     WHERE id = "#{id}"
     LIMIT 1
   SQL
   dog_array = []
   DB[:conn].execute(sql).map do |row|
     dog_array << self.new_from_db(row)
   end
   dog_array.first
  end

  def self.find_or_create_by(attribute)
    #name = attribute[:name]
    #breed = attribute[:breed]
    sql = <<-SQL
     SELECT *
     FROM dogs
     WHERE name = "#{attribute[:name]}" AND breed = "#{attribute[:breed]}"
    SQL
    row = DB[:conn].execute(sql)
    if row != []
      self.new_from_db(row)
    end

  end

end
