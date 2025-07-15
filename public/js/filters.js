document.addEventListener('DOMContentLoaded', function() {
  // Elementos do DOM
  const filterToggle = document.getElementById('filter-toggle');
  const filterPanel = document.getElementById('filter-panel');
  const typeFilters = document.querySelectorAll('.type-filter');
  const pokedexGrid = document.querySelector('.pokedex-grid');
  const pokemonCards = document.querySelectorAll('.pokemon-card');
  const resetFiltersBtn = document.getElementById('reset-filters');
  
  // Estado dos filtros
  let activeFilters = {
    types: [],
    favorite: false,
    search: ''
  };
  
  // Funções
  
  // Alternar visibilidade do painel de filtros
  if (filterToggle) {
    filterToggle.addEventListener('click', function() {
      filterPanel.classList.toggle('show');
      this.classList.toggle('active');
    });
  }
  
  // Adicionar evento aos filtros de tipo
  typeFilters.forEach(filter => {
    filter.addEventListener('click', function() {
      const type = this.dataset.type;
      
      // Toggle active class
      this.classList.toggle('active');
      
      // Update filter state
      if (this.classList.contains('active')) {
        if (!activeFilters.types.includes(type)) {
          activeFilters.types.push(type);
        }
      } else {
        activeFilters.types = activeFilters.types.filter(t => t !== type);
      }
      
      applyFilters();
    });
  });
  
  // Filtro de favoritos
  const favoriteFilter = document.getElementById('favorite-filter');
  if (favoriteFilter) {
    favoriteFilter.addEventListener('change', function() {
      activeFilters.favorite = this.checked;
      applyFilters();
    });
  }
  
  // Filtro de busca
  const searchFilter = document.getElementById('search-filter');
  if (searchFilter) {
    let debounceTimeout;
    
    searchFilter.addEventListener('input', function() {
      clearTimeout(debounceTimeout);
      
      debounceTimeout = setTimeout(() => {
        activeFilters.search = this.value.toLowerCase().trim();
        applyFilters();
      }, 300);
    });
  }
  
  // Reset filtros
  if (resetFiltersBtn) {
    resetFiltersBtn.addEventListener('click', function() {
      // Reset UI
      typeFilters.forEach(filter => filter.classList.remove('active'));
      if (favoriteFilter) favoriteFilter.checked = false;
      if (searchFilter) searchFilter.value = '';
      
      // Reset state
      activeFilters = {
        types: [],
        favorite: false,
        search: ''
      };
      
      applyFilters();
    });
  }
  
  // Aplicar filtros
  function applyFilters() {
    let visibleCount = 0;
    
    pokemonCards.forEach(card => {
      let shouldShow = true;
      
      // Verificar filtro de tipo
      if (activeFilters.types.length > 0) {
        const cardTypes = card.dataset.types ? card.dataset.types.split(',') : [];
        const hasMatchingType = activeFilters.types.some(type => cardTypes.includes(type));
        
        if (!hasMatchingType) {
          shouldShow = false;
        }
      }
      
      // Verificar filtro de favoritos
      if (activeFilters.favorite && !card.querySelector('.favorite-btn').classList.contains('favorited')) {
        shouldShow = false;
      }
      
      // Verificar filtro de busca
      if (activeFilters.search) {
        const cardName = card.querySelector('.pokemon-name').textContent.toLowerCase();
        const cardId = card.querySelector('.pokemon-id').textContent;
        
        if (!cardName.includes(activeFilters.search) && !cardId.includes(activeFilters.search)) {
          shouldShow = false;
        }
      }
      
      // Aplicar visibilidade
      if (shouldShow) {
        card.style.display = '';
        visibleCount++;
      } else {
        card.style.display = 'none';
      }
    });
    
    // Mostrar mensagem se não houver resultados
    const noResultsMsg = document.getElementById('no-results-message');
    if (noResultsMsg) {
      if (visibleCount === 0) {
        noResultsMsg.style.display = 'block';
      } else {
        noResultsMsg.style.display = 'none';
      }
    }
  }
});