function forEach(elems, fun) {
  Array.prototype.forEach.call(elems, fun);
}

function getPagetocElems() {
  return document.getElementsByClassName("pagetoc")[0].children;
}

// Un-active everything when you click it
function forPagetocElem(fun) {
  forEach(getPagetocElems(), fun);
}

function getRect(element) {
  return element.getBoundingClientRect();
}

function overflowTop(container, element) {
  return getRect(container).top - getRect(element).top;
}

function overflowBottom(container, element) {
  return getRect(container).bottom - getRect(element).bottom;
}

var activeHref = location.href;

var updateFunction = function (elem = undefined) {
  var id = elem;

  if (!id && location.href != activeHref) {
    activeHref = location.href;
    forPagetocElem(function (el) {
      if (el.href === activeHref) {
        id = el;
      }
    });
  }

  if (!id) {
    var elements = document.getElementsByClassName("header");
    let menuBottom = getRect(document.getElementById("menu-bar")).bottom;
    let contentCenter = window.innerHeight / 2;
    let margin = contentCenter / 3;

    forEach(elements, function (el, i, arr) {
      if (!id && getRect(el).bottom >= menuBottom) {
        if (getRect(el).top >= contentCenter + margin) {
          id = arr[Math.max(0, i - 1)];
        } else {
          id = el;
        }
      }
    });
  }

  forPagetocElem(function (el) {
    el.classList.remove("active");
  });

  if (!id) return;

  forPagetocElem(function (el) {
    if (id.href.localeCompare(el.href) == 0) {
      el.classList.add("active");
      let pagetoc = document.getElementsByClassName("pagetoc")[0];
      if (overflowTop(pagetoc, el) > 0) {
        pagetoc.scrollTop = el.offsetTop;
      }
      if (overflowBottom(pagetoc, el) < 0) {
        pagetoc.scrollTop -= overflowBottom(pagetoc, el);
      }
    }
  });
};

var elements = document.getElementsByClassName("header");

if (elements.length > 1) {
  // Populate sidebar on load
  window.addEventListener("load", function () {
    var pagetoc = document.getElementsByClassName("pagetoc")[0];
    var elements = document.getElementsByClassName("header");
    forEach(elements, function (el) {
      var link = document.createElement("a");
      link.appendChild(document.createTextNode(el.text));
      link.href = el.hash;
      link.classList.add("pagetoc-" + el.parentElement.tagName);
      pagetoc.appendChild(link);
      link.onclick = function () {
        updateFunction(link);
      };
    });
    updateFunction();
  });

  // Handle active elements on scroll
  window.addEventListener("scroll", function () {
    updateFunction();
  });
} else {
  document.getElementsByClassName("sidetoc")[0].remove();
}
