/* eslint-disable no-console */
/* eslint-disable no-alert */
/**************************************************************************************
LWC JS File         : fs_CaseRecordTypeSelection_LWC
Function            : This JS is created to handle Non custom case record type selection.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sai            8/26/2019        For LM Case record type it will open a custom LWC component 
                                  and for remaining it will open standard case creation popups
*************************************************************************************/
import { LightningElement, wire, track, api } from 'lwc';
import getCaseRecordTypeList from '@salesforce/apex/FS_CaseRecordTypeController.getCaseRecordTypeList';
import getCaseListViewID from '@salesforce/apex/FS_CaseRecordTypeController.getCaseListViewID';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
/**Constant variables declaring starts here */
const RT_LINKAGE_MANAGEMENT = 'Linkage Management';
export default class DatatableEx12 extends NavigationMixin(LightningElement) {
    
    /**Track variables and public api varialbes declaration starts here */
    
    @track openmodel = true;
    @api recordId;
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT }) objectInfo;
    @track SelectedValueId;
    @track SelectedValueName;
    @track bShowModal = false;
    @track value;
    lmCaseRecordTypeId = '';
    @track error;
    @track data;
    @track recentlyUsedCaseListViewId;
    @track items = []; //this will hold key, value pair
    /**Track variables and public api varialbes declaration ends here */
    /**Columns to display as Table on the record type selection popup**/
    @track columns = [{
        label: 'Record Type Label',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    },
    {
        label: 'Description',
        fieldName: 'Description',
        type: 'text',
        sortable: true
    }
    ];
    /**Columns to display Table for recordtypes ends here**/

    /*****************************************************************************************
         Method : getCaseRecordTypeList
         Description : Wire Method (Apex call) to get all the case record types list. In backend 
         apex, it will return record types based on the logged in user mode.
     ******************************************************************************************/
    @wire(getCaseRecordTypeList) getRTList({ error, data }) {
        if (data) {
            this.data = data;
            console.log(JSON.stringify(data, null, '\t'));
        } else if (error) {
            this.showToastMessage('system exception ',JSON.stringify(this.error),'error','sticky');
        }
    }
    
    /*****************************************************************************************
    	Method : getCaseListViewID
        Description : Wire Method (Apex call) to get case 'Recently Viewed Cases' List view id. 
        This id we are setting to display case list view page on New Non LM cases record creation popup.
    ******************************************************************************************/
    @wire(getCaseListViewID) caseListViewDetails({ error, data }) {
        if (data) {
            this.recentlyUsedCaseListViewId = data[0].Id;
           // console.log('Case /Recently Used Cases/ List view id ' + this.recentlyUsedCaseListViewId);
        } else if (error) {
            this.error = error;
           
            this.showToastMessage('system exception ',JSON.stringify(this.error),'error','sticky');
        }
    }


    /*****************************************************************************************
    	Method : getCaseRecordTypeList
        Description : Wire Method (Apex call) to get all case record types list and arrange them as picklist
                      field on the record type selection popup.
    ******************************************************************************************/
    @wire(getCaseRecordTypeList) wiredCaseRecTypes({ data,error }) {
        if (data) {
            //Arranging the picklist value and label
            let i = 0;
            for (i = 0; i < data.length; i++) {
                this.items = [...this.items, { value: data[i].Id, label: data[i].Name }];
                // Making the first record type which comes from above 'getCaseRecordTypeList' as default on initial loading of popup
                if (i===0) {
                    this.value = data[i].Id;
                    this.SelectedValueId = data[i].Id;
                }/** Saving LM case record type id in to a separate variable to navigate to custom LWC component after clicking on 'Continue' button
                     on the record type selection popup */
                if (data[i].Name ===  RT_LINKAGE_MANAGEMENT)
                    this.lmCaseRecordTypeId = data[i].Id;
            }
            this.error = undefined;
        } else if(error){
            this.error = error;
            
            this.showToastMessage('system exception ',JSON.stringify(this.error),'error','sticky');
        }
    }
    //gettter to return items which is mapped with options attribute
    get caseRecTypes() {
        return this.items;
    }
    //Value selected in Combobox.  
    newSelectedValue(event) {
        this.SelectedValueId = event.detail.value;

    }

    /************************************************************************************************************
    	Method : handleContinue
        Description : Redirect to case creation page based on the record type selected where we
                      can create new case. If we use normal LWC navigationmixin to open new case creation popup, in console app
                      the popup is opening in a separate tab. So to eliminate this behaviour, firing an DOM 
                      event in LWC(child) and handling that event in Aura(parent) to open case creation popup.
    ***********************************************************************************************************/
    handleContinue() {
       
        if (this.SelectedValueId !== this.lmCaseRecordTypeId) {
            this.openNonLmCase(this.SelectedValueId,this.recentlyUsedCaseListViewId);
           
        } else {
            //Initialising an custom DOM event to open LM case creation popup.
            const closeclickedevt = new CustomEvent('openLmInParentTab', {
                detail: { close },
            });
            //Firing the event.
            this.dispatchEvent(closeclickedevt);
            
        }
    }
    /************************************************************************************************************
    	Method : openNonLmCase
        Description : Firing an custom DOM event to open Non LM case creation popup. If we use normal LWC navigationmixin to open new case creation popup, in console app
                      the popup is opening in a separate tab. So to eliminate this behaviour, firing an DOM 
                      event in LWC(child) and handling that event in Aura(parent) to open case creation popup.
    ***********************************************************************************************************/
  
    openNonLmCase(id,listViewId){
        var recordTypeId =  id;
        var listId = listViewId;
        //Initialising an custom DOM event to open Non LM case creation popup.
        const fireLWCtoAuraEvent = new CustomEvent('openNonLmCase', {
            detail: { recordTypeId ,listId  },
        });
        //Firing the event.
        this.dispatchEvent(fireLWCtoAuraEvent); 
    }

    closeModal() {
        this.openmodel = false;
    }
    /*****************************************************************************************
       Method : navigateToCaseListView
       Description : Method to navigate to case object home page/ Case List view when clicked 
                     on close button.It returns to the 'recently viewed cases' list page.
   ******************************************************************************************/
    navigateToCaseList() {
        var close = true;
        this.openmodel = false;
        
        const closeConsoleAppRecordSelectionTab = new CustomEvent('closeTab', {
            detail: { close },
        });

         // Fire the custom event
         this.dispatchEvent(closeConsoleAppRecordSelectionTab); 

         //LWC Navigation to open case home page
         this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'home'
            }
        });
    }
    showToastMessage(toastTitle,toastMessage,ToastVariant,ToastMode){
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: ToastVariant,
            mode: ToastMode
        });
        this.dispatchEvent(evt);
    }
}