
function CloseNUI() {

  $("#main").fadeOut();
  $(".main-section").hide();
  $(".makeup-selected-section").hide();
  $(".groom-selected-section").hide();
  $(".lifestyle-selected-section").hide();
  $("#groom-selected-comps-list").html('');
  $("#main-categories-list").html('');

  $.post('http://tpz_makeup/close', JSON.stringify({}));
}

$(function() {

	window.addEventListener('message', function(event) {
		
    var item = event.data;

		if (item.type == "enable") {
			document.body.style.display = item.enable ? "block" : "none";

      $(".main-section").show();

      if (item.enable) {
        $("#main").fadeIn(1000);
      }

    } else if (item.action == "reset_components_list") {

      $("#groom-selected-comps-list").html('');

    } else if (item.action == "reset_makeup_components_list") {
      
      $("#makeup-selected-comps-list").html('');

    } else if (item.action == "set_information") {

      $("#main-title").text(item.title);
      $("#main-close-button").text(item.locales['NUI_CLOSE']);
      $("#makeup-selected-back-button").text(item.locales['NUI_BACK']);

      $("#makeup-info-text").text(item.locales['NUI_MAKEUP_INFO']);
      $("#makeup-texture-id-title").text(item.locales['NUI_MAKEUP_TEXTURE_ID']);
      $("#makeup-color1-title").text(item.locales['NUI_MAKEUP_COLOR1']);
      $("#makeup-color2-title").text(item.locales['NUI_MAKEUP_COLOR2']);
      $("#makeup-opacity-title").text(item.locales['NUI_MAKEUP_OPACITY']);

      $("#groom-selected-back-button").text(item.locales['NUI_BACK']);
      $("#lifestyle-selected-back-button").text(item.locales['NUI_BACK']);

      $("#lifestyle-texture-id-title").text(item.locales['NUI_LIFESTYLES_TEXTURE_TITLE']);
      $("#lifestyle-opacity-title").text(item.locales['NUI_LIFESTYLES_OPACITY_TITLE']);

      document.getElementById('main-info-text').innerHTML = item.locales['NUI_MAIN_PAGE_DESCRIPTION'];


    } else if (item.action == 'insertMakeupCategory') {
      let res = item.result;

      $("#makeup-categories-list").append(
        `<div id="makeup-categories-list-name" title = "` + res.label + `" category = "` + res.category + `" >` + res.label + `</div>` +
        `<div> &nbsp; </div>`
      );

    } else if (item.action == "insertMakeupCategoryElements") {

      let res = item.result;

      let current = res.current;
      let max = res.max

      if (res.category == 'hair' || res.category == 'beard' || res.category == 'bow') {
        $("#makeup-selected-comps-list").css('top', '38.3%');

      } else {

        if (res.type == 'opacity') {

          if (current == 9 || current == 1.0) {
            current = "0.9";
          }

          if (current == 0.0) {
            current = "0.0";
          }

          max = "0.9";
        }

        $("#makeup-selected-comps-list").css('top', '30.5%');
      }

      $("#makeup-selected-comps-list").append(
        `<div class="makeup-selected-comps-list-title">${res.label}</div>
				<div class="makeup-selected-comps-list-selector">
				  <div class="makeup-selected-comps-list-nav-container">
					<button id="makeup-selected-comps-list-prev" category ="${res.category}" type ="${res.type}">⟨</button>
					<div id="makeup-selected-comps-list-currentNumber" class = "makeup-currentNumber-${res.category}-${res.type}" >${current} / ${max}</div>
					<button id="makeup-selected-comps-list-next" category ="${res.category}" type ="${res.type}">⟩</button>
				  </div>
				</div>`
      );

    } else if (item.action == 'selectedMakeupCategory') {

      let res = item.result;
      $("#makeup-selected-title").text(res.title);
      $("#makeup-selected-info-text").text(res.description);

      $(".makeup-selected-section").fadeIn();

      let margin = res.max > 3 ? 80.1 : 79.9;

      $("#makeup-selected-comps-list").css('left', margin + "vw");

      CURRENT_MAKEUP_CATEGORY_ITEM = res.current_texture_id;
      MAXIMUM_MAKEUP_CATEGORY_ITEMS = res.max_texture_id;

      CURRENT_MAKEUP_COLOR_PRIMARY_ITEM = res.primary_color;
      CURRENT_MAKEUP_COLOR_SECONDARY_ITEM = res.secondary_color;

      CURRENT_MAKEUP_VARIANT_ITEM = res.current_variant;
      MAXIMUM_MAKEUP_VARIANT_ITEMS = res.max_variants;

      let opacity = res.current_opacity != 9 ? convertToInt(res.current_opacity) : 9;
      CURRENT_MAKEUP_OPACITY_ITEM = opacity;

    } else if (item.action == "insertGroomCategoryElements") {

      let res = item.result;

      let current = res.current;
      let max = res.max

      if (res.category == 'hair' || res.category == 'beard') {
        $("#groom-selected-comps-list").css('top', '38.3%');

      } else {

        if (res.type == 'opacity') {

          if (current == 10 || current == 1.0) {
            current = "1.0";
          }

          if (current == 0.0) {
            current = "0.0";
          }

          max = "1.0";
        }

        $("#groom-selected-comps-list").css('top', '30.5%');
      }

      $("#groom-selected-comps-list").append(
        `<div class="groom-selected-comps-list-title">${res.label}</div>
				<div class="groom-selected-comps-list-selector">
				  <div class="groom-selected-comps-list-nav-container">
					<button id="groom-selected-comps-list-prev" category ="${res.category}" type ="${res.type}">⟨</button>
					<div id="groom-selected-comps-list-currentNumber" class = "groom-currentNumber-${res.category}-${res.type}" >${current} / ${max}</div>
					<button id="groom-selected-comps-list-next" category ="${res.category}" type ="${res.type}">⟩</button>
				  </div>
				</div>`
      );

    } else if (item.action == 'selectedGroomCategory') {

      let res = item.result;
      $("#groom-selected-title").text(res.title);
      $("#groom-selected-info-text").text(res.description);

      $(".groom-selected-section").fadeIn();

      let margin = res.max > 3 ? 80.1 : 79.9;

      $("#groom-selected-comps-list").css('left', margin + "vw");

      CURRENT_GROOM_CATEGORY_ITEM = res.current_texture_id;
      MAXIMUM_GROOM_CATEGORY_ITEMS = res.max_texture_id;

      CURRENT_GROOM_COLOR_ITEM = res.current_color;
      MAXIMUM_GROOM_COLOR_ITEMS = res.max_colors;

      let opacity = res.current_opacity != 10 ? convertToInt(res.current_opacity) : 10;
      CURRENT_GROOM_OPACITY_ITEM = opacity;

    } else if (item.action == 'updateGroomSpecificData') {

      MAXIMUM_GROOM_COLOR_ITEMS = item.max_colors;
      $(".groom-currentNumber-" + item.category + "-color").text("1 / " + item.max_colors);
      $(".groom-currentNumber-" + item.category + "-opacity").text("1.0 / 1.0");

    } else if (item.action == 'selectedLifestyleCategory') {

      let res = item.result;
      let max = Number(res.max);

      CURRENT_LIFESTYLE_CATEGORY_ITEM = res.current;
      CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY = res.current_opacity;

      MAXIMUM_LIFESTYLE_CATEGORY_ITEMS = max;

      $("#lifestyle-texture-id-currentNumber").text(res.current + ' / ' + max);

      let opacity = res.current_opacity >= 1 ? "1.0" : res.current_opacity;

      $("#lifestyle-opacity-currentNumber").text(opacity + ' / 1.0');

      $("#lifestyle-selected-title").text(res.title);
      $("#lifestyle-selected-info-text").text(res.description);

      $(".lifestyle-selected-section").fadeIn();

    } else if (item.action == "insertCategory") {

      let res = item.result;

      $("#main-categories-list").append(
        `<div id="main-categories-list-name" title = "` + res.label + `" category = "` + res.category + `" nui_call = "` + res.nui_call + `" >` + res.label + `</div>` +
        `<div> &nbsp; </div>`
      );

    } else if (item.action == "close") {
      CloseNUI();
    }

  });

  /* ------------------------------------------------
  ------------------------------------------------ */ 

  $("#main").on("click", "#main-close-button", function () {
    PlayButtonClickSound();
    CloseNUI();
  });

  $("#main").on("click", "#makeup-selected-back-button", function () {
    PlayButtonClickSound();

    $(".makeup-selected-section").hide();
    $(".main-section").show();

    $.post('http://tpz_makeup/back', JSON.stringify({}));

  });

  $("#main").on("click", "#groom-selected-back-button", function () {
    PlayButtonClickSound();

    $(".groom-selected-section").hide();
    $(".main-section").show();

    $.post('http://tpz_makeup/groom_back', JSON.stringify({}));

  });

  $("#main").on("click", "#lifestyle-selected-back-button", function () {
    PlayButtonClickSound();

    $(".lifestyle-selected-section").hide();
    $(".main-section").show();

    $.post('http://tpz_makeup/lifestyle_back', JSON.stringify({}));

  });


  $("#main").on("click", "#main-categories-list-name", function () {
    PlayButtonClickSound();

    let $button = $(this);
    let $category = $button.attr('category');
    let $title = $button.attr('title');
    let $nui_call = $button.attr('nui_call');

    $.post('http://tpz_makeup/' + $nui_call, JSON.stringify({
      category: $category,
      title : $title,
    }));

    $(".main-section").fadeOut();

  });


  /* ------------------------------------------------
  ------------------------------------------------ */ 


});
