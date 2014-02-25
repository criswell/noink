function unFlip(n) {
  var detail = document.getElementById(n);
  var flipper_more = document.getElementById("flipper_more_"+n);
  var flipper_less = document.getElementById("flipper_less_"+n);

  if (detail.style.display == "inline") {
      detail.style.display = "none";
      flipper_less.style.display = "none";
      flipper_more.style.display = "inline";
  } else {
      detail.style.display = "inline";
      flipper_more.style.display = "none";
      flipper_less.style.display = "inline";
  }
}

