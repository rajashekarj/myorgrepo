/* eslint-disable no-console */
/* eslint-disable no-alert */
/**************************************************************************************
LWC JS File         : fs_LMCaseDetailPage_LWC
Function            : This JS is created to display To Account and From Account details on LM case record detail page.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sai            9/25/2019        Lightning form used to display To Account and From Account on the LM case record detail page. 
                                  On loading the form it will call apex methods to retrieve respective account
                                  details and Outlet dispensers details     
*************************************************************************************/
import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCaseDetails from '@salesforce/apex/FS_LMCaseController.getCaseDetails';
import getToAccn from '@salesforce/apex/FS_LMCaseController.toACNdetails';
import getToAccnOD from '@salesforce/apex/FS_LMCaseController.toACNODdetails';
import getFromAccn from '@salesforce/apex/FS_LMCaseController.fromAccnDetailsWrap';
import getFromAccnOD from '@salesforce/apex/FS_LMCaseController.fromACNODdetailswrpr';
import getSingleRt from '@salesforce/apex/FS_LMCaseController.getLMCaseRecordTypeID';
import TO_ACCOUNT_NOTE_LABEL from '@salesforce/label/c.FS_LM_case_detail_page_to_account_note';
import FROM_ACCOUNT_NOTE_LABEL from '@salesforce/label/c.FS_LM_case_detail_page_from_account_note';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class LMCaseDetailPageButtons extends NavigationMixin(LightningElement) {
    @api recordId;
    @track TO_ACCOUNT_NOTE = TO_ACCOUNT_NOTE_LABEL;
    @track FROM_ACCOUNT_NOTE = FROM_ACCOUNT_NOTE_LABEL;
    @track LM_Record_Type;
    @track ToAccountDetails;
    @track ToAccountODDetails;
    @track FromAccountODDetails;
    @track FromAccountDetails;
    @track createFactModalPopup = false;
    @track ToAccount;
    @track OutletDispensersFactList;
    @track hoverAccountId;
    @track left;
    @track top;
    toAccountName;
    fromAccountName;
    @track accountName;
    @track fromAccount;
   /*****************************************************************************************
        Method : connectedCallback
        Description : This method will invoke when the component initialise and get case Details 
        and LM case record type
    ******************************************************************************************/
    connectedCallback(){
        this.getCaseDetailsFromApex();
        this.getRecordTypeListId();
    }
    /*****************************************************************************************
        Method : getRecordTypeListId
        Description : This method will call apex method imperatively and retrieve LM case record type id
    ******************************************************************************************/
    getRecordTypeListId(){
        getSingleRt({recordTypeName : 'Linkage Management'}).then( data =>{
            if (data) {
                this.LM_Record_Type = data[0].Id;
            }
        }).catch(error=> {
        
            this.showToastMessage('Record Type Retrieving Error ',JSON.stringify(error),'error','sticky');
        });
    }
     /*****************************************************************************************
        Method : getCaseDetailsFromApex
        Description : This method will call apex method imperatively and get case details
    ******************************************************************************************/
    getCaseDetailsFromApex(){
       
        getCaseDetails({caseId:this.recordId}).then(data => {
        if(data){
            
            for (let i in data) {
                if (data[i] !== null) {
                    this.caseStatus = data[i].Status;
                    this.caseSubStatus = data[i].LM_Sub_Status__c;
                    this.caseType = data[i].FS_New_Case_Type__c;
                    this.ToAccount = data[i].To_Account__c;
                    this.fromAccount = data[i].From_Account__c;
                    if(data[i].To_Account__r.Name)
                        this.toAccountName = data[i].To_Account__r.Name;

                    if(data[i].From_Account__c)
                         this.fromAccountName = data[i].From_Account__r.Name;

                    if (this.ToAccount){
                        this.apexCalltoFillToAcnODDetails(this.ToAccount);
                    }
                        
                    if (this.fromAccount){
                        this.apexCalltoFillFromAcnODDetails(this.fromAccount);
                    }
                }
        }
    }
    }).catch(error =>{
        this.error = error;
        this.showToastMessage('Case details retrieving Error ',JSON.stringify(error),'error','sticky');
    });
    }
     
    /*****************************************************************************************
        Method : apexCalltoFillToAcnODDetails
        Description : This method call apex method to retrieve 'To account' details along with 
        their Outlet dispensers information.
    ******************************************************************************************/
    apexCalltoFillToAcnODDetails(toAcnId) {
        getToAccn({ toAccn: toAcnId })
            .then(result => {
                this.ToAccountDetails = result;
                this.error = undefined;
            })
            .catch(error => {
              this.error = error;
              this.showToastMessage('To Account details retrieving error ',JSON.stringify(error),'error','sticky');
            });

        getToAccnOD({ toAccn: toAcnId })
            .then(result => {
                this.ToAccountODDetails = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
              this.showToastMessage('To Account details OD retrieving error ',JSON.stringify(error),'error','sticky');
            });
    }
    /*****************************************************************************************
        Method : apexCalltoFillFromAcnODDetails
        Description : This method call apex method to retrieve 'From account' details along with 
        their Outlet dispensers information.
    ******************************************************************************************/
    apexCalltoFillFromAcnODDetails(fromAcnId) {

        getFromAccn({ fromAccn: fromAcnId })
            .then(result => {
                this.FromAccountDetails = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
              this.showToastMessage('From Account details retrieving error ',JSON.stringify(error),'error','sticky');
            });

        getFromAccnOD({ fromAccn: fromAcnId, caseId: this.recordId })
            .then(result => {
                this.FromAccountODDetails = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.showToastMessage('From Account OD details retrieving error ',JSON.stringify(error),'error','sticky');
            });
    }
   
    FromAccountODDetailsCheck() {
       return this.FromAccountODDetails.length > 0 ? true : false;
    }
    
   /*****************************************************************************************
        Method : openOutletDispenserPage
        Description : This method will invoke when user clicks on the OD number below To Account
        and From Account on the LM case record detail page. It will open Outlet Dispenser record 
        page in a new tab.
    ******************************************************************************************/
   openOutletDispenserPage(event){
       window.open(window.location.origin+'/lightning/r/FS_Outlet_Dispenser__c/'+event.currentTarget.dataset.id+'/view','_blank');
   }
   openAccount(event){
    window.open(window.location.origin+'/lightning/r/Account/'+event.currentTarget.dataset.id+'/view','_blank');
   }
   showToastMessage(toastTitle,toastMessage,ToastVariant,ToastMode){

    // eslint-disable-next-line no-undef
     /*****************************************************************************************
        Method : showToastMessage
        Description : This is a common method to display toast messages. In case of success the message will
        be disappear in 3 seconds and in case of any apex errors it will open until user clicks on 'x' mark.
        Toast mode - Sticky - Visible until user clicks 'x' mark
        Toast mode - dismissable - Toast will disappear in 3 seconds
    ******************************************************************************************/
    const evt = new ShowToastEvent({
        title: toastTitle,
        message: toastMessage,
        variant: ToastVariant,
        mode: ToastMode
    });
    this.dispatchEvent(evt);
}
   
}