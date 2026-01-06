
let CURRENT_MAKEUP_CATEGORY_ITEM = 0;
let MAXIMUM_MAKEUP_CATEGORY_ITEMS = 1;
let CURRENT_MAKEUP_COLOR_PRIMARY_ITEM = 0;
let CURRENT_MAKEUP_COLOR_SECONDARY_ITEM = 0;
let CURRENT_MAKEUP_VARIANT_ITEM = 0;
let MAXIMUM_MAKEUP_VARIANT_ITEMS = 0;
let CURRENT_MAKEUP_OPACITY_ITEM = 9;

let CURRENT_OVERLAY_INFO_EYES_TEXTURE_ID = 14;
let MAX_OVERLAYS_INFO_EYES_TEXTURE_ID = 14;

let CURRENT_GROOM_CATEGORY_ITEM = 1;
let MAXIMUM_GROOM_CATEGORY_ITEMS = 1;
let CURRENT_GROOM_COLOR_ITEM = 1;
let MAXIMUM_GROOM_COLOR_ITEMS = 1;
let CURRENT_GROOM_OPACITY_ITEM = 10;

let CURRENT_LIFESTYLE_CATEGORY_ITEM = 0;
let CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY = 0;
let MAXIMUM_LIFESTYLE_CATEGORY_ITEMS = 0;

let HAS_COOLDOWN = false;

document.addEventListener("DOMContentLoaded", function () {

  $("#main").fadeOut();

  displayPage("main-section", "visible");
  $(".main-section").fadeOut();

  displayPage("makeup-selected-section", "visible");
  $(".makeup-selected-section").fadeOut();

  displayPage("groom-selected-section", "visible");
  $(".groom-selected-section").fadeOut();

  displayPage("lifestyle-selected-section", "visible");
  $(".lifestyle-selected-section").fadeOut();
});

function PlayButtonClickSound() {
  var audio = new Audio('./audio/button_click.wav');
  audio.volume = 0.3;
  audio.play();
}

function displayPage(page, cb){
  document.getElementsByClassName(page)[0].style.visibility = cb;

  [].forEach.call(document.querySelectorAll('.' + page), function (el) {
    el.style.visibility = cb;
  });
}

function ResetCooldown(){ setTimeout(function () { HAS_COOLDOWN = false; }, 500); }

function convertSelectorValue(val) {
  if (val < 0 || val > 10) {
    return val;
  }
  const scaled = (val / 10).toFixed(1); // 0.1, 0.2, ..., 1.0
  return `${scaled}`;
}

function convertToInt(val) {
  const num = parseFloat(val); // handle both string and number inputs
  if (num < 0 || num > 1) {
    return val;
  }
  return Math.round(num * 10); // scale back up to integer
}