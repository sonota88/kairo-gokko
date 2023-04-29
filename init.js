(()=>{
  function ael(el, name, fn) {
    el.addEventListener(name, fn, false);
  }
  function qs(selector) {
    return document.querySelector(selector);
  }
  function hide(el) {
    el.style.display = "none";
  }
  function show(el) {
    el.style.display = "block";
  }

  function onclickRunButton() {
    hide(qs(".run_button"));
    show(qs(".loading_container"));

    const scr = document.createElement("script");
    qs("body").appendChild(scr);

    ael(scr, "load", () => console.log("main.js loaded"));
    scr.src = "./main.js";
  }

  function isEmbedMode() {
    const url = new URL(location.href);
    return url.searchParams.get("embed") === "1";
  }

  function init() {
    if (isEmbedMode()) {
      qs("body").style.margin = 0;
      qs("body").style.background = "#444";
      qs(".footer").style.display = "none";
    }

    ael(qs(".run_button"), "click", onclickRunButton);
  }

  ael(document, "DOMContentLoaded", init);
})();
