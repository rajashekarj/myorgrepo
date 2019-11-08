({
    doInit : function(component, event, helper) {
        component.set("v.spinner",true);
        
        var ODSettingsRecordDetails = component.get("c.ODSettingsRecordDetails");
        var actionProfileAccess = component.get("c.userProfileAccess");
        
        // Fetching OD Settings record id and setting it to 'ODrecordId' component attribute 
        ODSettingsRecordDetails.setParams({
            recordId : component.get("v.recordId")
        });
        
        ODSettingsRecordDetails.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null)
                    component.set("v.ODrecordId", response.getReturnValue());
                setTimeout(function()
                           { 
                               var ec = component.find("odreadDiv");
                               $A.util.removeClass(ec, 'slds-hide');
                               component.set("v.spinner",false);
                           }, 800);
            }
            else{
                console.log("Failed with state ODSettingsRecordDetails " + state);
            }
        });
        
        // Fetching logged in user profile and setting it to 'profileAccess' component attribute
        actionProfileAccess.setCallback(this, function(response){
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('profile '+response.getReturnValue());
                if(response.getReturnValue() != null)
                    component.set("v.profileAccess", response.getReturnValue());
                console.log('response'+response.getReturnValue());
            }
            else{
                console.log("Failed with state valid " + state);
            }
        });
        
        $A.enqueueAction(ODSettingsRecordDetails);// server call for getting user profile
        $A.enqueueAction(actionProfileAccess); // server call for getting user profile
        
    },
    
    handleSaveSuccess : function(component, event) {
        // Display the save status
        $A.get('e.force:refreshView').fire();
    },	
    
    // opens OD settings standard edit popup 
    navigateToEdit : function(component, event, helper) {
        var recordIdVal = component.get("v.ODrecordId");
        var editRecordEvent = $A.get("e.force:editRecord"); // Calling standard record edit view 
        editRecordEvent.setParams({
            "recordId": component.get("v.ODrecordId") // Passing recirdid to the record edit view
        });
        editRecordEvent.fire(); // Opens record edit popup
        
    }
})