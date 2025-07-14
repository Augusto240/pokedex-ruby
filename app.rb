require 'sinatra'
require 'httparty'
require 'rackup'
require 'puma'
require_relative 'services/poke_api_service.rb'

set :port, 5000

before do
  @poke_api = PokeApiService.new
end

get '/' do
  @page = params.fetch('page', 1).to_i
  @per_page = 24

  result = @poke_api.fetch_pokemons(page: @page, per_page: @per_page)
  
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
  @pokemon = @poke_api.find_pokemon(params['name'])
  
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
  redirect "/pokemon/#{query}"
end