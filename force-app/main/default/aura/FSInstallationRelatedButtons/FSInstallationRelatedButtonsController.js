({
	doInit : function(component, event, helper) {
        var getEP = component.get("c.getEpId");
        getEP.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                component.set("v.epid",a.getReturnValue());
            }
        }); 
        $A.enqueueAction(getEP); 
	},
    
     handleClickI4W : function(component, event, helper) {
		var accId = component.get("v.recordId");
        //alert('hqId' +hqId);
        var createRecordEvent = $A.get('e.force:createRecord');
         var windowHash = window.location.hash;
        if ( createRecordEvent ) {
            
            createRecordEvent.setParams({
                'entityApiName': 'FS_Installation__c',
                'recordTypeId' : '01261000000SEPB',
                 'defaultFieldValues': {
                     "FS_Outlet__c":accId,
                     "FS_Execution_Plan__c": component.get("v.epid")
                }
            });
            createRecordEvent.fire();
        } else {
            /* Create Record Event is not supported */
           alert("Creation not supported");
        }
	} ,
    handleClickO4W : function(component, event, helper) {
		var accId = component.get("v.recordId");
        //alert('hqId' +hqId);
        var createRecordEvent = $A.get('e.force:createRecord');
         
        if ( createRecordEvent ) {
            createRecordEvent.setParams({
                'entityApiName': 'FS_Installation__c',
                'recordTypeId' : '01261000000MbbK',
                 'defaultFieldValues': {
                     "FS_Outlet__c":accId,
                     "FS_Execution_Plan__c": component.get("v.epid")
                }
            });
            createRecordEvent.fire();
        } else {
            /* Create Record Event is not supported */
           alert("Creation not supported");
        }
	},
    handleClickRemove : function(component, event, helper) {
		var accId = component.get("v.recordId");
        //alert('hqId' +hqId);
        var createRecordEvent = $A.get('e.force:createRecord');
         
        if ( createRecordEvent ) {
            createRecordEvent.setParams({
                'entityApiName': 'FS_Installation__c',
                'recordTypeId' : '01261000000SEPC',
                 'defaultFieldValues': {
                     "FS_Outlet__c":accId,
                     "FS_Execution_Plan__c": component.get("v.epid")
                }
            });
            createRecordEvent.fire();
        } else {
            /* Create Record Event is not supported */
           alert("Creation not supported");
        }
	},
    handleClickReplace : function(component, event, helper) {
        component.set("v.isOpen", false);
		var accId = component.get("v.recordId");
        //alert('hqId' +hqId);
        var createRecordEvent = $A.get('e.force:createRecord');
        if ( createRecordEvent ) {
            createRecordEvent.setParams({
                'entityApiName': 'FS_Installation__c',
                'recordTypeId' : '01261000000SEPD',
                 'defaultFieldValues': {
                     "FS_Outlet__c":accId,
                     "FS_Execution_Plan__c": component.get("v.epid")
                }
            });
            createRecordEvent.fire();
        } else {
            /* Create Record Event is not supported */
           alert("Creation not supported");
        }
	},
    
})