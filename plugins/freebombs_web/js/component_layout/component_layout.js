var
ComponentButton = HButton.extend({
  defaultEvents: {
    click: true
  },
  componentView: null,
  ComponentView: HWindow.extend({
    drawSubviews: function(){
      var
      opt = this.options,
      spec = opt.spec,
      str = opt.strings,
      help = HStringView.nu([8,8,null,50,8,null],this,{
        value: str.component_details_help.replace(/\#\{title\}/g,opt.section_title)
      }),
      helpHeight,
      i = 0,
      top,
      parent,
      c_spec,
      nowrap_style = {
        'white-space': 'nowrap',
        'overflow': 'hidden',
        'text-overflow': 'ellipsis'
      };
      ELEM.addClassName( help.elemId, 'description' );
      helpHeight = ELEM.getSize( help.markupElemIds.value )[1];
      help.rect.setHeight( helpHeight );
      help.drawRect();
      top = helpHeight + 16;
      HStringView.nu([40,top,56,22],this,{
        value: str.component_table_count,
        style: {
          'font-weight': 'bold',
          'border-right': '1px solid #999'
        }
      });
      HStringView.nu([100,top,140,22],this,{
        value: str.component_table_component_id,
        style: {
          'font-weight': 'bold',
          'border-right': '1px solid #999'
        }
      });
      HStringView.nu([240,top,null,22,24,null],this,{
        value: str.component_table_component_title,
        style: {
          'font-weight': 'bold',
          'border-right': '1px solid #999'
        }
      });
      top += 20;
      parent = HScrollView.nu([0,top,null,null,0,0],this,{scrollX:false,scrollY:'auto'});
      for(;i<spec.length;i++){
        top = i * 30;
        c_spec = spec[i];
        HCheckBox.nu( [8,top,24,24], parent, {
          valueObj: HVM.values[c_spec.enabled]
        } );
        HNumericTextControl.nu( [40,top,40,22], parent, {
          valueObj: HVM.values[c_spec.count],
          minValue: 0
        } );
        HStepper.nu( [80,top,16,22], parent, {
          valueObj: HVM.values[c_spec.count],
          minValue: 0
        } );
        HStringView.nu( [100,top+3,140,20], parent, {
          value: c_spec.id,
          style: nowrap_style
        } );
      }
    },
    die: function(){
      this.options.parentRef.componentView = null;
      this.base();
    }
  }),
  click: function(){
    if( !this.componentView ){
      var
      opt = this.options,
      str = opt.strings;
      this.ComponentView.nu(
        [ 40, 40, 640, 640 ],
        this.app, {
          spec: opt.spec,
          strings: str,
          section_title: opt.section_title,
          label: str.component_window_prefix+opt.section_title,
          parentRef: this,
          closeButton: true,
          collapseButton: true,
          zoomButton: true,
          minSize: [ 400, 300 ]
        }
      );
    }
  }
});
