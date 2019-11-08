/**************************************************************************************
Apex Class Name     : FSCopyEPIPHelperClass
Version             : 1.0
Function            : This is a Helper class for FSCopyEPEPToInstallationsSearchExtension class
and FSCopyEPTIToInstallationsSearchExtension class.
to call some methods which are very large for field mapping
Modification Log    :
* Developer         :    Date              Description
* ----------------------------------------------------------------------------                 
* Venkat FET 4.0     11/23/2016          Original Version
* Venkat FET 5.0	  02/09/2018		 Updated  Version
* Neel	 FET 5.2      09/04/2018         Updated  Version-FFET 1273
*************************************************************************************/

public class FSCopyEPIPHelperClass {    
    
    /*****************************************************************
	Method: copyTechData
	Description: copyTechData method gets the old and New technician instruction records and assign
	New record values to the Old record and return back the Old Technician instruction record
	Modified: Venkat FET 5.0 JIRA:136
	*******************************************************************/
    
    public static FS_IP_Technician_Instructions__c copyTechData(final FS_IP_Technician_Instructions__c oldTIIP,final FS_EP_Technician_Instructions__c newTIIP){
        oldTIIP.FS_7000_Series_Dispenser_Placement__c=newTIIP.FS_X7000_Series_Dispenser_Placement__c;
        oldTIIP.FS_Type_of_Line__c=newTIIP.FS_Type_of_Line__c;
        oldTIIP.FS_Protocol_for_Existing_Lines__c=newTIIP.FS_Protocol_for_Existing_Lines__c;
        oldTIIP.FS_Path__c=newTIIP.FS_Path__c;
        oldTIIP.FS_Special_Instructions_Line_Run__c=newTIIP.FS_Line_Special_Instructions__c;
        oldTIIP.FS_Protocol_for_Existing_Rack__c=newTIIP.FS_Protocol_for_Existing_Rack__c;        
        oldTIIP.FS_Location_of_Syrup_Rack__c=newTIIP.FS_Location_of_Syrup_Rack__c;
        oldTIIP.FS_Special_Instructions_Syrup_Rack__c=newTIIP.FS_Rack_Special_Instructions__c;
        oldTIIP.FS_Water_Booster_Location__c=newTIIP.FS_Water_Booster_Location__c;
        oldTIIP.FS_Special_Instructions_Water_Booster__c=newTIIP.FS_Water_Booster_Special_Instructions__c;
        oldTIIP.FS_Water_Filter_Supplier__c=newTIIP.FS_Water_Filter_Supplier__c;
        oldTIIP.FS_Requirements__c=newTIIP.FS_Requirements__c;
        oldTIIP.FS_Installer__c=newTIIP.FS_Installer__c;
        oldTIIP.FS_Location__c=newTIIP.FS_Location__c;
        oldTIIP.FS_Special_Instructions_Water_Filter__c=newTIIP.FS_Water_Filter_Special_Instructions__c;
        oldTIIP.FS_Requirements_IM__c=newTIIP.FS_IM_Requirements__c;
        oldTIIP.FS_IM_Dispense_Soft_Ice__c=newTIIP.IM_Dispense_Soft_Ice__c;
        oldTIIP.FS_IM_Make__c=newTIIP.FS_IM_Make__c;
        oldTIIP.FS_IM_Model_SS__c=newTIIP.FS_IM_Model__c;
        oldTIIP.FS_Is_Coordination_by_Coca_Cola_Req__c=newTIIP.FS_Is_Coordination_by_Coca_Cola_Required__c;
        oldTIIP.FS_Special_Instructions_Ice_Maker__c=newTIIP.FS_IM_Special_Instructions__c;
        oldTIIP.FS_KO_DOE_Disposition_of_Removed_Equipme__c=newTIIP.FS_KO_or_DOE_Disposition_of_Removd__c;
        oldTIIP.FS_Equipment_Placement__c=newTIIP.FS_Equip_Placement__c;
        oldTIIP.FS_Special_Instructions_KO_DOE__c=newTIIP.FS_Instructions__c;
        oldTIIP.FS_Special_Instructions_Other__c=newTIIP.FS_Other_Instructions__c;
        oldTIIP.FS_Parts_SP_Needs_to_Order__c=newTIIP.FS_Parts_SP_Needs_to_Order__c;
        return oldTIIP;
    }
    /*****************************************************************
	Method: copyEquipment
	Description: copyEquipment method gets the old and New Equipment package records and assign
	New record values to the Old record and return back the Old Equipment package record
	Modified: Venkat FET 5.0 JIRA:135
	*******************************************************************/
    
    public static FS_IP_Equipment_Package__c copyEquipment(final FS_IP_Equipment_Package__c oldEPIP,final FS_EP_Equipment_Package__c newEPIP){
        oldEPIP.FS_Dispenser_Series_IC_code__c=newEPIP.FS_Dispenser_Series_IC_code__c;
        oldEPIP.FS_Dispenser_QTY__c=newEPIP.FS_Dispenser_QTY__c;
        oldEPIP.FS_LID_IM_Adapter1__c=newEPIP.FS_LID_IM_Adapter1__c;
        oldEPIP.FS_LID_IM_Adapter1_QTY__c=newEPIP.FS_LID_IM_Adapter1_QTY__c;
        oldEPIP.FS_LID_IM_Adapter2__c=newEPIP.FS_LID_IM_Adapter2__c;
        oldEPIP.FS_LID_IM_Adapter2_QTY__c=newEPIP.FS_LID_IM_Adapter2_QTY__c;
        oldEPIP.FS_Soft_Ice_Misc_Adapter__c=newEPIP.FS_Soft_Ice_Misc_Adapter__c;
        oldEPIP.FS_Soft_Ice_Misc_Adapter_QTY__c=newEPIP.FS_Soft_Ice_Misc_Adapter_QTY__c;
        oldEPIP.FS_Pump_Kit__c=newEPIP.FS_Pump_Kit__c;
        oldEPIP.FS_Pump_Kit_QTY__c=newEPIP.FS_Pump_Kit_QTY__c;
        oldEPIP.FS_External_Modems__c=newEPIP.FS_External_Modems__c;
        oldEPIP.FS_External_Modems_QTY__c=newEPIP.FS_External_Modems_QTY__c;
        oldEPIP.FS_Regulator__c=newEPIP.FS_Regulator__c;
        oldEPIP.FS_Regulator_QTY__c=newEPIP.FS_Regulator_QTY__c;
        oldEPIP.FS_Water_Booster__c=newEPIP.FS_Water_Booster__c;
        oldEPIP.FS_Water_Booster_QTY__c=newEPIP.FS_Water_Booster_QTY__c;
        oldEPIP.FS_Booster_Shelf__c=newEPIP.FS_Booster_Shelf__c;
        oldEPIP.FS_Booster_Shelf_QTY__c=newEPIP.FS_Booster_Shelf_QTY__c;
        oldEPIP.FS_Manifold__c=newEPIP.FS_Manifold__c;
        oldEPIP.FS_Manifold_QTY__c=newEPIP.FS_Manifold_QTY__c;
        oldEPIP.FS_Valid_Fill__c=newEPIP.FS_Valid_Fill__c;
        oldEPIP.FS_Valid_Fill_QTY__c=newEPIP.FS_Valid_Fill_QTY__c;
        oldEPIP.X30_Ice_Maker_Shroud__c=newEPIP.X30_Ice_Maker_Shroud__c;
        oldEPIP.X30_Ice_Maker_Shroud_QTY__c=newEPIP.X30_Ice_Maker_Shroud_QTY__c;
        oldEPIP.FS_Rack1__c=newEPIP.FS_Rack1__c;
        oldEPIP.FS_Rack1_QTY__c=newEPIP.FS_Rack1_QTY__c;
        oldEPIP.FS_Rack2__c=newEPIP.FS_Rack2__c;
        oldEPIP.FS_Rack2_QTY__c=newEPIP.FS_Rack2_QTY__c;
        oldEPIP.FS_Rack3__c=newEPIP.FS_Rack3__c;
        oldEPIP.FS_Rack3_QTY__c=newEPIP.FS_Rack3_QTY__c;
        oldEPIP.FS_Shelf1__c=newEPIP.FS_Shelf1__c;
        oldEPIP.FS_Shelf1_QTY__c=newEPIP.FS_Shelf1_QTY__c;
        oldEPIP.FS_Shelf2__c=newEPIP.FS_Shelf2__c;
        oldEPIP.FS_Shelf2_QTY__c=newEPIP.FS_Shelf2_QTY__c;
        oldEPIP.FS_Extended_Splash__c=newEPIP.FS_Extended_Splash__c;
        oldEPIP.FS_Extended_Splash_QTY__c=newEPIP.FS_Extended_Splash_QTY__c;
        oldEPIP.FS_Water_Filter__c=newEPIP.FS_Water_Filter__c;
        oldEPIP.FS_Water_Filter_QTY__c=newEPIP.FS_Water_Filter_QTY__c;
        oldEPIP.FS_Water_Filter_2__c=newEPIP.FS_Water_Filter_2__c;
        oldEPIP.FS_Water_Filter_2_QTY__c=newEPIP.FS_Water_Filter_2_QTY__c;
        oldEPIP.FS_Stand__c=newEPIP.FS_Stand__c;
        oldEPIP.FS_Stand_QTY__c=newEPIP.FS_Stand_QTY__c;
        oldEPIP.FS_Tall_Cup_Kit__c=newEPIP.FS_Tall_Cup_Kit__c;
        oldEPIP.FS_Tall_Cup_Kit_QTY__c=newEPIP.FS_Tall_Cup_Kit_QTY__c;
        oldEPIP.FS_Label_kits__c=newEPIP.FS_Label_kits__c;
        oldEPIP.FS_Label_kits_QTY__c=newEPIP.FS_Label_kits_QTY__c;
        oldEPIP.FS_Vacuum_Regulator__c=newEPIP.FS_Vacuum_Regulator__c;
        oldEPIP.FS_Vacuum_Regulator_QTY__c=newEPIP.FS_Vacuum_Regulator_QTY__c;
        oldEPIP.FS_Legacy_Equip_during_install__c=newEPIP.FS_Legacy_Equip_during_install__c;
        oldEPIP.FS_Legacy_Equip_IC_Code_Desc_Qty__c=newEPIP.FS_Legacy_Equip_IC_Code_Desc_Qty__c;
        oldEPIP.FS_X4LC_NNS_Tray__c=newEPIP.FS_X4LC_NNS_Tray__c;
        oldEPIP.FS_X4LC_NNS_Tray_QTY__c=newEPIP.FS_X4LC_NNS_Tray_QTY__c;
        oldEPIP.FS_X4LC_RCGP_Installation_Kit__c=newEPIP.FS_X4LC_RCGP_Installation_Kit__c;
        oldEPIP.FS_X4LC_RCGP_Installation_Kit_QTY__c=newEPIP.FS_X4LC_RCGP_Installation_Kit_QTY__c;
        oldEPIP.FS_X4LC_RCGP_Module_s__c=newEPIP.FS_X4LC_RCGP_Module_s__c;
        oldEPIP.FS_X4LC_RCGP_Module_s_QTY__c=newEPIP.FS_X4LC_RCGP_Module_s_QTY__c;  
        //FNF-871 adding newly created fields under Equipment Package for Copy down from EP to IP// 
        oldEPIP.FS_Ice_Maker_Cladding__c=newEPIP.FS_Ice_Maker_Cladding__c;
        oldEPIP.FS_Ice_Maker_Cladding_QTY__c=newEPIP.FS_Ice_Maker_Cladding_QTY__c;
        oldEPIP.FS_Coke_Pump__c=newEPIP.FS_Coke_Pump__c;
        oldEPIP.FS_Coke_Pump_QTY__c=newEPIP.FS_Coke_Pump_QTY__c;
        oldEPIP.FS_Boost_Installation_Kit_M_Series__c=newEPIP.FS_Boost_Installation_Kit_M_Series__c;
        oldEPIP.FS_Boost_Installation_Kit_M_Series_QTY__c=newEPIP.FS_Boost_Installation_Kit_M_Series_QTY__c;
        oldEPIP.FS_Boost_NNS_Tray_M_Series__c=newEPIP.FS_Boost_NNS_Tray_M_Series__c;
        oldEPIP.FS_Boost_NNS_Tray_M_Series_QTY__c=newEPIP.FS_Boost_NNS_Tray_M_Series_QTY__c;
        oldEPIP.FS_Boost_Tri_CGP_M_Series__c=newEPIP.FS_Boost_Tri_CGP_M_Series__c;
        oldEPIP.FS_Boost_Tri_CGP_M_Series_QTY__c=newEPIP.FS_Boost_Tri_CGP_M_Series_QTY__c;
        oldEPIP.FS_Misc_Kit_M_Series_QTY__c=newEPIP.FS_Misc_Kit_M_Series_QTY__c;
        oldEPIP.FS_Misc_Kit_M_Series__c=newEPIP.FS_Misc_Kit_M_Series__c;
        //FNF-871 adding newly created fields under Equipment Package for Copy down from EP to IP// 
        return oldEPIP;
    }    
    /*****************************************************************
	Method: copyEPtoInstallation
	Description: copyEPtoInstallation method gets the List of Selected installations and an Execution plan,
	assign the execution Plan record data to the installation records and return the List<FS_Installation__c>
	
	FET 5.2 - FFET 1273 - Removed below 4 field from copy down from EP to IP functionality
			  COM, Installation PM, Installation PC/AC 1, Sales Lead

	*******************************************************************/
    public static List<FS_Installation__c> copyEPtoInstallation(final List<FS_Installation__c> instalList,final FS_Execution_Plan__c exePlan){
        final List<FS_Installation__c> lstInstallation=new List<FS_Installation__c>();
        for(FS_Installation__c install : instalList){
            install.FS_Scope_of_Work__c    =   exePlan.FS_Scope_of_Work__c;            
            lstInstallation.add(install);
        } 
        return lstInstallation;
    }
}