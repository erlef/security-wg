function initRandomizer() {
  [...document.getElementsByClassName('randomize-order')].forEach(randomizeContainer);
}

function randomizeContainer(container) {
  for (let i = container.children.length; i >= 0; i--) {
    container.appendChild(container.children[Math.random() * i | 0]);
  }
}

document.addEventListener("DOMContentLoaded", initRandomizer);
