require 'sinatra'
require 'httparty'
require 'rackup'
require 'puma'
require 'json'
require_relative 'services/poke_api_service'
require_relative 'config/database'
require_relative 'models/pokemon'
require_relative 'controllers/pokemon_controller'
require_relative 'controllers/team_controller'
require_relative 'models/team'
require_relative 'models/team_pokemon'
require_relative 'services/weather_service'

set :port, 5000
set :public_folder, File.dirname(__FILE__) + '/public'

before do
  @api_service = PokeApiService.new
  @pokemon_controller = PokemonController.new(@api_service)
  @team_controller = TeamController.new(@api_service)
  @weather_service = WeatherService.new
end

before do
  if request.content_type == 'application/json'
    begin
      request_body = request.body.read
      params.merge!(JSON.parse(request_body)) unless request_body.empty?
    rescue JSON::ParserError
      halt 400, { error: "Invalid JSON" }.to_json
    end
  end
end


get '/' do
  @page = params.fetch('page', 1).to_i
  @per_page = 24

  result = @pokemon_controller.list(page: @page, per_page: @per_page)
  
  if result
    @pokemons = result['results']
    total_pokemons = result['count']
    @total_pages = (total_pokemons.to_f / @per_page).ceil
    erb :index
  else
    "Erro ao carregar Pokémon."
  end
end

get '/pokemon/:name' do
  @pokemon = @pokemon_controller.find(params['name'])
  
  if @pokemon
    current_id = @pokemon['id']
    @prev_pokemon_id = current_id > 1 ? current_id - 1 : nil
    @next_pokemon_id = current_id < 1025 ? current_id + 1 : nil
    erb :pokemon
  else
    status 404 
    erb :not_found
  end
end

get '/pokemon/search' do
  query = params['query'].downcase.strip
  
  pokemon = @api_service.find_pokemon(query)
  
  if pokemon
    redirect "/pokemon/#{query}"
  else
    status 404
    erb :not_found
  end
end

get '/api/search' do
  content_type :json
  query = params['query'].downcase.strip
  
  return { results: [] }.to_json if query.empty?
  
  result = @api_service.search_pokemons(query, limit: 10)
  
  { results: result }.to_json
end

post '/api/pokemon/:id/favorite' do
  content_type :json
  id = params['id'].to_i
  
  if @pokemon_controller.toggle_favorite(id)
    {success: true}.to_json
  else
    status 400
    {success: false, error: "Pokémon não encontrado"}.to_json
  end
end

get '/favorites' do
  favorites_data = Pokemon.where(favorite: true).map do |pokemon|
    {
      id: pokemon.pokemon_id,
      name: pokemon.name
    }
  end
  
  @favorites = favorites_data
  erb :favorites
end

get '/api/favorites' do
  content_type :json
  favorites = Pokemon.where(favorite: true).pluck(:pokemon_id, :name)
  favorites_data = favorites.map do |id, name|
    {
      id: id,
      name: name,
      image: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{id}.png"
    }
  end
  
  {pokemons: favorites_data}.to_json
end

get '/teams' do
  @teams = @team_controller.list_teams
  erb :teams
end

get '/teams/new' do
  erb :team_form
end

post '/teams' do
  team = @team_controller.create_team(params[:name])
  if team.persisted?
    redirect "/teams/#{team.id}"
  else
    @error = "Não foi possível criar a equipe"
    erb :team_form
  end
end

get '/teams/:id' do
  @team = @team_controller.get_team_with_pokemon_details(params[:id])
  if @team
    erb :team_detail
  else
    status 404
    erb :not_found
  end
end

get '/teams/:id/edit' do
  @team = @team_controller.find_team(params[:id])
  if @team
    erb :team_form
  else
    status 404
    erb :not_found
  end
end

put '/teams/:id' do
  if @team_controller.update_team(params[:id], params[:name])
    redirect "/teams/#{params[:id]}"
  else
    status 404
    erb :not_found
  end
end

delete '/teams/:id' do
  if @team_controller.delete_team(params[:id])
    redirect "/teams"
  else
    status 404
    erb :not_found
  end
end

post '/api/teams/:team_id/pokemon' do
  content_type :json
  result = @team_controller.add_pokemon_to_team(
    params[:team_id], 
    params[:pokemon_id], 
    params[:nickname],
    params[:position]&.to_i
  )
  
  if result
    { success: true }.to_json
  else
    status 400
    { success: false, error: "Não foi possível adicionar o Pokémon à equipe" }.to_json
  end
end

delete '/api/teams/:team_id/pokemon/:position' do
  content_type :json
  if @team_controller.remove_pokemon_from_team(params[:team_id], params[:position].to_i)
    { success: true }.to_json
  else
    status 400
    { success: false, error: "Não foi possível remover o Pokémon da equipe" }.to_json
  end
end

get '/compare' do
  if params['p1'] && params['p2']
    @pokemon1 = @api_service.find_pokemon(params['p1'])
    @pokemon2 = @api_service.find_pokemon(params['p2'])
    
    if @pokemon1 && @pokemon2
      erb :compare
    else
      status 404
      erb :not_found
    end
  else
    redirect '/'
  end
end

get '/recommend-team/:pokemon' do
  @base_pokemon = @pokemon_controller.find(params[:pokemon])
  
  if @base_pokemon
    @recommended_team = @team_controller.recommend_team(@base_pokemon['id'])
    erb :team_recommendation
  else
    status 404
    erb :not_found
  end
end

get '/game/who-is-that-pokemon' do
  random_id = rand(1..151)
  @pokemon = @pokemon_controller.find(random_id)
  
  @options = [@pokemon]
  
  while @options.length < 4
    option_id = rand(1..151)
    next if option_id == random_id
    
    option_pokemon = @pokemon_controller.find(option_id)
    @options << option_pokemon if option_pokemon && !@options.any? { |p| p['id'] == option_pokemon['id'] }
  end
  
  @options.shuffle!
  
  erb :who_is_that_pokemon
end

get '/api/weather-pokemon' do
  content_type :json
  
  lat = params[:lat] || 0
  lon = params[:lon] || 0
  
  pokemon = @weather_service.get_pokemon_for_weather(lat.to_f, lon.to_f)
  
  if pokemon
    weather_data = pokemon['weather_data'] || {'weather' => [{'main' => 'Clear'}], 'main' => {'temp' => 20}}
    condition = weather_data['weather'][0]['main']
    temperature = weather_data['main']['temp']
    
    {
      success: true,
      pokemon: {
        id: pokemon['id'],
        name: pokemon['name'],
        image: pokemon['sprites']['other']['official-artwork']['front_default'],
        types: pokemon['types'].map { |t| t['type']['name'] }
      },
      weather_description: @weather_service.get_weather_description(condition, temperature),
      weather_type: pokemon['weather_type'] || 'normal'
    }.to_json
  else
    status 500
    { error: "Não foi possível obter um Pokémon para o clima atual" }.to_json
  end
end