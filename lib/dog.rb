class Dog
	attr_accessor :name, :breed, :id
	
	def initialize(data)
		@id = nil
		@name = data[:name]
		@breed = data[:breed]
	end
	
	def self.create_table
		sql = <<~SQL
					CREATE TABLE IF NOT EXISTS dogs (
						id INTEGER PRIMARY KEY,
						name TEXT,
						breed TEXT
					)
					SQL
		DB[:conn].execute(sql)
	end
	
	def self.drop_table
		sql = "DROP TABLE IF EXISTS dogs"
		DB[:conn].execute(sql)
	end
	
	def self.new_from_db(row)
		dog = self.new({:name => row[1], :breed => row[2]})
		dog.id = row[0]
		dog
	end
	
	def self.find_by_name(name)
		sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
		result = DB[:conn].execute(sql, name) [0]
		self.new_from_db(result)
	end
	
	def self.find_by_id(id)
		sql = "SELECT * FROM dogs WHERE id = ?"
		result = DB[:conn].execute(sql, id) [0]
		self.new_from_db(result)
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
		sql = <<~SQL
					INSERT INTO dogs (name, breed)
					VALUES (?, ?)
					SQL
		DB[:conn].execute(sql, self.name, self.breed)
		self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self
	end
	
	def self.create(data)
		dog = self.new(data)
		dog.save
	end
	
	def self.find_or_create_by(data)
		sql = <<~SQL
					SELECT * FROM dogs
					WHERE name = ? AND breed = ?
					SQL
		row = DB[:conn].execute(sql, data[:name], data[:breed])
		
		if row.empty?
			self.create(data)
		else
			self.new_from_db(row[0])
		end
	end	
end