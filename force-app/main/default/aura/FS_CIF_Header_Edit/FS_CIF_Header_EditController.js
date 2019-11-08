({
    doInit : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/r/CIF_Header__c/'+component.get("v.recordId")+'/edit?nooverride=true'
        });
        urlEvent.fire();
        
    },
    handleclose : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
		  
})