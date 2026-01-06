

$(function () {

	// texture-id adjusters.
	$("#main").on("click", "#lifestyle-texture-id-prev", function () {
		PlayButtonClickSound();

		CURRENT_LIFESTYLE_CATEGORY_ITEM--;

		if (CURRENT_LIFESTYLE_CATEGORY_ITEM < 0) {
			CURRENT_LIFESTYLE_CATEGORY_ITEM = MAXIMUM_LIFESTYLE_CATEGORY_ITEMS;
		}

		CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY = 10;
		$("#lifestyle-opacity-currentNumber").text("1.0 / 1.0");

		$("#lifestyle-texture-id-currentNumber").text(CURRENT_LIFESTYLE_CATEGORY_ITEM + " / " + MAXIMUM_LIFESTYLE_CATEGORY_ITEMS);

		$.post("http://tpz_makeup/set_lifestyle_textures", JSON.stringify({
			texture_id: CURRENT_LIFESTYLE_CATEGORY_ITEM,
			opacity: CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY,
		}));

	});

	$("#main").on("click", "#lifestyle-texture-id-next", function () {
		PlayButtonClickSound();

		CURRENT_LIFESTYLE_CATEGORY_ITEM++;

		if (CURRENT_LIFESTYLE_CATEGORY_ITEM > MAXIMUM_LIFESTYLE_CATEGORY_ITEMS) {
			CURRENT_LIFESTYLE_CATEGORY_ITEM = 0;
		}

		CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY = 10;
		$("#lifestyle-opacity-currentNumber").text("1.0 / 1.0");

		$("#lifestyle-texture-id-currentNumber").text(CURRENT_LIFESTYLE_CATEGORY_ITEM + " / " + MAXIMUM_LIFESTYLE_CATEGORY_ITEMS);

		$.post("http://tpz_makeup/set_lifestyle_textures", JSON.stringify({
			texture_id: CURRENT_LIFESTYLE_CATEGORY_ITEM,
			opacity: CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY,
		}));
	});

	// opacity adjusters.
	$("#main").on("click", "#lifestyle-opacity-prev", function () {
		PlayButtonClickSound();

		CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY--;

		if (CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY <= 0) {
			CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY = 0;
		}

		let opacity_text = convertSelectorValue(CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY);
		$("#lifestyle-opacity-currentNumber").text(opacity_text + " / 1.0");

		$.post("http://tpz_makeup/set_lifestyle_textures", JSON.stringify({
			texture_id: CURRENT_LIFESTYLE_CATEGORY_ITEM,
			opacity: CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY,
		}));

	});

	$("#main").on("click", "#lifestyle-opacity-next", function () {
		PlayButtonClickSound();

		CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY++;

		if (CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY >= 10) {
			CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY = 10;
		}

		let opacity_text = convertSelectorValue(CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY);
		$("#lifestyle-opacity-currentNumber").text(opacity_text + " / 1.0");

		$.post("http://tpz_makeup/set_lifestyle_textures", JSON.stringify({
			texture_id: CURRENT_LIFESTYLE_CATEGORY_ITEM,
			opacity: CURRENT_LIFESTYLE_CATEGORY_ITEM_OPACITY,
		}));
	});

});

