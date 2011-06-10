var
ConfigurationLayout = HView.extend({
  buildConfigSection: function( parent, section_spec, strings ){
    var
    top = 32+this.drawDescriptionBox( 116, 32, parent, section_spec.description ),
    enablerList = [ HSystem.views[parent.views[0]] ],
    checkBox = HCheckBox.extend({
      refreshValue: function(){
        this.base();
        for( var i = 0; i < this.options.enablerList.length; i++ ){
          this.options.enablerList[i].setEnabled( this.value );
        }
      }
    }).nu( [ 0, 8, 100, 24 ], parent, {
      valueObj: HVM.values[section_spec.enabled],
      label: strings.enable,
      enablerList: enablerList,
      style: {
        'font-size': '16px',
        'font-weight': 'bold'
      }
    } );
    enablerList.push( this.TextBox.nu( [ 116, 8, null, 24, 8, null ], parent, {
      value: section_spec.title,
      style: {
        'font-size': '18px',
        'font-weight': 'bold'
      }
    } ) );
    enablerList.push( HNumericTextControl.nu( [ 116, top, 50, 22 ], parent, {
      valueObj: HVM.values[ section_spec.count ],
      minValue: section_spec.min,
      maxValue: section_spec.max
    } ) );
    enablerList.push( HStepper.nu( [ 166, top, 16, 22 ], parent, {
      valueObj: HVM.values[ section_spec.count ],
      minValue: section_spec.min,
      maxValue: section_spec.max
    } ) );
    enablerList.push( HButton.nu( [ null, top, 160, 24, 8, null ], parent, {
      label: 'View Components'
    } ) );
    top += 28;
    ELEM.setCSS( ELEM.make( parent.elemId ), 'position:absolute;top:'+top+'px;left:24px;height:1px;right:8px;background:#ccc;' );
    console.log('section_spec:', section_spec);
    checkBox.refreshValue();
    return top;
  },
  buildConfigSections: function( top, section_specs, strings ){
    var
    scrollView = HScrollView.nu(
      [ 0, top, null, null, 0, 0 ],
      this, {
        scrollX: false,
        scrollY: 'auto',
        style: {
          'border-top': '1px solid #ccc'
        }
      }
    ),
    i = 0,
    section_spec;
    top = 0;
    this.sectionViews = [];
    for(; i < section_specs.length; i++){
      section_spec = section_specs[i];
      this.sectionViews[i] = HView.nu(
        [ 0, top, null, 200, 0, null ],
        scrollView
      );
      top += this.buildConfigSection( this.sectionViews[i], section_spec, strings );
    }
  },
  TextBox: HStringView.extend({
    setEnabled: function( flag ){
      this.base( flag );
      this.setStyle('color',flag?'#333':'#999');
    }
  }),
  drawDescriptionBox: function( left, top, parent, value ){
    var
    descr_view, descr_height;
    descr_view = this.TextBox.nu( [ left, top, null, 200, 16, null ], parent, { value: value } );
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
    top_offset = 40,
    buttonRect;

    HStringView.nu( [ 8, 8, null, 32, 8, null ], this, {
      value: configuration_data.title,
      style: {
        'font-weight': 'bold',
        'font-size': '24px'
      }
    } );
    top_offset += this.drawDescriptionBox( 24, top_offset, this, configuration_data.description );
    buttonRect = HRect.nu( 24, top_offset, 192, top_offset+24 );
    top_offset += 24 + 16;
    HButton.nu( HRect.nu( buttonRect ), this, { label: strings.view_components } );
    buttonRect.offsetBy( buttonRect.width, 0 );
    HButton.nu( HRect.nu( buttonRect ), this, { label: strings.view_instructions, enabled: false } );
    HStringView.nu( [ 24, top_offset, null, 24, 16, null ], this, {
      value: strings.sections_title,
      style: {
        'font-size': '18px',
        'font-weight': 'bold'
      }
    } );
    top_offset += 24;
    this.buildConfigSections( top_offset, configuration_data.sections, strings );
  }
});
