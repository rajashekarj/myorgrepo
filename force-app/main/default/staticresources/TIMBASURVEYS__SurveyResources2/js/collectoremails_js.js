dojo.addOnLoad(init);

function init(){
    dojo.query('.tab').onclick(switchTab);

    dojo.query( dojo.query('.container .tab')[0] ).addClass('hideborderb');
    dojo.query( dojo.query('.container .tabtitle')[0] ).addClass('tabtitleopen');
    dojo.query( dojo.query('.container .mainfield')[0] ).removeClass('hide');
   
}

function switchTab(){
    dojo.query('.container .mainfield').addClass('hide');
    dojo.query('.container .tab').removeClass('hideborderb');
    dojo.query('.container .tabtitle').removeClass('tabtitleopen');

    dojo.query(this.parentNode).query('.mainfield').removeClass('hide');
    dojo.query(this.parentNode).query('.tab').addClass('hideborderb');
    dojo.query(this.parentNode).query('.tabtitle').addClass('tabtitleopen');
}
