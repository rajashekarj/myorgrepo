({
    helperMethod : function() {
        
    },
    // To disable or enable S3path or Settings fields based on Artifact Type value 
    helperDisableField: function(component,event,disablefield,enablefield) {
        component.find(disablefield).set("v.value", "");
        component.find(disablefield).set("v.disabled", true);
        component.find(disablefield).set("v.errors", null);
        component.find(disablefield).set("v.required", false);
        
        component.find(enablefield).set("v.disabled", false);
        component.find(enablefield).set("v.required", true);
    },
    
    handleUploadToAWSHelper : function(component, event,ruleType){
      var uploadRuleToS3 = component.get("c.uploadRuleToAWS_S3");
      var ruleFileName;
      var ruleFileContent;
      component.set("v.showLoadingSpinner", true);
        if(ruleType == 'ruleSet'){
           ruleFileName = component.get('v.ruleSetFileName');
           ruleFileContent = component.get("v.ruleSetFileContent");
        }else if(ruleType == 'overRideRuleSet'){
           ruleFileName = component.get('v.overRideRuleSetFileName');
           ruleFileContent = component.get("v.overRideRuleSetFileContent");
        }
        var resultsToast = $A.get("e.force:showToast");
        uploadRuleToS3.setParams({
            'fileContent': ruleFileContent,
            'ruleSetFileName' : ruleFileName
        })
        uploadRuleToS3.setCallback(this, function(response){
            var awsResponse = response.getState();
            var checkFile = response.getReturnValue();
            var fileName;
            if (awsResponse === "SUCCESS" && checkFile != 'Error') 
            {
               var s3RulePath = response.getReturnValue();
               component.set("v.showLoadingSpinner", false);
               var s3Name = s3RulePath.split('amazonaws.com/');
                if(ruleType == 'ruleSet'){
                    component.find("rule").set("v.value",'S3File:'+s3Name[1]);
                    component.set('v.ruleSetS3Link',s3RulePath);
                    fileName = component.get('v.ruleFileName');
                    component.set('v.ruleFileName','No File Selected..');
                }else if(ruleType == 'overRideRuleSet'){
                    component.find("overrideRule").set("v.value",'S3File:'+s3Name[1]); 
                    component.set('v.overRideRuleS3Link',s3RulePath);
                    fileName = component.get('v.overRideFileName');
                    component.set('v.overRideFileName','No File Selected..');
                }
                resultsToast.setParams({
                    "title": "Upload Success",
                    "type":"success",
                    "mode" : "pester",
                    "duration": 1000,
                    "message": fileName +" File Uploaded To S3 Successfully."
                });
                resultsToast.fire(); 
            }else{
                component.set("v.showLoadingSpinner", false);
                resultsToast.setParams({
                    "title": "Upload Fail",
                    "type":"error",
                    "mode" : "pester",
                    "duration": 1000,
                    "message": "Error while S3 File Upload.Please check AWS S3 setting and try again."
                });
                resultsToast.fire();
            }
        });
        $A.enqueueAction(uploadRuleToS3);
    },
    
     viewRuleFileFromAWSHelper : function(component, event,ruleType){
        var ruleFile;
        var fileName;
		var downloadRuleToS3 = component.get("c.viewRuleFileFromAWS_S3");
        if(ruleType == 'ruleSet'){
            ruleFile = component.get("v.artifact").FS_Rule__c;
            fileName = ruleFile.split("/");
            console.log('ruleFileName in helper' + fileName[1]);
        }else if(ruleType == 'overRideRuleSet'){
           ruleFile = component.get("v.artifact").FS_Overide_Group_Rule__c;
           fileName = ruleFile.split("/");
           console.log('Override group rule in helper' + fileName[1]);
        }
        downloadRuleToS3.setParams({
            's3FileName' : fileName[1]
        });
        downloadRuleToS3.setCallback(this, function(response){
            var awsResponse = response.getState();
            console.log('Set Call bAck');
            if (awsResponse === "SUCCESS") 
            {
                var s3RulePath = response.getReturnValue();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": s3RulePath
                });
                urlEvent.fire();
                console.log('s3RulePath' + s3RulePath);
            }else{
                console.log('Failed');
            }
        });
        $A.enqueueAction(downloadRuleToS3);
    },
    
    // Validate artifact version on it's value change
    validateVersion: function(component, event, flag){
        
        var artid, artVersion,errmsg;
        if( flag === true ){
            artid=[event.getSource().getLocalId()];
        }
        else{
            artid=["version","minVersion","breakVersion","secArtifactDepMinVersion","secArtifactDepBrkVersion"];
        }
        
        for(var i=0;i<artid.length;i++){
            artVersion = component.find(artid[i]).get("v.value");        
            
            if( artVersion != undefined && artVersion != null && artVersion != '' )
            {
                var invalidVer=false;
                //to check version value does not start, end with '.' or doesn't contain '..'
                if( artVersion[0] == '.' || artVersion[artVersion.length-1] == '.' || artVersion.indexOf("..") !== -1 )
                {
                    invalidVer = true;
                }
                
                // If version value is not matching the requirement "does not start, end with '.' or contains '..'"
                // show error notification
                if( invalidVer ){
                    component.set("v.artVersionValid",false);
                    component.find(artid[i]).set("v.errors", [{message:$A.get("$Label.c.FOT_VersionErrorMessage")}]);
                    component.find('notifLibEdit').showNotice({
                        "variant":"error",
                        "header": "Input Required",
                        "message":$A.get("$Label.c.FOT_VersionErrorMessage"),
                    });
                    setTimeout(function(){
                        component.find(artid[i]).focus();
                    }, 100);
                    return false;
                }
                else if( artVersion === undefined || artVersion === null || artVersion === '' ){
                    component.set("v.artVersionValid",true);
                    component.find(artid[i]).set("v.errors", null);
                }
                    else{
                        component.set("v.artVersionValid",true);
                        component.find(artid[i]).set("v.errors", null);
                    }
            }
            else{
                component.set("v.artVersionValid",true);
                component.find(artid[i]).set("v.errors", null);
            }
        }
        
    }
})