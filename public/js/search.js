document.addEventListener('DOMContentLoaded', function() {
  const searchInput = document.querySelector('.search-form input');
  const searchResults = document.createElement('div');
  searchResults.className = 'search-results';
  
  searchInput.parentNode.insertBefore(searchResults, searchInput.nextSibling);
   
  searchResults.style.display = 'none';
  
  let debounceTimeout;
  
  searchInput.addEventListener('input', function() {
    const query = this.value.trim();
      
    clearTimeout(debounceTimeout);
    
    if (!query) {
      searchResults.style.display = 'none';
      return;
    }
        
    debounceTimeout = setTimeout(async function() {
      try {
        const response = await fetch(`/api/search?query=${encodeURIComponent(query)}`);
        const data = await response.json();
            
        searchResults.innerHTML = '';
        
        if (data.results.length === 0) {
          searchResults.innerHTML = '<div class="search-no-results">Nenhum Pokémon encontrado</div>';
        } else {
    
          const resultsList = document.createElement('ul');
          
          data.results.forEach(pokemon => {
            const listItem = document.createElement('li');
            const link = document.createElement('a');
            link.href = `/pokemon/${pokemon.name}`;
                
            const thumbnail = document.createElement('img');
            thumbnail.src = `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.id}.png`;
            thumbnail.alt = pokemon.name;
                        
            const nameSpan = document.createElement('span');
            nameSpan.textContent = `#${pokemon.id} - ${pokemon.name.charAt(0).toUpperCase() + pokemon.name.slice(1)}`;
                        
            link.appendChild(thumbnail);
            link.appendChild(nameSpan);
                        
            listItem.appendChild(link);
                        
            resultsList.appendChild(listItem);
          });
                    
          searchResults.appendChild(resultsList);
        }
                
        searchResults.style.display = 'block';
        
      } catch (error) {
        console.error('Erro na busca:', error);
      }
    }, 300); 
  });
  
  document.addEventListener('click', function(e) {
    if (!searchResults.contains(e.target) && e.target !== searchInput) {
      searchResults.style.display = 'none';
    }
  });
  
  document.querySelector('.search-form').addEventListener('submit', function(e) {
    const query = searchInput.value.trim();
    if (!query) {
      e.preventDefault();
      return;
    }
      
    const results = searchResults.querySelectorAll('li');
    if (results.length === 1) {
      window.location.href = results[0].querySelector('a').href;
      e.preventDefault();
    }
  });
});