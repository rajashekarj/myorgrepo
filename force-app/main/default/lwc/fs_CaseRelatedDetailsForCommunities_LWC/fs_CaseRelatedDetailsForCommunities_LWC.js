/* eslint-disable no-console */
/* eslint-disable no-alert */
/**************************************************************************************
LWC JS File         : fs_CaseRelatedDetailsForCommunities_LWC
Function            : This JS is created to handle LM Case Record Details.
Author              : Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Karthika            10/15/2019        For LM Case record detail page  it will open a custom LWC component 
                                  to display case information for lightning communities.
*************************************************************************************/
import { LightningElement,api } from 'lwc';

export default class Fs_CaseRelatedDetailsForCommunities_LWC extends LightningElement {
    @api recordId;
}