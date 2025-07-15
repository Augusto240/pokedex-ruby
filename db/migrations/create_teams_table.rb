require 'active_record'

class CreateTeamsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :team_pokemons do |t|
      t.references :team, foreign_key: true
      t.integer :pokemon_id, null: false
      t.string :pokemon_name, null: false
      t.string :nickname
      t.integer :position, null: false
      t.timestamps
    end

    add_index :team_pokemons, [:team_id, :position], unique: true
  end
end