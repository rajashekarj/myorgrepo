({
	helperMethod : function() {
		
	},
        viewRuleFileFromAWSHelper : function(component, event,ruleType){
        var ruleFile;
        var fileName;
		var downloadRuleToS3 = component.get("c.viewRuleFileFromAWS_S3");
        if(ruleType == 'ruleSet'){
            ruleFile = component.get("v.arti").FS_Rule__c;
            fileName = ruleFile.split("/");
            console.log('ruleFileName in helper' + fileName[1]);
        }else if(ruleType == 'overRideRuleSet'){
           ruleFile = component.get("v.arti").FS_Overide_Group_Rule__c;
           fileName = ruleFile.split("/");
           console.log('Override group rule in helper' + fileName[1]);
        }
        downloadRuleToS3.setParams({
            's3FileName' : fileName[1]
        });
        downloadRuleToS3.setCallback(this, function(response){
            var awsResponse = response.getState();
            console.log('Set Call back');
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
})