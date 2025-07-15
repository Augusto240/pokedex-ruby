class PokemonController
  def initialize(api_service)
    @api_service = api_service
  end
  
  def list(page: 1, per_page: 24)
    result = @api_service.fetch_pokemons(page: page, per_page: per_page)
    return nil unless result

    result['results'].each do |pokemon|
      id = pokemon['url'].split('/')[-1].to_i
      db_pokemon = Pokemon.find_by(pokemon_id: id)
      pokemon['favorite'] = db_pokemon&.favorite || false
    end
    
    result
  end
  
  def find(id_or_name)
    pokemon = @api_service.find_pokemon(id_or_name)
    return nil unless pokemon

    db_pokemon = Pokemon.find_by(pokemon_id: pokemon['id'])
    pokemon['favorite'] = db_pokemon&.favorite || false
    
    pokemon
  end
  
  def toggle_favorite(id)
    pokemon = @api_service.find_pokemon(id)
    return false unless pokemon
    
    db_pokemon = Pokemon.find_or_initialize_by(pokemon_id: pokemon['id'])
    if db_pokemon.new_record?
      db_pokemon.name = pokemon['name']
    end
    
    db_pokemon.favorite = !db_pokemon.favorite
    db_pokemon.save
  end

  def get_pokemon_types(id)
    pokemon = @api_service.find_pokemon(id)
    return [] unless pokemon
  
    pokemon['types'].map { |t| t['type']['name'] }
  end
end