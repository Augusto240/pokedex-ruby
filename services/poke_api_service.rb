require 'httparty'
require 'json'
require 'fileutils'

class PokeApiService
  BASE_URL = "https://pokeapi.co/api/v2"
  CACHE_DIR = File.join(File.dirname(__FILE__), '../cache')

  def initialize
    # Cria o diretório de cache se não existir
    FileUtils.mkdir_p(CACHE_DIR) unless File.directory?(CACHE_DIR)
  end

  def fetch_pokemons(page: 1, per_page: 24)
    offset = (page - 1) * per_page
    endpoint = "pokemon?limit=#{per_page}&offset=#{offset}"
    
    # Tenta obter do cache primeiro
    cached = get_from_cache(endpoint)
    return cached if cached
    
    # Se não estiver em cache, tenta da API
    begin
      response = HTTParty.get("#{BASE_URL}/#{endpoint}")
      if response.success?
        # Salva no cache e retorna
        save_to_cache(endpoint, response.parsed_response)
        return response.parsed_response
      end
    rescue => e
      puts "Erro ao acessar a API: #{e.message}"
      # Se falhar, tenta usar os dados de fallback
      return get_fallback_data(page, per_page)
    end
    
    nil
  end

  def find_pokemon(id_or_name)
    endpoint = "pokemon/#{id_or_name.to_s.downcase}"
    
    # Tenta obter do cache primeiro
    cached = get_from_cache(endpoint)
    return cached if cached
    
    # Se não estiver em cache, tenta da API
    begin
      main_response = HTTParty.get("#{BASE_URL}/#{endpoint}")
      if main_response.success?
        pokemon_data = main_response.parsed_response
        
        # Busca dados adicionais (espécie)
        species_endpoint = pokemon_data['species']['url'].gsub(BASE_URL, '')
        species_cached = get_from_cache(species_endpoint)
        
        if species_cached
          species_response = species_cached
        else
          begin
            species_response = HTTParty.get(pokemon_data['species']['url']).parsed_response
            save_to_cache(species_endpoint, species_response)
          rescue => e
            puts "Erro ao acessar dados da espécie: #{e.message}"
            species_response = {}
          end
        end
        
        # Adiciona descrição
        if species_response && species_response['flavor_text_entries']
          flavor_text_entry = species_response['flavor_text_entries'].find do |entry|
            entry['language']['name'] == 'en'
          end
          
          pokemon_data['description'] = flavor_text_entry ? 
            flavor_text_entry['flavor_text'].gsub("\n", " ").gsub("\f", " ") : 
            "No description available."
        else
          pokemon_data['description'] = "Description not available in offline mode."
        end
        
        # Adiciona cadeia evolutiva
        if species_response && species_response['evolution_chain']
          evolution_chain_url = species_response['evolution_chain']['url']
          pokemon_data['evolution_chain'] = get_evolution_chain(evolution_chain_url)
        else
          pokemon_data['evolution_chain'] = []
        end
        
        # Salva no cache e retorna
        save_to_cache(endpoint, pokemon_data)
        return pokemon_data
      end
    rescue => e
      puts "Erro ao acessar a API: #{e.message}"
      # Se falhar, tenta usar os dados de fallback
      return get_fallback_pokemon(id_or_name)
    end
    
    nil
  end

  def search_pokemons(query, limit: 10)
    # Em caso de problemas de rede, buscar no banco de dados
    begin
      response = HTTParty.get("#{BASE_URL}/pokemon?limit=1000")
      if response.success?
        matches = response.parsed_response['results'].select do |pokemon|
          pokemon['name'].start_with?(query)
        end
        
        matches = matches.take(limit)
        
        matches.map do |pokemon|
          id = pokemon['url'].split('/')[-1]
          pokemon.merge('id' => id)
        end
      else
        # Fallback para busca local
        search_local_pokemon(query, limit)
      end
    rescue => e
      puts "Erro na busca: #{e.message}"
      # Fallback para busca local
      search_local_pokemon(query, limit)
    end
  end
  
  private
  
  def get_evolution_chain(url)
    evolution_endpoint = url.gsub(BASE_URL, '')
    
    # Tenta obter do cache primeiro
    cached = get_from_cache(evolution_endpoint)
    if cached
      chain_data = cached['chain']
    else
      begin
        response = HTTParty.get(url)
        if response.success?
          chain_data = response.parsed_response['chain']
          save_to_cache(evolution_endpoint, response.parsed_response)
        else
          return []
        end
      rescue => e
        puts "Erro ao acessar cadeia evolutiva: #{e.message}"
        return []
      end
    end
    
    evolution_chain = []
    process_evolution_chain(chain_data, evolution_chain)
    
    evolution_chain
  end
  
  def process_evolution_chain(chain_data, evolution_chain)
    return unless chain_data
    
    species_name = chain_data['species']['name']
    species_url = chain_data['species']['url']
    
    # Extrair ID corretamente
    species_id = species_url.match(/\/pokemon-species\/(\d+)\//)[1]
    
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
  
  def cache_file_path(endpoint)
    # Remove barra inicial e substitui outras por underscore
    safe_endpoint = endpoint.gsub(/^\//, '').gsub(/[\/\?=&]/, '_')
    File.join(CACHE_DIR, "#{safe_endpoint}.json")
  end
  
  def get_from_cache(endpoint)
    path = cache_file_path(endpoint)
    if File.exist?(path)
      begin
        data = JSON.parse(File.read(path))
        return data
      rescue
        return nil
      end
    end
    nil
  end
  
  def save_to_cache(endpoint, data)
    path = cache_file_path(endpoint)
    File.write(path, JSON.pretty_generate(data))
  end
  
  def get_fallback_data(page, per_page)
    # Dados básicos para o caso de falha total
    # Estes são os 24 primeiros Pokémon (suficiente para a primeira página)
    pokemons = (1..150).map do |i|
      {
        'name' => "pokemon-#{i}",
        'url' => "https://pokeapi.co/api/v2/pokemon/#{i}/"
      }
    end
    
    offset = (page - 1) * per_page
    
    {
      'count' => 1025,
      'next' => (offset + per_page < 1025) ? "https://pokeapi.co/api/v2/pokemon?offset=#{offset + per_page}&limit=#{per_page}" : nil,
      'previous' => (offset > 0) ? "https://pokeapi.co/api/v2/pokemon?offset=#{offset - per_page}&limit=#{per_page}" : nil,
      'results' => pokemons[offset, per_page] || []
    }
  end
  
  def get_fallback_pokemon(id_or_name)
    # Tenta buscar do banco de dados
    pokemon = Pokemon.find_by(pokemon_id: id_or_name) || Pokemon.find_by(name: id_or_name.to_s.downcase)
    
    if pokemon
      # Retorna um hash básico com os dados do Pokémon
      {
        'id' => pokemon.pokemon_id,
        'name' => pokemon.name,
        'height' => 0,
        'weight' => 0,
        'sprites' => {
          'front_default' => "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{pokemon.pokemon_id}.png",
          'other' => {
            'official-artwork' => {
              'front_default' => "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/#{pokemon.pokemon_id}.png"
            }
          }
        },
        'stats' => [
          {'base_stat' => 45, 'stat' => {'name' => 'hp'}},
          {'base_stat' => 45, 'stat' => {'name' => 'attack'}},
          {'base_stat' => 45, 'stat' => {'name' => 'defense'}},
          {'base_stat' => 45, 'stat' => {'name' => 'special-attack'}},
          {'base_stat' => 45, 'stat' => {'name' => 'special-defense'}},
          {'base_stat' => 45, 'stat' => {'name' => 'speed'}}
        ],
        'types' => [
          {'type' => {'name' => 'normal'}}
        ],
        'abilities' => [
          {'ability' => {'name' => 'unknown'}}
        ],
        'species' => {
          'url' => "https://pokeapi.co/api/v2/pokemon-species/#{pokemon.pokemon_id}/"
        },
        'description' => 'Dados não disponíveis no modo offline.',
        'evolution_chain' => [],
        'favorite' => pokemon.favorite
      }
    else
      # Retorna um Pokémon padrão caso não encontre
      {
        'id' => id_or_name.to_i > 0 ? id_or_name.to_i : 0,
        'name' => id_or_name.to_s,
        'height' => 0,
        'weight' => 0,
        'sprites' => {
          'front_default' => "/images/offline-pokemon.png",
          'other' => {
            'official-artwork' => {
              'front_default' => "/images/offline-pokemon.png"
            }
          }
        },
        'stats' => [
          {'base_stat' => 45, 'stat' => {'name' => 'hp'}},
          {'base_stat' => 45, 'stat' => {'name' => 'attack'}},
          {'base_stat' => 45, 'stat' => {'name' => 'defense'}},
          {'base_stat' => 45, 'stat' => {'name' => 'special-attack'}},
          {'base_stat' => 45, 'stat' => {'name' => 'special-defense'}},
          {'base_stat' => 45, 'stat' => {'name' => 'speed'}}
        ],
        'types' => [
          {'type' => {'name' => 'normal'}}
        ],
        'abilities' => [
          {'ability' => {'name' => 'unknown'}}
        ],
        'description' => 'Dados não disponíveis no modo offline.',
        'evolution_chain' => []
      }
    end
  end
  
  def search_local_pokemon(query, limit)
    # Busca no banco de dados
    pokemons = Pokemon.where("name LIKE ?", "#{query}%").limit(limit)
    
    pokemons.map do |pokemon|
      {
        'id' => pokemon.pokemon_id,
        'name' => pokemon.name
      }
    end
  end
end