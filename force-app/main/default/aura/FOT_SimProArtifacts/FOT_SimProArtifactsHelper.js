({
    reInit : function(component, event, helper) {
        
        //disabling Right click and F12 key
        /* document.addEventListener('contextmenu', event => event.preventDefault());        
        document.onkeydown = function(e) {
            if(e.keyCode == 123) {                
                e.preventDefault();
            }
        };*/
        //end of disabling Right click and F12 key
        
        var recordId=component.get("v.recordId");
        var mdmReadOnly = $A.get("$Label.c.FOT_MDM_Read_only");
        var actionGetArtifactDetails=component.get("c.recordArifactDetails");
        var getRuleSetName = component.get("c.getRuleSetName");
        var getProfile = component.get("c.userProfileAccess");
        var getRuleSetDetails = component.get("c.recordDetails");
        
        getRuleSetName.setParams({
            recordId : recordId  
        })
        
        actionGetArtifactDetails.setParams({
            recordId : recordId
        });
        
        getRuleSetDetails.setParams({
            recordId : recordId
        });
        
        // Get the Ruleset Details 
        getRuleSetDetails.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.ruleSet",response.getReturnValue());
            }
        });
        
        getProfile.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.profileName",response.getReturnValue());
            }
        });
        
        actionGetArtifactDetails.setCallback(this, function(response) {
            console.log('actionGetArtifactDetails' + response.getState());
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.enableRulesetMap',response.getReturnValue());
                
                //enabling Simulate and Promote button based on User profile  
                if(component.get("v.profileName")!='MDM Read only')
                {
                    console.log('check simulate'+!component.get('v.enableRulesetMap.checkSimulate'));
                    component.find("simulateBtn").set("v.disabled",!component.get('v.enableRulesetMap.checkSimulate'));
                    console.log('check promote'+!component.get('v.enableRulesetMap.checkPromote'));
                    component.find("promoteBtn").set("v.disabled",!component.get('v.enableRulesetMap.checkPromote'));                    
                }
                else
                {
                    component.find("simulateBtn").set("v.disabled",true);
                    component.find("promoteBtn").set("v.disabled",true); 
                }
                
            }
        });
        
        //to get the RuleSet Name
        getRuleSetName.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.ruleSetName",response.getReturnValue());
                console.log("ruleNameruleName" + response.getReturnValue());
            }
        });
        
        $A.enqueueAction(getProfile);
        $A.enqueueAction(getRuleSetName);       
        $A.enqueueAction(actionGetArtifactDetails);
        $A.enqueueAction(getRuleSetDetails);
        
    },
    
    finalPromoteContinue: function (component, event, helper) {
        var ruleSetName=component.get("v.ruleSetName");
        var hashCode=component.get("v.hashCode");
        var recordId=component.get("v.recordId");
        component.set("v.spinner",true);
        
        var actionfinalPromote=component.get("c.finalPromote");
        actionfinalPromote.setParams({
            ruleSetName : ruleSetName,
            hashcode : hashCode,
            recordId : recordId
            
        });
        
        actionfinalPromote.setCallback(this, function(response) {
            var state = response.getState();
            var concVal = response.getReturnValue();
            console.log("--- concVal split 1--- "+concVal.split(',')[1]);
            var statcode=concVal.split(',')[1];
            var statMsg =concVal.split(',')[2];
            var errmsg;
            
            // To set error message based on status error code (40x or 50x).
            if( statcode != undefined){ 
                if(statcode.indexOf('40') != -1 )
                {
                   errmsg = $A.get("$Label.c.FOT_APIError_40X") + ', ' + statMsg;
                }
                else if( statcode.indexOf('50') != -1 )
                {
                    errmsg = $A.get("$Label.c.FOT_APIError_500") + ', ' + statMsg;
                }
            }
            
            console.log("--- concVal error message --- "+errmsg);
            
            if (component.isValid() && state === "SUCCESS" && concVal == 'true' ) {
                component.set("v.isOpen", false);
                component.set("v.spinner",false);
                console.log('test result concVal true');
            }else if (component.isValid() && state === "SUCCESS" && concVal.indexOf(',') != -1 ){
                console.log('test result false error messageee :: ' +errmsg );
                component.set("v.isOpen", false);
                component.find('notifLibEdit').showNotice({
                    "variant":"error",
                    "header": "Integration Layer Error While Promote",
                    "message": errmsg
                }); 
                component.set("v.spinner",false);
                console.log('test result false');
            }
                else{
                    console.log('test result false');
                    component.set("v.isOpen", false);
                    component.find('notifLibEdit').showNotice({
                        "variant":"error",
                        "header": "Error While Promote",
                        "message": $A.get("$Label.c.FOT_Promote_ConError"),
                    }); 
                    component.set("v.spinner",false);
                    console.log('test result false');
                }
        });
        $A.enqueueAction(actionfinalPromote);
        
        var boolReInit = false;
        setTimeout(
            $A.getCallback(function(){ 
                //To refresh view and reload entire page
                $A.get('e.force:refreshView').fire();
                helper.reInit(component, event, helper);            
            }), 5000);
        $A.get('e.force:refreshView').fire();
    }
})