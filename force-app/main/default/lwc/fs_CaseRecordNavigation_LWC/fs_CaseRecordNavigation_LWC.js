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
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import { NavigationMixin } from 'lightning/navigation';
export default class DatatableEx12 extends NavigationMixin(LightningElement) {
    @track openmodel = true;
    @api recordId;
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT }) objectInfo;
    @api SelectedValueId;
    @track SelectedValueName;
    @track bShowModal = false;
    @track value;
    lmCaseRecordTypeId = '';
    @track error;
    @track data;
    @api recentlyUsedCaseListViewId;
    @api openLmRecordPage;
    @api caseRecordId;
    @api navigateToCaseHomePageFlag;
    //Colums to display Table for recordtypes
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

    /*****************************************************************************************
    	Method : handleContinue
    	Description : Redirect to case creation page based on the record type.
    ******************************************************************************************/
    connectedCallback() {
           console.log('workingg record iid--->'+this.SelectedValueId);
           if(this.navigateToCaseHomePageFlag){
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Case',
                    actionName: 'home'
                }
            });
           }
            if(this.openLmRecordPage){
                  
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.caseRecordId,
                        objectApiName: 'Case', // objectApiName is optional
                        actionName: 'view'
                    }
                });
            }
            else{
               
                this[NavigationMixin.Navigate]({
                    type: "standard__objectPage",
                    attributes: {
                        objectApiName: "Case",
                        actionName: "new"
                    },
                    state: {
                        nooverride: 1,
                        useRecordTypeCheck: 1,
                        navigationLocation: 'LIST_VIEW',
                        backgroundContext: '/lightning/o/Case/list?filterName=' + this.recentlyUsedCaseListViewId,
                        recordTypeId: this.SelectedValueId
                    }
                }); 
            }
            
    }
    
}