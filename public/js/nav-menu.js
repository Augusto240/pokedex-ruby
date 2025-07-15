document.addEventListener('DOMContentLoaded', function() {
  const navMenu = document.querySelector('.nav-menu');
  const navMenuToggle = document.querySelector('.nav-menu-toggle');
  
  if (navMenuToggle) {
    navMenuToggle.addEventListener('click', function() {
      navMenu.classList.toggle('active');
    });
        
    document.addEventListener('click', function(e) {
      if (!navMenu.contains(e.target)) {
        navMenu.classList.remove('active');
      }
    });
  }
});