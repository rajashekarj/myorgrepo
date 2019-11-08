dojo.addOnLoad(add_switch_behavior);

function add_switch_behavior(){
    dojo.query('a.switch').onclick(function(e){
        dojo.toggleClass(this,'on');
    });

    dojo.query('#response').onmouseover(function(e){
        dojo.query('#response').attr('class','fieldTitleC');
        dojo.query('#responsed').attr('class','content fieldTitleB');
    });

    dojo.query('#response').onmouseleave(function(e){
        dojo.query('#response').attr('class','fieldTitle');
        dojo.query('#responsed').attr('class','content');
    });

}
