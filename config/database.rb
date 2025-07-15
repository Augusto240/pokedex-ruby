require 'active_record'
require 'sqlite3'

# Configuração da conexão
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: File.join(File.dirname(__FILE__), '../db/pokedex.db')
)

# Verifica se as tabelas existem e as cria se necessário
unless ActiveRecord::Base.connection.table_exists?(:pokemons)
  ActiveRecord::Base.connection.create_table :pokemons do |t|
    t.integer :pokemon_id, null: false
    t.string :name, null: false
    t.boolean :favorite, default: false
    t.timestamps
  end

  ActiveRecord::Base.connection.add_index :pokemons, :pokemon_id, unique: true
end

unless ActiveRecord::Base.connection.table_exists?(:teams)
  ActiveRecord::Base.connection.create_table :teams do |t|
    t.string :name, null: false
    t.timestamps
  end
end

unless ActiveRecord::Base.connection.table_exists?(:team_pokemons)
  ActiveRecord::Base.connection.create_table :team_pokemons do |t|
    t.references :team, foreign_key: true
    t.integer :pokemon_id, null: false
    t.string :pokemon_name, null: false
    t.string :nickname
    t.integer :position, null: false
    t.timestamps
  end

  ActiveRecord::Base.connection.add_index :team_pokemons, [:team_id, :position], unique: true
end