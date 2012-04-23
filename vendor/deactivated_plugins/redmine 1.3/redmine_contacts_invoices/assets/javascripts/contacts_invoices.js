function remove_fields (link) {
	$(link).previous("input[type=hidden]").value = "1";
	$(link).up(".fields").fade({ duration: 0.5 });
}

function add_fields (link, association, content) {
	var	new_id = new Date().getTime();
	var regexp = new RegExp("new_" + association, "g");
	$$('#sortable tr').last().insert({'after':content.replace(regexp, new_id)});
	// new Effect.Highlight(new_id);
}

function formatCurrency(num) {
    num = isNaN(num) || num === '' || num === null ? 0.00 : num;
    return parseFloat(num).toFixed(2);
}

function updateTotal(element) {
	row = element.up("tr");
	amount_value = row.getElementsBySelector(".price input").first().value * row.getElementsBySelector(".quantity input").first().value
	row.getElementsBySelector(".total").first().innerHTML = formatCurrency(amount_value);
	return false;
}

function activateTextAreaResize(element) {
  Event.observe(element, 'keyup', function() {
    updateTextAreaSize(element)
  });
  updateTextAreaSize(element)
}

function updateTextAreaSize(element) {
  //if scrollbars appear, make it bigger, unless it's bigger then the user's browser area.
  if(Element.getHeight(element) < $(element).scrollHeight && Element.getHeight(element) < document.viewport.getHeight()) {
    $(element).style.height = $(element).getHeight()+15+'px'
    if(Element.getHeight(element) < $(element).scrollHeight) {
      window.setTimeout("updateSize('"+element+"')",5)
    }               
  }
}
