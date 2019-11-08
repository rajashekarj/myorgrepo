({
    doInit : function(component, event, helper) {
        component.set("v.spinner",true);
        
        // Fetching OD Settings Readonly record id and setting it to 'ODrecordId' component attribute 
        var ODEDitableSettingsRecordDetails = component.get("c.ODEDitableSettingsRecordDetails");
        
        ODEDitableSettingsRecordDetails.setParams({
            recordId : component.get("v.recordId")
        });
        
        ODEDitableSettingsRecordDetails.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null){
                    component.set("v.ODSettingEditableRecordId", response.getReturnValue()); //Setting od readonly record id to component attribute                     
                    setTimeout(function()
                               { 
                                   var ec = component.find("odreadDiv");
                                   $A.util.removeClass(ec, 'slds-hide');
                                   component.set("v.spinner",false);
                               }, 1000);
                }          
            }
            else{
                console.log("Failed with state ODSettingsRecordDetails " + state);                
            }
            
        });
        
        $A.enqueueAction(ODEDitableSettingsRecordDetails);
        
        
    },
    handleSaveSuccess : function(component, event) {
        // Display the save status
        $A.get('e.force:refreshView').fire();
    }
    
})