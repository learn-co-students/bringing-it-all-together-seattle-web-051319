class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<~SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<~SQL
    DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(hash)
    dog = Dog.new(name: hash[:name], breed: hash[:breed])
    dog.id = hash[0]
    dog.save
    dog
  end

  def self.new_from_db(row)
    new_dog = self.new(name: row[1], breed: row[2])
    new_dog.id = row[0]
    new_dog
  end

  def self.name_finder(name)
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    self.name_finder(name).first
  end

  def self.find_by_id(id)
    sql = <<~SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(hash)
    dog_checker = self.name_finder(hash[:name])
    matching_dog = dog_checker.find do |dog|
            dog.breed == hash[:breed]
          end
    if matching_dog
      matching_dog
    else
      self.create(hash)
    end
  end

  def update
    sql = <<~SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

    def save
      if self.id
        self.update
      else
        sql = <<~SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
      end
    end

end
