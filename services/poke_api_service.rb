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
    end
    
    pokemon_data
  end
end