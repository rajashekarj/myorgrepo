({
    onInit : function(cmp, event, helper) {
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)).split('1.');
        var sURLVariables1 = sPageURL[1].split('%3D');
        var sURLVariables = sURLVariables1[0].split('&0');
        var sURLEncoded = decodeURIComponent(sURLVariables[0]);
        
        debugger;
        var recordId = cmp.get("v.recordId");//fetches the brandset id
        var action = cmp.get('c.getHQRecordId'); 
        var getVal;
        var profileAccess;
        var profileAccessAction = cmp.get('c.getProfileAccess');
        var RTypeNameAction = cmp.get('c.getInstallationRT');
        var RTType;
        
        var decodeurlAction = cmp.get('c.getdecodeurl');
        var decodeurl;
        var pageReference;
        decodeurlAction.setParams({
            "decodeurl":sURLEncoded
        });
        decodeurlAction.setCallback(this, function(a){
            var state = a.getState();
        if(state = 'SUCCESS'){
            decodeurl = a.getReturnValue();
        }
        });
         profileAccessAction.setParams({
            "brandsetId" : recordId,
            "ObjName":sURLEncoded
        });
        profileAccessAction.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                profileAccess=a.getReturnValue();
            }
        });
        debugger;
        RTypeNameAction.setParams({
            "brandsetId" : recordId,
            "ObjName":sURLEncoded
        });
        RTypeNameAction.setCallback(this, function(b){
            var state = b.getState();
            if(state == 'SUCCESS') {
              RTType=b.getReturnValue();  
            }
        });
        debugger;
        action.setParams({
            "brandsetId" : recordId,
            "ObjName":sURLEncoded
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                cmp.set('v.hqRec', a.getReturnValue());
                getVal=a.getReturnValue();
                //The below is pagereference for the HQ and the action is view, record id is account ID
                   pageReference = {    
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": getVal,
                        "actionName": "view"                                
                    },
                    "state":{
                        "nooverride":""
                    }
                };
                if(decodeurl == 'Account_Brandsets__r'){
                    pageReference = {    
                    "type": "standard__recordRelationshipPage",
                    "attributes": {
                        "recordId": getVal,
                        "relationshipApiName": "Account_Brandsets__r",
                        "actionName": "view"                                
                    },
                    "state":{
                        "nooverride":""
                    }
                };
                }
                if(decodeurl == 'FSHeadquarters__r'){
                    pageReference = {    
                    "type": "standard__recordRelationshipPage",
                    "attributes": {
                        "recordId": getVal,
                        "relationshipApiName": "FSHeadquarters__r",
                        "actionName": "view"                                
                    },
                    "state":{
                        "nooverride":""
                    }
                };
                }
                
                
                
                //Navigating to standard default brandset edit page
                 var navService = cmp.find("navService");
                 navService.navigate(pageReference);//Navigating to the parent page
                pageReference.type = "standard__recordPage";
                   if(profileAccess && RTType){
                    debugger;
                    pageReference.attributes.recordId = recordId;//default brandset record Id 
                    pageReference.attributes.actionName = "edit";
                    pageReference.state.nooverride = "1";
                    navService.navigate(pageReference);
                }  
                else{
                    //alert('You do not have permission to edit the record');
                    alert($A.get("$Label.c.FS_AB_Edit_Error"));
                }
                
            }
        });
        $A.enqueueAction(decodeurlAction);
        $A.enqueueAction(profileAccessAction);
        $A.enqueueAction(RTypeNameAction);
        $A.enqueueAction(action);
    }    
})