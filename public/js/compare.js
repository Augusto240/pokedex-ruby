document.addEventListener('DOMContentLoaded', function() {
  const statBars = document.querySelectorAll('.stat-bar-inner');
  
  statBars.forEach(bar => {
    const width = bar.style.width;
    bar.style.width = '0';
    
    setTimeout(() => {
      bar.style.transition = 'width 1s ease-out';
      bar.style.width = width;
    }, 100);
  });
  
  const statRows = document.querySelectorAll('.stat-row');
  
  statRows.forEach(row => {
    const values = row.querySelectorAll('.stat-value');
    if (values.length === 2) {
      const value1 = parseInt(values[0].textContent);
      const value2 = parseInt(values[1].textContent);
      
      if (value1 > value2) {
        values[0].classList.add('higher');
      } else if (value2 > value1) {
        values[1].classList.add('higher');
      }
    }
  });
});