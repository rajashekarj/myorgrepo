({
	render: function(component, helper) {
     //  console.log('render');
        var title1=document.title;
        component.set("v.titleValue",title1);
  
	    var timer;var cleared=false;
        
        //set interval for the first time when user is in same tab
       timer=window.setInterval( $A.getCallback(function() {
                 // console.log('call method');
                  helper.callApexMethod(component)
       			 }), 500); 
        
     var title = component.get("v.titleValue");
     
    //check if the user is in current tab or other tab by checking document's title 
    document.addEventListener('mouseover', function(e) {
               // console.log(document.title);
               // console.log(title);

        //if title of current tab and installation's title is equal resume the setinterval else if user navigated in same tab clear interval
        if(title===document.title){
           // console.log('cleared:'+cleared);
            if(cleared==true){
            timer=window.setInterval( $A.getCallback(function() {
                //  console.log('call method');
                  helper.callApexMethod(component)
       			 }), 500); 
       			 cleared=false;
            }
        }
        else{
            clearInterval(timer);
            cleared=true;
           // console.log('cleared:'+cleared);
        }
    })
    
			var checkFocus = function() {
           // console.log(document.hasFocus());
            if( document.hasFocus() ){
                if(cleared==true){
                    //execute callApexMethod() again after 5 millisec each
                    timer=window.setInterval( $A.getCallback(function() {
            //            console.log('call method');
                        helper.callApexMethod(component)
                    }), 500); 
                    cleared=false;
                }
            }
            else{
                //clear interval when user is in other tab
                clearInterval(timer);
                cleared=true;
            }


}
checkFocus(); // init

//listeners to check if the user is in current tab or other tab
window.addEventListener("focus", checkFocus);
window.addEventListener("blur", checkFocus);
 
        
           		//execute callApexMethod() again after 5 millisec each
          /*		window.setInterval( $A.getCallback(function() {
                    var title = component.get("v.titleValue");
                    console.log("enters interval");  
                    console.log('hasfocus'+document.hasFocus());
                    if(document.hasFocus() && title===document.title){                        
                        console.log('call Apex method');
                        helper.callApexMethod(component)
                    }
       			 }), 500); */
            

       return this.superRender()
    },
})