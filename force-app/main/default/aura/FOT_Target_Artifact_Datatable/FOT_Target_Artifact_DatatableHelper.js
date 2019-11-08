({
    // Getting the Traget Artifact records data specific to od record id
    getData : function(cmp,helper) { 
        var action = cmp.get('c.getTargetArtifactsOnLoad');
        action.setParams({
            recordId : cmp.get("v.recordId")
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
                var fromsort = false;
                this.sortData(cmp, cmp.get("v.sortedBy"), cmp.get("v.sortedDirection"),fromsort);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },
    
    // Method To add sort functionality to the table columns
    sortData: function (cmp, fieldName, sortDirection,fromsort) { 
        var data = cmp.get("v.mydata");
        
        if( fromsort ){
            if(data.length > 0 ){
                var reverse = sortDirection !== 'asc'; // Setting sort direction as ascending
                data.sort(this.sortBy(fieldName, reverse)) // Using standard 'sort' method on data object and calling controller js 'sortBy' method
                cmp.set("v.mydata", data);    
            }
            else if(data.length === 0 ){                
                // Enable 'notifLib' notification and set nitification attribute values
                cmp.find('notifLib').showNotice({
                    "variant":"error",
                    "header": "No Records",
                    "message":"No records to sort...",
                });
                //End of error notification
            }
        }        
    },
    
    // Setting to sorting column  with sort direction
    sortBy: function (field, reverse, primer) { 
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    
    //method to update the target artifacts table
    updateTargetArtfiacts: function (cmp) {
        var rows = cmp.get('v.rawData');
        var activeFilter = cmp.get('v.activeFilter');
        var filteredRows = rows;
        if (activeFilter !== 'all') {
            filteredRows = rows.filter(function (row) {
                return (activeFilter === 'show_base' || activeFilter === 'show_actual');
            });
        }
        cmp.set('v.mydata', filteredRows);
    },
    
    //method to construct the targetArtifact datatable
    constructTable: function(cmp) { 
        var headerActions = [
            {
                label: 'All',
                checked: true,
                name:'all'
            },
            {
                label: 'Base',
                checked: false,
                name:'show_base'
            },
            {
                label: 'Actual',
                checked: false,
                name:'show_actual'
            },
        ];
            
            // Adding columns to the table and matching individual column with Target Artifact fields
            cmp.set('v.mycolumns', [
            {label: 'Artifact Name', fieldName: 'name', type: 'text'},
            {label: 'Record Type', fieldName: 'RcrdType', type: 'text',sortable:'true'},
            {label: 'Artifact Type', fieldName: 'ArtifactType', type: 'text'},
            {label: 'Ruleset', fieldName: 'Ruleset', type: 'text'}
        ]);
        
    }
    
})