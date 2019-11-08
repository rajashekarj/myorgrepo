dojo.require("dijit.ColorPalette");
dojo.addOnLoad(init);

function init(){
    var cp = new dijit.ColorPalette({
        palette: "7x10",
        onChange: function(color) {

            dojo.query('.divforecolor').style('background',color);
            dojo.query('.theme_previewer').style('color',color);

            var params = [];
            params.type = "theme_creator_fg_color";
            params.color = color;

            set_theme_attribute(params);
        },
        id: 'colorpickerselectorfore'
    },
    "colorselectorforeground");

    dojo.query("#colorpickerselectorfore").style("z-index", "10");
    dojo.query("#colorpickerselectorfore").style("display", "none");

    cp = new dijit.ColorPalette({
        palette: "7x10",
        onChange: function(color) {

            dojo.query('.divbackcolor').style('background',color);
            dojo.query('.theme_previewer').style('background',color);

            var params = [];
            params.type = "theme_creator_bg_color";
            params.color = color;

            set_theme_attribute(params);
        },
        id: 'colorpickerselectorback'
    },
    "colorselectorbackground");

    dojo.query('#colorpickerselectorback').style("z-index", "10");
    dojo.query("#colorpickerselectorback").style("display", "none");

    dojo.connect(dojo.byId('btnBackgroundColor'), 'onclick', showColorPickerBack);
    dojo.connect(dojo.byId('btnForegroundColor'), 'onclick', showColorPickerFore);

    dojo.connect(dojo.byId('font_family'),'onchange', function(){

        var params = [];
        params.type = "theme_fnt_family";
        params.font_family = document.getElementById('font_family').value;

        dojo.style(dojo.byId('theme_creator_preview'), 'fontFamily',params.font_family);

        set_theme_attribute(params);
    });

}

function showColorPickerBack(){
    dojo.query("#colorpickerselectorfore").style("display", "none");
    dojo.query("#btnForegroundColor").style("display", "inline-block");

    dojo.query("#colorpickerselectorback").style("display", "inline-block");
    dojo.query("#btnBackgroundColor").style("display", "none");
}
function showColorPickerFore(){
    dojo.query("#colorpickerselectorback").style("display", "none");
    dojo.query("#btnBackgroundColor").style("display", "inline-block");

    dojo.query("#colorpickerselectorfore").style("display", "inline-block");
    dojo.query("#btnForegroundColor").style("display", "none");
}


function set_theme_attribute(params){

    var ref = dojo.byId('theme_creator_preview');
    var ref_borders = dojo.byId('division_borders');
    var theme = SurveyThemes[active_theme_id];

    var item;

    switch(params.type){
        case 'theme_creator_fg_color':
            item = dojo.byId(params.type);
            ref.style.color = params.color;
            ref_borders.style.borderColor = params.color;
            theme.foreground_color = params.color;
            break;
        case 'theme_creator_bg_color':
            item = dojo.byId(params.type);
            ref.style.backgroundColor = params.color;
            theme.background_color = params.color;
            break;
        case 'theme_fnt_family':
            ref.style.fontFamily = params.font_family;
            theme.font_family = params.font_family;
            break;
        case 'theme_name':

            theme.name = params.theme_name;
            break;
        case 'attached_img':
            dojo.byId('theme_img').innerHTML = '<img src="../servlet/servlet.FileDownload?file='+params.img_id+'" />';
            theme.attachment_id = params.img_id;
            break;
    }
}
