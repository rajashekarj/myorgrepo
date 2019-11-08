@isTest
private with sharing class FSRevenueCenterTest {
  static String rc;
  static testmethod void TestRevenueCenter15() {    
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('151210');
    System.debug('********* retrieved ********* : ' + rc);
    Test.stopTest();
    System.assert(rc == 'Central Region');
  }
  
  static testmethod void TestRevenueCenter253() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('253100');
    Test.stopTest();
    System.assert(rc == 'Central Region - Independent Bottler');
  }
  
  static testmethod void TestRevenueCenter26() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('264410');
    Test.stopTest();
    System.assert(rc == 'East Region');
  }
  
  static testmethod void TestRevenueCenter263() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('263221');
    Test.stopTest();
    System.assert(rc == 'East Region - Independent Bottler');
  }
  
  static testmethod void TestRevenueCenter17() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('174410');
    Test.stopTest();
    System.assert(rc == 'West Region');
  }
  
  static testmethod void TestRevenueCenter273() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('273410');
    Test.stopTest();
    System.assert(rc == 'West Region - Independent Bottler');
  }
  
  static testmethod void TestRevenueCenter711() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('711410');
    Test.stopTest();
    System.assert(rc == 'Walmart/Sams');
  }
  
  static testmethod void TestRevenueCenter712() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('712410');
    Test.stopTest();
    System.assert(rc == 'Kroger');
  }
  
  static testmethod void TestRevenueCenter713() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('713410');
    Test.stopTest();
    System.assert(rc == 'Large Store Northern Market');
  }
  
  static testmethod void TestRevenueCenter714() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('714410');
    Test.stopTest();
    System.assert(rc == 'Large Store East');
  }
  //New
  static testmethod void TestRevenueCenter7141() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('714110');
    Test.stopTest();
    System.assert(rc == 'Large Store East Dispensed');
  }
  
   //New
  static testmethod void TestRevenueCenter7142() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('714210');
    Test.stopTest();
    System.assert(rc == 'Publix');
  }
  static testmethod void TestRevenueCenter9001() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('900110');
    Test.stopTest();
    System.assert(rc == 'Military Account Group');
  }
  
  static testmethod void TestRevenueCenter715() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('715410');
    Test.stopTest();
    System.assert(rc == 'Large Store Central');
  }
  
  //New
  static testmethod void TestRevenueCenter7151() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('715110');
    Test.stopTest();
    System.assert(rc == 'Large Store Central Dispensed');
  }
  //New
  static testmethod void TestRevenueCenter7152() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('715210');
    Test.stopTest();
    System.assert(rc == 'Target');
  }
  static testmethod void TestRevenueCenter716() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('716710');
    Test.stopTest();
    System.assert(rc == 'Large Store West');
  }
  //New
  static testmethod void TestRevenueCenter7161() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('716110');
    Test.stopTest();
    System.assert(rc == 'Large Store West Dispensed');
  }
  //New
  static testmethod void TestRevenueCenter7162() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('716210');
    Test.stopTest();
    System.assert(rc == 'Stater Bros');
  }
  //New
  static testmethod void TestRevenueCenter7163() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('716310');
    Test.stopTest();
    System.assert(rc == 'Safeway');
  }
  
  
  static testmethod void TestRevenueCenter717() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('717510');
    Test.stopTest();
    System.assert(rc == 'Convenience Retail');
  }
  
  
  //New
  static testmethod void TestRevenueCenter7171() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('717110');
    Test.stopTest();
    System.assert(rc == 'Convenience Retail East');
  }

  //New
  static testmethod void TestRevenueCenter7172() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('717210');
    Test.stopTest();
    System.assert(rc == 'Convenience Retail West');
  }
  
  //New
  static testmethod void TestRevenueCenter7173() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('717310');
    Test.stopTest();
    System.assert(rc == 'Circle K');
  }
  
  //New
  static testmethod void TestRevenueCenter7174() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('717410');
    Test.stopTest();
    System.assert(rc == 'Convenience Retail Central');
  }
  
  
  static testmethod void TestRevenueCenter718() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('718710');
    Test.stopTest();
    System.assert(rc == 'Drug Value Channel');
  }
  
  //New
  static testmethod void TestRevenueCenter7181() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('718110');
    Test.stopTest();
    System.assert(rc == 'Walgreens');
  }
  
  //New
  static testmethod void TestRevenueCenter7182() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('718210');
    Test.stopTest();
    System.assert(rc == 'Drug Value Other');
  }  
  
  static testmethod void TestRevenueCenter719() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('719410');
    Test.stopTest();
    System.assert(rc == 'Specialty Retail & Emerging');
  }
  
  static testmethod void TestRevenueCenter72() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('728110');
    Test.stopTest();
    System.assert(rc == 'Warehouse Sales');
  }
  
  static testmethod void TestRevenueCenter77() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('779410');
    Test.stopTest();
    System.assert(rc == '7-Eleven');
  }

  static testmethod void TestRevenueCenter61() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('619410');
    Test.stopTest();
    System.assert(rc == 'Burger King');
  }
  
  static testmethod void TestRevenueCenter62() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('628110');
    Test.stopTest();
    System.assert(rc == 'Subway');
  }
  
  static testmethod void TestRevenueCenter63() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('639410');
    Test.stopTest();
    System.assert(rc == 'Sonic');
  }
  
  static testmethod void TestRevenueCenter641() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('641410');
    Test.stopTest();
    System.assert(rc == 'NFSOP East Zone');
  }
  
  static testmethod void TestRevenueCenter642() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('642110');
    Test.stopTest();
    System.assert(rc == 'NFSOP Central Zone');
  }
  
  static testmethod void TestRevenueCenter643() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('643410');
    System.debug('********* retrieved ********* : ' + rc);
    Test.stopTest();
    System.assert(rc == 'NFSOP West Zone');
  }  
  
  static testmethod void TestRevenueCenter651() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('651410');
    Test.stopTest();
    System.assert(rc == 'SPM Airlines');
  }
  
  static testmethod void TestRevenueCenter652() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('652110');
    Test.stopTest();
    System.assert(rc == 'SPM Strategic Alliances');
  }
  //
    static testmethod void TestRevenueCenter66() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('661410');
    Test.stopTest();
    System.assert(rc == 'Wendys');
  }
  
  static testmethod void TestRevenueCenter671() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('671110');
    Test.stopTest();
    System.assert(rc == 'Onsite - Daly');
  }
  //New
  static testmethod void TestRevenueCenter6712() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('671210');
    Test.stopTest();
    System.assert(rc == 'Compass');
  }
  //New
  static testmethod void TestRevenueCenter6713() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('671310');
    Test.stopTest();
    System.assert(rc == 'Aramark');
  }
  
  static testmethod void TestRevenueCenter672() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('672710');
    Test.stopTest();
    System.assert(rc == 'Onsite - Taylor');
  }
  //New
  static testmethod void TestRevenueCenter6721() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('672110');
    Test.stopTest();
    System.assert(rc == 'Sodexo');
  }
  //New
  static testmethod void TestRevenueCenter6722() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('672210');
    Test.stopTest();
    System.assert(rc == 'HMS Host');
  }
  //New
  static testmethod void TestRevenueCenter6723() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('672310');
    Test.stopTest();
    System.assert(rc == 'Healthcare');
  }
  
  static testmethod void TestRevenueCenter673() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('673110');
    Test.stopTest();
    System.assert(rc == 'Onsite - NSR');
  }
  //New
    static testmethod void TestRevenueCenter6732() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('673210');
    Test.stopTest();
    System.assert(rc == 'NSR Central and West');
  }
  //New
    static testmethod void TestRevenueCenter6733() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('673310');
    Test.stopTest();
    System.assert(rc == 'NSR East');
  }
  //New
    static testmethod void TestRevenueCenter6734() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('673410');
    Test.stopTest();
    System.assert(rc == 'Home Depot');
  }
  
  
  static testmethod void TestRevenueCenter68() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('682110');
    Test.stopTest();
    System.assert(rc == 'National Distribution');
  }
  static testmethod void TestRevenueCenter51() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('512110');
    Test.stopTest();
    System.assert(rc == 'McDonalds');
  }
  static testmethod void NoMatch() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('999999');
    Test.stopTest();
    System.assert(rc == 'no match');
  }
  
  static testmethod void TestRevenueCenter60() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('602110');
    Test.stopTest();
    System.assert(rc == 'NFSOP Foodservice');
  }
  
  static testmethod void TestRevenueCenter64() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('640000');
    Test.stopTest();
    System.assert(rc == 'NFSOP Zones');
  }
  
  static testmethod void TestRevenueCenter65() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('650000');
    Test.stopTest();
    System.assert(rc == 'Strategic Partnership Marketing (SPM)');
  }
  
  static testmethod void TestRevenueCenter67() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('670000');
    Test.stopTest();
    System.assert(rc == 'Onsite & NSR');
  }
  
  static testmethod void TestRevenueCenter141() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('941000');
    Test.stopTest();
    System.assert(rc == 'NFSOP East Zone');
  }
  
  static testmethod void TestRevenueCenter142() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('942000');
    Test.stopTest();
    System.assert(rc == 'NFSOP Central Zone');
  }
  
  static testmethod void TestRevenueCenter143() {
    Test.startTest();
    rc = FSRevenueCenterUtil.lookupRevenueCenter('943000');
    Test.stopTest();
    System.assert(rc == 'NFSOP West Zone');
  }
  
}