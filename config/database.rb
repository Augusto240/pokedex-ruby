require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: File.join(File.dirname(__FILE__), '../db/pokedex.db')
)

unless ActiveRecord::Base.connection.table_exists?(:pokemons)
  ActiveRecord::Base.connection.create_table :pokemons do |t|
    t.integer :pokemon_id, null: false
    t.string :name, null: false
    t.boolean :favorite, default: false
    t.timestamps
  end

  ActiveRecord::Base.connection.add_index :pokemons, :pokemon_id, unique: true
end