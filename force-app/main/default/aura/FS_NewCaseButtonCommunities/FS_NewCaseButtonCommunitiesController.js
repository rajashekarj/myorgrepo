({
    callRecordSelectionPage:function(component,event,helper){
        
        component.set("v.openRecordTypeSelectionPage", true);     // update our message

    },
    //handler to open Non LM cases record creation popup based on the console or non console app.
    createNonLmCases : function(component, event, helper) { 
        component.set("v.edit", false);   
        var recordTypeId = event.getParam('recordTypeId');
        var listViewId = event.getParam('listId');
        var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
            "entityApiName": "Case",  // sObject API Name [Required Parameter]
            "recordTypeId":  recordTypeId,// Optionally Specify Record Type Id
                
            });
			createRecordEvent.fire();
        	component.set("v.edit", false);  
    },
    //Handler to close focused tab in console app
    closeFocusedTab : function(component, event, helper) {
       
        var workspaceAPI = component.find("workspace");
		workspaceAPI
      .isConsoleNavigation()
      .then(function(isConsole) {
        if (isConsole) {
            
         	workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
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
    createLmCase : function(component, event, helper) {
         component.set('v.lmCaseCreate', true);
        
        
    },
     //Handler to close recordTypeSelection tab(for console app) and open case record page in console app and non console app
    openLMCaseRecordPage : function(component, event, helper) {
          var recordId = event.getParam('recordId');
        
					  component.set('v.opnLmRecordPageForNonConsoleApp',true);
          	
					  component.set('v.lmRecordPageId', recordId);
         	          component.set('v.LMAndnonLMnavigation', true);

        
        
    }
});