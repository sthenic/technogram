const sections = [];
document.querySelectorAll('[id]').forEach(el => {
  if (document.querySelector('.sidebar a[href="#' + el.id + '"]')) {
    sections.push(el);
  }
});

function updateActive() {
  let current = null;
  for (const section of sections) {
    if (section.getBoundingClientRect().top <= 100) {
      current = section;
    } else {
      break;
    }
  }
  if (!current) current = sections[0];
  document.querySelectorAll('.sidebar a').forEach(a => a.classList.remove('active'));
  if (current) {
    const link = document.querySelector('.sidebar a[href="#' + current.id + '"]');
    if (link) link.classList.add('active');
  }
}

document.addEventListener('scroll', updateActive, { passive: true });
updateActive();
