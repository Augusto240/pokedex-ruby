require 'httparty'
require 'yaml'

class WeatherService
  def initialize
    @api_service = PokeApiService.new
    load_api_key
  end
  
  def get_pokemon_for_weather(lat, lon)
    weather = get_current_weather(lat, lon)
    return fallback_pokemon unless weather

    pokemon_type = weather_to_pokemon_type(weather['weather'][0]['main'], weather['main']['temp'])

    pokemon = get_random_pokemon_of_type(pokemon_type)
    pokemon['weather_data'] = weather
    pokemon['weather_type'] = pokemon_type
    
    pokemon
  end
  
  def get_weather_description(condition = nil, temperature = nil)
    if condition.nil? || temperature.nil?
      return "O clima está bom para sair e encontrar Pokémon!"
    end
    
    weather_to_description(condition, temperature)
  end
  
  private
  
  def load_api_key
    # Método 1: Carregar da variável de ambiente (mais seguro para produção)
    @api_key = ENV['WEATHER_API_KEY']
    
    # Método 2: Carregar de um arquivo de configuração local (para desenvolvimento)
    if @api_key.nil? || @api_key.empty?
      begin
        config = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'config', 'secrets.yml'))
        @api_key = config['weather_api_key']
      rescue => e
        puts "Aviso: Não foi possível carregar a chave da API do arquivo de configuração: #{e.message}"
        @api_key = nil
      end
    end
    
    # Fallback para modo offline se nenhuma chave estiver disponível
    @api_key ||= nil
  end
  
  def get_current_weather(lat, lon)
    # Se não tiver API key, usar modo offline
    return simulate_weather unless @api_key
    
    url = "https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&appid=#{@api_key}&units=metric"
    
    begin
      response = HTTParty.get(url)
      if response.success?
        return response.parsed_response
      else
        puts "Erro ao obter dados meteorológicos: #{response.code} - #{response.message}"
        return simulate_weather
      end
    rescue => e
      puts "Exceção ao chamar API de clima: #{e.message}"
      return simulate_weather
    end
  end
  
  # Simula dados meteorológicos quando offline ou sem API key
  def simulate_weather
    today = Date.today.yday # Dia do ano (1-366)
    
    # Determinar tipo com base no dia do ano
    type = case today % 18
           when 0 then 'normal'
           when 1 then 'fire'
           when 2 then 'water'
           when 3 then 'electric'
           when 4 then 'grass'
           when 5 then 'ice'
           when 6 then 'fighting'
           when 7 then 'poison'
           when 8 then 'ground'
           when 9 then 'flying'
           when 10 then 'psychic'
           when 11 then 'bug'
           when 12 then 'rock'
           when 13 then 'ghost'
           when 14 then 'dragon'
           when 15 then 'dark'
           when 16 then 'steel'
           else 'fairy'
           end
    
    weather_condition = get_weather_condition_for_type(type)
    temperature = get_temperature_for_type(type)
    
    {
      'weather' => [{'main' => weather_condition}],
      'main' => {'temp' => temperature}
    }
  end
  
  def weather_to_pokemon_type(condition, temperature)
    case condition.downcase
    when 'thunderstorm'
      'electric'
    when 'drizzle', 'rain'
      'water'
    when 'snow'
      'ice'
    when 'mist', 'smoke', 'haze', 'dust', 'fog'
      'ghost'
    when 'sand'
      'ground'
    when 'ash'
      'fire'
    when 'squall', 'tornado'
      'flying'
    when 'clear'
      if temperature > 30
        'fire'
      elsif temperature < 0
        'ice'
      else
        'normal'
      end
    when 'clouds'
      if temperature < 5
        'ice'
      else
        'flying'
      end
    else
      ['normal', 'grass', 'bug'].sample
    end
  end
  
  def get_random_pokemon_of_type(type)
    # Pokémon representativos por tipo
    type_representatives = {
      'normal' => [143, 16, 133, 161], # Snorlax, Pidgey, Eevee, Sentret
      'fire' => [6, 37, 58, 136],      # Charizard, Vulpix, Growlithe, Flareon
      'water' => [9, 120, 129, 134],   # Blastoise, Staryu, Magikarp, Vaporeon
      'electric' => [25, 100, 125, 135], # Pikachu, Voltorb, Electabuzz, Jolteon
      'grass' => [3, 69, 114, 470],    # Venusaur, Bellsprout, Tangela, Leafeon
      'ice' => [144, 131, 124, 471],   # Articuno, Lapras, Jynx, Glaceon
      'fighting' => [68, 107, 106, 448], # Machamp, Hitmonchan, Hitmonlee, Lucario
      'poison' => [49, 109, 89, 169],  # Venomoth, Koffing, Muk, Crobat
      'ground' => [28, 104, 111, 27],  # Sandslash, Cubone, Rhyhorn, Sandshrew
      'flying' => [149, 18, 22, 169],  # Dragonite, Pidgeot, Fearow, Crobat
      'psychic' => [65, 96, 151, 196], # Alakazam, Drowzee, Mew, Espeon
      'bug' => [12, 15, 127, 214],     # Butterfree, Beedrill, Pinsir, Heracross
      'rock' => [76, 142, 141, 248],   # Golem, Aerodactyl, Kabutops, Tyranitar
      'ghost' => [94, 93, 200, 442],   # Gengar, Haunter, Misdreavus, Spiritomb
      'dragon' => [149, 148, 230, 373], # Dragonite, Dragonair, Kingdra, Salamence
      'dark' => [248, 197, 198, 197],  # Tyranitar, Umbreon, Murkrow, Umbreon
      'steel' => [208, 81, 379, 437],  # Steelix, Magnemite, Registeel, Bronzong
      'fairy' => [36, 35, 176, 700]    # Clefable, Clefairy, Togetic, Sylveon
    }
    
    pokemon_ids = type_representatives[type] || [25] # Pikachu como fallback
    random_id = pokemon_ids.sample
    
    @api_service.find_pokemon(random_id)
  end
  
  def fallback_pokemon
    get_random_pokemon_of_type('normal')
  end
  
  def get_weather_condition_for_type(type)
    case type
    when 'fire'
      'Clear'
    when 'water'
      'Rain'
    when 'electric'
      'Thunderstorm'
    when 'grass'
      'Clear'
    when 'ice'
      'Snow'
    when 'ground'
      'Sand'
    when 'flying'
      'Clouds'
    when 'ghost'
      'Mist'
    else
      ['Clear', 'Clouds', 'Drizzle'].sample
    end
  end
  
  def get_temperature_for_type(type)
    case type
    when 'fire'
      rand(30..40)
    when 'ice'
      rand(-10..0)
    when 'water'
      rand(15..25)
    else
      rand(10..30)
    end
  end
  
  def weather_to_description(condition, temperature)
    case condition.to_s.downcase
    when 'thunderstorm'
      "Uma tempestade está caindo! É um ótimo momento para encontrar Pokémon do tipo Elétrico!"
    when 'drizzle', 'rain'
      "Está chovendo! Os Pokémon do tipo Água adoram este clima!"
    when 'snow'
      "Está nevando! Os Pokémon do tipo Gelo aparecem com mais frequência neste tempo!"
    when 'clear'
      if temperature > 30
        "Está muito quente! Os Pokémon do tipo Fogo estão mais ativos agora!"
      elsif temperature < 0
        "Está muito frio! Os Pokémon do tipo Gelo estão aproveitando o clima gelado!"
      else
        "O clima está perfeito! Pokémon do tipo Normal podem ser vistos por toda parte!"
      end
    when 'clouds'
      "O céu está nublado! Os Pokémon do tipo Voador aproveitam para planar nas correntes de ar!"
    when 'mist', 'smoke', 'haze', 'dust', 'fog'
      "A visibilidade está baixa! Os Pokémon do tipo Fantasma adoram se esconder na névoa!"
    when 'sand'
      "Há uma tempestade de areia! Os Pokémon do tipo Terra estão em seu elemento!"
    when 'ash'
      "Cinzas vulcânicas no ar! Os Pokémon do tipo Fogo são atraídos por este fenômeno!"
    when 'squall', 'tornado'
      "Ventos fortes estão soprando! Os Pokémon do tipo Voador aproveitam as rajadas!"
    else
      "O clima está normal. Vários tipos de Pokémon podem ser encontrados!"
    end
  end
end