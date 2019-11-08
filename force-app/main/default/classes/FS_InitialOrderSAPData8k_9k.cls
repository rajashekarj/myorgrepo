// dummy codes are updated from line no 3 to 23

global class FS_InitialOrderSAPData8k_9k implements Database.Batchable<sObject>
{

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
        String query = 'SELECT Id,Name,Phone FROM Account ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        for ( Account a : scope)
        {
           a.Phone='123';
        }
        update scope;
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}

/*Commenting below lines of code bcoz of deleting Initial Order SAP Data Object in FET 5.0

global class FS_InitialOrderSAPData8k_9k implements Database.Batchable<sObject>,Database.Stateful {
   global String query;
   
   global FS_InitialOrderSAPData8k_9k(String q) {
       query = q;
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC) {
       Id RecortypeId8K_9K = Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('8000 OR 9000 Series').getRecordTypeId();
       Id RecortypeIdRelocation8k_9k = Schema.SObjectType.FS_Initial_Order__c.getRecordTypeInfosByName().get('Relocation 8000 OR 9000 Series').getRecordTypeId();   
       String recordtypeId1 = String.valueOf(RecortypeId8K_9K);
       String recordtypeId2 = String.valueOf(RecortypeIdRelocation8k_9k);   
       query =  'SELECT Id, FS_SpicyCherry__c, FS_1_Cost_Unit__c,FS_2_Cost_Unit__c,FS_3_Cost_Unit__c,FS_4_Cost_Unit__c,FS_5_Cost_Unit__c,FS_6_Cost_Unit__c,FS_7_Cost_Unit__c,FS_8_Cost_Unit__c,FS_9_Cost_Unit__c,FS_10_Cost_Unit__c,FS_11_Cost_Unit__c,FS_12_Cost_Unit__c,FS_13_Cost_Unit__c,FS_14_Cost_Unit__c,FS_15_Cost_Unit__c,FS_16_Cost_Unit__c,FS_17_Cost_Unit__c,FS_18_Cost_Unit__c,FS_19_Cost_Unit__c,FS_20_Cost_Unit__c,FS_21_Cost_Unit__c,FS_22_Cost_Unit__c,FS_23_Cost_Unit__c,FS_24_Cost_Unit__c,FS_25_Cost_Unit__c,FS_26_Cost_Unit__c,FS_1_Package_Days_Capacity_1000__c,FS_2_Package_Days_Capacity_1000__c,FS_3_Package_Days_Capacity_1000__c,FS_4_Package_Days_Capacity_1000__c,FS_5_Package_Days_Capacity_1000__c,FS_6_Package_Days_Capacity_1000__c,FS_7_Package_Days_Capacity_1000__c,FS_8_Package_Days_Capacity_1000__c,FS_9_Package_Days_Capacity_1000__c,FS_10_Package_Days_Capacity_1000__c,FS_11_Package_Days_Capacity_1000__c,FS_12_Package_Days_Capacity_1000__c,FS_13_Package_Days_Capacity_1000__c,FS_14_Package_Days_Capacity_1000__c,FS_15_Package_Days_Capacity_1000__c,FS_16_Package_Days_Capacity_1000__c,FS_17_Package_Days_Capacity_1000__c,FS_18_Package_Days_Capacity_1000__c,FS_19_Package_Days_Capacity_1000__c,FS_20_Package_Days_Capacity_1000__c,FS_21_Package_Days_Capacity_1000__c,FS_22_Package_Days_Capacity_1000__c,FS_23_Package_Days_Capacity_1000__c,FS_24_Package_Days_Capacity_1000__c,FS_25_Package_Days_Capacity_1000__c,FS_26_Package_Days_Capacity_1000__c,FS_1_SAP_Material__c,FS_2_SAP_Material__c,FS_3_SAP_Material__c,FS_4_SAP_Material__c,FS_5_SAP_Material__c,FS_6_SAP_Material__c,FS_7_SAP_Material__c,FS_8_SAP_Material__c,FS_9_SAP_Material__c,FS_10_SAP_Material__c,FS_11_SAP_Material__c,FS_12_SAP_Material__c,FS_13_SAP_Material__c,FS_14_SAP_Material__c,FS_15_SAP_Material__c,FS_16_SAP_Material__c,FS_17_SAP_Material__c,FS_18_SAP_Material__c,FS_19_SAP_Material__c,FS_20_SAP_Material__c,FS_21_SAP_Material__c,FS_22_SAP_Material__c,FS_23_SAP_Material__c,FS_24_SAP_Material__c,FS_25_SAP_Material__c,FS_26_SAP_Material__c FROM FS_initial_order__c where recordtypeid ='+ '\''+recordtypeId1+'\'' +' OR recordtypeid ='+'\''+recordtypeId2+'\'';
       system.debug('The SOQL is '+query );
       return Database.getQueryLocator(query);
   }
   
    global void execute(Database.BatchableContext BC, List<FS_initial_order__c> scope) {
        try {
            Id RecortypeIdIO = Schema.SObjectType.FS_Initial_Order_SAP_Data__c.getRecordTypeInfosByName().get('Initial Order Transaction Data').getRecordTypeId();         
            list <FS_Initial_Order_SAP_Data__c>  SAPData = new list <FS_Initial_Order_SAP_Data__c>();
            for(FS_initial_order__c  a : scope) {
                if( a.FS_1_SAP_Material__c != null && a.FS_1_SAP_Material__c.contains('1457121')) {
                    FS_Initial_Order_SAP_Data__c s1 = new FS_Initial_Order_SAP_Data__c();
                    string splitvar1 =a.FS_1_SAP_Material__c ;
                    list <string> splitString1 = splitvar1.split(':');
                    s1.name=splitString1[0];
                    s1.Cartridge_Name__c =splitString1[1]; 
                    s1.Brand_Name__c = 'Coca-Cola';
                    s1.Brand_group__c='Core';                   
                    s1.Cost_per_Unit__c = a.FS_1_Cost_Unit__c;
                    s1.Initial_Order__c = a.id ;
                    s1.FS_Type__c = '8000 OR 9000 Series';
                    s1.Days_In_Stock__c=21;
                    s1.Master_Data__c = False;
                    s1.recordtypeid= RecortypeIdIO;
                    s1.Slots_8k9k__c=2; 
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s1.FS_7000_Package_Days_Capacity_1000__c = a.FS_1_Package_Days_Capacity_1000__c;
                    } else if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s1.FS_7000_Package_Days_Capacity_1000__c = a.FS_1_Package_Days_Capacity_1000__c;
                    }             

                    SAPData.add(s1); 
                } 
                if (a.FS_2_SAP_Material__c != null && a.FS_2_SAP_Material__c.contains('1452931')) {
                    FS_Initial_Order_SAP_Data__c s2 = new FS_Initial_Order_SAP_Data__c(); 
                    string splitvar2 =a.FS_2_SAP_Material__c ;
                    list <string> splitString2 = splitvar2.split(':');
                    s2.name=splitString2[0];
                    s2.Cartridge_Name__c =splitString2[1]; 
                    s2.Brand_Name__c = 'Coke Zero';
                    s2.Brand_group__c='Core' ;         
                    s2.Cost_per_Unit__c = a.FS_2_Cost_Unit__c;              
                    s2.Initial_Order__c = a.id ;
                    s2.FS_Type__c = '8000 OR 9000 Series';
                    s2.Days_In_Stock__c=21;
                    s2.Master_Data__c = False;
                    s2.recordtypeid= RecortypeIdIO;
                    s2.Slots_8k9k__c=2; 
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s2.FS_7000_Package_Days_Capacity_1000__c = a.FS_2_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s2.FS_7000_Package_Days_Capacity_1000__c = a.FS_2_Package_Days_Capacity_1000__c;
                    }                 
                    SAPData.add(s2);      
                } 
                if (a.FS_3_SAP_Material__c != null &&  a.FS_3_SAP_Material__c.contains('1452929')) {
                    FS_Initial_Order_SAP_Data__c s3 = new FS_Initial_Order_SAP_Data__c();     
                    string splitvar3 =a.FS_3_SAP_Material__c ;
                    list <string> splitString3 = splitvar3.split(':');
                    s3.name=splitString3[0];
                    s3.Cartridge_Name__c =splitString3[1];           
                    s3.Brand_Name__c = 'Diet Coke';
                    s3.Brand_group__c='Core';
                    s3.Cost_per_Unit__c = a.FS_3_Cost_Unit__c; 
                    s3.Initial_Order__c = a.id ;
                    s3.FS_Type__c = '8000 OR 9000 Series';
                    s3.Days_In_Stock__c=21;
                    s3.Master_Data__c = False;
                    s3.recordtypeid= RecortypeIdIO;
                    s3.Slots_8k9k__c=2; 
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s3.FS_7000_Package_Days_Capacity_1000__c = a.FS_3_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s3.FS_7000_Package_Days_Capacity_1000__c = a.FS_3_Package_Days_Capacity_1000__c;
                    }
                    SAPData.add(s3); 
                } 
                if (a.FS_4_SAP_Material__c != null && a.FS_4_SAP_Material__c.contains('1454306')) {
                    FS_Initial_Order_SAP_Data__c s4 = new FS_Initial_Order_SAP_Data__c();  
                    string splitvar4 =a.FS_4_SAP_Material__c ;
                    list <string> splitString4 = splitvar4.split(':');
                    s4.name=splitString4[0];
                    s4.Cartridge_Name__c =splitString4[1];             
                    s4.Brand_Name__c = 'Sprite';
                    s4.Brand_group__c='Core';
                    s4.Cost_per_Unit__c = a.FS_4_Cost_Unit__c;  
                    s4.Initial_Order__c = a.id ;
                    s4.FS_Type__c = '8000 OR 9000 Series';
                    s4.Days_In_Stock__c=21;
                    s4.Master_Data__c = False;
                    s4.recordtypeid= RecortypeIdIO;
                    s4.Slots_8k9k__c=2; 
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s4.FS_7000_Package_Days_Capacity_1000__c = a.FS_4_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s4.FS_7000_Package_Days_Capacity_1000__c = a.FS_4_Package_Days_Capacity_1000__c;
                    }
                    SAPData.add(s4); 
                } 
                if (a.FS_5_SAP_Material__c != null && a.FS_5_SAP_Material__c.contains('171081')) { 
                    FS_Initial_Order_SAP_Data__c s5 = new FS_Initial_Order_SAP_Data__c();         
                    string splitvar5 =a.FS_5_SAP_Material__c ;
                    list <string> splitString5 = splitvar5.split(':');
                    s5.name=splitString5[0];
                    s5.Cartridge_Name__c =splitString5[1]; 
                    s5.Brand_Name__c = 'Fanta';
                    s5.Brand_group__c='Core';         
                    s5.Cost_per_Unit__c = a.FS_5_Cost_Unit__c;    
                    s5.Initial_Order__c = a.id ;
                    s5.FS_Type__c = '8000 OR 9000 Series';
                    s5.Days_In_Stock__c=21;
                    s5.Master_Data__c = False;
                    s5.recordtypeid= RecortypeIdIO;
                    s5.Slots_8k9k__c=2; 
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s5.FS_7000_Package_Days_Capacity_1000__c = a.FS_5_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s5.FS_7000_Package_Days_Capacity_1000__c = a.FS_5_Package_Days_Capacity_1000__c;
                    }   
                    SAPData.add(s5);
                } 
                if (a.FS_6_SAP_Material__c != null && a.FS_6_SAP_Material__c.contains('171185')) { 
                    FS_Initial_Order_SAP_Data__c s6 = new FS_Initial_Order_SAP_Data__c();  
                    string splitvar6 =a.FS_6_SAP_Material__c ;
                    list <string> splitString6 = splitvar6.split(':');
                    s6.name=splitString6[0];
                    s6.Cartridge_Name__c =splitString6[1];  
                    s6.Brand_Name__c = 'Hi-C';
                    s6.Brand_group__c='Core';       
                    s6.Cost_per_Unit__c = a.FS_6_Cost_Unit__c;        
                    s6.Initial_Order__c = a.id ;
                    s6.FS_Type__c = '8000 OR 9000 Series';
                    s6.Days_In_Stock__c=21;
                    s6.Master_Data__c = False;
                    s6.recordtypeid= RecortypeIdIO;
                    s6.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s6.FS_7000_Package_Days_Capacity_1000__c = a.FS_6_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s6.FS_7000_Package_Days_Capacity_1000__c = a.FS_6_Package_Days_Capacity_1000__c;
                    }   
                    SAPData.add(s6); 
                } 
                if (a.FS_7_SAP_Material__c != null && a.FS_7_SAP_Material__c.contains('1442200')) {      
                    FS_Initial_Order_SAP_Data__c s7 = new FS_Initial_Order_SAP_Data__c();
                    string splitvar7 =a.FS_7_SAP_Material__c ;
                    list <string> splitString7 = splitvar7.split(':');
                    s7.name=splitString7[0];
                    s7.Cartridge_Name__c =splitString7[1];  
                    s7.Brand_Name__c = 'Minute Maid';
                    s7.Brand_group__c='Core';          
                    s7.Cost_per_Unit__c = a.FS_7_Cost_Unit__c;
                    s7.Initial_Order__c = a.id ;
                    s7.FS_Type__c = '8000 OR 9000 Series';
                    s7.Days_In_Stock__c=21;
                    s7.Master_Data__c = False;
                    s7.recordtypeid= RecortypeIdIO;
                    s7.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s7.FS_7000_Package_Days_Capacity_1000__c = a.FS_7_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s7.FS_7000_Package_Days_Capacity_1000__c = a.FS_7_Package_Days_Capacity_1000__c;
                    }
                    SAPData.add(s7); 
                }  
                if (a.FS_8_SAP_Material__c != null && a.FS_8_SAP_Material__c.contains('1452928')) { 
                    FS_Initial_Order_SAP_Data__c s8 = new FS_Initial_Order_SAP_Data__c();
                    string splitvar8 =a.FS_8_SAP_Material__c ;
                    list <string> splitString8 = splitvar8.split(':');
                    s8.name=splitString8[0];
                    s8.Cartridge_Name__c =splitString8[1].unescapeEcmaScript(); 
                    s8.Brand_Name__c = 'Barq'+'\''+'s';
                    s8.Brand_group__c='Core';           
                    s8.Cost_per_Unit__c = a.FS_8_Cost_Unit__c;
                    s8.Initial_Order__c = a.id ;
                    s8.FS_Type__c = '8000 OR 9000 Series';
                    s8.Days_In_Stock__c=21;
                    s8.Master_Data__c = False;
                    s8.recordtypeid= RecortypeIdIO;
                    s8.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s8.FS_7000_Package_Days_Capacity_1000__c = a.FS_8_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s8.FS_7000_Package_Days_Capacity_1000__c = a.FS_8_Package_Days_Capacity_1000__c;
                    }
                    SAPData.add(s8); 
                }  
                if (a.FS_9_SAP_Material__c != null && a.FS_9_SAP_Material__c.contains('1452930')) { 
                    FS_Initial_Order_SAP_Data__c s9 = new FS_Initial_Order_SAP_Data__c();  
                    string splitvar9 =a.FS_9_SAP_Material__c ;
                    list <string> splitString9 = splitvar9.split(':');
                    s9.name=splitString9[0];
                    s9.Cartridge_Name__c =splitString9[1]; 
                    s9.Brand_Name__c = 'Diet Coke';
                    s9.Brand_group__c='Core';           
                    s9.Cost_per_Unit__c = a.FS_9_Cost_Unit__c;
                    s9.Initial_Order__c = a.id ;
                    s9.FS_Type__c = '8000 OR 9000 Series';
                    s9.Days_In_Stock__c=21;
                    s9.Master_Data__c = False;
                    s9.recordtypeid= RecortypeIdIO;
                    s9.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s9.FS_7000_Package_Days_Capacity_1000__c = a.FS_9_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s9.FS_7000_Package_Days_Capacity_1000__c = a.FS_9_Package_Days_Capacity_1000__c;
                    }                     
                    SAPData.add(s9); 
                } 
                if (a.FS_10_SAP_Material__c != null ) { 
                    
                    if(a.FS_10_SAP_Material__c.contains('241078') || a.FS_10_SAP_Material__c.contains('1473972')){
                      FS_Initial_Order_SAP_Data__c s10 = new FS_Initial_Order_SAP_Data__c();     
                    string splitvar10 =a.FS_10_SAP_Material__c ;
                    list <string> splitString10 = splitvar10.split(':');
                    s10.name=splitString10[0];
                    s10.Cartridge_Name__c =splitString10[1]; 
                    if(a.FS_10_SAP_Material__c.contains('241078')){
                        s10.Brand_Name__c = 'Mello Yello';
                    }
                    else if(a.FS_10_SAP_Material__c.contains('1473972')){
                        s10.Brand_Name__c = 'Vault';
                    }
                    s10.Brand_group__c='Core';  
                    s10.Cost_per_Unit__c = a.FS_10_Cost_Unit__c;
                    s10.Initial_Order__c = a.id ;
                    s10.FS_Type__c = '8000 OR 9000 Series';
                    s10.Days_In_Stock__c=21;
                    s10.Master_Data__c = False;
                    s10.recordtypeid= RecortypeIdIO;
                    s10.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s10.FS_7000_Package_Days_Capacity_1000__c = a.FS_10_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s10.FS_7000_Package_Days_Capacity_1000__c = a.FS_10_Package_Days_Capacity_1000__c;
                    }                       
                     SAPData.add(s10);
                    }
                } 
                  if (a.FS_11_SAP_Material__c != null) {
                    if (a.FS_11_SAP_Material__c.contains('1445014') || a.FS_11_SAP_Material__c.contains('205082')) { 
                        FS_Initial_Order_SAP_Data__c s11 = new FS_Initial_Order_SAP_Data__c(); 
                        string splitvar11=a.FS_11_SAP_Material__c ;
                        list <string> splitString11 = splitvar11.split(':');
                        s11.name=splitString11[0];
                        s11.Cartridge_Name__c =splitString11[1];  
                        s11.Cost_per_Unit__c = a.FS_11_Cost_Unit__c;  
                        s11.Initial_Order__c = a.id ;
                        s11.FS_Type__c = '8000 OR 9000 Series';
                        s11.Days_In_Stock__c=21;
                        s11.Master_Data__c = False;
                        s11.recordtypeid= RecortypeIdIO;
                        s11.Slots_8k9k__c=2;
                        if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                            System.debug('#####');
                            s11.FS_7000_Package_Days_Capacity_1000__c = a.FS_11_Package_Days_Capacity_1000__c;
                            s11.Brand_Name__c = 'Pibb Xtra';
                            s11.Brand_group__c='Core';
                        }

                        if (a.FS_SpicyCherry__c == 'Pibb') {   
                            System.debug('>>>>>');
                            s11.FS_7000_Package_Days_Capacity_1000__c = a.FS_11_Package_Days_Capacity_1000__c;        
                            s11.Brand_Name__c = 'Pibb';
                            s11.Brand_group__c='Core';
                        }

                        if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                            System.debug('<<<<<<<<');
                            s11.FS_7000_Package_Days_Capacity_1000__c = a.FS_11_Package_Days_Capacity_1000__c;
                            s11.Brand_Name__c = 'Dr Pepper';
                            s11.Brand_group__c='Core';
                        }

                        SAPData.add(s11);      
                        System.debug('the s11 is '+s11);

                    } 
                }
                 if (a.FS_12_SAP_Material__c != null && (a.FS_12_SAP_Material__c.contains('241378') || a.FS_12_SAP_Material__c.contains('1488596'))) { 
                    FS_Initial_Order_SAP_Data__c s12 = new FS_Initial_Order_SAP_Data__c(); 
                    string splitvar12=a.FS_12_SAP_Material__c ;
                    list <string> splitString12 = splitvar12.split(':');
                    s12.name=splitString12[0];
                    s12.Cartridge_Name__c =splitString12[1]; 
                    s12.Brand_Name__c = 'Powerade';
                    s12.Brand_group__c='Core';     
                    s12.Cost_per_Unit__c = a.FS_12_Cost_Unit__c;  
                    s12.Initial_Order__c = a.id ;
                    s12.FS_Type__c = '8000 OR 9000 Series';
                    s12.Days_In_Stock__c=21;
                    s12.Master_Data__c = False;
                    s12.recordtypeid= RecortypeIdIO;
                    s12.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s12.FS_7000_Package_Days_Capacity_1000__c = a.FS_12_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s12.FS_7000_Package_Days_Capacity_1000__c = a.FS_12_Package_Days_Capacity_1000__c;
                    }
                    SAPData.add(s12);       

                }
                 if (a.FS_13_SAP_Material__c != null && (a.FS_13_SAP_Material__c.contains('222878') || a.FS_13_SAP_Material__c.contains('247578'))) { 
                                    FS_Initial_Order_SAP_Data__c s13 = new FS_Initial_Order_SAP_Data__c();         
                                    string splitvar13 =a.FS_13_SAP_Material__c ;
                                    list <string> splitString13 = splitvar13.split(':');
                                    s13.name=splitString13[0];
                                    s13.Cartridge_Name__c =splitString13[1]; 
                                    if(a.FS_13_SAP_Material__c.contains('222878')){
                                       s13.Brand_Name__c = 'Black Cherry';
                                       s13.Brand_group__c='Flavor'; 
                                    }
                                    else if(a.FS_13_SAP_Material__c.contains('247578')){
                                       s13.Brand_Name__c = 'Gingerale';
                                       s13.Brand_group__c='Core';
                                    }
                                      
                                    s13.Cost_per_Unit__c = a.FS_13_Cost_Unit__c;
                                    s13.Initial_Order__c = a.id ;
                                    s13.FS_Type__c = '8000 OR 9000 Series';
                                    s13.Days_In_Stock__c=21;
                                    s13.Master_Data__c = False;
                                    s13.recordtypeid= RecortypeIdIO;
                                    s13.Slots_8k9k__c=2;
                                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                                    s13.FS_7000_Package_Days_Capacity_1000__c = a.FS_13_Package_Days_Capacity_1000__c;
                                    }
                                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                                    s13.FS_7000_Package_Days_Capacity_1000__c = a.FS_13_Package_Days_Capacity_1000__c;
                                    }
                                    SAPData.add(s13); 
                 }                  
                if (a.FS_14_SAP_Material__c != null && a.FS_14_SAP_Material__c.contains('1445012')) { 
                    FS_Initial_Order_SAP_Data__c s14 = new FS_Initial_Order_SAP_Data__c();
                    string splitvar14 =a.FS_14_SAP_Material__c ;
                    list <string> splitString14 = splitvar14.split(':');
                    s14.name=splitString14[0];
                    s14.Cartridge_Name__c =splitString14[1];  
                    s14.Brand_Name__c = 'Dasani';
                    s14.Brand_group__c='Core';   
                    s14.Cost_per_Unit__c = a.FS_14_Cost_Unit__c;
                    s14.Initial_Order__c = a.id ;
                    s14.FS_Type__c = '8000 OR 9000 Series';
                    s14.Days_In_Stock__c=21;
                    s14.Master_Data__c = False;
                    s14.recordtypeid= RecortypeIdIO;
                    s14.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s14.FS_7000_Package_Days_Capacity_1000__c = a.FS_14_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s14.FS_7000_Package_Days_Capacity_1000__c = a.FS_14_Package_Days_Capacity_1000__c;
                    }                        


                    SAPData.add(s14); 
                } 
                if (a.FS_15_SAP_Material__c != null && a.FS_15_SAP_Material__c.contains('1454307')) { 
                    FS_Initial_Order_SAP_Data__c s15 = new FS_Initial_Order_SAP_Data__c();            
                    s15.Initial_Order__c = a.id ;
                    s15.FS_Type__c = '8000 OR 9000 Series';
                    s15.Days_In_Stock__c=21;
                    s15.Master_Data__c = False;
                    s15.recordtypeid= RecortypeIdIO;
                    s15.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s15.FS_7000_Package_Days_Capacity_1000__c = a.FS_15_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s15.FS_7000_Package_Days_Capacity_1000__c = a.FS_15_Package_Days_Capacity_1000__c;
                    }

                    string splitvar15 =a.FS_15_SAP_Material__c ;
                    list <string> splitString15 = splitvar15.split(':');
                    s15.name=splitString15[0];
                    s15.Cartridge_Name__c =splitString15[1]; 
                    s15.Brand_Name__c = 'Orange';
                    s15.Brand_group__c='Flavor';            
                    s15.Cost_per_Unit__c = a.FS_15_Cost_Unit__c;                            


                    SAPData.add(s15); 
                } 
                if (a.FS_16_SAP_Material__c != null && a.FS_16_SAP_Material__c.contains('1454308')) {
                    FS_Initial_Order_SAP_Data__c s16 = new FS_Initial_Order_SAP_Data__c();            
                    s16.Initial_Order__c = a.id ;
                    s16.FS_Type__c = '8000 OR 9000 Series';
                    s16.Days_In_Stock__c=21;
                    s16.Master_Data__c = False;
                    s16.recordtypeid= RecortypeIdIO;
                    s16.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s16.FS_7000_Package_Days_Capacity_1000__c = a.FS_16_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s16.FS_7000_Package_Days_Capacity_1000__c = a.FS_16_Package_Days_Capacity_1000__c;
                    }

                    string splitvar16 =a.FS_16_SAP_Material__c ;
                    list <string> splitString16 = splitvar16.split(':');
                    s16.name=splitString16[0];
                    s16.Cartridge_Name__c =splitString16[1];   
                    s16.Brand_Name__c = 'Cherry';
                    s16.Brand_group__c='Flavor';
                    s16.Cost_per_Unit__c = a.FS_16_Cost_Unit__c;

                    SAPData.add(s16); 
                } 
                if (a.FS_17_SAP_Material__c != null && a.FS_17_SAP_Material__c.contains('1454309')) {
                    FS_Initial_Order_SAP_Data__c s17 = new FS_Initial_Order_SAP_Data__c();            
                    s17.Initial_Order__c = a.id ;
                    s17.FS_Type__c = '8000 OR 9000 Series';
                    s17.Days_In_Stock__c=21;
                    s17.Master_Data__c = False;
                    s17.recordtypeid= RecortypeIdIO;
                    s17.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s17.FS_7000_Package_Days_Capacity_1000__c = a.FS_17_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s17.FS_7000_Package_Days_Capacity_1000__c = a.FS_17_Package_Days_Capacity_1000__c;
                    }

                    string splitvar17 =a.FS_17_SAP_Material__c ;
                    list <string> splitString17 = splitvar17.split(':');
                    s17.name=splitString17[0];
                    s17.Cartridge_Name__c =splitString17[1];   
                    s17.Brand_Name__c = 'Lime';
                    s17.Brand_group__c='Flavor';
                    s17.Cost_per_Unit__c = a.FS_17_Cost_Unit__c;



                    SAPData.add(s17); 
                } 
                if (a.FS_18_SAP_Material__c != null && a.FS_18_SAP_Material__c.contains('1454311')) {
                    FS_Initial_Order_SAP_Data__c s18 = new FS_Initial_Order_SAP_Data__c();            
                    s18.Initial_Order__c = a.id ;
                    s18.FS_Type__c = '8000 OR 9000 Series';
                    s18.Days_In_Stock__c=21;
                    s18.Master_Data__c = False;
                    s18.recordtypeid= RecortypeIdIO;
                    s18.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s18.FS_7000_Package_Days_Capacity_1000__c = a.FS_18_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s18.FS_7000_Package_Days_Capacity_1000__c = a.FS_18_Package_Days_Capacity_1000__c;
                    }

                    string splitvar18 =a.FS_18_SAP_Material__c ;
                    list <string> splitString18 = splitvar18.split(':');
                    s18.name=splitString18[0];
                    s18.Cartridge_Name__c =splitString18[1];   
                    s18.Brand_Name__c = 'Lemon';
                    s18.Brand_group__c='Flavor';
                    s18.Cost_per_Unit__c = a.FS_18_Cost_Unit__c;

                    SAPData.add(s18); 
                } 
                if (a.FS_19_SAP_Material__c != null && a.FS_19_SAP_Material__c.contains('1454312')) {
                    FS_Initial_Order_SAP_Data__c s19 = new FS_Initial_Order_SAP_Data__c();            
                    s19.Initial_Order__c = a.id ;
                    s19.FS_Type__c = '8000 OR 9000 Series';
                    s19.Days_In_Stock__c=21;
                    s19.Master_Data__c = False;
                    s19.recordtypeid= RecortypeIdIO;
                    s19.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s19.FS_7000_Package_Days_Capacity_1000__c = a.FS_19_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s19.FS_7000_Package_Days_Capacity_1000__c = a.FS_19_Package_Days_Capacity_1000__c;
                    }

                    string splitvar19 =a.FS_19_SAP_Material__c ;
                    list <string> splitString19 = splitvar19.split(':');
                    s19.name=splitString19[0];
                    s19.Cartridge_Name__c =splitString19[1];   
                    s19.Brand_Name__c = 'Vanilla';
                    s19.Brand_group__c='Core';
                    s19.Cost_per_Unit__c = a.FS_19_Cost_Unit__c;

                    SAPData.add(s19); 
                } 
                if (a.FS_20_SAP_Material__c != null && a.FS_20_SAP_Material__c.contains('1454310')) {
                    FS_Initial_Order_SAP_Data__c s20 = new FS_Initial_Order_SAP_Data__c();            
                    s20.Initial_Order__c = a.id ;
                    s20.FS_Type__c = '8000 OR 9000 Series';
                    s20.Days_In_Stock__c=21;
                    s20.Master_Data__c = False;
                    s20.recordtypeid= RecortypeIdIO;
                    s20.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s20.FS_7000_Package_Days_Capacity_1000__c = a.FS_20_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s20.FS_7000_Package_Days_Capacity_1000__c = a.FS_20_Package_Days_Capacity_1000__c;
                    }

                    string splitvar20 =a.FS_20_SAP_Material__c ;
                    list <string> splitString20 = splitvar20.split(':');
                    s20.name=splitString20[0];
                    s20.Cartridge_Name__c =splitString20[1];  
                    s20.Brand_Name__c = 'Raspberry';
                    s20.Brand_group__c='Flavor';
                    s20.Cost_per_Unit__c = a.FS_20_Cost_Unit__c;

                    SAPData.add(s20); 
                } 
                if (a.FS_21_SAP_Material__c != null && a.FS_21_SAP_Material__c.contains('1454313')) {
                    FS_Initial_Order_SAP_Data__c s21 = new FS_Initial_Order_SAP_Data__c();            
                    s21.Initial_Order__c = a.id ;
                    s21.FS_Type__c = '8000 OR 9000 Series';
                    s21.Days_In_Stock__c=21;
                    s21.Master_Data__c = False;
                    s21.recordtypeid= RecortypeIdIO;
                    s21.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s21.FS_7000_Package_Days_Capacity_1000__c = a.FS_21_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s21.FS_7000_Package_Days_Capacity_1000__c = a.FS_21_Package_Days_Capacity_1000__c;
                    }

                    string splitvar21 =a.FS_21_SAP_Material__c ;
                    list <string> splitString21 = splitvar21.split(':');
                    s21.name=splitString21[0];
                    s21.Cartridge_Name__c =splitString21[1];   
                    s21.Brand_Name__c = 'Fruit Punch';
                    s21.Brand_group__c='Core';
                    s21.Cost_per_Unit__c = a.FS_21_Cost_Unit__c;

                    SAPData.add(s21); 
                } 
                if (a.FS_22_SAP_Material__c != null && a.FS_22_SAP_Material__c.contains('1473530')) {
                    FS_Initial_Order_SAP_Data__c s22 = new FS_Initial_Order_SAP_Data__c();            
                    s22.Initial_Order__c = a.id ;
                    s22.FS_Type__c = '8000 OR 9000 Series';
                    s22.Days_In_Stock__c=21;
                    s22.Master_Data__c = False;
                    s22.recordtypeid= RecortypeIdIO;
                    s22.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s22.FS_7000_Package_Days_Capacity_1000__c = a.FS_22_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s22.FS_7000_Package_Days_Capacity_1000__c = a.FS_22_Package_Days_Capacity_1000__c;
                    }

                    string splitvar22 =a.FS_22_SAP_Material__c ;
                    list <string> splitString22= splitvar22.split(':');
                    s22.name=splitString22[0];
                    s22.Cartridge_Name__c =splitString22[1];   
                    s22.Brand_Name__c = 'Strawberry';
                    s22.Brand_group__c='Flavor';
                    s22.Cost_per_Unit__c = a.FS_22_Cost_Unit__c;
                    SAPData.add(s22); 
                } 
                if (a.FS_23_SAP_Material__c != null && a.FS_23_SAP_Material__c.contains('1473531')) {
                    FS_Initial_Order_SAP_Data__c s23 = new FS_Initial_Order_SAP_Data__c();            
                    s23.Initial_Order__c = a.id ;
                    s23.FS_Type__c = '8000 OR 9000 Series';
                    s23.Days_In_Stock__c=21;
                    s23.Master_Data__c = False;
                    s23.recordtypeid= RecortypeIdIO;
                    s23.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s23.FS_7000_Package_Days_Capacity_1000__c = a.FS_23_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s23.FS_7000_Package_Days_Capacity_1000__c = a.FS_23_Package_Days_Capacity_1000__c;
                    }

                    string splitvar23 =a.FS_23_SAP_Material__c ;
                    list <string> splitString23 = splitvar23.split(':');
                    s23.name=splitString23[0];
                    s23.Cartridge_Name__c =splitString23[1];   
                    s23.Brand_Name__c = 'Grape';
                    s23.Brand_group__c='Flavor';
                    s23.Cost_per_Unit__c = a.FS_23_Cost_Unit__c;

                    SAPData.add(s23); 

                } 
                if (a.FS_24_SAP_Material__c != null && a.FS_24_SAP_Material__c.contains('1473533')) {
                    FS_Initial_Order_SAP_Data__c s24 = new FS_Initial_Order_SAP_Data__c();            
                    s24.Initial_Order__c = a.id ;
                    s24.FS_Type__c = '8000 OR 9000 Series';
                    s24.Days_In_Stock__c=21;
                    s24.Master_Data__c = False;
                    s24.recordtypeid= RecortypeIdIO;
                    s24.Slots_8k9k__c=2;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s24.FS_7000_Package_Days_Capacity_1000__c = a.FS_24_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s24.FS_7000_Package_Days_Capacity_1000__c = a.FS_24_Package_Days_Capacity_1000__c;
                    }

                    string splitvar24 =a.FS_24_SAP_Material__c ;
                    list <string> splitString24 = splitvar24.split(':');
                    s24.name=splitString24[0];
                    s24.Cartridge_Name__c =splitString24[1];   
                    s24.Brand_Name__c = 'Peach';
                    s24.Brand_group__c='Flavor';
                    s24.Cost_per_Unit__c = a.FS_24_Cost_Unit__c;
                    SAPData.add(s24); 

                } 
                if (a.FS_25_SAP_Material__c != null && a.FS_25_SAP_Material__c.contains('183677')) {
                    FS_Initial_Order_SAP_Data__c s25 = new FS_Initial_Order_SAP_Data__c();            
                    s25.Initial_Order__c = a.id ;
                    s25.FS_Type__c = '8000 OR 9000 Series';
                    s25.Days_In_Stock__c=21;
                    s25.Master_Data__c = False;
                    s25.recordtypeid= RecortypeIdIO;
                    s25.Slots_8k9k__c=0;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                    s25.FS_7000_Package_Days_Capacity_1000__c = a.FS_25_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                    s25.FS_7000_Package_Days_Capacity_1000__c = a.FS_25_Package_Days_Capacity_1000__c;
                    }

                    string splitvar25 =a.FS_25_SAP_Material__c ;
                    list <string> splitString25 = splitvar25.split(':');
                    s25.name=splitString25[0];
                    s25.Cartridge_Name__c =splitString25[1];   
                    s25.Brand_Name__c = 'HFCS';
                    s25.Brand_group__c='Sweetener';
                    s25.Cost_per_Unit__c = a.FS_25_Cost_Unit__c;

                    SAPData.add(s25); 
                } 
                if (a.FS_26_SAP_Material__c != null && a.FS_26_SAP_Material__c.contains('183678')) {
                    FS_Initial_Order_SAP_Data__c s26 = new FS_Initial_Order_SAP_Data__c();            
                    s26.Initial_Order__c = a.id ;
                    s26.FS_Type__c = '8000 OR 9000 Series';
                    s26.Days_In_Stock__c=21;
                    s26.Master_Data__c = False;
                    s26.recordtypeid= RecortypeIdIO;
                    s26.Slots_8k9k__c=0;
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pibb')) {
                        s26.FS_7000_Package_Days_Capacity_1000__c = a.FS_26_Package_Days_Capacity_1000__c;
                    }
                    if (a.FS_SpicyCherry__c  != null && a.FS_SpicyCherry__c.contains('Pepper')) {
                        s26.FS_7000_Package_Days_Capacity_1000__c = a.FS_26_Package_Days_Capacity_1000__c;
                    }

                    string splitvar26 =a.FS_26_SAP_Material__c ;
                    list <string> splitString26 = splitvar26.split(':');
                    s26.name=splitString26[0];
                    s26.Cartridge_Name__c =splitString26[1];   
                    s26.Brand_Name__c = 'NNS';
                    s26.Brand_group__c='Sweetener';
                    s26.Cost_per_Unit__c = a.FS_26_Cost_Unit__c;

                    SAPData.add(s26); 
                }
            }    
            system.debug('The SAP Data to be inserted is '+ SAPData.size());
            
            Database.insert(SAPData, true);
        } catch(Exception exp) {
            System.debug('Exception occurred- '+exp);
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
    
    }
}*/