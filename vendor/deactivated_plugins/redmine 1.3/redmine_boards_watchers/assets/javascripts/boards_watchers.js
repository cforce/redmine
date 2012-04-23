
function toggleWatchersCheckBoxes(ids_to_toggle_str,on_off_str) {
    var user_ids=ids_to_toggle_str.evalJSON();
    var turn_on=on_off_str.evalJSON();
    var bw_users=$('bw-users');
    var user_check_boxes=(bw_users==null ? null : Prototype.Selector.select("input",bw_users));

    if(user_check_boxes!=null) {
      var i;
      for(i=0;i<user_check_boxes.length;i++) {
        if(user_ids[0] == -1 || user_ids.indexOf(parseInt(user_check_boxes[i].value)) != -1) {
            if(turn_on==-1) {
              if(user_check_boxes[i].checked==0) {
                turn_on=1;
              } else {
                turn_on=0;
              }
            }
            user_check_boxes[i].checked=turn_on;
        }
      }
    }
}

function highlightWatchers() {
  var bw_users=$('bw-users');
  var user_check_boxes=(bw_users==null ? null : Prototype.Selector.select("input[type=checkbox]",bw_users));

  if(user_check_boxes!=null) {
    var value=$('watcher_search').value.toUpperCase();
    var i;
    var user_name;
    var label_elem;

    for(i=0;i<user_check_boxes.length;i++) {
      label_elem=user_check_boxes[i].up();
      label_elem.removeClassName('bw-floating');
      label_elem.removeClassName('bw-floating-select');

      user_name=label_elem.childNodes[1].nodeValue.toUpperCase();

      if(value.length > 1 && user_name.include(value)) {
        label_elem.addClassName('bw-floating-select');
      } else {
        label_elem.addClassName('bw-floating');
      }
    }
  }
}

function toggleSelectedWatchers(on_off_str) {
  var turn_on=on_off_str.evalJSON();
  var bw_users=$('bw-users');
  var user_check_boxes=(bw_users==null ? null : Prototype.Selector.select("input[type=checkbox]",bw_users));

  if(user_check_boxes!=null) {
    var i;

    for(i=0;i<user_check_boxes.length;i++) {
      if(user_check_boxes[i].up().hasClassName('bw-floating-select')) {
        user_check_boxes[i].checked=turn_on;
      }
    }

  }
}
