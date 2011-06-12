var
OverviewLayout = HView.extend({

  drawDescriptionBox: function( left, top, parent, value ){
    var
    descr_view, descr_height;
    descr_view = HStringView.nu( [ left, top, null, 200, 16, null ], parent, { value: value } );
    ELEM.addClassName( descr_view.elemId, 'description' );
    descr_height = ELEM.getSize(descr_view.markupElemIds.value)[1];
    descr_view.rect.setHeight( descr_height );
    descr_view.drawRect();
    return descr_height+8;
  },
  drawSubviews: function(){
    var
    configuration_data = this.options.items,
    strings = this.options.strings,
    top = 40;

    HStringView.nu( [ 24, 8, null, 32, 8, null ], this, {
      value: configuration_data.title,
      style: {
        'font-weight': 'bold',
        'font-size': '18px'
      }
    } );
    top += this.drawDescriptionBox( 24, top, this, configuration_data.description );
    ComponentButton.nu( [null, top-8, 160, 24, 23, null], this, {
      label: strings.base_components,
      spec: configuration_data.components,
      strings: strings,
      section_title: 'Baseline'
    } );
    top += 24;
  }
});
