/* eslint-disable no-console */
/* eslint-disable no-alert */
/**************************************************************************************
LWC JS File         : fs_NonLMCaseCustomButtons_LWC
Function            : This JS is created to handle Non LM case custom buttons.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sai            8/26/2019         Based on the RecordType the custom buttons will display on the Non LM case record page.
*************************************************************************************/
import { LightningElement, api, track, wire } from 'lwc';
import getCaseDetails from '@salesforce/apex/FS_NonLMCaseController.getCaseDetails';
import getLoggedinUserDetails from '@salesforce/apex/FS_NonLMCaseController.getLoggedinUserDetails';
import updateCaseDetails from '@salesforce/apex/FS_NonLMCaseController.updateCaseDetails';
import getAccountTeamMembersList from '@salesforce/apex/FS_NonLMCaseController.getAccountTeamMembersList';
import saveAccountTeamMembersAndSendEmail from '@salesforce/apex/FS_NonLMCaseController.saveAccountTeamMembersAndSendEmail';
import getDispensersList from '@salesforce/apex/FS_SEMultiDispensersController.getDispensersList';
import setSerialNumber from '@salesforce/apex/FS_SEMultiDispensersController.setSerialNumber';
import deleteNonLMCase from '@salesforce/apex/FS_NonLMCaseController.deleteNonLMCase';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import INLINE_EDIT_MESSAGE_LABEL from '@salesforce/label/c.FS_Case_Inline_Edit_Message';
import EMT_ALERT_MESSAGE from '@salesforce/label/c.FS_EMT_alert_message';
import ESCALATE_GC_ALERT_MESSAGE from '@salesforce/label/c.FS_escalate_to_GC_alert_message';
import ESCALATION_ONCE_ALERT_MESSAGE from '@salesforce/label/c.FS_case_escalation_alert_message';
import ATLEASE_ONE_DISPENSER_MESSAGE from '@salesforce/label/c.FS_select_atleast_one_dispenser_alert_message';
import { getRecord } from 'lightning/uiRecordApi';
/**
 * Constant variable declaration starts here
 */
const ESCALATE_TO_FACT = 'Escalate To FACT';
const SELECT_ACCOUNT_TEAM_MEMBER = 'Select Account Team Member';
const ESCALATE_TO_EMT = 'Escalate To EMT';
const ESCALATE_TO_GC = 'Escalate To GC';
const CASE_DELETED = 'Case was Deleted';
const ADD_DELETE_DISPENSERS = 'Add/delete Dispensers';
const CONNECTIVITY_SOLUTION = 'Connectivity Solution';
const NORTH_AMERICAN_CASE = 'North American Case';
const NON_NORTH_AMERICAN_CASE = 'Non - North American Case';
const FREESTYLE_AGENTS_US = 'Freestyle Agents US';
const SERVICE_ESCALATION_AGENT = 'Service Escalation Agent';
const FS_SE = 'FS SE';
const FET_SE = 'FET SE';
const SERVICE_ESCALATION_ACCESS = 'Service_Escalation_Access';
const ASSIGNED = 'Assigned';
const EMT_ON_HOLD = 'EMT On Hold';
const ESCALATED = 'Escalated';
const GC_ON_HOLD = 'GC on Hold';
const FACT_ON_HOLD = 'FACT On Hold';
const SERVICE_ESCALATION_COMMUNITY = 'Service Escalation Community';
const SERVICE_ESCALATION_COMMUNITY_PLUS = 'Service Escalation Community Plus';
const FREESTYLE_CUSTOMER_COMMUNITY_SERVICE_TECHNICIAN = 'Freestyle Customer Community Service technician';
/**
 * Constant variable declaration ends here
 */
export default class EscalateToEMT extends NavigationMixin(LightningElement) {
    @api recordId;
    @api communitySiteId; // this community site id value comes from the parent aura component to indicate opened application is a community

    caseStatus;
    caseSubStatus;
    caseType;
    OwnerName;
    caseOutletDispenser;
    recordTypeName;
    escalateToGlobalCenterFlag;
    escalateToGCReason;
    @track profileName;
    @track userRelatedPermissionSet;
    /** Initialising the below variables with false value to make Modal popups disable on page load */
    @track isPopupSubmitButtonDisabled = false;
    @track isEscalateToEMTButtonDisabled = false;
    @track accountTeamMemberModal = false;
    @track deleteCaseModal = false;
    @track addDeleteDispenserModal = false;
    /** Initialising variables for modal popups on page load end here **/
    @track buttonEMTFlag = false;
    @track buttonGCFlag =false;
    @track buttonFactFlag=false;
    @track buttonAccountTeamMemberFlag =false;
    @track accountTeamMembersList;
    @track buttonEditDeleteCloneForNACase = true;
    @track preSelectedRows;
    @track selectedRecords;
    @track accountTeamMembersDetails;
    @track outletDispensersDetails;
    @track INLINE_EDIT_MESSAGE = INLINE_EDIT_MESSAGE_LABEL;
    @track hideButtonsForCommunity = false;
    @track openAlertModal = false;
    @track alertMesssage;

    /*****************************************************************************************
         Method : connectedCallback
         Description : This method will invokes when the component initialise and get case Details
                        and aslo it will get the logged in user details
     ******************************************************************************************/
    connectedCallback() {
        this.getLoggedinUserDetails();
    }
    /*****************************************************************************************
         Method : getRecord
         Description : This wire method will invokes when a change occurs in case record
     ******************************************************************************************/
    @wire(getRecord, { recordId: '$recordId', fields: ['Case.Id'] })
    getaccountRecord({ data, error }) {
        if (data) {
            this.getLoggedinUserDetails();
        } else if (error) {
            this.showToastMessage('Case details retrieving error', JSON.stringify(error), 'Error', 'sticky');
        }
    }
    /*****************************************************************************************
        Method : getLoggedinUserDetails
        Description : Method to get current logged in user details.It will set the profile name 
                      and related permission set variables which will be need for displaying some 
                      custom buttons.
    ******************************************************************************************/
    getLoggedinUserDetails() {
        getLoggedinUserDetails()
            .then(result => {
                if (result) {
                    this.profileName = result.Profile.Name;
                    this.userRelatedPermissionSet = result.Related_Permission_Set__c;
                    this.refreshCaseDetails();
                }
            }).catch(error => {
                this.error = error;
                this.showToastMessage('User details error', JSON.stringify(error), 'Error', 'sticky');
            });
    }

    /*************************************************************************************************
         Method : getCaseDetails
         Description : Method to get current case record details.
                       It Controls the custom buttons on the detail page respective with record type.
     *************************************************************************************************/
    refreshCaseDetails() {
        getCaseDetails({ caseId: this.recordId })
            .then(result => {
                if (result) {
                    for (let i in result) {
                        if (result[i] !== null) {
                            this.caseStatus = result[i].Status;
                            this.caseOutletDispenser = result[i].FS_Outlet_Dispenser__r.Name;
                            this.OwnerName = result[i].Owner.Name;
                            this.escalateToGlobalCenterFlag = result[i].Escalate_to_Global_Center__c;
                            this.recordTypeName = result[i].RecordType.Name;
                            this.escalateToGCReason = result[i].Global_Center_Esca__c;
                            //Checking the condition with record types and Profile names
                            //If community users logged in then hideButtonsForCommunity set to false and it hides all the buttons except 'Edit' & 'Add/Delete Dispensers'
                            if ((this.recordTypeName === NORTH_AMERICAN_CASE || this.recordTypeName === NON_NORTH_AMERICAN_CASE) && (this.profileName === SERVICE_ESCALATION_COMMUNITY || this.profileName === SERVICE_ESCALATION_COMMUNITY_PLUS || this.profileName === FREESTYLE_CUSTOMER_COMMUNITY_SERVICE_TECHNICIAN)) {
                                this.hideButtonsForCommunity = false;
                            } else {
                                this.hideButtonsForCommunity = true;
                            }
                            //If community users logged in then remaining button flags will not require to execute.
                            if (this.hideButtonsForCommunity) {
                                // Based on the respective conditions, below statements will set the flag variables to display the custom buttons
                                if (this.recordTypeName === CONNECTIVITY_SOLUTION || this.recordTypeName === NON_NORTH_AMERICAN_CASE) {
                                    this.buttonEditDeleteCloneForNACase = false;
                                }
                                else {
                                    this.buttonEditDeleteCloneForNACase = true;
                                }
                                if (this.recordTypeName === CONNECTIVITY_SOLUTION && this.OwnerName !== FREESTYLE_AGENTS_US) {
                                    this.buttonEMTFlag = true;
                                } else {
                                    this.buttonEMTFlag = false;
                                }
                                if (this.recordTypeName === CONNECTIVITY_SOLUTION) {
                                    this.buttonAccountTeamMemberFlag = true;
                                } else {
                                    this.buttonAccountTeamMemberFlag = false;
                                }
                                if (this.escalateToGlobalCenterFlag) {
                                    this.buttonGCFlag = false;
                                } else if ((this.recordTypeName === NORTH_AMERICAN_CASE || this.recordTypeName === NON_NORTH_AMERICAN_CASE) && (this.profileName === SERVICE_ESCALATION_AGENT || this.profileName.includes(FS_SE) || this.profileName.includes(FET_SE) || this.userRelatedPermissionSet === SERVICE_ESCALATION_ACCESS)) {
                                    this.buttonGCFlag = true;
                                } else {
                                    this.buttonGCFlag = false;
                                }

                                if (this.recordTypeName === NORTH_AMERICAN_CASE) {
                                    this.buttonFactFlag = true;

                                } else {
                                    this.buttonFactFlag = false;
                                }
                            }
                        }
                    }
                }
            })
            .catch(error => {
                this.error = error;
                // this.showToastMessage('Case details Error',JSON.stringify(error),'Error','sticky');

            });

    }

    /*****************************************************************************************
    	Method : escalateToEMT
        Description : Method to update the case status to 'Assigned' and sub status to 
                     'EMT On Hold' if Owner name is not equal to 'Freestyle Agents US' and call 
                      Apex method to save the details in backend.
    ******************************************************************************************/
    escalateToEMT() {
        this.isEscalateToEMTButtonDisabled = true;
        if (this.OwnerName !== FREESTYLE_AGENTS_US) {
            // Initialising a case object with respective details which need to be update in apex
            const caseDetails = {
                cs: {
                    Status: ASSIGNED,
                    Sub_Status__c: EMT_ON_HOLD,
                    Id: this.recordId
                }
            };
            this.updateCaseApex(caseDetails, ESCALATE_TO_EMT);

        } else {
            this.showAlertModalMethod(EMT_ALERT_MESSAGE);
        }
        this.isEscalateToEMTButtonDisabled = false;
    }
    /*****************************************************************************************
    	Method : escalateToGC
        Description : Method to call 'updateCaseDetails' Apex method imperatively to update the case details and 
                      reload the current case page. If Escalate_to_Global_Center__c is false then it will check the profile name
                      is 'service esalation agent' Or profile name includes 'FS SE' or 'FET SE'. If all conditions are ture
                      then it call apex method to update the status,substatus fields.
    ******************************************************************************************/
    escalateToGC() {
        if (this.escalateToGlobalCenterFlag === false) {
            //Checking the profile name of the current logged in user
            if (this.escalateToGCReason) {
                const caseDetails = {
                    cs: {
                        Status: ESCALATED,
                        Sub_Status__c: GC_ON_HOLD,
                        Id: this.recordId,
                        Escalate_to_Global_Center__c: true,
                        Service_Escalation_Agent__c: Id ///Id/ is the current logged in user id
                    }
                };
                this.updateCaseApex(caseDetails, ESCALATE_TO_GC);

            } else {
                this.showAlertModalMethod(ESCALATE_GC_ALERT_MESSAGE);
            }
        } else {
            this.showAlertModalMethod(ESCALATION_ONCE_ALERT_MESSAGE);


        }
    }

    /*****************************************************************************************
       Method : EscalatetoFACT
       Description : Method to call 'updateCaseDetails' Apex method imperatively to update the case details and 
                     reload the current case page. It will update the status, substatus and Escalated_to_FACT__c
                     field
   ******************************************************************************************/
    escalatetoFACT() {

        const caseDetails = {
            cs: {
                Escalated_to_FACT__c: true,
                Status: ASSIGNED,
                Sub_Status__c: FACT_ON_HOLD,
                Id: this.recordId
            }
        };
        this.updateCaseApex(caseDetails, ESCALATE_TO_FACT);

    }
    /*****************************************************************************************
       Method : updateCaseApex
       Description : Method to call 'updateCaseDetails' Apex method imperatively to update the case details and 
                     reload the current case record page.
   ******************************************************************************************/
    updateCaseApex(caseDetails, successMessage) {

        updateCaseDetails(caseDetails) // Calling Apex method imperatively
            .then(result => {
                this.isPopupSubmitButtonDisabled = false;
                //Evaluation aura force refreshview function to make the standard components on the
                eval("$A.get('e.force:refreshView').fire();");
                this.error = undefined;
                //Toast event to show success message
                this.showToastMessage('Success!', successMessage, 'success', 'dismissable');
            })
            .catch(error => {
                this.error = error;
                this.showToastMessage('System Exception ', JSON.stringify(error), 'Error', 'sticky');
            });
    }
    /*****************************************************************************************
       Method : navigateToCaseRecordPage
       Description : Method to navigate to current case record page.
   ******************************************************************************************/
    navigateToCaseRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
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
    	Method : closeModal,closeDispensersModal,openDeleteCaseConfirmModal,closeDeleteCaseModal
        Description : Methods to show/Hide modals.
    ******************************************************************************************/
    closeModal() {
        this.accountTeamMemberModal = false;
    }
    closeDispensersModal() {
        this.addDeleteDispenserModal = false;
    }
    openDeleteCaseConfirmModal() {
        this.deleteCaseModal = true;
    }
    closeDeleteCaseModal() {
        this.deleteCaseModal = false;
    }

    /*****************************************************************************************
    	Method : getAccountTeamMembers
        Description : Method to call 'getAccountTeamMembersList' apex method imperatively to get 
                      account team members List and open popup modal.
    ******************************************************************************************/
    getAccountTeamMembers() {

        getAccountTeamMembersList({ caseId: this.recordId })//Calling Apex imperatively
            .then(result => {
                this.error = undefined;
                this.accountTeamMembersList = result;
            })
            .catch(error => {
                this.error = error;
                this.showToastMessage('AccountTeam Members error ', JSON.stringify(error), 'Error', 'sticky');
            });
        this.accountTeamMemberModal = true;

    }
    /*****************************************************************************************
    	Method : getDispensersListModal
        Description : Method to call 'getDispensersList' apex method imperatively to get 
                      Dispensers List and open the popup modal.
    ******************************************************************************************/
    getDispensersListModal() {
        if(this.recordId) {
        getDispensersList({ dispenserId: this.caseOutletDispenser, caseID: this.recordId })
            .then(result => {
                this.error = undefined;
                this.outletDispensersDetails = result;
            })
            .catch(error => {
                this.error = error;
                this.showToastMessage('Outlet Dispensers error ', JSON.stringify(error), 'Error', 'sticky');
            });
        this.addDeleteDispenserModal = true;
        }    
    }
    /*****************************************************************************************
         Method : saveAccountTeamMembers
         Description : Method to call 'saveAccountTeamMembersAndSendEmail' apex method imperatively 
         to save Account Team Members and reload/navigate to currect record page.
     ******************************************************************************************/
    saveAccountTeamMembers() {
        var selectedATMembers = [];
        this.isPopupSubmitButtonDisabled = true;
        // Get all the check box details on the Select Account Team Members popup
        let els = this.template.querySelectorAll('[data-id="selectedAT"]');
        //Iterating the checkboxes
        els.forEach((v) => {
            //Checking if the checkbox is checked or not
            if (v.checked) {
                selectedATMembers.push(v.dataset.item);
            }
        });
        //Calling apex method imperatively
        saveAccountTeamMembersAndSendEmail({ atMembersFullList: this.accountTeamMembersList, selectedATMembers: selectedATMembers, caseId: this.recordId })
            .then(result => {
                this.error = undefined;
                eval("$A.get('e.force:refreshView').fire();");
                this.accountTeamMemberModal = false;
                this.isPopupSubmitButtonDisabled = false;
                this.showToastMessage('Success!', SELECT_ACCOUNT_TEAM_MEMBER, 'success', 'dismissable');

            })
            .catch(error => {
                this.error = error;
                this.isPopupSubmitButtonDisabled = false;
                this.showToastMessage('Save Account team members error ', JSON.stringify(error), 'Error', 'sticky');
            });
    }
    /*****************************************************************************************
    	Method : saveDispensersList
        Description : Method to collect all the selected serial numbers and call 'setSerialNumber'
                      apex method imperatively to save Dispensers and reload/navigate to correct 
                      record page.
    ******************************************************************************************/
    saveDispensersList() {

        var selectedZPLs = [];
        var checkFlag = false;
        // Get all the checkboxes on Dispensers list popup
        let els = this.template.querySelectorAll('[data-id="selectedZPLs"]');
        // Iteration all the checkboxes
        els.forEach((v) => {
            // Checking if the checkbox is checked or not and if true it will concatinate the selectedZPL's
            if (v.checked) {
                checkFlag = true;
                selectedZPLs = selectedZPLs + v.dataset.item + ',';
            }

        });
        //Condition to check if user select atleast one dispenser otherwise alert message will display
        if (checkFlag) {
            this.isPopupSubmitButtonDisabled = true;
            //call apex method imperatively
            setSerialNumber({ caseId: this.recordId, zpls: selectedZPLs, dispenserId: this.caseOutletDispenser })
                .then(result => {
                    this.error = undefined;
                    eval("$A.get('e.force:refreshView').fire();");
                    this.addDeleteDispenserModal = false;
                    this.isPopupSubmitButtonDisabled = false;
                    this.showToastMessage('Success!', ADD_DELETE_DISPENSERS, 'success', 'dismissable');

                })
                .catch(error => {
                    this.isPopupSubmitButtonDisabled = false;
                    this.error = error;
                    this.showToastMessage('Save outlet dispensers list error ', JSON.stringify(error), 'Error', 'sticky');
                });
        } else {
            this.showAlertModalMethod(ATLEASE_ONE_DISPENSER_MESSAGE);
        }

    }
    AccountTeamMembersCheck() {
        return this.accountTeamMembersDetails.length > 0 ? true : false;
    }
    OutletDispensersCheck() {
        return this.outletDispensersDetails.length > 0 ? true : false;
    }

    /*****************************************************************************************
    	Method : navigateToEditCase
        Description :(Standard) Method to navigate/Open standard edit case popup.
    ******************************************************************************************/
    navigateToEditCase() {
        var caseId = this.recordId;
        //If community user logged in it will fire an DOM event and open edit case popup in aura component
        if (!this.hideButtonsForCommunity) {

            const openEditPageInCommunities = new CustomEvent('openEditPage', {
                detail: { caseId },
            });
            this.dispatchEvent(openEditPageInCommunities);
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    "recordId": this.recordId,
                    "objectApiName": "Case",
                    "actionName": "edit"
                },
            });
        }

    }
    /*****************************************************************************************
       Method : navigateToCloneCase
       Description :(Standard) Method to navigate/Open standard clone case popup.
   ******************************************************************************************/
    navigateToCloneCase() {
        //LWC Navigation
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.recordId,
                "objectApiName": "Case",
                "actionName": "clone"
            },
        });
    }
    /*****************************************************************************************
    	Method : selectAllDispensersCheckBox
        Description : Method to select/de-select all dispensers check boxes on 'Add/Delete Dispensers' 
                      Popup
    ******************************************************************************************/
    selectAllDispensersCheckBox() {
        let dispenserCheckboxes = this.template.querySelectorAll('[data-id="selectedZPLs"]');
        let selectAllChkbox = this.template.querySelector('[data-id="selectAllDispCheckBox"]');
        //if 'Select All' checkbox is checked it will check all the dispensers checkbox
        if (selectAllChkbox.checked) {
            dispenserCheckboxes.forEach((v) => {
                //Sets the dispenser checkbox always true if the dispenser is disabled
                if (!v.disabled) {
                    v.checked = true;
                }
            });
        } else {
            //if 'Select All' checkbox is unchecked it will uncheck all the dispensers checkbox
            dispenserCheckboxes.forEach((v) => {
                if (!v.disabled) {
                    v.checked = false;
                }
            });
        }
    }
    /*****************************************************************************************
    	Method : navigateToDeleteCase
        Description :(Custom Delete) Method to delete Non LM case by calling apex method imperatively and redirects 
                      to case object list view.This will delete the selected case and shows alert in the page 
    ******************************************************************************************/
    navigateToDeleteCase() {
        var recordIdToDelete = this.recordId;
        this.isPopupSubmitButtonDisabled = true;
        deleteNonLMCase({ caseId: this.recordId })
            .then(result => {
                this.error = undefined;
                this.showToastMessage('Success!', CASE_DELETED, 'success', 'dismissable');
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
                this.showToastMessage('Delete Case error ', JSON.stringify(error), 'error', 'sticky');
            });
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