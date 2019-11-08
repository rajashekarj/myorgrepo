({
    doInit : function(component, event, helper) {
        helper.reInit(component, event, helper);
        //disabling Right click and F12 key
        document.addEventListener('contextmenu', event => event.preventDefault());
        document.onkeydown = function(e) {
            if(e.keyCode == 123) {                
                e.preventDefault();
            } 
        };
        //end of disabling Right click and F12 key
    },
    clickSimulate: function(component, event, helper) {
        var recordId=component.get("v.recordId");
        var actionSimulate=component.get("c.simulateRuleset");
        var respmsg, correctedrespmsg;
        
        actionSimulate.setParams({
            recordId : recordId
        });
        
        actionSimulate.setCallback(this, function(response) {
            var state = response.getState();
            
            //to display Simulate response on the component
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.isSimulate", true);
                respmsg = response.getReturnValue();
                correctedrespmsg=respmsg.replace(/<br>/g, '<br/>');  
                component.set("v.responseMsg",correctedrespmsg);
            }
        });
        $A.enqueueAction(actionSimulate);
    },
    closeSimModalEdit: function(component, event, helper) {
        component.set("v.isOpen", false);
        component.set("v.isSimulate", false);
        component.set("v.conPromote", false);
        
        //To refresh view and reload entire page
        helper.reInit(component, event, helper);
        $A.get('e.force:refreshView').fire();     
        
    },
    closeProModalEdit: function(component, event, helper) {
        component.set("v.isOpen", false);
        component.set("v.isSimulate", false);
        component.set("v.conPromote", false);
    },
    clickPromote: function(component, event, helper) {
        component.set("v.isOpen", false);
        component.set("v.spinner",true);
        var recordId=component.get("v.recordId");
        var actionPromote=component.get("c.promoteRuleset");
        var respmsg, correctedrespmsg;
        
        actionPromote.setParams({
            recordId : recordId
        });
        
        actionPromote.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.spinner",false);
                
                //to display Promotion message from the webcall
                if(response.getReturnValue()!=null && response.getReturnValue().valid != null)
                {
                    //to show error message on Promotion
                    if(!response.getReturnValue().valid)
                    {
                        component.find('notifLibEdit').showNotice({
                            "variant":"error",
                            "header": "Error While Promote",
                            "message":response.getReturnValue().message ,
                        });  
                    }
                    else
                    {  
                        
                        //to show Success message on Promotion
                        component.set("v.isOpen", true);
                        respmsg=response.getReturnValue().message;
                        correctedrespmsg=respmsg.replace(/<br>/g, '<br/>');
                        component.find("promConBtn").set("v.label",response.getReturnValue().yesMsg);
                        component.find("proBtn").set("v.label",response.getReturnValue().noMsg);
                        
                        component.set("v.responseMsg",correctedrespmsg);                        
                        component.set("v.hashCode",response.getReturnValue().hashCode);
                        
                        //to format the response message to display on the component
                        var text=response.getReturnValue().textArea;
                        var text1=text.replace(/:\[/g,':<br/>&emsp;');
                        var text2 = text1.replace(/\],/g,',<br/>');
                        var text3 = text2.replace(/,/g,',<br/>');
                        text=text.substring(1,text.length-1);
                        
                        var strsplit=text.split("]");
                        var str21,str22,str31,str32, finalstr="";
                        
                        for(var i=0;i<strsplit.length;i++)
                        {
                            str21=strsplit[i].split("[");
                            if(str21.length == 2 && str21[1] == "" ){
                                str22=str21[0].substring(1,str21[0].length);
                                str22=str22+"<br/>&emsp;{<br/>&emsp;},<br/>";
                                finalstr = finalstr+str22;
                            }
                            else{                                
                                for(var j=0;j<str21.length;j++){
                                    console.log(" --- str21 [j] --- j "+j+" ==== value === "+ str21[j]);
                                    if(str21[j].indexOf(',') == 0){
                                        str22=str21[j].substring(1,str21[j].length);
                                    }
                                    else{
                                        str22=str21[j];
                                    }
                                    
                                    str22=str22.replace(/,/g,",<br/>&emsp;&emsp;&emsp;");
                                    str22=str22.replace(new RegExp('{','g'),"<br/>&emsp;{<br/>&emsp;&emsp;&emsp;");
                                    str22=str22.replace(new RegExp('}','g'),"<br/>&emsp;},<br/>");
                                    
                                    if( str22.indexOf('},<br/>,<br/>&emsp;&emsp;&emsp;<br/>&emsp;{' !== -1 ) ){
                                        str22=str22.replace(new RegExp('},<br/>,<br/>&emsp;&emsp;&emsp;<br/>&emsp;{','g'),"},<br/>&emsp;{");
                                    }
                                    
                                    finalstr = finalstr+str22;
                                }
                            }
                            
                        }
                        
                        if( (finalstr.length - 6) == finalstr.lastIndexOf(',') ){
                            finalstr=finalstr.substring(0,finalstr.lastIndexOf(','));
                        } 
                        //end of response formatting
                        component.set("v.textArea",finalstr);
                    }
                }else{
                    component.set("v.isOpen", true);
                    component.set("v.responseMsg",response.getReturnValue());
                }
                
            }
        });
        
        $A.enqueueAction(actionPromote);
    },
    clickPromoteContinue: function (component, event, helper) {
        
        /*var ruleSetName=component.get("v.ruleSetName");
        var hashCode=component.get("v.hashCode");
        var recordId=component.get("v.recordId");
        component.set("v.spinner",true);
        
        var actionfinalPromote=component.get("c.finalPromote");
        actionfinalPromote.setParams({
            ruleSetName : ruleSetName,
            hashcode : hashCode,
            recordId : recordId
            
        });
        
        actionfinalPromote.setCallback(this, function(response) {
            var state = response.getState();
            var concVal = response.getReturnValue();
            if (component.isValid() && state === "SUCCESS" && concVal) {
                component.set("v.isOpen", false);
                component.set("v.spinner",false);
                console.log('test result true');
            }else{
                console.log('test result false');
                component.set("v.isOpen", false);
                component.find('notifLibEdit').showNotice({
                    "variant":"error",
                    "header": "Error While Promote",
                    "message": $A.get("$Label.c.FOT_Promote_ConError"),
                }); 
                component.set("v.spinner",false);
                console.log('test result false');
            }
        });
        $A.enqueueAction(actionfinalPromote);
        */
       
        //To refresh view and reload entire page        
        helper.finalPromoteContinue(component, event, helper);
        helper.reInit(component, event, helper);
        $A.get('e.force:refreshView').fire();
        
    },
    // Onclick on New Artifact navigate to Create Artifact Component with Ruleset Name.
    newArtifact:function(component,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:FOT_CreateArtifact",
            componentAttributes: {
                selectedLookUpRecord : component.get("v.ruleSet")// Passing Ruleset Object
            }
        });
        
        evt.fire();
    },
    clickRefreshView:function(component,event,helper){
        helper.reInit(component, event, helper);
        $A.get('e.force:refreshView').fire();
    }
})