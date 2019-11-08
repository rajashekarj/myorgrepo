({ 
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        var recordId = component.get("v.recordId");
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/' + recordId
        });
        urlEvent.fire();
        
    }
})