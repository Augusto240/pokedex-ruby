class Team < ActiveRecord::Base
  has_many :team_pokemons, dependent: :destroy
  
  validates :name, presence: true
  
  def full?
    team_pokemons.count >= 6
  end
  
  def add_pokemon(pokemon_id, pokemon_name, nickname = nil, position = nil)
    return false if full? && position.nil?
    
    if position.nil?
      position = (team_pokemons.maximum(:position) || 0) + 1
    end
    
    team_pokemons.create(
      pokemon_id: pokemon_id,
      pokemon_name: pokemon_name,
      nickname: nickname,
      position: position
    )
  end
  
  def remove_pokemon(position)
    pokemon = team_pokemons.find_by(position: position)
    return false unless pokemon
    
    pokemon.destroy
    
    # Reordenar posições após remoção
    team_pokemons.where('position > ?', position).order(:position).each do |p|
      p.update(position: p.position - 1)
    end
    
    true
  end
end