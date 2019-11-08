({
    doInit : function(component, event, helper) {
        component.set("v.spinner",true);
        
        // Fetching OD Settings Readonly record id and setting it to 'ODrecordId' component attribute 
        var ODEDitableSettingsRecordDetails = component.get("c.ShowHideRecordDetails");
        
        ODEDitableSettingsRecordDetails.setParams({
            recordId : component.get("v.recordId")
        });
        
        ODEDitableSettingsRecordDetails.setCallback(this, function(response){
            var state = response.getState();
            console.log('calling record Id Check');
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.spinner",false);
                if(response.getReturnValue() != null){
                    console.log('response return values are::');
                    component.set("v.odShowHideList", response.getReturnValue()); //Setting od readonly record id to component attribute                     
                    setTimeout(function()
                     { 
                         var ec = component.find("odreadDiv");
                         $A.util.removeClass(ec, 'slds-hide');
                     }, 1000);
                }else{
                    var showHideNoRecs = component.find("showHideNoRec");
                    $A.util.removeClass(showHideNoRecs, 'slds-hide');
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