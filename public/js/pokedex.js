document.addEventListener('DOMContentLoaded', function() {
  const favoriteButtons = document.querySelectorAll('.favorite-btn');
  
  favoriteButtons.forEach(button => {
    button.addEventListener('click', async function(e) {
      e.preventDefault();
      const pokemonId = this.dataset.id;
      
      try {
        const response = await fetch(`/api/pokemon/${pokemonId}/favorite`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          }
        });
        
        const data = await response.json();
        
        if (data.success) {          
          this.classList.toggle('favorited');
                    
          const icon = this.querySelector('i');
          if (this.classList.contains('favorited')) {
            icon.className = 'fas fa-star';
            showToast(`${this.dataset.name} adicionado aos favoritos!`);
          } else {
            icon.className = 'far fa-star';
            showToast(`${this.dataset.name} removido dos favoritos!`);
          }
        }
      } catch (error) {
        console.error('Erro ao favoritar:', error);
        showToast('Erro ao atualizar favorito.', true);
      }
    });
  });
  
  function showToast(message, isError = false) {
    const toast = document.createElement('div');
    toast.className = `toast ${isError ? 'toast-error' : 'toast-success'}`;
    toast.textContent = message;
    
    document.body.appendChild(toast);
      
    setTimeout(() => {
      toast.classList.add('show');
    }, 100);
    
    setTimeout(() => {
      toast.classList.remove('show');
      setTimeout(() => {
        document.body.removeChild(toast);
      }, 300);
    }, 3000);
  }
});