class TeamRecommendationService
  def initialize(api_service)
    @api_service = api_service
  end
  
  def recommend_team(base_pokemon_id)
    base_pokemon = @api_service.find_pokemon(base_pokemon_id)
    return [] unless base_pokemon

    base_types = base_pokemon['types'].map { |t| t['type']['name'] }
    
    complementary_types = get_complementary_types(base_types)
  
    recommended_pokemon_ids = []

    complementary_types.each do |type|
      pokemon_id = get_pokemon_for_type(type)
      recommended_pokemon_ids << pokemon_id unless recommended_pokemon_ids.include?(pokemon_id)

      break if recommended_pokemon_ids.size >= 5
    end

    while recommended_pokemon_ids.size < 5
      random_type = all_types.sample
      pokemon_id = get_pokemon_for_type(random_type)
      recommended_pokemon_ids << pokemon_id unless recommended_pokemon_ids.include?(pokemon_id)
    end

    recommended_pokemon_ids.map { |id| @api_service.find_pokemon(id) }.compact
  end
  
  private
  
  def get_complementary_types(base_types)
    type_coverage = {
      'normal' => ['fighting', 'rock'],
      'fire' => ['water', 'ground', 'rock'],
      'water' => ['electric', 'grass'],
      'electric' => ['ground'],
      'grass' => ['fire', 'ice', 'poison', 'flying', 'bug'],
      'ice' => ['fire', 'fighting', 'rock', 'steel'],
      'fighting' => ['flying', 'psychic', 'fairy'],
      'poison' => ['ground', 'psychic'],
      'ground' => ['water', 'grass', 'ice'],
      'flying' => ['electric', 'ice', 'rock'],
      'psychic' => ['bug', 'ghost', 'dark'],
      'bug' => ['fire', 'flying', 'rock'],
      'rock' => ['water', 'grass', 'fighting', 'ground', 'steel'],
      'ghost' => ['ghost', 'dark'],
      'dragon' => ['ice', 'dragon', 'fairy'],
      'dark' => ['fighting', 'bug', 'fairy'],
      'steel' => ['fire', 'fighting', 'ground'],
      'fairy' => ['poison', 'steel']
    }

    weaknesses = base_types.flat_map { |type| type_coverage[type] || [] }.uniq

    complementary = []
    weaknesses.each do |weakness|
      counters = type_coverage.select { |_, weak_against| weak_against.include?(weakness) }.keys
      complementary.concat(counters)
    end

    defensive_types = ['steel', 'fairy', 'water', 'ghost', 'normal']
    complementary.concat(defensive_types)

    (complementary - base_types).uniq.sample(5)
  end
  
  def get_pokemon_for_type(type)
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
    pokemon_ids.sample
  end
  
  def all_types
    ['normal', 'fire', 'water', 'electric', 'grass', 'ice', 'fighting', 'poison', 
     'ground', 'flying', 'psychic', 'bug', 'rock', 'ghost', 'dragon', 'dark', 
     'steel', 'fairy']
  end
end