({
    myAction : function(component, event, helper) {
        
    },    
    executeSearch: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-show");
        
        if( $A.util.isUndefinedOrNull(component.find("serialNum").get("v.value")) === false ){
            var action = component.get("c.searchDisp");
            action.setStorable();
            action.setParams({
                serialNum: component.find("serialNum").get("v.value")
            });
            
            action.setCallback(this, function(response) {                
                var state = response.getState();
                
                //if(component.isValid() && state === "SUCCESS" && response.getReturnValue().length > 0 ){
                if(component.isValid() && state === "SUCCESS" && !$A.util.isUndefinedOrNull(response.getReturnValue()) ){
                    if( response.getReturnValue().length > 0 ){
                        component.set("v.ODList",response.getReturnValue());
                        component.set("v.listFlag",true);
                        component.set("v.listNull",false);
                        $A.util.removeClass(spinner, "slds-show");
                    }else{
                        component.set("v.listFlag",false);
                        component.set("v.listNull",true);
                        $A.util.removeClass(spinner, "slds-show");
                    }               
                }
                else{
                    component.set("v.listFlag",false);
                    component.set("v.listNull",true);
                    $A.util.removeClass(spinner, "slds-show");
                }                
            });
            
            $A.enqueueAction(action);
        }
        else{
            component.set("v.listFlag",false);
            component.set("v.listNull",true);
            $A.util.removeClass(spinner, "slds-show");
        }        
        
    },
    waiting: function(component, event, helper) {
        //document.getElementById("Accspinner").style.display = "block";
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-show");
    },
    
    doneWaiting: function(component, event, helper) {
        //document.getElementById("Accspinner").style.display = "none";
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-show");
    }
})