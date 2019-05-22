class Dog
  
  attr_accessor :name, :breed, :id
  
  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    if hash[:id]
      @id = hash[:id]
    else 
      @id = nil
    end
  end
  
  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        );
        SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
 
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    return self
  end
  
  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    return dog
  end
  
  def self.new_from_db(row)
    hash = {:id => row[0], :name => row[1], :breed => row[2]}
    return Dog.new(hash)
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * 
      FROM dogs 
      WHERE id = ?
    SQL
    result = DB[:conn].execute(sql, id)[0]
    Dog.new({:id => result[0], :name => result[1], :breed => result[2]})
  end
  
  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? and breed = ?", hash[:name], hash[:breed])
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new({:id => dog_info[0], :name => dog_info[1], :breed => dog_info[2]})
    else 
      dog = self.create(hash)
    end
    return dog
  end
  
  def self.find_by_name(name)
    result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    return Dog.new({:id => result[0], :name => result[1], :breed => result[2]})
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
    
    
  
end