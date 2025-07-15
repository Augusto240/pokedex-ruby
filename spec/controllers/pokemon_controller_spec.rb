require 'spec_helper'

describe TeamController do
  let(:api_service) { instance_double(PokeApiService) }
  let(:controller) { TeamController.new(api_service) }
  
  describe '#create_team' do
    it 'creates a new team with the given name' do
      expect {
        controller.create_team('Test Team')
      }.to change { Team.count }.by(1)
      
      expect(Team.last.name).to eq('Test Team')
    end
  end
  
  describe '#list_teams' do
    before do
      Team.create(name: 'Team 1')
      Team.create(name: 'Team 2')
    end
    
    it 'returns all teams ordered by creation date' do
      teams = controller.list_teams
      expect(teams.count).to eq(2)
      expect(teams.first.name).to eq('Team 2')
      expect(teams.last.name).to eq('Team 1')
    end
  end
  
  describe '#add_pokemon_to_team' do
    let(:team) { Team.create(name: 'Test Team') }
    let(:pokemon_data) {
      {
        'id' => 25,
        'name' => 'pikachu'
      }
    }
    
    before do
      allow(api_service).to receive(:find_pokemon).with('25').and_return(pokemon_data)
    end
    
    it 'adds a pokemon to the team' do
      expect {
        controller.add_pokemon_to_team(team.id, '25')
      }.to change { team.reload.team_pokemons.count }.by(1)
      
      expect(team.team_pokemons.first.pokemon_id).to eq(25)
      expect(team.team_pokemons.first.pokemon_name).to eq('pikachu')
    end
    
    it 'returns false if the team does not exist' do
      result = controller.add_pokemon_to_team(999, '25')
      expect(result).to be_falsey
    end
    
    it 'returns false if the pokemon does not exist' do
      allow(api_service).to receive(:find_pokemon).with('999').and_return(nil)
      result = controller.add_pokemon_to_team(team.id, '999')
      expect(result).to be_falsey
    end
    
    it 'respects the position parameter' do
      controller.add_pokemon_to_team(team.id, '25', nil, 3)
      expect(team.reload.team_pokemons.first.position).to eq(3)
    end
    
    it 'supports nicknames' do
      controller.add_pokemon_to_team(team.id, '25', 'Sparky')
      expect(team.reload.team_pokemons.first.nickname).to eq('Sparky')
    end
  end
  
  describe '#remove_pokemon_from_team' do
    let(:team) { Team.create(name: 'Test Team') }
    
    before do
      allow(api_service).to receive(:find_pokemon).with('25').and_return({
        'id' => 25,
        'name' => 'pikachu'
      })
      controller.add_pokemon_to_team(team.id, '25', nil, 1)
    end
    
    it 'removes a pokemon from the team' do
      expect {
        controller.remove_pokemon_from_team(team.id, 1)
      }.to change { team.reload.team_pokemons.count }.by(-1)
    end
    
    it 'returns false if the team does not exist' do
      result = controller.remove_pokemon_from_team(999, 1)
      expect(result).to be_falsey
    end
    
    it 'returns false if the position does not exist' do
      result = controller.remove_pokemon_from_team(team.id, 999)
      expect(result).to be_falsey
    end
  end
  
  describe '#get_team_with_pokemon_details' do
    let(:team) { Team.create(name: 'Test Team') }
    let(:pikachu_data) {
      {
        'id' => 25,
        'name' => 'pikachu',
        'sprites' => {
          'other' => {
            'official-artwork' => {
              'front_default' => 'https://example.com/pikachu.png'
            }
          }
        },
        'types' => [
          {'type' => {'name' => 'electric'}}
        ]
      }
    }
    
    before do
      allow(api_service).to receive(:find_pokemon).with(25).and_return(pikachu_data)
      team.add_pokemon(25, 'pikachu', 'Sparky', 1)
    end
    
    it 'returns team data with pokemon details' do
      result = controller.get_team_with_pokemon_details(team.id)
      expect(result[:id]).to eq(team.id)
      expect(result[:name]).to eq('Test Team')
      expect(result[:pokemons]).to be_an(Array)
      expect(result[:pokemons].first[:id]).to eq(25)
      expect(result[:pokemons].first[:name]).to eq('pikachu')
      expect(result[:pokemons].first[:nickname]).to eq('Sparky')
      expect(result[:pokemons].first[:position]).to eq(1)
      expect(result[:pokemons].first[:image]).to eq('https://example.com/pikachu.png')
      expect(result[:pokemons].first[:types]).to eq([{'type' => {'name' => 'electric'}}])
    end
    
    it 'returns nil if the team does not exist' do
      result = controller.get_team_with_pokemon_details(999)
      expect(result).to be_nil
    end
  end
end