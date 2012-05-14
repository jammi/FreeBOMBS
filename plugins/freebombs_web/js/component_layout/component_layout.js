var
ComponentButton = HButton.extend({
  defaultEvents: {
    click: true
  },
  componentView: null,
  ComponentView: HWindow.extend({
    PDFIcon: HControl.extend({
      defaultEvents: {
        click: true,
        contextMenu: true
      },
      click: function(){return false;},
      contextMenu: function(){return true;},
      focus: function(){
        this.base();
        ELEM.setStyle(this.elemId,'border','1px solid #039');
      },
      blur: function(){
        this.base();
        ELEM.setStyle(this.elemId,'border','1px solid transparent');
      },
      _makeElem: function(_parent){
        this.elemId = ELEM.make(_parent,'a');
        ELEM.setAttr(this.elemId,'href',this.options.href);
        ELEM.setAttr(this.elemId,'target','_new'+this.elemId);
      },
      _setCSS: function(_additional){
        this.base( _additional );
        ELEM.setStyle(this.elemId,'background-image','url(/img/pdf_icon.png)');
        ELEM.setStyle(this.elemId,'background-repeat','no-repeat');
        ELEM.setStyle(this.elemId,'border','1px solid transparent');
      }
    }),
    die: function(){
      for( var i = 0; i < this.gridElems.length; i++ ){
        ELEM.del(this.gridElems[i]);
      }
      this.options.parentRef.componentView = null;
      this.base();
    },
    _initActionFlag: function(){
      this.base();
      this.recalculateTableTop();
    },
    onAnimationEnd: function(){
      this.base();
      this.recalculateTableTop();
    },
    recalculateTableTop: function(){
      if(this.help){
        this.options.parentRef.origPos[0]=this.rect.left;
        this.options.parentRef.origPos[1]=this.rect.top;
        var
        helpHeight = ELEM.getSize( this.help.markupElemIds.value )[1],
        newTop = helpHeight+16;
        this.help.rect.setHeight( helpHeight );
        this.help.drawRect();
        this.table.rect.setTop( newTop );
        this.table.drawRect();
      }
    },
    drawSubviews: function(){
      this.base();
      var
      opt = this.options,
      spec = opt.spec,
      str = opt.strings,
      component_db = this.app.options.component_db,
      help = HStringView.nu([8,8,null,50,8,null],this,{
        value: str.component_details_help.replace(/\#\{title\}/g,opt.section_title)
      }),
      helpHeight,
      i = 0,
      gridElems = [],
      top, otop,
      parent,
      c_spec,
      gridlines = [97,237,-100],
      pos, gridline,
      gridline_style = 'position:absolute;background-color:#999;',
      nowrap_style = {
        'white-space': 'nowrap',
        'overflow': 'hidden',
        'text-overflow': 'ellipsis'
      };
      this.help = help;
      ELEM.addClassName( help.elemId, 'description' );
      helpHeight = ELEM.getSize( help.markupElemIds.value )[1];
      help.rect.setHeight( helpHeight );
      help.drawRect();
      top = helpHeight + 16;
      this.table = HView.nu([0,top,null,null,0,0],this);
      top = 0;
      HStringView.nu([40,top,56,22],this.table,{
        value: str.component_table_count,
        style: {
          'font-weight': 'bold'
        }
      });
      HStringView.nu([100,top,140,22],this.table,{
        value: str.component_table_component_id,
        style: {
          'font-weight': 'bold'
        }
      });
      HStringView.nu([240,top,null,22,100,null],this.table,{
        value: str.component_table_component_title,
        style: {
          'font-weight': 'bold'
        }
      });
      HStringView.nu([null,top,97,22,0,null],this.table,{
        value: str.component_table_component_descr,
        style: {
          'font-weight': 'bold'
        }
      });
      otop = top-5;
      top += 20;
      parent = HScrollView.nu([0,top-3,null,null,0,0],this.table,{scrollX:false,scrollY:true});
      for(;i<spec.length;i++){
        top = (i * 25)+2;
        c_spec = spec[i];
        c_info = component_db[c_spec.id];
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
        HStringView.nu( [100,top+3,135,20], parent, {
          value: c_spec.id,
          style: nowrap_style
        } );
        HStringView.nu([240,top+3,null,22,100,null],parent,{
          value: c_info.title,
          style: nowrap_style
        });
        if( c_info.datasheet ){
          this.PDFIcon.nu( [ null, top-2, 48, 24, 32, null ], parent, {
            href: c_info.datasheet
          } );
        }
        gridline = ELEM.make(parent.elemId); gridElems.push( gridline );
        ELEM.setCSS(gridline,'position:absolute;border-bottom:1px dotted #999;left:0px;top:'+(top+22)+'px;right:0px;height:1px;');
      }
      for(i=0;i<gridlines.length;i++){
        pos = gridlines[i];
        gridline = ELEM.make(this.table.elemId); gridElems.push( gridline );
        ELEM.setCSS(gridline,gridline_style+((pos>=0)?('left:'+pos):('right:'+(0-pos)))+'px;top:'+(otop+5)+'px;bottom:0px;width:1px;');
      }
      gridline = ELEM.make(this.table.elemId); gridElems.push( gridline );
      ELEM.setCSS(gridline,gridline_style+'left:0px;top:'+(otop+21)+'px;right:0px;height:1px;');
      this.gridElems = gridElems;
    }
  }),
  die: function(){
    if(this.componentView){ this.componentView.die(); }
    this.base();
  },
  origPos: [ 20, 20 ],
  click: function(){
    if( !this.componentView ){
      this.origPos[0]+=20;
      this.origPos[1]+=20;
      var
      opt = this.options,
      str = opt.strings,
      winSize = ELEM.windowSize(),
      winWidth = winSize[0],
      winHeight = winSize[1],
      height = 300;
      if(winWidth<this.origPos[0]+640){
        this.origPos[0]=20;
      }
      if( opt.spec.length > 6 ){
        height = (opt.spec.length*26)+100;
        if( height > winHeight ){
          height = winHeight-this.origPos[1];
          if( height < 300 ){
            this.origPos[1]-=300-height;
            height = 300;
          }
        }
        else if(height>winHeight-this.origPos[1]){
          this.origPos[1]=20;
        }
      }
      this.componentView = this.ComponentView.nu(
        [ this.origPos[0], this.origPos[1], 640, height ],
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
      console.log('this.componentView.options.closeButton => ',this.componentView.options.closeButton);
    }
  }
});