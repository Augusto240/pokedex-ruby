require_relative '../spec_helper'

describe PokemonController do
  let(:api_service) { instance_double(PokeApiService) }
  let(:controller) { PokemonController.new(api_service) }
  
  describe '#list' do
    let(:api_response) do
      {
        'count' => 1126,
        'results' => [
          {
            'name' => 'bulbasaur',
            'url' => 'https://pokeapi.co/api/v2/pokemon/1/'
          }
        ]
      }
    end
    
    before do
      allow(api_service).to receive(:fetch_pokemons).and_return(api_response)
    end
    
    it "enriches pokemon data with favorite status" do
      Pokemon.create(pokemon_id: 1, name: 'bulbasaur', favorite: true)
      
      result = controller.list
      
      expect(result['results'].first['favorite']).to eq(true)
    end
  end
  
  describe '#toggle_favorite' do
    let(:pokemon_data) do
      {
        'id' => 25,
        'name' => 'pikachu'
      }
    end
    
    before do
      allow(api_service).to receive(:find_pokemon).and_return(pokemon_data)
    end
    
    context "when pokemon is not favorited" do
      it "adds the pokemon to favorites" do
        expect {
          controller.toggle_favorite(25)
        }.to change { Pokemon.where(pokemon_id: 25, favorite: true).count }.from(0).to(1)
      end
    end
    
    context "when pokemon is already favorited" do
      before do
        Pokemon.create(pokemon_id: 25, name: 'pikachu', favorite: true)
      end
      
      it "removes the pokemon from favorites" do
        expect {
          controller.toggle_favorite(25)
        }.to change { Pokemon.where(pokemon_id: 25, favorite: true).count }.from(1).to(0)
      end
    end
  end
end