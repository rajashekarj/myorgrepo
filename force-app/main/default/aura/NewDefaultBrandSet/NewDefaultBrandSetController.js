({
	doInit : function(component, event, helper) {
        /*var windowHash = window.location.hash;
		var hqId = component.get("v.recordId");
        alert('hqId' +hqId);
        var createRecordEvent = $A.get('e.force:createRecord');
        if ( createRecordEvent ) {
            createRecordEvent.setParams({
                'entityApiName': 'FS_Association_Brandset__c',
                 'defaultFieldValues': {
                    'FS_Headquarters__c' : hqId,
                     "panelOnDestroyCallback": function(event) {
             window.location.hash = windowHash;
    }
                }
            });
            createRecordEvent.fire();
        } else {
            //Create Record Event is not supported 
           alert("Default Brandset creation not supported");
        }*/
	},
    
     handleClick : function(component, event, helper) {
		var hqId = component.get("v.recordId");
        //alert('hqId' +hqId);
        var createRecordEvent = $A.get('e.force:createRecord');
         
        if ( createRecordEvent ) {
            createRecordEvent.setParams({
                'entityApiName': 'FS_Association_Brandset__c',
                 'defaultFieldValues': {
                    'FS_Headquarters__c' : hqId,
                }
            });
            createRecordEvent.fire();
        } else {
            /* Create Record Event is not supported */
           alert("Default Brandset creation not supported");
        }
	}    
})