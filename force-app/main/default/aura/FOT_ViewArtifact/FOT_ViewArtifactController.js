({
    
    doInit : function(component, event, helper) {
        
        var actionPublishArtifact = component.get("c.actionPublishArtifact");
        var actionRTArtifact = component.get("c.actionRTArtifact");        
        var actionRecordDetail = component.get("c.recordDetails"); 
        var actionProfileName = component.get("c.userProfileAccess"); 
        var checkDelete = component.get("c.checkDelete");
        
         checkDelete.setParams({
            recordId : component.get("v.recordId")
        });
        
        var purl=window.history;
        actionRecordDetail.setParams({
            recordId : component.get("v.recordId")
        });
        
        actionPublishArtifact.setParams({
            recordId : component.get("v.recordId")
        });
        
        actionRTArtifact.setParams({
            recordId : component.get("v.recordId")
        });
        
         actionRecordDetail.setParams({
            recordId : component.get("v.recordId")
        });
        
        checkDelete.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('isDeleteValue' +response.getReturnValue());
                component.set("v.isDelete", response.getReturnValue());
            }
        });
        
        actionPublishArtifact.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.pubRecordId", response.getReturnValue());
                if(response.getReturnValue() != null)
                    component.set("v.isPubArtifact","true");
            }
        });
        
        actionRTArtifact.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null)
                    component.set("v.artifactRT", response.getReturnValue());
            }
        });
        
         actionRecordDetail.setCallback(this, function(response){
            var state = response.getState();
             
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null)
                    component.set("v.arti", response.getReturnValue());
            }
        });
        
         actionProfileName.setCallback(this, function(response){
            var state = response.getState();
             
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null)
                    component.set("v.profile", response.getReturnValue());
            }
        });
        
        // Send queue of server-side controller action to be executed
        $A.enqueueAction(actionPublishArtifact);
        $A.enqueueAction(actionRTArtifact);
        $A.enqueueAction(actionRecordDetail);
        $A.enqueueAction(actionProfileName);
        $A.enqueueAction(checkDelete);
        var editsave=event.getParam("editsaveClick");
        component.set("v.editsaveClick",event.getParam("editsaveClick"));
    },
    clickCancel: function(component, event, helper) {
  
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "FS_Artifact__c"
        });
        homeEvt.fire();
     },
    navigateToEdit : function(component, event, helper) {
        var recordTyp = component.get('v.artifactRT');
        var recordIdVal;
        if(recordTyp == 'Published'){
            recordIdVal = component.get('v.pubRecordId');
        }else{
            recordIdVal = component.get('v.recordId'); 
        }
        component.set("v.editClick","true");
        
        var evt = $A.get("e.force:navigateToComponent");
       
        evt.setParams({
            componentDef : "c:FOT_ViewEditArtifact",
            componentAttributes: {
                recordId : recordIdVal,
                viewEdit : true
            }
        });
        evt.fire(); 
    },
    handleDeleteRecord: function(component, event, helper) {
       var recordId = component.get("v.recordId");
       var actionDelete=component.get("c.deleteArtifact");
         actionDelete.setParams({
                'recordId': recordId
            })
         actionDelete.setCallback(this, function(response) {
                //store state of response
                var state = response.getState();
             if (component.isValid() && state === "SUCCESS") {
                 if(response.getReturnValue()){
                      var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saved",
                    "type":"success",
                    "mode" : "pester",
                    "duration": 1000,
                    "message": "The record is deleted ."
                });
   
                resultsToast.fire();
                     
                     var homeEvt = $A.get("e.force:navigateToObjectHome");
                     homeEvt.setParams({
                         "scope": "FS_Artifact__c"
                     });
                     homeEvt.fire();
                 }
             }
         });
        // to queue the action to be executed
         $A.enqueueAction(actionDelete);
    },
    
   viewRuleFileFromAWS : function(component, event,helper){
        var ruleSetFile = component.get("v.arti").FS_Rule__c;
        var resultsToast = $A.get("e.force:showToast");
        if(ruleSetFile != undefined && ruleSetFile.includes('.DryRun.Rule.sql')){
            helper.viewRuleFileFromAWSHelper(component, event,'ruleSet');
        }else{
            console.log('ruleSetFile' + ruleSetFile);
            resultsToast.setParams({
                "title": "View File Error",
                "type":"error",
                "mode" : "pester",
                "duration": 1000,
                "message": "This is not a vaild file name or file doesn't exist ."
            });
            resultsToast.fire();
            return false;
        }  
    },
    
    viewOverrideRuleFileAWS : function(component, event,helper){
        var overRideRuleFile = component.get("v.arti").FS_Overide_Group_Rule__c;
        var resultsToast = $A.get("e.force:showToast");
        if(overRideRuleFile != undefined && overRideRuleFile.includes('.DryRun.OverrideRule.sql')){
            helper.viewRuleFileFromAWSHelper(component, event,'overRideRuleSet');
        }else{
            resultsToast.setParams({
                "title": "View File Error",
                "type":"error",
                "mode" : "pester",
                "duration": 1000,
                "message": "This is not a vaild file name or file doesn't exist ."
            });
            resultsToast.fire();
            return false;
        }  
    },
    
    handleEditSave : function(component, event, helper){
        var editsave=event.getParam("editsaveClick");
        component.set("v.editsaveClick",event.getParam("editsaveClick"));
    },
    
    setDeleteModal : function(component, event, helper){
        component.set('v.isDeleteArt', true);
    },
    
        closeModalEdit: function(component, event, helper) {
        component.set("v.isDeleteArt", false);
    }
    
})