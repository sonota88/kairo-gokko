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

  function onLoadDXOpal() {
    console.debug("DXOpal loaded");
    Opal.eval(`
      DXOpal.dump_error{
        require_remote "main.rb?#{Time.now.to_i}"
      }
    `);
  }

  function onclickRunButton() {
    hide(qs(".run_button"));
    show(qs(".loading_container"));

    const scr = document.createElement("script");
    qs("body").appendChild(scr);

    ael(scr, "load", onLoadDXOpal);
    scr.src = "./dxopal.min.js";
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
