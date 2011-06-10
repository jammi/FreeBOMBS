var
SettingsLayout = HView.extend({
  drawSubviews: function(){
    var
    i = 0,
    items = this.options.items,
    item,
    labelRect = HRect.nu( 8, 12, 120, 32 ),
    ctrlRect  = HRect.nu( 128, 8, 578, 32 ),
    offsetBy = 28,
    valueObj;
    for(;i<items.length;i++){
      item = items[i];
      HStringView.nu(
        HRect.nu( labelRect ),
        this, {
          value: item.label,
          style: { 'text-align': 'right' }
        }
      );
      valueObj = HVM.values[item.value];
      if( item.min !== undefined && item.max !== undefined ){
        var numRect = HRect.nu( ctrlRect );
        numRect.setWidth( 60 );
        HNumericTextControl.nu(
          numRect,
          this, {
            valueObj: valueObj,
            minValue: item.min,
            maxValue: item.max
          }
        );
        var stepRect = HRect.nu( ctrlRect );
        stepRect.offsetBy( numRect.width, 0 );
        stepRect.setWidth( 16 );
        HStepper.nu(
          stepRect,
          this, {
            valueObj: valueObj,
            minValue: item.min,
            maxValue: item.max
          }
        );
      }
      else if ( item.menu !== undefined ){
        HPopupMenu.nu(
          HRect.nu( ctrlRect ),
          this, {
            valueObj: valueObj
          }
        ).setListItems( item.menu );
      }
      else {
        HTextControl.nu(
          HRect.nu( ctrlRect ),
          this, {
            valueObj: valueObj
          }
        );
      }
      labelRect.offsetBy( 0, offsetBy );
      ctrlRect.offsetBy( 0, offsetBy );
    }
  }
});
