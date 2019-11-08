({
    //Gets called on component load
    init: function (cmp, event, helper) {
        helper.constructTable(cmp);
        helper.getData(cmp);
    },
    
    //Method to update the table sorting
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        var fromsort = true;
        helper.sortData(cmp, fieldName, sortDirection,fromsort);
    },
    
    //Handle the childToparentEvent event and sets the selected recordTypes
    handleComponentEvent : function(cmp, event) {
        var recordTypeString = event.getParam("message");
		
        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", recordTypeString);
        var recordTypearray = recordTypeString.toString().split(',');
        cmp.set("v.recordTypesSelected", recordTypearray);        
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
        
        var getFilteredArtifacts = cmp.get("c.getTargetArtifacts");
        getFilteredArtifacts.setParams({RecordTypeList : cmp.get("v.recordTypesSelected"), 
                                        recordId : cmp.get("v.recordId")});
        
        getFilteredArtifacts.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(getFilteredArtifacts);
    },
    
    //method to handle the actions performed on table header
    handleHeaderAction: function (cmp, event, helper) {
        // Retrieves the name of the selected filter
        var actionName = event.getParam('action').name;
        
        // Retrieves the current column definition based on the selected filter
        var colDef = event.getParam('columnDefinition');
        var columns = cmp.get('v.mycolumns');
        var activeFilter = cmp.get('v.activeFilter');
        if (actionName !== activeFilter) {
            var idx = columns.indexOf(colDef);
            // Update the column definition with the updated actions data
            var actions = columns[idx].actions;
            actions.forEach(function (action) {
                action.checked = action.name === actionName;
            });
            cmp.set('v.activeFilter', actionName);
            helper.updateTargetArtfiacts(cmp);
            cmp.set('v.mycolumns', columns);
        }
    }
})