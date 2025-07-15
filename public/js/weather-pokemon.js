document.addEventListener('DOMContentLoaded', function() {
  const weatherPokemonContainer = document.getElementById('weather-pokemon-container');
  
  if (weatherPokemonContainer) {
    if (navigator.geolocation) {
      weatherPokemonContainer.innerHTML = `
        <div class="weather-loader">
          <i class="fas fa-spinner fa-spin"></i>
          <p>Buscando Pokémon com base no seu clima local...</p>
        </div>
      `;
      
      navigator.geolocation.getCurrentPosition(
        // Sucesso
        function(position) {
          fetchWeatherPokemon(position.coords.latitude, position.coords.longitude);
        },
        function(error) {
          console.error("Erro ao obter localização:", error);
          weatherPokemonContainer.innerHTML = `
            <div class="weather-error">
              <i class="fas fa-exclamation-circle"></i>
              <p>Não foi possível obter sua localização. Por favor, permita o acesso à localização para ver o Pokémon do clima.</p>
            </div>
          `;
        }
      );
    } else {
      weatherPokemonContainer.innerHTML = `
        <div class="weather-error">
          <i class="fas fa-exclamation-circle"></i>
          <p>Seu navegador não suporta geolocalização.</p>
        </div>
      `;
    }
  }
  
  async function fetchWeatherPokemon(lat, lon) {
    try {
      const response = await fetch(`/api/weather-pokemon?lat=${lat}&lon=${lon}`);
      const data = await response.json();
      
      if (data.success) {
        const pokemon = data.pokemon;
        
        weatherPokemonContainer.innerHTML = `
          <div class="weather-pokemon-card">
            <h3>Pokémon do Clima</h3>
            <p class="weather-description">${data.weather_description}</p>
            <div class="weather-pokemon">
              <img src="${pokemon.image}" alt="${pokemon.name}">
              <div class="weather-pokemon-info">
                <h4>${pokemon.name.charAt(0).toUpperCase() + pokemon.name.slice(1)}</h4>
                <div class="weather-pokemon-types">
                
                  ${pokemon.types.map(type => `
                    <span class="type-badge ${type}">${type.charAt(0).toUpperCase() + type.slice(1)}</span>
                  `).join('')}
                </div>
                <br><br>
                <a href="/pokemon/${pokemon.id}" class="btn-secondary btn-sm">Ver detalhes</a>
              </div>
            </div>
          </div>
        `;
      } else {
        weatherPokemonContainer.innerHTML = `
          <div class="weather-error">
            <i class="fas fa-exclamation-circle"></i>
            <p>${data.error || 'Erro ao buscar Pokémon do clima'}</p>
          </div>
        `;
      }
    } catch (error) {
      console.error("Erro ao buscar Pokémon do clima:", error);
      weatherPokemonContainer.innerHTML = `
        <div class="weather-error">
          <i class="fas fa-exclamation-circle"></i>
          <p>Erro ao conectar com o servidor. Por favor, tente novamente mais tarde.</p>
        </div>
      `;
    }
  }
});