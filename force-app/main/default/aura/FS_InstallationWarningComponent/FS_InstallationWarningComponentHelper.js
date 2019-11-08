(  {
    
    pollApex : function(component,event,helper) { 
        helper.callApexMethod(component);
        
    },
    
    
    callApexMethod : function (component){    
       // debugger;
        var sPageURL = window.location.href;
        var sURLVariables = component.get("v.recordId"); 
        
       // debugger;
        var CallApex = component.get("c.checkBrandsetAndSyncValues");
        var isEmpty = $A.util.isEmpty(component.get("c.checkBrandsetAndSyncValues"));
        
        //alert(CallApex);
        if(!isEmpty){
            
            CallApex.setParams(
                { 
                    "RecID" :  sURLVariables
                });
            CallApex.setCallback(this, function(response) {
                //  var state = a.getState();
                if ( response.getState() == "SUCCESS") {
                    component.set("v.objCnt", response.getReturnValue());			
                    
                }            
            });       
            $A.enqueueAction(CallApex);
            
            
        }
        
    }
})