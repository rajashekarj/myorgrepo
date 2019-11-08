({
    doInit: function(component, event, helper) {
        // Fetch the account list from the Apex controller
        helper.getRelatedList(component);
        //debugger;
        
        var Helptext1 = component.get("c.HelpText");
        var FieldAPI = 'FS_DispRequested1__c';
        var isEmpty = $A.util.isEmpty(component.get("c.HelpText"));
        //debugger;
        if(!isEmpty){
            // Set up the callback
            Helptext1.setParams(
                { 
                    "FieldAPI" :  FieldAPI
                });
            Helptext1.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    component.set("v.FS_DispRequested1_Helptext", response.getReturnValue());
                }
            });
            
        }
        var Helptext2 = component.get("c.HelpText");
        var FieldAPI2 = 'FS_DispOrder1__c';
        var isEmpty2 = $A.util.isEmpty(component.get("c.HelpText"));
        //debugger;
        if(!isEmpty2){
            // Set up the callback
            Helptext2.setParams(
                { 
                    "FieldAPI" :  FieldAPI2
                });
            Helptext2.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    component.set("v.FS_DispOrder1_Helptext", response.getReturnValue());
                }
            });
           
        }
        $A.enqueueAction(Helptext1);
         $A.enqueueAction(Helptext2);
    }, 
})