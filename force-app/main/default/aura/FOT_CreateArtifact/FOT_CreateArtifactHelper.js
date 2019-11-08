({
    helperArtifactType: function(component,event,flag) { // Validating Artifact type value, with existing artifact type of selected Ruleset
        //console.log('helper method');
        var artType = component.find("artifactType").get("v.value");   
        var actionArtiType=component.get("c.actionArtifactType"); 
        var ruleset=component.get("v.selectedLookUpRecord").Id;
        var ruleSetName=component.get("v.selectedLookUpRecord").Name;
        
        actionArtiType.setParams({
            'ruleset': ruleset
        }) 
        
        actionArtiType.setCallback(this, function(response) {
            var state = response.getState();
            var errMsg;
            component.set("v.arttypeErrMsg","");
            //console.log('state valu '+state+' valid '+component.isValid());
            if (component.isValid() && state === "SUCCESS") {  
                //console.log('response helper '+response.getReturnValue()+' artifact type'+artType+' atType value '+ component.get("v.atType"));
                if(artType !=response.getReturnValue()&&response.getReturnValue()!='')
                {
                    component.set("v.spinner",false);
                    component.set("v.atType",true);
                    
                    //console.log('if helper '+artType+' '+component.get("v.spinner")+'  '+response.getReturnValue()+' '+component.get("v.atType"));
                    errMsg = "Select '"+response.getReturnValue()+"' as "+component.find("artifactType").get("v.label")+" if you are selecting '"+ruleSetName+"' as "+component.get("v.label");
                    component.set("v.arttypeErrMsg",errMsg);
                    
                    component.find("artifactType").set("v.errors", [{message:errMsg}]);
                    if( !component.get("v.fromSave") ){
                        component.find('notifLib').showNotice({
                            "variant":"error",
                            "header": "Input Required",
                            "message":errMsg
                        });
                    }
                    
                    return false;
                    
                }
                else
                {
                    component.set("v.atType",false);
                    //console.log('helper else part'+ component.get("v.atType"));
                    component.find("artifactType").set("v.errors", null);
                    //to check whether this method is invoked on click of save
                    if(component.get("v.fromSave")==true && component.get("v.artVersion")==false )
                    {
                        this.helperWebCall(component,event);
                    }
                }
            }
        });
        
        $A.enqueueAction(actionArtiType); 
    },
    helpervalidateRank: function(component,event) {
        //console.log('inside validate rank helper');
        var inp = component.find("artifactRank").get("v.value");
        //console.log("inp --- "+inp);
        if(inp !== undefined && inp !== null)
        {
            var len=component.find("artifactRank").get("v.value").toString().length;            
            if( len > 10 ){
                component.set("v.artRank",true);            
            }
            else{
                component.set("v.artRank",false);
                component.find("artifactRank").set("v.errors",null);
                //console.log('helper artRank value '+component.get("v.artRank"));
            }            
        }
        
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
    //to invoke A5 Validation web callout 
    helperWebCall: function(component,event)
    {
        component.set("v.spinner",true);
        if(component.get("v.atType")==false && component.get("v.artRank")==false && component.get("v.artVersion")==false)
        {
            //console.log('inside web call');
            var artObj = component.get("v.simpleNewArtifact");
            //console.log('inside web '+artObj.FS_UUID__c);
            var actionWebCall=component.get("c.actionWebCallout");
            
            actionWebCall.setParams({
                'artObj': artObj
            })
            
            actionWebCall.setCallback(this, function(response) {
                //store state of response
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.spinner",false);
                    if(response.getReturnValue()!=null)
                    {
                        
                        //console.log('success '+response.getReturnValue().valid);
                        //Validation error from api
                        if(!response.getReturnValue().valid)
                        {
                            component.find('notifLib').showNotice({
                                "variant":"error",
                                "header": "Validation Error",
                                "message":response.getReturnValue().message ,
                            });  
                        }
                        else //On successfull validation from api
                        {  
                            component.set("v.isOpen", true);
                            component.set("v.responseMsg",response.getReturnValue().message);
                        }
                    }  
                }
            });
            $A.enqueueAction(actionWebCall);  
            
        }
    },
    handleUploadToAWSHelper : function(component, event){
      var uploadRuleToS3 = component.get("c.uploadRuleToAWS_S3");
        var resultsToast = $A.get("e.force:showToast");
        component.set("v.showLoadingSpinner", true);
        uploadRuleToS3.setParams({
                'fileContent': component.get("v.ruleSetFileContent"),
            	'ruleSetFileName' : component.get('v.ruleSetFileName')
            })
        uploadRuleToS3.setCallback(this, function(response){
            var awsResponse = response.getState();
            if (awsResponse === "SUCCESS") 
            {
                var s3RulePath = response.getReturnValue();
                component.find("ruleUrl").set("v.value",s3RulePath);
                component.find("artifactRule").set("v.value",s3RulePath);
                component.set("v.showLoadingSpinner",false);
                resultsToast.setParams({
                    "title": "Upload Success",
                    "type":"success",
                    "mode" : "pester",
                    "duration": 1000,
                    "message": "Rule File Uploaded To S3 Successfully."
                });
                resultsToast.fire(); 
            }else{
                component.set("v.showLoadingSpinner",false);
                resultsToast.setParams({
                    "title": "Upload Fail",
                    "type":"error",
                    "mode" : "pester",
                    "duration": 1000,
                    "message": "Upload Fail.Please check AWS S3 setting and try again."
                });
                resultsToast.fire();
            }
        });
       $A.enqueueAction(uploadRuleToS3);  
    },
    // Validate artifact version on it's value change
    validateVersion: function(component, event, flag){ 
        
        console.log("==== From helper validateVersion ====");
        var artid, artVersion,errmsg;
        component.set("v.verErrMsg","");
        if( flag === true ){
            artid=[event.getSource().getLocalId()];
        }
        else{
            artid=["artifactVersion","artifactDepMinVersion","artifactDepBrkVersion","secArtifactDepMinVersion","secArtifactDepBrkVersion"];
        }
        
        for(var i=0;i<artid.length;i++){
            artVersion = component.find(artid[i]).get("v.value");        
            
            if( artVersion != undefined && artVersion != null && artVersion != '' )
            {
                component.set("v.spinner",false);
                var invalidVer=false;
                
                //to check version value does not start, end with '.' or doesn't contain '..'
                
                if( artVersion[0] == '.' || artVersion[artVersion.length-1] == '.' || artVersion.indexOf("..") !== -1 )
                {
                    invalidVer = true;
                }
                
                errmsg = $A.get("$Label.c.FOT_VersionErrorMessage");
                
                // If version value is not matching the requirement "does not start, end with '.' or contains '..'"
                // show error notification
                if( invalidVer ){
                    component.set("v.artVersion",true);
                    component.set("v.verErrMsg",errmsg);
                    
                    component.find(artid[i]).set("v.errors", [{message:errmsg}]);
                    
                    // Adding error notification for field value change and not on save button click
                    if( !component.get("v.fromSave") ){
                        component.find('notifLib').showNotice({
                            "variant":"error",
                            "header": "Input Required",
                            "message":errmsg,
                        });
                        setTimeout(function(){
                            component.find(artid[i]).focus();
                        }, 100); 
                    }
                    
                    
                    break;
                    return false;
                    
                }
                else{
                    component.set("v.artVersion",false);
                    component.find(artid[i]).set("v.errors", null);
                }
            }
            else{
                component.set("v.artVersion",false);
                component.find(artid[i]).set("v.errors", null);
            }
        }
        
    }
})