({
    //hanndler to open create fact case creation popup by prepopulating default values 
    // LM case and Outlet Dispenser information
    openCreateFactCase : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var caseId = event.getParam('caseId');
        var recTypeId = event.getParam('connectivitySolutionRecordTypeId');
        var outletDispenserId = event.getParam('outletDispenserId');
        createRecordEvent.setParams({ 
            "entityApiName": "Case", 
            "recordTypeId":recTypeId,
            "defaultFieldValues": {
                'LM_Case__c': caseId,
                'FS_Outlet_Dispenser__c': outletDispenserId
                
            },
            
        });
        
        createRecordEvent.fire(); 
    },
    //Handler to close focused tab on click of delete button and refresh the list view for LM Cases in console app
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
    openEdit: function(component, event, helper) {
        
       
        var action = component.get("c.isCommunity");
		action.setCallback(this, function(response) {
          
         var isCommunity = response.getReturnValue(); // do any operation needed here
           if(isCommunity){
               var caseId = event.getParam('caseId');
               component.set('v.lmRecordPageId',caseId);
                component.set('v.openLMEditPage',true);
               
        }
        });
        $A.enqueueAction(action);
       
        
    },
    //Handler to open case record page in communities
    openLMCaseRecordPage : function(component, event, helper) {
        var action = component.get("c.isCommunity");
		action.setCallback(this, function(response) {
         var isCommunity = response.getReturnValue(); 
           if(isCommunity){
               var recordId = event.getParam('recordId');
                component.set('v.opnLmRecordPageForNonConsoleApp',true);
                component.set('v.lmRecordPageId', recordId);
                component.set('v.nonLMnavigation', true);
        }
        });
        $A.enqueueAction(action);
        
    }
})