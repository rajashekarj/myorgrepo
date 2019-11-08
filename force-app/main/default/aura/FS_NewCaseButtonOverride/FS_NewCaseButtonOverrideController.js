({
    //handler to open Non LM cases record creation popup based on the console or non console app.
    createNonLmCases : function(component, event, helper) { 
        var workspaceAPI = component.find("workspace");
        var recordTypeId = event.getParam('recordTypeId');
        var listViewId = event.getParam('listId');
        workspaceAPI.isConsoleNavigation().then(function(isConsole) {
        if (isConsole) { //Checking if the opened application is Console or non console
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
            "entityApiName": "Case",  // sObject API Name [Required Parameter]
            "recordTypeId":  recordTypeId,// Optionally Specify Record Type Id
                
            });
			createRecordEvent.fire();
       } else {
             component.set('v.recTypeId', recordTypeId);
         	 component.set('v.listId', listViewId);
         	 component.set('v.opnLmRecordPageForNonConsoleApp',false);
         	 component.set('v.LMAndnonLMnavigation', true);
        }
      })
      .catch(function(error) {
        console.log(error);
      });
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
          var workspaceAPI = component.find("workspace");
          var recordId = event.getParam('recordId');
          workspaceAPI.isConsoleNavigation().then(function(isConsole) {
			if (isConsole) { //Checking if the opened application is Console or non console
						workspaceAPI.getFocusedTabInfo().then(function(response) {
							var focusedTabId = response.tabId;
							//Opening Record Page Tab
							workspaceAPI.openTab({
								url: '#/sObject/'+recordId+'/view'
							}).then(function(response) {
								workspaceAPI.focusTab({tabId : response});
							})
							.catch(function(error) {
								console.log(error);
							});

							//Closing record type selection tab
							workspaceAPI.closeTab({tabId: focusedTabId});
						})
						.catch(function(error) {
							console.log(error);
						});

			} 
			else {
					  component.set('v.opnLmRecordPageForNonConsoleApp',true);
					  component.set('v.lmRecordPageId', recordId);
         	          component.set('v.LMAndnonLMnavigation', true);
			}
      })
	.catch(function(error) {
		console.log(error);
	 });
        
        
    }
    
   
	
})