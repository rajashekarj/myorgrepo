({
    doInit: function(component, event, helper) {
        
        var getArtifactTypeList = component.get("c.ArtifactTypeList");
        var getDependArtifactTypeList = component.get("c.dependArtifactTypeList");
        var getsecDependArtifactTypeList = component.get("c.secDependArtifactTypeList");
        var getLabelName=component.get("c.actionLabel");        
        //disabling Right click and F12 key
      //  document.addEventListener('contextmenu', event => event.preventDefault());
       /* document.onkeydown = function(e) {
            if(e.keyCode == 123) {                
                e.preventDefault();
            } 
        };*/
        //end of disabling Right click and F12 key
        
        getArtifactTypeList.setCallback(this, function(response3){
            var ArtifactType = response3.getState();
            if (ArtifactType === "SUCCESS") 
            {
                console.log("=== artifactTypeList ==== "+response3.getReturnValue());
                component.set("v.artifactTypeList" , response3.getReturnValue());
            } 
            
        });
        getDependArtifactTypeList.setCallback(this, function(response3){
            var state = response3.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.dependArtifactTypeList" , response3.getReturnValue());
            }
        });
        getsecDependArtifactTypeList.setCallback(this, function(response3){
            var state = response3.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.secDependArtifactTypeList" , response3.getReturnValue());
            }
        });
        
        getLabelName.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.label",response.getReturnValue());
            }
        });   
        $A.enqueueAction(getArtifactTypeList);
        $A.enqueueAction(getDependArtifactTypeList); 
        $A.enqueueAction(getsecDependArtifactTypeList);
        $A.enqueueAction(getLabelName);
    },
    
    handleUploadToAWS : function(component, event,helper){
        var ruleSetFile = component.get("v.ruleSetFileName");
        var resultsToast = $A.get("e.force:showToast");
        if(ruleSetFile != undefined && ruleSetFile != ''){
            helper.handleUploadToAWSHelper(component, event);
        }else{
            resultsToast.setParams({
                "title": "Upload fail",
                "type":"error",
                "mode" : "pester",
                "duration": 1000,
                "message": "Please select a file to upload."
            });
            resultsToast.fire();
            return false;
        }  
    },
    
    handleFilesChange : function(component, event)
    {
        var fileName =''; 
        var resultsToast = $A.get("e.force:showToast");
        var uploadFile = event.getSource().get("v.files")[0];
        var reader = new FileReader();
        reader.readAsText(uploadFile, "UTF-8");
        var allowedExtensions = /(\.txt|\.sql)$/i;
        if (event.getSource().get("v.files").length > 0 ) {
            fileName = event.getSource().get("v.files")[0]['name'];
            if(!allowedExtensions.exec(fileName)){
                resultsToast.setParams({
                    "title": "Upload Fail",
                    "type":"error",
                    "mode" : "pester",
                    "duration": 1000,
                    "message": "Please select a valid input file."
                });
                resultsToast.fire();
                component.set("v.ruleSetFileName", '');
                return false;
            }
            component.set("v.ruleSetFileName", fileName);
        }
        reader.onload = function (evt) { 
            var readContent = evt.target.result;
            component.set('v.ruleSetFileContent',readContent);
        }
    },
    
    handleSaveArtifact: function(component, event, helper) {
        component.set("v.spinner",true);
        var bundle=$A.get("$Label.c.FOT_Bundle");
        var stInstall=$A.get("$Label.c.FOT_SoftwareInstall");
        var fda=$A.get("$Label.c.FOT_FDA");
        var roundingRules=$A.get("$Label.c.FOT_RoundingRules");
        var setting=$A.get("$Label.c.FOT_Settings");
        
        //artifact form field names array
        var fieldsarr=["artifactName","artifactRank","artifactVersion","artifactType","artifactDepGroupRule","artifactRule"];
        var tempName, fieldId,validationstatus = true;
        var errfields=[];
        var errstr="";
        
        // based on artifact type value for required validation adding dependent field name to fieldsarr array 
        var artType = component.find("artifactType").get("v.value");
        if(artType === bundle || artType === stInstall || artType === fda || artType === roundingRules ){
            fieldsarr.push('artifactS3Path');
        } else if(artType === setting){
            fieldsarr.push('artifactSetting');
        }
        
        // Required field validation
        for(var i=0;i<fieldsarr.length;i++){
            fieldId=fieldsarr[i];
            tempName=component.find(fieldId).get("v.value");
            var msgtext;
            if( fieldsarr[i] == 'artifactSetting'){
                msgtext=$A.get("$Label.c.FOT_Settings_Update_Required_Message"); //"Settings Update is required if Artifact Type is Settings."
            }
            else{
                msgtext="Please enter a value for "+component.find(fieldId).get("v.label")+".";                                
            }
            
            if(tempName === undefined || tempName === null || tempName === '' || tempName =='--None--')
            {   
                component.find(fieldId).set("v.errors", [{message:msgtext}]);
                errfields.push(component.find(fieldId).get("v.label"));
                validationstatus = false;                
            }
            else {
                component.find(fieldId).set("v.errors", null);
            }
        }
        
        // Ruleset lookup required error
        if(component.get("v.selectedLookUpRecord").Id != undefined){
            $("#artifactRuleset").removeClass("slds-show");
            $("#artifactRuleset").addClass("slds-hide");
        }else{            
            $("#artifactRuleset").removeClass("slds-hide");
            $("#artifactRuleset").addClass("slds-show");
            errfields.push("Rule set");
            validationstatus = false;
        }
        // End Ruleset lookup required error
        
        // Concatinating required field names and adding field names string to required error message.
        if( errfields.length > 0){
            for(var k=0;k<errfields.length;k++){
                
                if(k == errfields.length-1){
                    errstr=errstr+errfields[k]+".";
                }
                else if(k <= errfields.length){
                    errstr=errstr+errfields[k]+", ";
                }
            }
            console.log("Input Required .... notifLib");
            component.set("v.spinner",false);
            // Enable 'notifLib' notification and set nitification attribute values
            component.find('notifLib').showNotice({
                "variant":"error",
                "header": "Input Required",
                "message":"Please enter a value(s) for "+errstr ,
            });
            //End of error notification
            
        }
        // End of required error message.
        component.find("artifactName").focus();
        //component.set("v.atType",null);
        // On successfull client side validations, sending A5 validation api request
        if(validationstatus == true)
        {   
            console.log('atType initial '+component.get("v.atType"));
            var artObj = component.get("v.simpleNewArtifact");
            component.set("v.spinner",true);
            component.set("v.fromSave",true);//set to "True" if it is invoke on click of "Save" button
            if(component.get("v.selectedLookUpRecord").Id != undefined){
                
                artObj.FS_Ruleset__c = component.get("v.selectedLookUpRecord").Id;
            } 
            
            if(component.find("depArtifactType").get("v.value")=="--None--")
            {
                artObj.FS_Dependency_Artifact_Type__c='';
            }
            if(component.find("secDepArtifactType").get("v.value")=="--None--")
            {
                artObj.Second_Dependency_Artifact_Type__c='';
            }
            
            /*if(artObj.FS_Artifact_Type__c ==setting)
            {
                artObj.FS_UUID__c="";
                console.log('inside create st null '+artObj.FS_UUID__c);
            }*/
            console.log('inside create st null '+artObj.FS_UUID__c);
            //to validate Artifact Type value
            helper.helperArtifactType(component,event, false); 
            //to validate Rank field value
            helper.helpervalidateRank(component,event); 
            console.log('atType value in create '+component.get("v.atType"));
            helper.validateVersion(component, event, false);
            
            // Artifact type and version error notifications for save button click
            
            // Merging artifact type and version error messages
            var valErrMsg=component.get("v.arttypeErrMsg")+"/n"+component.get("v.verErrMsg");
            
            if( component.get("v.atType") || component.get("v.artVersion") ){
                var valErrMsg=component.get("v.arttypeErrMsg")+"\n"+component.get("v.verErrMsg");
                console.log("=== notifLib === "+valErrMsg);
                component.find('notifLib').showNotice({
                            "variant":"error",
                            "header": "Input Required",
                            "message":valErrMsg,
                        });
                component.set("v.spinner",false);
            }
            
        }
        
        console.log(" --- handleSaveArtifact selectedLookUpRecord ---"+component.get("v.selectedLookUpRecord"));
    },
    // Validate artifact type on it's value change
    checkVersion: function(component, event, helper){ 
        helper.validateVersion(component, event, true);        
    },
    checkValue: function(component, event, helper){ // Validate artifact type on it's value change
        var bundle=$A.get("$Label.c.FOT_Bundle");
        var stInstall=$A.get("$Label.c.FOT_SoftwareInstall");
        var fda=$A.get("$Label.c.FOT_FDA");
        var roundingRules=$A.get("$Label.c.FOT_RoundingRules");
        var setting=$A.get("$Label.c.FOT_Settings");
        
        var artType = component.find("artifactType").get("v.value");
        component.set("v.artifactType",artType);
        
        component.set("v.fromSave",false);//to check if it is invoked from save button
        
        if(artType === bundle || artType === stInstall|| artType === fda || artType === roundingRules ){
            helper.helperDisableField(component,event,"artifactSetting","artifactS3Path");
        } else if(artType === setting){
            helper.helperDisableField(component,event,"artifactS3Path","artifactSetting");
        } else {
            component.find("artifactS3Path").set("v.disabled", false);
            component.find("artifactSetting").set("v.disabled", false);
            
            component.find("artifactS3Path").set("v.errors", null);
            component.find("artifactSetting").set("v.errors", null);
        }
        
        if(component.get("v.selectedLookUpRecord").Id != undefined && artType!='--None--' )
        {
            helper.helperArtifactType(component,event,true);
        }
        
    },
    //Close modal popup
    closeModal: function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    // Saving after artifact success validation
    toSave :  function(component, event, helper) {
        var artifact= component.get("v.simpleNewArtifact");
        component.set("v.isOpen", false);
        component.set("v.spinner",true);
        
        console.log(" --- toSave selectedLookUpRecord ---"+component.get("v.selectedLookUpRecord"));
        var actionSave=component.get("c.saveArtifact");
        actionSave.setParams({
            'artifact': artifact
        })
        
        actionSave.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {   
                component.set("v.spinner",false);
                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saved",
                    "type":"success",
                    "mode" : "pester",
                    "duration": 1000,
                    "message": "Record Created."
                });
                resultsToast.fire();   
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId":  artifact.FS_Ruleset__c  
                });
                navEvt.fire(); 
                
            }else{
                console.log('Record Fail');
            }
        });
        $A.enqueueAction(actionSave);
        
    },
    handleCancel: function(component, event, helper) { // On clcik of Cancel button navigate to the respecitve page
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "FS_Artifact__c"
        });
        homeEvt.fire();
        
    },
    validateRank : function(component, event, helper) {
        var rankErrMsg=$A.get("$Label.c.FOT_Rank_Length_Error"); // Maximum length of Rank field is 10 digits only...
        helper.helpervalidateRank(component,event);
        console.log('artRank '+component.get("v.artRank"));
        if(component.get("v.artRank")){
            component.find("artifactRank").set("v.errors", [{message:rankErrMsg}]);
            component.find('notifLib').showNotice({
                "variant":"error",
                "header": "Rank Length Error",
                "message":rankErrMsg,
            }); 
        }
        
    }
    
})