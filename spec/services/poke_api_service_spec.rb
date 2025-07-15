require 'httparty'

class PokeApiService
  BASE_URL = "https://pokeapi.co/api/v2"

  def fetch_pokemons(page: 1, per_page: 24)
    offset = (page - 1) * per_page
    response = HTTParty.get("#{BASE_URL}/pokemon?limit=#{per_page}&offset=#{offset}")
    return nil unless response.success?
    response.parsed_response
  end

  def find_pokemon(id_or_name)
    main_response = HTTParty.get("#{BASE_URL}/pokemon/#{id_or_name.to_s.downcase}")
    return nil unless main_response.success?
    
    pokemon_data = main_response.parsed_response
    
    species_response = HTTParty.get(pokemon_data['species']['url'])
    if species_response.success?      
      flavor_text_entry = species_response.parsed_response['flavor_text_entries'].find do |entry|
        entry['language']['name'] == 'en'
      end      
      pokemon_data['description'] = flavor_text_entry ? flavor_text_entry['flavor_text'].gsub("\n", " ").gsub("\f", " ") : "No description available."
  
      if species_response.parsed_response['evolution_chain']
        evolution_chain_url = species_response.parsed_response['evolution_chain']['url']
        pokemon_data['evolution_chain'] = get_evolution_chain(evolution_chain_url)
      end
    end
    
    pokemon_data
  end

  def search_pokemons(query, limit: 10)
    response = HTTParty.get("#{BASE_URL}/pokemon?limit=1000")
    return [] unless response.success?

    matches = response.parsed_response['results'].select do |pokemon|
      pokemon['name'].start_with?(query)
    end

    matches = matches.take(limit)

    matches.map do |pokemon|
      id = pokemon['url'].split('/')[-1]
      pokemon.merge('id' => id)
    end
  end
  
  private
  
  def get_evolution_chain(url)
    response = HTTParty.get(url)
    return [] unless response.success?
    
    chain_data = response.parsed_response['chain']
    evolution_chain = []

    process_evolution_chain(chain_data, evolution_chain)
  
    return evolution_chain 
  end

  def process_evolution_chain(chain_data, evolution_chain)
    return unless chain_data
    
    species_name = chain_data['species']['name']
    species_url = chain_data['species']['url']
    
    species_id = species_url.split('/')[-2]
    
    evolution_chain << {
      'name' => species_name,
      'id' => species_id,
      'image_url' => "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/#{species_id}.png"
    }
    
    if chain_data['evolves_to']&.any?
      chain_data['evolves_to'].each do |evolution|
        process_evolution_chain(evolution, evolution_chain)
      end
    end
  end
end 