({
    doInit : function(component, event, helper) {
        
        //disabling Right click and F12 key
        document.addEventListener('contextmenu', event => event.preventDefault());
        document.onkeydown = function(e) {
            if(e.keyCode == 123) {                
                e.preventDefault();
            } 
        };
        //end of disabling Right click and F12 key
        
        //custom labels 
        var opsAdmin=$A.get("$Label.c.FOT_Operations_Admin");
        var opsAnalyst=$A.get("$Label.c.FOT_Operations_Analyst");
        var sysAdmin=$A.get("$Label.c.FOT_System_Administrator");
        var bundle=$A.get("$Label.c.FOT_Bundle");
        var stInstall=$A.get("$Label.c.FOT_SoftwareInstall");
        var fda=$A.get("$Label.c.FOT_FDA");
        var roundingRules=$A.get("$Label.c.FOT_RoundingRules");
        var setting=$A.get("$Label.c.FOT_Settings");
        
        //to enable/disable the form fields based on the logged user's profile
        var actionProfileAccess = component.get("c.userProfileAccess");
        var userProfile;
        
        actionProfileAccess.setCallback(this, function(response){
            //artifact form field names array
            var fieldsarr=["name","rank","version","minVersion","breakVersion","rule","overrideRule"];
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                if(response.getReturnValue() != null){
                    component.set("v.profileAccess", response.getReturnValue());
                    if(response.getReturnValue() == opsAdmin ||response.getReturnValue() == sysAdmin){
                        for(var i=0;i<fieldsarr.length;i++){
                            component.find(fieldsarr[i]).set("v.disabled",false);
                        } 
                        
                    }
                    userProfile=response.getReturnValue();
                    if(response.getReturnValue() == opsAdmin || response.getReturnValue() == opsAnalyst || response.getReturnValue() == sysAdmin ){
                        component.find("enabled").set("v.disabled",false);
                        component.find("groupRule").set("v.disabled",false);
                        component.find("overrideRule").set("v.disabled",false);
                        
                        component.find("saveBtn").set("v.disabled",false);

                    }     
                }
            }
            else{
                console.log("Status" + state);
            }
        });
        
        //to fetch the artifact record details inorder to display it onload of the form
        var recordId=component.get("v.recordId");
        var actionGetRecordDetails=component.get("c.recordDetails");
        var getVal = component.get("v.profileAccess");
        
        if(getVal == opsAdmin || getVal == opsAnalyst){
            component.find("enabled").set("v.disabled",false);
        }
        
        actionGetRecordDetails.setParams({
            recordId : recordId
        });
        
        actionGetRecordDetails.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() != null)             
                    component.set("v.artifact",response.getReturnValue());
                
                var arti= component.get("v.artifact");
                var artUUID=arti.FS_UUID__c;
                component.set("v.artifactEnabled",arti.FS_Enabled__c);
                component.set("v.artifactType",arti.FS_Artifact_Type__c);
                component.set("v.recordTypeId",response.getReturnValue().RecordTypeId);
                
                //On load disable / enable s3path & settings update fields based on Artifact type value
                if(arti.FS_Artifact_Type__c === bundle || arti.FS_Artifact_Type__c === stInstall || arti.FS_Artifact_Type__c === fda || arti.FS_Artifact_Type__c === roundingRules ){
                    component.find("settings").set("v.disabled", true);
                    component.find("s3path").set("v.required", true);
                } else if(arti.FS_Artifact_Type__c === setting){
                    component.find("s3path").set("v.disabled", true);
                    component.find("settings").set("v.required", true);
                   //component.find("artUUID").set("v.value", null);//to nullify UUID value
                }
                console.log('UUID in edit '+arti.FS_UUID__c);
                //field access for Operation Admin profile
                if(userProfile == opsAdmin ){ 
                    component.find("depArtType").set("v.disabled", false);
                    //for Active artifact record
                    if(arti.FS_Enabled__c)
                    {
                        component.find("s3path").set("v.disabled",true);
                        component.find("version").set("v.disabled",true);
                        component.find("name").set("v.disabled",true);
                        component.find("settings").set("v.disabled", true);
                    }
                    else
                    {
                        if(arti.FS_Artifact_Type__c === bundle || arti.FS_Artifact_Type__c === stInstall || arti.FS_Artifact_Type__c === fda || arti.FS_Artifact_Type__c === roundingRules ){
                            helper.helperDisableField(component,event,"settings","s3path");                           
                        } else if(arti.FS_Artifact_Type__c === setting){                            
                            helper.helperDisableField(component,event,"s3path","settings");
                        }else{
                            component.find("s3path").set("v.value", "");
                            component.find("settings").set("v.value", "");
                            component.find("s3path").set("v.disabled", true);
                            component.find("settings").set("v.disabled", true);
                        }
                    }
                    
                }
                //if a Published artifact is associated
                if(arti.FS_Published_Artifact__c!=null)
                {
                    var actionPublishActive=component.get("c.actionPublishActive");
                    
                    actionPublishActive.setParams({
                        recordId : arti.FS_Published_Artifact__c
                    });
                    actionPublishActive.setCallback(this, function(response) {
                        var state = response.getState();
                        
                        if (component.isValid() && state === "SUCCESS" && ( userProfile === opsAdmin || userProfile === sysAdmin ) ) {
                            //if Artifact is active in both areas
                            if(response.getReturnValue()==true && arti.FS_Enabled__c)
                            {
                                component.find("version").set("v.disabled",true);
                                component.find("s3path").set("v.disabled",true);
                                component.find("name").set("v.disabled",true);
                                component.find("settings").set("v.disabled", true);
                            }
                            //if artifact is active in either dry run or published area
                            else if(response.getReturnValue()==true || arti.FS_Enabled__c) 
                            {
                                component.find("version").set("v.disabled",true);
                                component.find("s3path").set("v.disabled",true);
                                component.find("name").set("v.disabled",true); 
                                component.find("settings").set("v.disabled", true);
                            }
                            
                            
                        }
                    });
                    $A.enqueueAction(actionPublishActive);
                }
                
            }
            else{
                console.log("Failed with state: actionGetRecordDetails " + state);
            }
            
            
        });
        
        //to display dependency artifact type field values
        var actionDependencyType=component.get("c.getDependArtifactTypeValues");
        
        actionDependencyType.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("v.dependArtifactTypeValues",response.getReturnValue());
                var opts = [{"class":"optionClass" , label:"--None--" , value:""}];
                var dependencyList=component.get("v.dependArtifactTypeValues");
                for(var i=0;i<dependencyList.length;i++)
                {
                    if(dependencyList[i]===component.get("v.artifact").FS_Dependency_Artifact_Type__c)
                    {
                        opts.push({"class":"optionClass" , label:dependencyList[i] , value:dependencyList[i] , selected: "true"});
                    }
                    else
                    {
                        opts.push({"class":"optionClass" , label:dependencyList[i] , value:dependencyList[i]});
                    }
                }
                component.find("depArtType").set("v.options", opts);
            }
        });
        
        var actionSecondDependencyType=component.get("c.getSecondDependArtifactTypeValues");
        actionSecondDependencyType.setCallback(this, function(response) {
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.secDependArtifactTypeList",response.getReturnValue());
            }
        });
        
        //to get lookup field label name - FS_Ruleset__c
        var getLabelName=component.get("c.actionLabel");
        getLabelName.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                component.set("v.label",response.getReturnValue());
            }
        });
        
        //to put all server-side controller actions into a queue of action to be executed
        $A.enqueueAction(actionProfileAccess);
        $A.enqueueAction(actionGetRecordDetails);
        $A.enqueueAction(actionDependencyType);
        $A.enqueueAction(actionSecondDependencyType);
        $A.enqueueAction(getLabelName); 
        
    },
    handleComponentEvent : function(component, event, helper){
        var recordId = event.getParam("recordId");
        component.set("v.recordId", recordId);      
    },
    //to navigate to previous page
    clickCancel: function(component, event, helper) {
        var viewEdit = component.get("v.viewEdit");    
        if(!viewEdit){    
            window.history.back();    
        }else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:FOT_ViewEditArtifact",
                componentAttributes: {
                    recordId : componet.get("v.recordId"),
                    editClick : true
                }
            });
            evt.fire(); 
        }
    },
    S3change:function(component, event, helper){ // Clear UUID value on change of S3Path...        
        component.find("artUUID").set("v.value", "");
    },
    
    handleUploadToAWS : function(component, event,helper){
        var ruleSetFile = component.get("v.ruleSetFileName");
        var resultsToast = $A.get("e.force:showToast");
        if(ruleSetFile != undefined && ruleSetFile != ''){
            helper.handleUploadToAWSHelper(component, event,'ruleSet');
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
    
   	 viewRuleFileFromAWS : function(component, event,helper){
        var ruleSetFile = component.get("v.artifact").FS_Rule__c;
        var resultsToast = $A.get("e.force:showToast");
        if(ruleSetFile != undefined && ruleSetFile.includes('.DryRun.Rule.sql')){
            console.log('inside helper ');
            helper.viewRuleFileFromAWSHelper(component, event,'ruleSet');
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
    
     viewOverRideRuleFileFromAWS : function(component, event,helper){
        var overRideruleFile = component.get("v.artifact").FS_Overide_Group_Rule__c;
        var resultsToast = $A.get("e.force:showToast");
        if(overRideruleFile != undefined && overRideruleFile.includes('.DryRun.OverrideRule.sql')){
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
    
    handleOverRideRuleUploadToAWS : function(component, event,helper){
        var ruleSetFile = component.get("v.overRideRuleSetFileName");
        var resultsToast = $A.get("e.force:showToast");
        if(ruleSetFile != undefined && ruleSetFile != ''){
            helper.handleUploadToAWSHelper(component, event,'overRideRuleSet');
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
                component.set("v.ruleFileName", 'No File Selected..');
                return false;
            }
            var fileNa = component.get("v.artifact").FS_UUID__c;
            component.set("v.ruleFileName", fileName);
            fileNa = fileNa + '.DryRun.Rule.sql';
            component.set("v.ruleSetFileName", fileNa);
        }
        
        reader.onload = function (evt) { 
            var readContent = evt.target.result;
            component.set('v.ruleSetFileContent',readContent);
        }
        
    },
    
    handleFilesChangeOverRideRule : function(component, event)
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
                component.set("v.overRideRuleSetFileName", '');
                component.set("v.overRideFileName", 'No File Selected..');
                return false;
            }
            var fileNa = component.get("v.artifact").FS_UUID__c;
            component.set("v.overRideFileName", fileName);
            fileNa = fileNa + '.DryRun.OverrideRule.sql';
            component.set("v.overRideRuleSetFileName", fileNa);
        }
        
        reader.onload = function (evt) { 
            var readContent = evt.target.result;
            component.set('v.overRideRuleSetFileContent',readContent);
        }
        
    },
    
    settingsChange :function(component, event, helper){ // Clear UUID value on change of Settings Update...        
        component.find("artUUID").set("v.value", "");
    },
    
    //to validate the values given in the edit mode
    clickSave:function(component, event, helper) {
        var bundle=$A.get("$Label.c.FOT_Bundle");
        var stInstall=$A.get("$Label.c.FOT_SoftwareInstall");
        var fda=$A.get("$Label.c.FOT_FDA");
        var roundingRules=$A.get("$Label.c.FOT_RoundingRules");
        var setting=$A.get("$Label.c.FOT_Settings");
        
        var artifact = component.get("v.artifact");
        
        var artType = component.find("artType").get("v.value");
       
        var error = false;
        var fieldsarr=["name","rank","version","groupRule","rule"]; // Field names array from edit form
        var tempName, fieldId,validationstatus = true;
        
        var errfields=[];
        var errstr="";
        
        var artType = component.find("artType").get("v.value");
        if(artType === bundle || artType === stInstall || artType === fda || artType === roundingRules){
            fieldsarr.push('s3path');
        } else if(artType === setting){
            fieldsarr.push('settings');
        }
        
        for(var i=0;i<fieldsarr.length;i++){
            fieldId=fieldsarr[i];
            tempName=component.find(fieldId).get("v.value");
            var msgtext;
            //to show error message if any required field is empty
            if( fieldsarr[i] == 'settings'){
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
                error =  true;
            }
            else {
                component.find(fieldId).set("v.errors", null);
            }
        } 
        //to get the fields valued from the component
        artifact.Id=component.get("v.recordId");
        artifact.FS_Enabled__c=component.find("enabled").get("v.value");
        artifact.Second_Dependency_Artifact_Type__c = component.find("secDepArtifactType").get("v.value");
        artifact.Name=component.find("name").get("v.value");
        artifact.FS_Rank__c=component.find("rank").get("v.value");
        artifact.FS_Version__c=component.find("version").get("v.value");
        artifact.FS_Dependency_M_in_Version__c=component.find("minVersion").get("v.value");
        artifact.DependancyBreakVersion__c=component.find("breakVersion").get("v.value");
        artifact.FS_Deployment_Group_Rule__c=component.find("groupRule").get("v.value");
        artifact.FS_Rule__c=component.find("rule").get("v.value");
        artifact.FS_Overide_Group_Rule__c=component.find("overrideRule").get("v.value");
        artifact.FS_S3Path__c=component.find("s3path").get("v.value");
        artifact.Settings_Update__c=component.find("settings").get("v.value"); 
           if(artifact.FS_UUID__c === undefined || artifact.FS_UUID__c === null || artifact.FS_UUID__c === '')
            {
                artifact.FS_UUID__c='';
            }
        if(artifact.Second_Dependency_Artifact_Type__c === undefined || artifact.Second_Dependency_Artifact_Type__c === null || artifact.Second_Dependency_Artifact_Type__c === '--None--'){
            artifact.Second_Dependency_Artifact_Type__c ='';
        }
        artifact.FS_Dependency_Artifact_Type__c=component.find("depArtType").get("v.value");
        if( errfields.length > 0){
            for(var k=0;k<errfields.length;k++){
                
                if(k == errfields.length-1){
                    errstr=errstr+errfields[k]+".";
                }
                else if(k <= errfields.length){
                    errstr=errstr+errfields[k]+", ";
                }
            }
            component.find('notifLibEdit').showNotice({ // Show 'notifLibEdit' notification and set nitification attribute values
                "variant":"error",
                "header": "Input Required",
                "message":"Please enter a value(s) for "+errstr ,
            });
        }
        
        helper.validateVersion(component, event, false);
        
        if(!error && component.get("v.artVersionValid") ){
            var artifactRec=component.get("v.artifact");
            
            //to invoke Validation API on save
            var actionWeb=component.get("c.actionWebCall");
            
            component.set("v.spinner",true);
            
            actionWeb.setParams({
                'artifactRec': artifactRec
            })
            
            actionWeb.setCallback(this, function(response) {
                //store state of response
                var state = response.getState();
                
                
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.spinner",false);
                    
                    if(response.getReturnValue()!=null)
                    {
                        //if any validation fails
                        if(!response.getReturnValue().valid)
                        {
                            component.find('notifLibEdit').showNotice({ // Show 'notifLibEdit' notification and set nitification attribute values
                                "variant":"error",
                                "header": "Validation Error",
                                "message":response.getReturnValue().message ,
                            });  
                        }
                        //to display the success response message
                        else
                        {  
                            component.set("v.isOpen", true);
                            component.set("v.responseMsg",response.getReturnValue().message);
                        }
                    }
                    
                }else{  
                    component.set("v.spinner",false);
                    component.find('notifLibEdit').showNotice({ // Show 'notifLibEdit' notification and set nitification attribute values
                        "variant":"error",
                        "header": "Validation Error",
                        "message":response.getReturnValue() ,
                    });  
                }
            });
             //to queue up the server side controller actions
            $A.enqueueAction(actionWeb);
        }
        else
        {
            component.set("v.spinner",false);
        }
        
    },
    closeModalEdit: function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    //to finaly update the artifact with new values 
    toSaveEdit :  function(component, event, helper) {
        var artObj=component.get("v.artifact");
        artObj.Id=component.get("v.recordId");
        
        component.set("v.valuechanged",true);
        
        component.set("v.isOpen", false);
        component.set("v.spinner",true);
        //to update the artifact record
        var actionSaveEdit=component.get("c.updateArtifact");
        var valchange=component.get("v.valuechanged");
        
        actionSaveEdit.setParams({
            'artObj': artObj,
            'valchange' : valchange
        })
        
        actionSaveEdit.setCallback(this, function(response) {
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
                    "message": "The record was updated."
                });
                
                resultsToast.fire();
                
                //after save navigate to Ruleset detail page
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId":  artObj.FS_Ruleset__c  
                });
                navEvt.fire();
                
            }else{
                
                component.set("v.spinner",false);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Not Saved",
                    "type":"error",
                    "mode" : "pester",
                    "duration": 1000,
                    "message": "The record was not updated."
                });
                
                resultsToast.fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId":  artObj.FS_Ruleset__c,
                    
                });
                navEvt.fire(); 
            }
        });
        //to queue up the server side controller actions
        $A.enqueueAction(actionSaveEdit);
        
    }, 
    //on deactivating dry run artifact check
   /* deactivateArtifact : function(component, event, helper) {
        
        var arti= component.get("v.artifact");
        var checkVal = component.find("enabled").get("v.value");
        var oldValue=component.get("v.artifactEnabled");
        
        if(arti.FS_Published_Artifact__c !=null && arti.FS_Published_Artifact__c !=undefined)
        {
            
            if(arti.FS_Published_Artifact__c !=null && arti.FS_Published_Artifact__r.FS_Enabled__c && oldValue && !checkVal)
            {
                component.set("v.isWarning",true);
            }     
        }
        
    },*/
    
    closeCancel: function(component, event, helper) {
        component.find("enabled").set("v.value",true);
        component.set("v.isWarning", false); 
    },
    toContinue: function(component, event, helper) {
        component.set("v.isWarning", false);
    }, 
    //to check the length of Rank field
    validateRank : function(component, event, helper) {
        var inp = component.find("rank").get("v.value");
        
        if(inp !== undefined && inp !== null)
        {
            var len=event.getSource().get("v.value").toString().length;
            var rankErrMsg=$A.get("$Label.c.FOT_Rank_Length_Error"); // Maximum length of Rank field is 10 digits only...
            
            if( len > 10 ){
                component.find("rank").set("v.errors", [{message:rankErrMsg}]);
                
                component.find('notifLibEdit').showNotice({
                    "variant":"error",
                    "header": "Rank Length Error",
                    "message":rankErrMsg,
                }); 
            }
            else{
                component.find("rank").set("v.errors",null);
            }
            
        }        
    },
    // Validate artifact type on it's value change
    checkVersion: function(component, event, helper){ 
        helper.validateVersion(component, event, true);    
    }
})