require 'sinatra'
require 'httparty'
require 'rackup'
require 'puma'
require 'json'
require_relative 'services/poke_api_service'
require_relative 'config/database'
require_relative 'models/pokemon'
require_relative 'controllers/pokemon_controller'

set :port, 5000
set :public_folder, File.dirname(__FILE__) + '/public'

before do
  @api_service = PokeApiService.new
  @pokemon_controller = PokemonController.new(@api_service)
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