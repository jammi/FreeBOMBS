var
ConfigurationLayout = HView.extend({
  buildConfigSection: function( parent, section_spec, strings ){
    var
    top = 32+this.drawDescriptionBox( 96, 32, parent, section_spec.description ),
    enablerList = [ HSystem.views[parent.views[0]] ],
    checkBox = HCheckBox.extend({
      refreshValue: function(){
        this.base();
        for( var i = 0; i < this.options.enablerList.length; i++ ){
          this.options.enablerList[i].setEnabled( this.value );
        }
      }
    }).nu( [ 0, 8, 80, 24 ], parent, {
      valueObj: HVM.values[section_spec.enabled],
      label: strings.enable,
      enablerList: enablerList,
      style: {
        'font-weight': 'bold'
      }
    } );
    enablerList.push( this.TextBox.nu( [ 96, 8, null, 24, 8, null ], parent, {
      value: section_spec.title,
      style: {
        'font-size': '16px',
        'font-weight': 'bold'
      }
    } ) );
    if( section_spec.presets.length > 0 ){
      var
      presetLabel = this.TextBox.nu( [ 96, top+3, 60, 20 ], parent, {
        value: strings.presets
      } ),
      presetMenu = HPopupMenu.extend({
        refreshValue: function(){
          this.base();
          if( typeof this.value == 'number' ){
            this.options.countValue.set( this.value );
          }
        }
      }).nu( [ 96+60, top, null, 24, 8, null ], parent, {
        value: null,
        countValue: HVM.values[section_spec.count]
      } );
      presetMenu.setListItems( section_spec.presets );
      enablerList.push( presetLabel );
      enablerList.push( presetMenu );
      top += 28;
    }
    var
    countLabel = this.TextBox.nu( [ 96, top+3, 60, 20 ], parent, {
      value: strings.count
    } );
    enablerList.push( countLabel );
    enablerList.push( HNumericTextControl.nu( [ 96+60, top, 50, 22 ], parent, {
      valueObj: HVM.values[ section_spec.count ],
      minValue: section_spec.min,
      maxValue: section_spec.max
    } ) );
    enablerList.push( HStepper.nu( [ 96+60+50, top, 16, 22 ], parent, {
      valueObj: HVM.values[ section_spec.count ],
      minValue: section_spec.min,
      maxValue: section_spec.max
    } ) );
    enablerList.push( this.TextBox.nu( [96+60+66, top+3, 200, 20], parent, {
      value: strings.count_limits.replace('#{min}',section_spec.min).replace('#{max}',section_spec.max)
    } ) );
    if( section_spec.components.length > 0 ){
      enablerList.push( ComponentButton.nu( [ null, top, 160, 24, 8, null ], parent, {
        label: strings.view_components,
        spec: section_spec.components,
        strings: strings,
        section_title: section_spec.title
      } ) );
    }
    top += 28;
    ELEM.setCSS( ELEM.make( parent.elemId ), 'position:absolute;top:'+top+'px;left:24px;height:1px;right:8px;background:#ccc;' );
    checkBox.refreshValue();
    return top;
  },
  buildConfigSections: function( top, section_specs, strings ){
    var
    scrollView = HScrollView.nu(
      [ 24, top, null, null, 0, 0 ],
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
    top = 0, prevTop = 0;
    this.sectionViews = [];
    for(; i < section_specs.length; i++){
      section_spec = section_specs[i];
      this.sectionViews[i] = HView.nu(
        [ 0, top, null, 10, 0, null ],
        scrollView
      );
      prevTop = top;
      top += this.buildConfigSection( this.sectionViews[i], section_spec, strings );
      this.sectionViews[i].rect.setHeight( top-prevTop+1 );
      this.sectionViews[i].drawRect();
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
    top = 40;
    HStringView.nu( [ 24, 8, null, 32, 8, null ], this, {
      value: strings.configurations_title,
      style: {
        'font-weight': 'bold',
        'font-size': '18px'
      }
    } );
    HStringView.nu( [24, 32, null, 32, 200, null ], this, {
      value: strings.configurations_help
    } );
    ComponentButton.nu( [null, top-8, 160, 24, 23, null], this, {
      label: strings.base_components,
      spec: configuration_data.components,
      strings: strings,
      section_title: 'Baseline'
    } );
    top += 24;
    this.buildConfigSections( top, configuration_data.sections, strings );
  }
});
