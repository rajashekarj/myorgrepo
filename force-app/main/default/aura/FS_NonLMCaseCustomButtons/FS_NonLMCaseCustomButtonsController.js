({
     init: function(component, event, helper) {
        var action = component.get("c.checkCommunity");
        action.setCallback(this, function(response) {
            var communitySiteId = response.getReturnValue(); 
            if(communitySiteId){
                component.set("v.communitySiteId",communitySiteId);
            }
           
        });
        $A.enqueueAction(action);
    },
    //Handler to close focused tab on click of delete button and refresh the list view for Non LM Cases in console app
    closeFocusedTab : function(component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI
        .isConsoleNavigation()
        .then(function(isConsole) {
            if (isConsole) {
                
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                    $A.get('e.force:refreshView').fire();
                })
                .catch(function(error) {
                    console.log(error);
                });
                component.set('v.navigateToCaseHomePageFlag','true');
                var navigationItemAPI = component.find("navigationItemAPI");
                navigationItemAPI.refreshNavigationItem().then(function(response) {
                    console.log(response);
                })
                .catch(function(error) {
                    console.log(error);
                });
                
            } 
        })
        .catch(function(error) {
            console.log(error);
        });  
        
        
    },
     //Handler to open Edit page for Communities
    openEdit: function(component, event, helper) {
        
     
        var action = component.get("c.checkCommunity");
        action.setCallback(this, function(response) {
            var communitySiteId = response.getReturnValue(); 
            if(communitySiteId){
              
                var caseId = event.getParam('caseId');
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": caseId
                });
                editRecordEvent.fire(); 
            }
           
        });
        $A.enqueueAction(action);
        
        
    }
    
})