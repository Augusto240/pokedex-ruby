require 'spec_helper'

describe PokeApiService do
  let(:service) { PokeApiService.new }
  
  describe '#fetch_pokemons' do
    context 'when API is available' do
      before do
        # Mock da resposta HTTP para simular a API
        stub_request(:get, "https://pokeapi.co/api/v2/pokemon?limit=24&offset=0")
          .to_return(
            status: 200,
            body: {
              count: 1126,
              next: "https://pokeapi.co/api/v2/pokemon?offset=24&limit=24",
              previous: nil,
              results: [
                {
                  name: "bulbasaur",
                  url: "https://pokeapi.co/api/v2/pokemon/1/"
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
      
      it 'returns pokemon data' do
        result = service.fetch_pokemons
        expect(result).to be_a(Hash)
        expect(result['results']).to be_an(Array)
        expect(result['results'].first['name']).to eq('bulbasaur')
      end
      
      it 'supports pagination' do
        # Mock para página 2
        stub_request(:get, "https://pokeapi.co/api/v2/pokemon?limit=24&offset=24")
          .to_return(
            status: 200,
            body: {
              count: 1126,
              next: "https://pokeapi.co/api/v2/pokemon?offset=48&limit=24",
              previous: "https://pokeapi.co/api/v2/pokemon?offset=0&limit=24",
              results: [
                {
                  name: "charmander",
                  url: "https://pokeapi.co/api/v2/pokemon/4/"
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          
        result = service.fetch_pokemons(page: 2)
        expect(result['results'].first['name']).to eq('charmander')
      end
    end
    
    context 'when API is unavailable' do
      before do
        stub_request(:get, "https://pokeapi.co/api/v2/pokemon?limit=24&offset=0")
          .to_timeout
      end
      
      it 'returns fallback data' do
        result = service.fetch_pokemons
        expect(result).to be_a(Hash)
        expect(result['results']).to be_an(Array)
        expect(result['results'].length).to be > 0
      end
    end
  end
  
  describe '#find_pokemon' do
    context 'when API is available' do
      before do
        # Mock para busca por ID
        stub_request(:get, "https://pokeapi.co/api/v2/pokemon/25")
          .to_return(
            status: 200,
            body: {
              id: 25,
              name: "pikachu",
              height: 4,
              weight: 60,
              sprites: {
                front_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
                other: {
                  'official-artwork': {
                    front_default: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png"
                  }
                }
              },
              types: [
                {
                  slot: 1,
                  type: {
                    name: "electric",
                    url: "https://pokeapi.co/api/v2/type/13/"
                  }
                }
              ],
              stats: [
                {
                  base_stat: 35,
                  effort: 0,
                  stat: {
                    name: "hp",
                    url: "https://pokeapi.co/api/v2/stat/1/"
                  }
                }
              ],
              species: {
                url: "https://pokeapi.co/api/v2/pokemon-species/25/"
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          
        # Mock para a species
        stub_request(:get, "https://pokeapi.co/api/v2/pokemon-species/25/")
          .to_return(
            status: 200,
            body: {
              flavor_text_entries: [
                {
                  flavor_text: "When several of\nthese POKéMON\ngather, their\felectricity could\nbuild and cause\nlightning storms.",
                  language: {
                    name: "en",
                    url: "https://pokeapi.co/api/v2/language/9/"
                  },
                  version: {
                    name: "red",
                    url: "https://pokeapi.co/api/v2/version/1/"
                  }
                }
              ],
              evolution_chain: {
                url: "https://pokeapi.co/api/v2/evolution-chain/10/"
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
          
        # Mock para a evolution chain
        stub_request(:get, "https://pokeapi.co/api/v2/evolution-chain/10/")
          .to_return(
            status: 200,
            body: {
              chain: {
                species: {
                  name: "pichu",
                  url: "https://pokeapi.co/api/v2/pokemon-species/172/"
                },
                evolves_to: [
                  {
                    species: {
                      name: "pikachu",
                      url: "https://pokeapi.co/api/v2/pokemon-species/25/"
                    },
                    evolves_to: [
                      {
                        species: {
                          name: "raichu",
                          url: "https://pokeapi.co/api/v2/pokemon-species/26/"
                        },
                        evolves_to: []
                      }
                    ]
                  }
                ]
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
      
      it 'returns detailed pokemon data by id' do
        result = service.find_pokemon(25)
        expect(result).to be_a(Hash)
        expect(result['id']).to eq(25)
        expect(result['name']).to eq('pikachu')
        expect(result['types'].first['type']['name']).to eq('electric')
      end
      
      it 'includes a description' do
        result = service.find_pokemon(25)
        expect(result['description']).to include('electricity')
      end
      
      it 'includes evolution chain data' do
        result = service.find_pokemon(25)
        expect(result['evolution_chain']).to be_an(Array)
        expect(result['evolution_chain'].map { |e| e['name'] }).to eq(['pichu', 'pikachu', 'raichu'])
      end
    end
    
    context 'when API is unavailable' do
      before do
        stub_request(:get, "https://pokeapi.co/api/v2/pokemon/25")
          .to_timeout
      end
      
      it 'returns fallback data' do
        Pokemon.create(pokemon_id: 25, name: 'pikachu')
        result = service.find_pokemon(25)
        expect(result).to be_a(Hash)
        expect(result['id']).to eq(25)
        expect(result['name']).to eq('pikachu')
      end
    end
  end
  
  describe '#search_pokemons' do
    context 'when API is available' do
      before do
        stub_request(:get, "https://pokeapi.co/api/v2/pokemon?limit=1000")
          .to_return(
            status: 200,
            body: {
              count: 1126,
              next: nil,
              previous: nil,
              results: [
                {
                  name: "bulbasaur",
                  url: "https://pokeapi.co/api/v2/pokemon/1/"
                },
                {
                  name: "ivysaur",
                  url: "https://pokeapi.co/api/v2/pokemon/2/"
                },
                {
                  name: "venusaur",
                  url: "https://pokeapi.co/api/v2/pokemon/3/"
                },
                {
                  name: "charmander",
                  url: "https://pokeapi.co/api/v2/pokemon/4/"
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
      
      it 'returns matching pokemon' do
        result = service.search_pokemons('char')
        expect(result).to be_an(Array)
        expect(result.length).to eq(1)
        expect(result.first['name']).to eq('charmander')
      end
      
      it 'respects the limit parameter' do
        result = service.search_pokemons('', limit: 2)
        expect(result.length).to eq(2)
      end
    end
  end
end