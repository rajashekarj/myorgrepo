({
    getBarCode:function(cmp,evt,result){
        $A.util.removeClass(cmp.find('_barCode'),"slds-hide");
        var barcodeval=cmp.get("v.barCode");
        if( result.data !== undefined  && ! $A.util.isUndefinedOrNull(barcodeval) ){
            var _result = JSON.parse(result.data);            
            var barCode = 'NULL';
            try{
                barCode = _result.codeResult.code;
            }catch(e){
                console.log('result is ', _result);
            }
            cmp.set('v.barCode',barCode);
            $A.util.addClass(cmp.find('_spinner'),"slds-hide");
        }
        else{
            cmp.set('v.barCode','NULL');
            cmp.set('v.errorMsg','Unable to read barcode.');
            $A.util.addClass(cmp.find('_spinner'),"slds-hide");            
        }
        
        
    },
    getBarCodeRecords:function(cmp,evt){
        var spinner = cmp.find("_spinner");
        $A.util.addClass(spinner, "slds-show");
        
        var barcodeval=cmp.get("v.barCode");
        if( ! $A.util.isUndefinedOrNull(barcodeval) )
        {
            //console.log("cmp.isValid()  "+cmp.isValid() );
            cmp.set('v.errorMsg','No matching records found.');
            var action = cmp.get("c.BarcodeMatchODList");
            action.setParams({
                barCode: cmp.get("v.barCode")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(cmp.isValid() && state === "SUCCESS"){
                    console.log(response.getReturnValue().errString);
                        cmp.set("v.listNull",false);
                        //cmp.set("v.ODList",response.getReturnValue());
                        cmp.set("v.objClassController",response.getReturnValue());
                        $A.util.removeClass(spinner, "slds-show");
                }
                if(response.getReturnValue().listOutlets.length == 0){
                    cmp.set("v.listNull",true);
                    $A.util.removeClass(spinner, "slds-show");
                }
            });
            $A.enqueueAction(action);
        }
        else{
            $A.util.addClass(cmp.find('_spinner'),"slds-hide");
        }
    }
})