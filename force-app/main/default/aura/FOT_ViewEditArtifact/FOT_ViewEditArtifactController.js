({
  
    doInit : function(component, event, helper) {
        var actionPublishArtifact = component.get("c.actionPublishArtifact");
        var actionRTArtifact = component.get("c.actionRTArtifact");
        //var actionValidArtifact=component.get("c.actionValidArtifact");
        var actionProfileAccess = component.get("c.userProfileAccess");
       
        actionPublishArtifact.setParams({
            recordId : component.get("v.recordId")
        });
        
        actionRTArtifact.setParams({
            recordId : component.get("v.recordId")
        });
        
      /*  actionValidArtifact.setParams({
            recordId : component.get("v.recordId")
        });*/
        
        actionPublishArtifact.setCallback(this, function(response) {
            console.log('actionPublishArtifact');
            var state = response.getState();
            console.log('component.isValid()' + component.isValid());
            console.log('state' + state);
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.pubRecordId", response.getReturnValue());
                if(response.getReturnValue() != null)
                    component.set("v.isPubArtifact","true");
            }
            else{
                console.log("Failed with state: actionPublishArtifact " + state);
                component.set("v.isPubArtifact","false");
            }
        });
        
        actionRTArtifact.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null)
                    component.set("v.artifactRT", response.getReturnValue());
            }
            else{
                console.log("Failed with state actionRTArtifact " + state);
            }
        });
      
        /*actionValidArtifact.setCallback(this, function(response){
            console.log('actionValidArtifact'+response.getReturnValue());
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null)
                    component.set("v.valid", response.getReturnValue());
            }
            else{
                console.log("Failed with state valid " + state);
            }
        });*/
        
         actionProfileAccess.setCallback(this, function(response){
           
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('profile '+response.getReturnValue());
                if(response.getReturnValue() != null)
                    component.set("v.profileAccess", response.getReturnValue());
            }
            else{
                console.log("Failed with state valid " + state);
            }
        });
        
        // Send queue of action to be executed
        $A.enqueueAction(actionPublishArtifact);
        $A.enqueueAction(actionRTArtifact);
        //$A.enqueueAction(actionValidArtifact);
         $A.enqueueAction(actionProfileAccess);
    },
    changeEditLayout : function(component, event, helper) {
        component.set("v.isEditPage", true);
        helper.removeDivider();
        helper.removeEditIcon();
    },
    clickCancel : function(component, event, helper) {
        // component.set("v.isEditPage", false);
        //	helper.addDivider();
        //   helper.addEditIcon();
        $A.get('e.force:refreshView').fire();
    },
    clickSave : function(component, event, helper){
        helper.saveRecord(component, event, 'save');
        component.set("v.isEditPage", false);
        helper.addDivider();
        helper.addEditIcon(); 
        $A.get('e.force:refreshView').fire();
    },
    save : function(component, event ,helper) {
        // Save the record
        var artfactType = component.get("v.artifactRT");
        //var validValue=component.get("v.valid");
            
            if(artfactType == 'Dry Run'){
                component.find("editDryRun").get("e.recordSave").fire();
        }else if(artfactType == 'Published'){
        component.find("editPublish").get("e.recordSave").fire();
    		}
        var com = component;
        var record = component.find("editPublish");      
    },
    handleSaveSuccess : function(component, event) {
        // Display the save status
        $A.get('e.force:refreshView').fire();
    },
    clickCancel : function(component, event, helper){
        history.back();
    }
})