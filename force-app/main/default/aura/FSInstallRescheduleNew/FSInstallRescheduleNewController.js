({
    doInit : function(component, event, helper) {
        var action = component.get("c.disableAccessCheck");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var storeResponse = response.getReturnValue();                
                if(!storeResponse){                  
                    $A.util.removeClass(component.find('newButton'), 'slds-hide');
                }                
            }            
        });
        $A.enqueueAction(action);
    },
    
    handleClick : function(component, event, helper) {
        var installId = component.get("v.recordId");        
        var createRecordEvent = $A.get('e.force:createRecord');
        var action = component.get("c.installScheduleDateCheck");
        
        action.setParams({  recordId : installId  });
        
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==="SUCCESS"){
                var storeResponse = response.getReturnValue();  
                if(createRecordEvent){
                    if(!storeResponse.ipScheduleCheck){/*condition added for FNF-798 */
                        /*condition added for FNF 747*/
                        if(!storeResponse.outletDispensersNotSelectedError && !storeResponse.dispenserSectionEmptyError && !storeResponse.plattformMismatchError){

                            createRecordEvent.setParams({
                                'entityApiName': 'FS_Installation_Reschedule__c',
                                'defaultFieldValues': {
                                    'FS_Installation__c' : installId,
                                }
                            });
                            createRecordEvent.fire();   
                        }
                     /*   FNF 747 Change Starts*/
                        else if(storeResponse.plattformMismatchError ){
                            alert($A.get("$Label.c.FS_PlatForm_Type_Mismatch"));
                        }
                        else if(storeResponse.outletDispensersNotSelectedError){
                           alert($A.get("$Label.c.FS_DispenserSection_Not_Empty"));
                        }
                         else if(storeResponse.dispenserSectionEmptyError){
                           alert($A.get("$Label.c.FS_DispenserSection_Empty"));
                        }
                        /*   FNF 747 Change ends*/
                    }else{/*Else condition added for FNF-798 */
                        alert($A.get("$Label.c.FS_Install_Reschedule_Prevention_Error_Message"));
                    }
                }
                else {
                    /* Create Record Event is not supported */
                    alert("Reschedule Install creation not supported");
                }
            }
        });
        $A.enqueueAction(action);  
    },  
})