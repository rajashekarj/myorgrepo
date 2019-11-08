({
    // Fetch the related details from the Apex controller
    getRelatedList: function(component) {
        var sURLVariables = component.get("v.recordId"); 
        //debugger;
        
        var isEmpty = $A.util.isEmpty(component.get("c.FSPlatformDetailsInstallationExtension"));
        var action = component.get("c.FSPlatformDetailsInstallationExtension");
        
        if(!isEmpty){
            // Set up the callback
            action.setParams(
                { 
                    "RecordId" :  sURLVariables
                });
            action.setCallback(this, function(response) {
                var state = response.getState();
            if (state === "SUCCESS"){
                   
                    component.set("v.Wrapper", response.getReturnValue());
                   
                }
            });
            $A.enqueueAction(action);
        }
    }  
})