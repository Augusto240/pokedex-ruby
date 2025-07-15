class TeamController
  def initialize(api_service)
    @api_service = api_service
  end
  
  def list_teams
    Team.all.order(created_at: :desc)
  end
  
  def find_team(id)
    Team.find_by(id: id)
  end
  
  def create_team(name)
    Team.create(name: name)
  end
  
  def update_team(id, name)
    team = Team.find_by(id: id)
    return false unless team
    
    team.update(name: name)
  end
  
  def delete_team(id)
    team = Team.find_by(id: id)
    return false unless team
    
    team.destroy
    true
  end
  
  def add_pokemon_to_team(team_id, pokemon_id, nickname = nil, position = nil)
    puts "Tentando adicionar Pokémon: team_id=#{team_id}, pokemon_id=#{pokemon_id}, nickname=#{nickname}, position=#{position}"
    
    team = Team.find_by(id: team_id)
    puts "Equipe encontrada: #{team.inspect}" if team
    return false unless team
    
    pokemon = @api_service.find_pokemon(pokemon_id)
    puts "Pokémon encontrado: #{pokemon ? 'sim' : 'não'}"
    return false unless pokemon
    
    result = team.add_pokemon(pokemon['id'], pokemon['name'], nickname, position)
    puts "Resultado de add_pokemon: #{result.inspect}"
    
    result
  end
  
  def remove_pokemon_from_team(team_id, position)
    team = Team.find_by(id: team_id)
    return false unless team
    
    team.remove_pokemon(position)
  end
  
  def get_team_with_pokemon_details(team_id)
    team = Team.find_by(id: team_id)
    return nil unless team
    
    team_data = {
      id: team.id,
      name: team.name,
      pokemons: []
    }
    
    team.team_pokemons.order(:position).each do |team_pokemon|
      pokemon_details = @api_service.find_pokemon(team_pokemon.pokemon_id)
      next unless pokemon_details
      
      team_data[:pokemons] << {
        id: team_pokemon.pokemon_id,
        name: team_pokemon.pokemon_name,
        nickname: team_pokemon.nickname,
        position: team_pokemon.position,
        image: pokemon_details['sprites']['other']['official-artwork']['front_default'],
        types: pokemon_details['types']
      }
    end
    
    team_data
  end
  
  def recommend_team(base_pokemon_id)    
    unless defined?(TeamRecommendationService)
      require_relative '../services/team_recommendation_service'
    end
    
    recommendation_service = TeamRecommendationService.new(@api_service)
    recommendation_service.recommend_team(base_pokemon_id)
  end

end