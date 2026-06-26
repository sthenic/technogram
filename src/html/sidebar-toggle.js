const toggle = document.querySelector('.sidebar-toggle');
const sidebar = document.querySelector('.sidebar');
if (toggle && sidebar) {
  toggle.addEventListener('click', () => sidebar.classList.toggle('open'));
  sidebar.addEventListener('click', e => {
    if (e.target.tagName === 'A') sidebar.classList.remove('open');
  });
}
