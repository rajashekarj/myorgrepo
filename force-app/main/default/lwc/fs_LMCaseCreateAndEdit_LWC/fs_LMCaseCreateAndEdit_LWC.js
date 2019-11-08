/* eslint-disable no-console */
/* eslint-disable no-alert */
/**************************************************************************************
LWC JS File         : fs_LMCaseCreateAndEdit_LWC
Function            : This JS is created to handle New LM case popup and Edit LM case.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sai            9/25/2019         Creating a custom LM case creation popup by using lightning record edit form     
                                   It will act as edit LM case form when user clicks on 'Edit' button on LM case record page.
                                   This LWC component included in 'FS_NewCaseButtonOverride' and 'FS_LMCaseCreateAndEdit' Aura
                                   components
*************************************************************************************/
import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getToAccn from '@salesforce/apex/FS_LMCaseController.toACNdetails';
import getToAccnOD from '@salesforce/apex/FS_LMCaseController.toACNODdetails';
import getFromAccn from '@salesforce/apex/FS_LMCaseController.fromAccnDetailsWrap';
import getFromAccnOD from '@salesforce/apex/FS_LMCaseController.fromACNODdetailswrpr';
import getSingleRt from '@salesforce/apex/FS_LMCaseController.getLMCaseRecordTypeID';
import getCaseDetails from '@salesforce/apex/FS_LMCaseController.getCaseDetails';
import saveCaseOd from '@salesforce/apex/FS_LMCaseController.saveCaseOD';
import updateCaseDetails from '@salesforce/apex/FS_LMCaseController.updateCaseDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TO_ACCOUNT_NOTE_LABEL from '@salesforce/label/c.FS_LM_case_detail_page_to_account_note';
import FROM_ACCOUNT_NOTE_LABEL from '@salesforce/label/c.FS_LM_case_detail_page_from_account_note';
import ACCOUNT_ERROR from '@salesforce/label/c.FS_case_account_error_alert_message';
import CASE_SUB_STATUS_ALERT from '@salesforce/label/c.FS_case_sub_status_alert_message';
const STATUS_ASSIGNED = 'Assigned';
const CASE_TYPE_ACCOUNT_TEAM_INITIATED_AMOA = 'Account Team Initiated AMOA';
const STATUS_JDE_AMS_HOLD = 'JDE AMS on Hold';
const CASE_TYPE_JDE_LINKAGE_REQUEST = 'JDE Linkage Request';
const STATUS_ACCOUNT_TEAM_HOLD = 'Account Team on Hold';
const STATUS_FINANCE_HOLD = 'Finance on Hold';
const STATUS_JDE_INSTALL_BASE_NOTIFIED = 'JDE Install Base Notified';
const LINKAGE_MANAGEMENT_Rec_Type = 'Linkage Management';
export default class LMCaseNew extends NavigationMixin(LightningElement) {
    @api recordId;  //if recordId varialbe is not empty means it is Edit LM case popup or else it is new LM case popup
    @track TO_ACCOUNT_NOTE = TO_ACCOUNT_NOTE_LABEL;
    @track FROM_ACCOUNT_NOTE = FROM_ACCOUNT_NOTE_LABEL;
    @track LM_Record_Type;
    @track ToAccountDetails;
    @track ToAccountODDetails;
    @track FromAccountODDetails;
    @track FromAccountDetails;
    @track caseNumber;
    @track selectedODIds = [];
    @track nonSelectedODIds = [];
    @track saveandNewButtonFlag = false;//flag use to set if user clicks on Save & New button
    @track isPopupSubmitButtonDisabled = false;
    @track openAlertModal = false;
    @track alertMesssage;
    connectedCallback() {
        this.getRecordTypeListId();
         //if recordId varialbe is not empty means it is Edit LM case popup or else it is new LM case popup
        if(this.recordId){
            this.getCaseDetailsFromApex();
        }
    }

   
    /*****************************************************************************************
       Method : getCaseDetailsFromApex
       Description : This method will call apex method imperatively and gets case details
   ******************************************************************************************/
    getCaseDetailsFromApex() {
        //if recordId varialbe is not empty means it is Edit LM case popup or else it is new LM case popup
        if(this.recordId){
        getCaseDetails({ caseId: this.recordId }).then(data => {
            if (data) {
               for (let i in data) {
                    if (data[i] !== null) {
                        this.caseStatus = data[i].Status;
                        this.caseSubStatus = data[i].LM_Sub_Status__c;
                        this.caseType = data[i].FS_New_Case_Type__c;
                        if( this.caseType === CASE_TYPE_ACCOUNT_TEAM_INITIATED_AMOA){
                            this.template.querySelector('[data-id="csType"]').value  = CASE_TYPE_ACCOUNT_TEAM_INITIATED_AMOA;
                        }
                        this.ToAccount = data[i].To_Account__c;
                        this.fromAccount = data[i].From_Account__c;

                        
                        if (this.ToAccount) {
                            this.template.querySelector('[data-id="toAccountField"]').value = this.ToAccount;
                            this.apexCalltoFillToAcnODDetails(this.ToAccount);
                        }

                        if (this.fromAccount) {
                            this.template.querySelector('[data-id="fromAccountField"]').value = this.fromAccount;
                            this.apexCalltoFillFromAcnODDetails(this.fromAccount);
                        }
                        
                    }
                }
            }
        }).catch(error => {
            this.error = error;
            
            this.showToastMessage('Case details error ',JSON.stringify(error),'error','sticky');
        });
    }
    }
    /*****************************************************************************************
        Method : getRecordTypeListId
        Description : This method will call apex method and sets LM case record type id
    ******************************************************************************************/

    getRecordTypeListId() {
        getSingleRt({ recordTypeName: LINKAGE_MANAGEMENT_Rec_Type }).then(data => {
            if (data) {
               this.LM_Record_Type = data[0].Id;
            }
        }).catch(error => {
            
            this.showToastMessage('Record Type error ',JSON.stringify(error),'error','sticky');
        });
    }

    /*****************************************************************************************
        Method : filToAcnDetails
        Description : This method will call apex method to get respective account details and 
        outlet dispenser detials. This method will invoke on 'onchange' event of 'To Account'
    ******************************************************************************************/
    filToAcnDetails(event) {
        this.apexCalltoFillToAcnODDetails(event.target.value);
    }
    /*****************************************************************************************
        Method : filFromAcnDetails
        Description : This method will call apex method to get respective account details and 
        outlet dispenser detials. This method will invoke on 'onchange' event of 'From Account'
    ******************************************************************************************/
    filFromAcnDetails(event) {
        this.apexCalltoFillFromAcnODDetails(event.target.value);

    }
    /*****************************************************************************************
        Method : apexCalltoFillToAcnODDetails
        Description : This method call apex method to retrieve 'To account' details along with 
        their Outlet dispensers information.
    ******************************************************************************************/
    apexCalltoFillToAcnODDetails(toAcnId) {
        if (toAcnId) {

            getToAccn({ toAccn: toAcnId })
                .then(result => {
                    this.ToAccountDetails = result;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.showToastMessage('To Account details error ',JSON.stringify(error),'error','sticky');
                });

            getToAccnOD({ toAccn: toAcnId })
                .then(result => {
                    this.ToAccountODDetails = result;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.showToastMessage('To Account OD details error ',JSON.stringify(error),'error','sticky');
                });
        }
    }
    FromAccountODDetailsCheck() {
        return this.FromAccountODDetails.length > 0 ? true : false;

    }

    /*****************************************************************************************
        Method : apexCalltoFillFromAcnODDetails
        Description : This method call apex method to retrieve 'From account' details along with 
        their Outlet dispensers information.
    ******************************************************************************************/
    apexCalltoFillFromAcnODDetails(fromAcnId) {
        if (fromAcnId) {
            getFromAccn({ fromAccn: fromAcnId })
                .then(result => {
                    this.FromAccountDetails = result;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.showToastMessage('From Account details error ',JSON.stringify(error),'error','sticky');
                });

            getFromAccnOD({ fromAccn: fromAcnId, caseId: this.recordId })
                .then(result => {
                    this.FromAccountODDetails = result;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.showToastMessage('From Account OD details error ',JSON.stringify(error),'error','sticky');
                });
        }
    }
    saveNewButtonFlag(event) {
        this.saveandNewButtonFlag = true;
    }

    /*****************************************************************************************
        Method : handleLMCaseSubmit
        Description : This method will invoke when save / save & new button clicked on LM case creation form
                     Before submitting the form it will check the custom validations(To Account and 
                     From Account should not be same). There are two separate form submissions here. One is for
                     New LM case scenario(Javascript Submission) and another is for Edit LM case scenario(Apex submission)
    ******************************************************************************************/
    handleLMCaseSubmit(event) {
        event.preventDefault();
        if (this.customValidations()) {
            this.isPopupSubmitButtonDisabled = true;
            const fields = event.detail.fields;
            if(fields.FS_New_Case_Type__c === '' && this.caseType === CASE_TYPE_ACCOUNT_TEAM_INITIATED_AMOA){
                fields.FS_New_Case_Type__c = CASE_TYPE_ACCOUNT_TEAM_INITIATED_AMOA;
            }
            //If condition to check whether LM case submission is 'Edit' or 'New'
            if(this.recordId){
                const caseDetails = {
                    cs: {
                        FS_New_Case_Type__c : fields.FS_New_Case_Type__c,
                        Issue_Name__c:fields.Issue_Name__c,
                        Status: fields.Status,  
                        LM_Sub_Status__c: fields.LM_Sub_Status__c,
                        To_Account__c : fields.To_Account__c,
                        From_Account__c : fields.From_Account__c,
                        Priority: fields.Priority,
                        Id:this.recordId
                    } 
                  }
                  //Calling apex method to update case details
                  updateCaseDetails(caseDetails)
                  .then(result => {
                      //Calling a method to update the 'From Account' outlet dispenser details
                      this.saveFromAccountOutletDispensersApex(this.recordId);
                  })
                  .catch(error => {
                      this.error = error;
                      this.showToastMessage('LM Case update error ',JSON.stringify(error),'error','sticky');
                  });
            } else {
                // New LM case submission
                let els = this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
            
              
            } 

    }
    /*****************************************************************************************
        Method : handleFormSuccess
        Description : This method will invoke after the LM case form submission get success in New LM case.
        In this method, the selected Outlet dispensers under the from account and saves in backend
    ******************************************************************************************/
    handleFormSuccess(event) {
        this.saveFromAccountOutletDispensersApex(event.detail.id);       
    }
     /*****************************************************************************************
        Method : handleFormSuccess
        Description : This method will invoke when a user clicks on 'save' button on New/Edit LM Case popup.
        In this method, the selected Outlet dispensers under the from account and saves in backend
    ******************************************************************************************/
   saveFromAccountOutletDispensersApex(lmCaseId){
        var recordId = lmCaseId;
        this.selectedODIds = [];
        this.nonSelectedODI = [];
        //retrieving selected or non selected from account outlet dispensers from html
        let els = this.template.querySelectorAll('[data-id="selectedOd"]');
        // data-item attribute holds the Outlet dispenser ID for each OD row on the 'From Account' OD table 
        els.forEach((v) => {
            if (v.checked) {
                this.selectedODIds.push(v.dataset.item);

            } else {
                this.nonSelectedODIds.push(v.dataset.item);
            }

        });
        //apex call to save outlet dispensers
        saveCaseOd({ caseId: recordId, selectedOdList: this.selectedODIds, nonSelectedOdList: this.nonSelectedODIds })
            .then(result => {
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                
                this.showToastMessage('OD update error ',JSON.stringify(error),'error','sticky');
            });
        // firing an success toast event    
        this.showToastMessage('Success! ','Case was submitted','success','dismissable');
        //if user clicks on 'Save & New' it will go inside the if condition and opens a new LM case popup
        //if users clicks on Save button page redirects to LM case record page
        if (this.saveandNewButtonFlag) {
            this.saveandNewButtonFlag = false;
            //navigateToCaseRecordPage Event : To open LM Case Record Page for Console app
            const navigateToCaseRecordPage = new CustomEvent('openCaseRecordPage', {
                detail: { recordId },
            });
            this.dispatchEvent(navigateToCaseRecordPage);
       
           // LWC navigation to open lightning component
            this[NavigationMixin.Navigate]({
                type: "standard__component",
                attributes: {
                    componentName: "c__FS_LMCaseCreateAndEdit"
                }
            });
        } else {
            this.isPopupSubmitButtonDisabled = false;
            //navigateToCaseRecordPage Event : To open LM Case Record Page for Console app and Communities
            const navigateToCaseRecordPage = new CustomEvent('openCaseRecordPage', {
                detail: { recordId },
            });
            this.dispatchEvent(navigateToCaseRecordPage);
            const navigateToCaseRecordPageForCommunities = new CustomEvent('openCaseRecordPageForCommunities', {
                detail: { recordId },
            });
            this.dispatchEvent(navigateToCaseRecordPageForCommunities);
            //closeDetailPageOnEdit Event : To Close detail page when user clicks save button after edit for console app
            const closeDetailPageOnEdit = new CustomEvent('saveforEdit', {
                detail: { recordId },
            });
            this.dispatchEvent(closeDetailPageOnEdit);


        }
    }
    /*****************************************************************************************
        Method : navigateToCaseRecordPage
        Description : This method will navigate to case record detail page
    ******************************************************************************************/
    navigateToCaseRecordPage(caseRecordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseRecordId,
                objectApiName: 'Case', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
    /*****************************************************************************************
        Method : customValidations
        Description : This method will do custom validations (To Account and 
                     From Account should not be same)
    ******************************************************************************************/
    customValidations() {
        let flag = true;
        let toAcnId = this.template.querySelector('[data-id="toAccountField"]').value;
        let fromAcnId = this.template.querySelector('[data-id="fromAccountField"]').value;
        let lmCaseType = this.template.querySelector('[data-id="csType"]').value;
        let lmCaseSubStatus = this.template.querySelector('[data-id="subStatusField"]').value;
        let lmCaseStatus = this.template.querySelector('[data-id="statusField"]').value;
        if (toAcnId === fromAcnId) {
            //this.showToastMessage('LM case save error ',ACCOUNT_ERROR,'error','sticky');
            this.showAlertModalMethod(ACCOUNT_ERROR);
            flag = false;
            this.saveandNewButtonFlag = false;
        } else if (lmCaseStatus === STATUS_ASSIGNED && lmCaseType === CASE_TYPE_JDE_LINKAGE_REQUEST && (lmCaseSubStatus === STATUS_ACCOUNT_TEAM_HOLD || lmCaseSubStatus === STATUS_FINANCE_HOLD || lmCaseSubStatus === STATUS_JDE_INSTALL_BASE_NOTIFIED)) {

            this.showAlertModalMethod(CASE_SUB_STATUS_ALERT);
            flag = false;
            this.saveandNewButtonFlag = false;
        } else if (lmCaseStatus === STATUS_ASSIGNED && lmCaseType === CASE_TYPE_ACCOUNT_TEAM_INITIATED_AMOA && (lmCaseSubStatus === STATUS_ACCOUNT_TEAM_HOLD || lmCaseSubStatus === STATUS_JDE_AMS_HOLD)) {

           this.showAlertModalMethod(CASE_SUB_STATUS_ALERT);
            flag = false;
            this.saveandNewButtonFlag = false;
        }
        return flag;
    }
    /*****************************************************************************************
       Method : redirectBack
       Description : This method will redirect back to case home page in case of New lm case creation,
       or,it will redirect back to case record detail page in case of LM case edit.
   ******************************************************************************************/
    redirectBack() {
        var close = true;
        // eslint-disable-next-line no-restricted-globals
        this.openmodel = false;
        //closeConsoleAppRecordSelectionTab Event : To close current focused tab on click of cancel button in console app
        const closeConsoleAppRecordSelectionTab = new CustomEvent('closeTabbb', {
            detail: { close },
        });
        // Fire the custom event
        this.dispatchEvent(closeConsoleAppRecordSelectionTab);
        //Checking if the recordId is set.
        //if recordId is set means it is Edit LM case popup or else it is new LM case popup
        if (this.recordId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Case', // objectApiName is optional
                    actionName: 'view'
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Case',
                    actionName: 'home'
                }
            });
        }
    }
   
    /*****************************************************************************************
        Method : openOutletDispenserPage
        Description : This method will invoke when user clicks on the OD number below To Account
        and From Account on the LM case record detail page. It will open Outlet Dispenser record 
        page in a new tab.
    ******************************************************************************************/
    openOutletDispenserPage(event) {
        window.open(window.location.origin + '/lightning/r/FS_Outlet_Dispenser__c/' + event.currentTarget.dataset.id + '/view', '_blank');
    }
    /*****************************************************************************************
        Method : showToastMessage
        Description : This is a common method to display toast messages. In case of success the message will
        be disappear in 3 seconds and in case of any apex errors it will open until user clicks on 'x' mark.
        Toast mode - Sticky - Visible until user clicks 'x' mark
        Toast mode - dismissable - Toast will disappear in 3 seconds
    ******************************************************************************************/
    showToastMessage(toastTitle,toastMessage,ToastVariant,ToastMode){
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: ToastVariant,
            mode: ToastMode
        });
        this.dispatchEvent(evt);
    }
    /*****************************************************************************************
        Method : showAlertModalMethod
        Description : This method will open modal popup to display custom error messages.
    ******************************************************************************************/
    showAlertModalMethod(message){
        this.alertMesssage = message;
        this.openAlertModal = true;
    }
    /*****************************************************************************************
        Method : closeAlertModalMethod
        Description : This method will close modal popup of custom error messages.
    ******************************************************************************************/
    closeAlertModalMethod(){
        this.alertMesssage = '';
        this.openAlertModal = false;
    }

}