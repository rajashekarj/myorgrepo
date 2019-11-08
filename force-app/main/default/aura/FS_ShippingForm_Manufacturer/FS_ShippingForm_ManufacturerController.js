({
    doInit : function(component, event, helper) {
     },
    
    handle_Send_for_PreBook : function(component, event, helper) {
        var RecId = component.get("v.recordId");
        var SendforPreBook = component.get("c.SendforPreBook");
        
        SendforPreBook.setParams(
            { 
                "id" :  RecId
            });
        SendforPreBook.setCallback(this, function(response) {
            //  var state = a.getState();
            debugger;
            if ( response.getState() == "SUCCESS") {
                var res = response.getReturnValue();
              //  alert(res.toString().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
                if(res.toString().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') != -1){
                    var startPosition = res.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                    var error = startPosition[1].split(':');
                    alert('Error:' + error[0]);
                }else if(res.toString().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') == -1 && !response.getReturnValue() =='Success'){
                   alert(res);  
                }else if(res.toString().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') == -1 && response.getReturnValue() =='Success'){
                    alert('Pre-Book sent to dispenser coordinator.');
                    $A.get('e.force:refreshView').fire();
                }
            }else if (saveResult.state() === "ERROR") {
                console.log("Error Saving Shipping form ");
            }                 
            
        });       
        $A.enqueueAction(SendforPreBook);
    },
    
    isRefreshed: function(component, event, helper) {
        location.reload();
    },

    handle_Notify_Coordinator : function(component, event, helper) {
        var RecId = component.get("v.recordId");
        var SendNotification = component.get("c.Notify_Coordinator");
        var SendTrue = 'True';
        SendNotification.setParams(
            { 
                "id" :  RecId,
                "IsnotTestClass" : SendTrue
            });
        SendNotification.setCallback(this, function(response) {
            //  var state = a.getState();
            if ( response.getState() == "SUCCESS") {
               // alert(response.getReturnValue());
                if(response.getReturnValue() == "Success"){
                    alert("Your email has been sent to the coordinator.");
                }else{
                    alert("Error in sending email to coordinator.");
                } 
            }            
        });       
        $A.enqueueAction(SendNotification);
    }
})