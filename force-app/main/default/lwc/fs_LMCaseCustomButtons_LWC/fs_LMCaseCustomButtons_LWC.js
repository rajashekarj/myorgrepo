/* eslint-disable no-console */
/* eslint-disable no-alert */
/**************************************************************************************
LWC JS File         : fs_LMCaseCustomButtons_LWC
Function            : This JS is created to handle LM case custom buttons.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sai            9/25/2019         Based on the status and case type custom buttons will display on the LM case record page.
                                   This LWC component is used inside an auracomponent 'FS_LMCaseCustomButtons' and placed on the
                                   LM case detail lightning page       
*************************************************************************************/
import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCaseDetails from '@salesforce/apex/FS_LMCaseController.getCaseDetails';
import updateCaseDetails from '@salesforce/apex/FS_LMCaseController.updateCaseDetails';
import Id from '@salesforce/user/Id';
import getSingleRt from '@salesforce/apex/FS_LMCaseController.getLMCaseRecordTypeID';
import getOutletDispensers from '@salesforce/apex/FS_LMCaseController.getFactOutletDispensers';
import escalateToSalesSupport from '@salesforce/apex/FS_LMCaseController.escalateToSalesSupport';
import deleteLMCase from '@salesforce/apex/FS_LMCaseController.deleteLMCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLoggedinUserDetails from '@salesforce/apex/FS_LMCaseController.getLoggedinUserDetails';
import INLINE_EDIT_MESSAGE_LABEL from '@salesforce/label/c.FS_Case_Inline_Edit_Message';
import ATLEAST_ONE_DISPENSER_MESSAGE from '@salesforce/label/c.FS_select_atleast_one_dispenser_alert_message';
import AMS_ALERT_MESSAGE from '@salesforce/label/c.FS_Escalate_to_AMS_alert_message';
import RSS_ALERT_MESSAGE from '@salesforce/label/c.FS_Escalate_to_RSS_alert_message';
import INSTALL_BASE_ALERT_MESSAGE from '@salesforce/label/c.FS_Escalate_to_Install_base_team_alert_message';
import CLOSED_CASE_ALERT_MESSAGE from '@salesforce/label/c.FS_closed_case_cannot_be_escalated';
import FACT_ALERT_MESSAGE from '@salesforce/label/c.FS_Escalate_to_FACT_alert_message';
import SALES_SUPPORT_ALERT_MESSAGE from '@salesforce/label/c.FS_escalate_to_sales_support_alert_message';
import CREATE_FACT_CASE_ALERT_MESSAGE from '@salesforce/label/c.FS_Create_Fact_case_alert_message';
import FROM_ACCOUNT_MANDATORY_ALERT_MESSAGE from '@salesforce/label/c.FS_From_Account_mandatory_alert_message';
import INSUFFICIENT_ACCESS_ALERT from '@salesforce/label/c.FS_insufficient_access_alert_message';


const ESCALATE_TO_AMS = 'Escalate to AMS';
const ESCALATE_TO_FACT = 'Escalate to FACT';
const ESCALATE_TO_RSS = 'Escalate to RSS';
const ESCALATE_TO_INSTALL = 'Escalate to Install Base';
const ESCALATE_TO_SALES_SUPPORT = 'Escalate to Sales Support';
const CASE_TYPE_ACCOUNT_TEAM_INITIATED_AMOA = 'Account Team Initiated AMOA';
const CASE_TYPE_JDE_INITIATED_AMOA = 'JDE Initiated AMOA';
const STATUS_JDE_AMS_HOLD = 'JDE AMS on Hold';
const CASE_TYPE_JDE_LINKAGE_REQUEST = 'JDE Linkage Request';
const RECORDTYPE_LINKAGE_MANAGEMENT = 'Linkage Management';
const STATUS_FS_FACT_AMS_P = 'FS_FACT_AMS_P';
const PROFILE_SYSTEM_ADMIN = 'System Administrator';
const STATUS_PENDING_INSTALL = 'Pending Install';
const STATUS_FINANCE_HOLD = 'Finance on Hold';
const STATUS_JDE_INSTALL_BASE_NOTIFIED = 'JDE Install Base Notified';
const STATUS_ASSIGNED = 'Assigned';
const STATUS_NEW = 'New';
const STATUS_CLOSED = 'Closed';
const FS_FACT_BAST_P = 'FS_FACT_BAST_P';
export default class LMCaseDetailPageButtons extends NavigationMixin(LightningElement) {
    @api recordId;
    @track caseStatus;
    @track caseSubStatus;
    @track caseType;
    @track caseNumber;
    @track buttonAMSFlag;
    @track buttonFactFlag;
    @track buttonRSSFlag;
    @track buttonInstallBaseFlag;
    @track LM_Record_Type;
    @track buttonSalesSupportFlag;
    @track ToAccount;
    @track OutletDispensersFactList;
    userId = Id;
    @track profileName;
    @track selectedODIds = '';
    @track csRecordTypeId;
    @track INLINE_EDIT_MESSAGE = INLINE_EDIT_MESSAGE_LABEL;
    @track openAlertModal = false;
    @track alertMesssage;


    /** Track varialbes assigning with false to make modal popups disable on page load
     * and to make custom buttons disable after user clicks on first time
     */
    @track deleteCaseModal = false;
    @track createFactModalPopup = false;
    @track isPopupSubmitButtonDisabled = false;
    @track isEscalateToAMSButtonDisabled = false;
    @track isEscalateToSalesButtonDisabled = false;
    @track isEscalateToFACTButtonDisabled = false;
    @track isEscalateToRSSButtonDisabled = false;
    @track isEscalateToInstallButtonDisabled = false;
    /*****************************************************************************************
        Method : connectedCallback
        Description : This method will invoke when the component initialise and get case Details 
        and LM case record type Id
    ******************************************************************************************/
    connectedCallback() {
        this.getLoggedinUserDetails();
        this.getRecordTypeListId();
    }
    /*****************************************************************************************
        Method : getRecordTypeListId
        Description : This method will call the apex method to get Linkage Management record type id
    ******************************************************************************************/
    getRecordTypeListId() {
        getSingleRt({ recordTypeName: RECORDTYPE_LINKAGE_MANAGEMENT }).then(data => {
            if (data) {
                this.LM_Record_Type = data[0].Id;
            }
        }).catch(error => {

            this.showToastMessage('LM record type error ', JSON.stringify(error), 'error', 'sticky');
        });
    }
    /*****************************************************************************************
        Method : getLoggedinUserDetails
        Description : Method to get current logged in user details and set profile variable .
    ******************************************************************************************/
    getLoggedinUserDetails() {
        getLoggedinUserDetails()
            .then(result => {
                if (result) {
                    this.profileName = result.Profile.Name;
                    //calling this method to get case details after loggedin user details retrieved 
                    this.refreshCaseDetails();
                }
            }).catch(error => {
                this.error = error;

                this.showToastMessage('User details error ', JSON.stringify(error), 'error', 'sticky');
            });
    }
    /*****************************************************************************************
        Method : refreshCaseDetails
        Description : Method to get current case record details.
         It Controls the custom buttons on the detail page respective with case status, substatus
         ,case type and loggedin user profile.
    ******************************************************************************************/
    refreshCaseDetails() {
        getCaseDetails({ caseId: this.recordId })
            .then(data => {
                if (data) {
                    for (let i in data) {
                        if (data[i] !== null) {
                            this.caseStatus = data[i].Status;
                            this.caseSubStatus = data[i].LM_Sub_Status__c;
                            this.caseType = data[i].FS_New_Case_Type__c;
                            this.ToAccount = data[i].To_Account__c;
                            this.fromAccount = data[i].From_Account__c;
                            this.caseNumber = data[i].CaseNumber;
                        }
                    }
                    //Conditions to enable/disable custom buttons
                    if (this.caseStatus === STATUS_NEW && this.caseType !== CASE_TYPE_ACCOUNT_TEAM_INITIATED_AMOA && this.caseType !== CASE_TYPE_JDE_INITIATED_AMOA) {
                        this.buttonAMSFlag = true;
                    } else {
                        this.buttonAMSFlag = false;
                    }
                    if (this.caseSubStatus === STATUS_JDE_AMS_HOLD && this.caseType === CASE_TYPE_JDE_LINKAGE_REQUEST && (this.profileName === PROFILE_SYSTEM_ADMIN || this.profileName === STATUS_FS_FACT_AMS_P))
                        this.buttonFactFlag = true;
                    else
                        this.buttonFactFlag = false;

                    if ((this.caseStatus === STATUS_NEW && this.caseType === CASE_TYPE_JDE_INITIATED_AMOA))
                        this.buttonSalesSupportFlag = true;
                    else
                        this.buttonSalesSupportFlag = false;

                    if (((this.caseStatus === STATUS_ASSIGNED && this.caseType !== CASE_TYPE_JDE_LINKAGE_REQUEST) && this.caseSubStatus === STATUS_JDE_AMS_HOLD) && (this.profileName !== FS_FACT_BAST_P))
                        this.buttonRSSFlag = true;
                    else
                        this.buttonRSSFlag = false;

                    if ((this.caseType === CASE_TYPE_JDE_INITIATED_AMOA || this.caseType === CASE_TYPE_ACCOUNT_TEAM_INITIATED_AMOA) && this.caseSubStatus === STATUS_PENDING_INSTALL && this.profileName !== FS_FACT_BAST_P) 
                        this.buttonInstallBaseFlag = true;
                    else
                        this.buttonInstallBaseFlag = false;
                }
            })
            .catch(error => {
                this.error = error;

                this.showToastMessage('Case details error ', JSON.stringify(error), 'error', 'sticky');
            });

    }
    /*****************************************************************************************
         Method : navigateToEditComponent
         Description : Method to navigate to LM case custom lightning aura component. In that aura
         component,LWC component 'fs_LMCaseCreateAndEdit_LWC call as child component
     ******************************************************************************************/
    navigateToEditComponent() {
        var caseId = this.recordId;
        const openEditPageForCommunity = new CustomEvent('openEditPage', {
            detail: { caseId },
        });

        // Fire the custom event
        this.dispatchEvent(openEditPageForCommunity);


        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__FS_LMCaseCreateAndEdit"

            },
            state: {
                //setting current case recordId as a parameter in navigation url 
                c__recordId: this.recordId
            }
        });
    }
    /*****************************************************************************************
         Method : escalateToAMS
         Description : Case will be escalated to JDE AMS by updating the status and substatus
         fields backend. After updating the status fields, record page will get refresh.
     ******************************************************************************************/
    escalateToAMS() {
        this.isEscalateToAMSButtonDisabled = true;
        if (this.caseStatus !== STATUS_ASSIGNED) {
            const caseDetails = {
                cs: {
                    Status: STATUS_ASSIGNED,
                    LM_Sub_Status__c: STATUS_JDE_AMS_HOLD,
                    Id: this.recordId
                }
            };
            this.updateCaseApex(caseDetails, ESCALATE_TO_AMS);

        } else {
            this.showAlertModalMethod(AMS_ALERT_MESSAGE);
        }
        this.isEscalateToAMSButtonDisabled = false;
    }
    /*****************************************************************************************
        Method : escalateToRSS
        Description : Case will be escalated to RSS by updating the status and substatus
        fields backend. After updating the status fields, record page will get refresh.
    ******************************************************************************************/
    escalateToRSS() {
        if (this.profileName === FS_FACT_BAST_P) {
            this.showAlertModalMethod(INSUFFICIENT_ACCESS_ALERT);
        } else if (this.caseSubStatus !== STATUS_FINANCE_HOLD) {
            const caseDetails = {
                cs: {
                    Status: STATUS_ASSIGNED,
                    LM_Sub_Status__c: STATUS_FINANCE_HOLD,
                    Id: this.recordId
                }
            };
            this.updateCaseApex(caseDetails, ESCALATE_TO_RSS);

        } else {
            this.showAlertModalMethod(RSS_ALERT_MESSAGE);
        }
    }
    /*****************************************************************************************
        Method : Escalatetoinstall
        Description : Case will be escalated to Install Base by updating the status and substatus
        fields backend. After updating the status fields, record page will get refresh.
    ******************************************************************************************/
    Escalatetoinstall() {
        if (this.profileName === FS_FACT_BAST_P) {

            this.showAlertModalMethod(INSUFFICIENT_ACCESS_ALERT);
        } else {
            this.isEscalateToInstallButtonDisabled = true;
            if (this.caseSubStatus !== STATUS_JDE_INSTALL_BASE_NOTIFIED) {
                const caseDetails = {
                    cs: {
                        Status: STATUS_ASSIGNED,
                        LM_Sub_Status__c: STATUS_JDE_INSTALL_BASE_NOTIFIED,
                        Id: this.recordId
                    }
                };
                this.updateCaseApex(caseDetails, ESCALATE_TO_INSTALL);

            } else {

                this.showAlertModalMethod(INSTALL_BASE_ALERT_MESSAGE);

            }
            this.isEscalateToInstallButtonDisabled = false;
        }

    }
    /*****************************************************************************************
        Method : EscalatetoFACT
        Description : Case will be escalated to Fact by updating the status and substatus
        fields backend. After updating the status fields, record page will get refresh.
    ******************************************************************************************/
    EscalatetoFACT() {
        this.isEscalateToFACTButtonDisabled = true;
        if (this.caseStatus === STATUS_CLOSED) {
           this.showAlertModalMethod(CLOSED_CASE_ALERT_MESSAGE);

        } else if (this.caseSubStatus !== STATUS_PENDING_INSTALL) {
            const caseDetails = {
                cs: {
                    Status: STATUS_ASSIGNED,
                    LM_Sub_Status__c: STATUS_PENDING_INSTALL,
                    Id: this.recordId
                }
            };
            this.updateCaseApex(caseDetails, ESCALATE_TO_FACT);

        } else {
           this.showAlertModalMethod(FACT_ALERT_MESSAGE);

        }
        this.isEscalateToFACTButtonDisabled = false;
    }
    /*****************************************************************************************
        Method : EscalatetoSalesSupport
        Description : It will check if To Account or From account is empty or not. If those are empty
        it will show an alert else it will update status fields and fire assignment rules in apex class.
        After updating the status fields, record page will get refresh.
    ******************************************************************************************/
    EscalatetoSalesSupport() {
        this.isEscalateToSalesButtonDisabled = true;
        if (this.ToAccount === '' || this.fromAccount === '' || this.ToAccount === null || this.fromAccount === null || this.ToAccount === undefined || this.fromAccount === undefined) {
           this.showAlertModalMethod(SALES_SUPPORT_ALERT_MESSAGE);
           this.isEscalateToSalesButtonDisabled = false;

        } else {
            escalateToSalesSupport({ caseId: this.recordId })
                .then(result => {
                    this.showSuccessToastAndReload(ESCALATE_TO_SALES_SUPPORT);

                }).catch(error => {
                    this.error = error;
                    this.isEscalateToSalesButtonDisabled = false;
                    this.showToastMessage('Escalate to sales support error ', JSON.stringify(error), 'error', 'sticky');
                });
        }

        
    }
    /*****************************************************************************************
        Method : showSuccessToastAndReload
        Description : Refresh the record page and show toast success message after an record update.
    ******************************************************************************************/
    showSuccessToastAndReload(successMessage) {
        this.error = undefined;
        this.showToastMessage('Success! ', successMessage, 'success', 'dismissable');
        this.refreshCaseDetails();
        eval("$A.get('e.force:refreshView').fire();");
    }
    /*****************************************************************************************
       Method : navigateToCaseRecordPage
       Description : Method to navigate to case record page based on the current record id.
   ******************************************************************************************/
    navigateToCaseRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Case', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
    /*****************************************************************************************
        Method : updateCaseApex
        Description : Method to call apex imperatively and update casedetails when user clicks on 
        the respective custom buttons.
    ******************************************************************************************/
    updateCaseApex(caseDetails, successMessage) {
        //Imperative apex call
        updateCaseDetails(caseDetails)
            .then(result => {
                this.showSuccessToastAndReload(successMessage);
            })
            .catch(error => {
                this.error = error;
                this.showToastMessage('Case update error ', JSON.stringify(error), 'error', 'sticky');
            });
    }
    /*****************************************************************************************
        Method : openDispensersSelectPopup
        Description : This method is an onclick function for button create fact case. It will check
        whether from account is filled or not for the case and will show alert message. If it is filled
        it will call apex method and retrieve Outlet Dispensers.
    ******************************************************************************************/
    openDispensersSelectPopup() {
        //if condition to check from account field is filled or not
        if (!this.fromAccount) {
            if (this.caseType === CASE_TYPE_JDE_LINKAGE_REQUEST && this.profileName === FS_FACT_BAST_P) {

                this.getOutletDispensersForCreateFactCase();
            } else {
                this.showAlertModalMethod(FROM_ACCOUNT_MANDATORY_ALERT_MESSAGE);
            }

        } else {
            if (this.profileName !== STATUS_FS_FACT_AMS_P) {
                this.getOutletDispensersForCreateFactCase();
            } else {
                this.showAlertModalMethod(CREATE_FACT_CASE_ALERT_MESSAGE);
            }
        }
    }

    /*****************************************************************************************
       Method : getOutletDispensersForCreateFactCase
       Description : This method is an onclick function for button create fact case. It will check
       whether from account is filled or not for the case and will show alert message. If it is filled
       it will call apex method and retrieve Outlet Dispensers.
   ******************************************************************************************/
    getOutletDispensersForCreateFactCase() {
        getOutletDispensers({ outletId: this.ToAccount })
            .then(result => {
                this.OutletDispensersFactList = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.showToastMessage('Outlet dispensers Retrieving error ', JSON.stringify(error), 'error', 'sticky');
            });
        this.createFactModalPopup = true;
        //Calling apex method to get connectivity solution record id
        getSingleRt({ recordTypeName: 'Connectivity Solution' }).then(data => {
            if (data) {
                this.csRecordTypeId = data[0].Id;
            }
        });
    }
    closeDeleteCaseModal() {
        this.deleteCaseModal = false;
    }
    closeModal() {
        this.createFactModalPopup = false;
    }
    openDeleteCaseConfirmModal() {
        this.deleteCaseModal = true;
    }
    /*****************************************************************************************
    	Method : navigateToCaseListView
        Description : Method to navigate to case object home page/ Case List view.
    ******************************************************************************************/
    navigateToCaseListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'home'
            }
        });
    }
    /*****************************************************************************************
       Method : navigateToDeleteCase
       Description : Method to delete the case and navigates to case home page.
   ******************************************************************************************/
    navigateToDeleteCase() {
        var recordIdToDelete = this.recordId;
        this.isPopupSubmitButtonDisabled = true;


        deleteLMCase({ caseId: this.recordId })
            .then(result => {
                this.error = undefined;
                this.showToastMessage('Success! ', 'Case was Deleted', 'success', 'dismissable');
                // "deleteRecord" Event : To delete the tab in Console Application
                const deleteRecord = new CustomEvent('deleteLmCase', {
                    detail: { recordIdToDelete },
                });
                this.dispatchEvent(deleteRecord);
                this.navigateToCaseListView();
            })
            .catch(error => {
                this.error = error;
                this.isPopupSubmitButtonDisabled = false;
                this.showToastMessage('Delete LM case error  ', JSON.stringify(error), 'error', 'sticky');
            });


    }
    /*****************************************************************************************
    	Method : openFactCase
        Description : Method to open connectivity solution case creation popup. Inside this function
        firing an DOM event. This DOM event will be handled at Aura component (parent component) to 
        open connectivity solution case creation popup with prepopulate dispenser and LM case fields.
        In LWC, there is no feature for prepopulating values while opening a new case creation till date
    ******************************************************************************************/
    openFactCase() {
        var caseId = this.recordId;
        var outletDispenserId = '';
        var connectivitySolutionRecordTypeId = this.csRecordTypeId;
        this.selectedODIds = '';
        this.createFactModalPopup = false;
        //fetching the selected dispenser id
        let els = this.template.querySelectorAll('[data-id="selectedOd"]');
        els.forEach((v) => {
            if (v.checked) {
                this.selectedODIds = v.dataset.item;
            }
        });
        if (this.selectedODIds) { // checking whether user clicks on continue button without selecting any dispenser
            outletDispenserId = this.selectedODIds;
            //arranging custom event to fire
            const openFactCaseCreationFormEvent = new CustomEvent('openFactCaseCreationForm', {
                detail: { caseId, outletDispenserId, connectivitySolutionRecordTypeId },
            });
            //firing custom event
            this.dispatchEvent(openFactCaseCreationFormEvent);
        } else {
            this.showAlertModalMethod(ATLEAST_ONE_DISPENSER_MESSAGE);
        }

    }
    /*****************************************************************************************
        Method : showToastMessage
        Description : This is a common method to display toast messages. In case of success the message will
        be disappear in 3 seconds and in case of any apex errors it will open until user clicks on 'x' mark.
        Toast mode - Sticky - Visible until user clicks 'x' mark
        Toast mode - dismissable - Toast will disappear in 3 seconds
    ******************************************************************************************/
    showToastMessage(toastTitle, toastMessage, ToastVariant, ToastMode) {
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
    showAlertModalMethod(message) {
        this.alertMesssage = message;
        this.openAlertModal = true;
    }
    /*****************************************************************************************
        Method : closeAlertModalMethod
        Description : This method will close modal popup of custom error messages.
    ******************************************************************************************/
    closeAlertModalMethod() {
        this.alertMesssage = '';
        this.openAlertModal = false;
    }
}