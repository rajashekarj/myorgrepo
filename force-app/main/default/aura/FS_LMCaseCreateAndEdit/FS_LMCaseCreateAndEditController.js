({
    init: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        cmp.set("v.recordId", recordId);
    },
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
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
                    console.log("id---->"+focusedTabId);
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log("error coming hereee"+error);
                });
                
            } 
        })
        .catch(function(error) {
            console.log(error);
        });       
        
    },
    
    //Handler to close recordTypeSelection tab and open case record page in console app
    openLMCaseRecordPage : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var recordId = event.getParam('recordId');
        workspaceAPI.isConsoleNavigation().then(function(isConsole) {
            if (isConsole) { //Checking if the opened application is Console or non console
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    //Opening New Tab
                    workspaceAPI.openTab({
                        url: '#/sObject/'+recordId+'/view'
                    }).then(function(response) {
                        workspaceAPI.focusTab({tabId : response});
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    
                    //Closing old one
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log(error);
                });
                
            } 
            else {
                component.set('v.opnLmRecordPageForNonConsoleApp',true);
                component.set('v.lmRecordPageId', recordId);
                component.set('v.nonLMnavigation', true);
            }
        })
        .catch(function(error) {
            console.log(error);
        });
        
        
    }
})