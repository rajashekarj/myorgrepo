({
	doInit : function(component, event, helper) {
        var accId = component.get("v.recordId");
        var action = component.get('c.getPhone');
        var phoneNo;
        action.setParams({
            "outletid" : accId
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                phoneNo=a.getReturnValue();
                component.set("v.phoneNumber",a.getReturnValue());
            }
        });
        var hqAction = component.get('c.getHqId');
        var hqId;
        hqAction.setParams({
            "outletid" : accId
        });
        hqAction.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                hqId=a.getReturnValue();
                component.set("v.hqId",a.getReturnValue());
            }
        });
        $A.enqueueAction(hqAction);
        $A.enqueueAction(action);
	},
    
     handleClick : function(component, event, helper) {
		var accId = component.get("v.recordId");
        var hqId=component.get("v.hqId");
        var createRecordEvent = $A.get('e.force:createRecord');
         
        if ( createRecordEvent ) {
            createRecordEvent.setParams({
                'entityApiName': 'FS_Execution_Plan_Contact__c',
                 'defaultFieldValues': {
                    'Outlet__c' : accId,
                    'FS_Headquarters__c' : hqId,
                }
            });
            createRecordEvent.fire();
        } else {
            /* Create Record Event is not supported */
           alert("Creation not supported");
        }
	} ,
    handleClickContact : function(component, event, helper) {
		var accId = component.get("v.recordId");
        var phoneNum = component.get("v.phoneNumber");
        var createRecordEvent = $A.get('e.force:createRecord');
        
        if ( createRecordEvent ) {
                    createRecordEvent.setParams({
                        'entityApiName': 'Contact',
                        'recordTypeId' : '01261000000SEOc',
                         'defaultFieldValues': {
                            'AccountId' : accId,
                             'Phone' : phoneNum,                     
                        }
                    });
                    createRecordEvent.fire();
          } else {
               /* Create Record Event is not supported */
               alert("Creation not supported");
          }
	}  
})