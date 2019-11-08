({
	doInit : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");
        var recId = component.get("v.recordId");
        urlEvent.setParams({
              "url": "/apex/FSCustomerInputForm?Accid="+recId,
              "isredirect": "true"
            });
        urlEvent.fire();
	}
})