class TeamPokemon < ActiveRecord::Base
  belongs_to :team
  
  validates :pokemon_id, presence: true, numericality: { only_integer: true }
  validates :pokemon_name, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 6 }
  validates :position, uniqueness: { scope: :team_id }
  
  validate :team_not_full, on: :create
  
  private
  
  def team_not_full
    if team.team_pokemons.count >= 6 && team.team_pokemons.where(position: position).none?
      errors.add(:team, "já está com o máximo de 6 Pokémon")
    end
  end
end