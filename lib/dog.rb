require 'pry'

class Dog
	
	attr_accessor :id, :name, :breed

	def initialize(id: nil, name:, breed:)
		@id = id
		@name = name
		@breed = breed
	end

    def self.create_table

    	sql = <<-SQL
    	CREATE TABLE dogs(
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

    #  def self.create(hash)
    #     dog = Dog.new(name: hash[:name], breed: hash[:breed])
    #     dog.save
    #     dog
    # end



#    returns an instance of the dog class (FAILED - 1)
    # saves an instance of the dog class to the database and then sets the given dogs `id` attribute (FAILED - 2)
    def save
    	if self.id 
    		self.update
    	else
  			sql = <<-SQL
          	INSERT INTO dogs (name, breed) 
          	VALUES (?, ?)
          SQL

           DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
          self

    	end
    end

# takes in a hash of attributes and uses metaprogramming to create a new dog object. 
# Then it uses the save method to save that dog to the database (FAILED - 1)
# returns a new dog object (FAILED - 2)
    def self.create(hash)
        dog = Dog.new(name: hash[:name], breed: hash[:breed])
        dog.save
        dog
        # binding.pry
    end

# returns a new dog object by id
    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        dog = Dog.new(id: result[0], name: result[1], breed: result[2])
        # binding.pry
    end


# # creates an instance of a dog if it does not already exist (FAILED - 1)
#     when two dogs have the same name and different breed, it returns the correct dog (FAILED - 2)
#     when creating a new dog with the same name as persisted dogs, it returns the correct dog (FAILED - 3)
    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
        # binding.pry
    end

    # creates an instance with corresponding attribute values (FAILED - 4)
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
        # binding.pry
    end

    # returns an instance of dog that matches the name from the DB (FAILED - 1)
    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql, name)[0]
        dog = Dog.new(id: result[0], name: result[1], breed: result[2])
        # binding.pry
    end

#     updates the record associated with a given instance
    def update
        sql = <<-SQL 
        UPDATE dogs 
        SET name = ?, breed = ? 
        WHERE id = ?; 
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
        # binding.pry
    end


end