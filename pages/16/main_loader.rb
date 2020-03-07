def start_loading
  require_remote "main.rb"
end

%x{
  if (location.href.match(/\?embed=1/)) {
    var body = document.querySelector("body");
    body.style.margin = 0;
  }

  var button = document.querySelector("button");
  button.addEventListener("click", ()=>{
    button.style.display = "none";
    var loadingContainer = document.querySelector(".loading_container");
    loadingContainer.style.display = "block";
    #{start_loading};
  });
}
