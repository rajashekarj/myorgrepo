/**************************************************************************************
Apex Class Name     : FSCaseCommentTriggerHandlerTest
Function            : This is a Case Comment Trigger Handler Test class for handling 
					  all unit test methods for Case Comment Trigger Handler class.
Author				: Infosys
Modification Log    :
* Developer         : Date             Description
* ----------------------------------------------------------------------------                 
* Sunil TD	          07/31/2017       Original Version for handling unit testing.
*************************************************************************************/

@isTest(seeAllData=false)
public class FSCaseCommentTriggerHandlerTest {

    /*****************************************************************************************
        Method : dataSetup
        Description : Method for setting up the data required in this unit test class.
    ******************************************************************************************/
    @testSetup
    public static void dataSetup()
    {
        List<Case> caseList=FACT_TestFactory.createFACTCaseRecords(1,true);
    }
    
    /*****************************************************************************************
        Method : insertCaseComment
        Description : Method for unit testing case comment insertion.
    ******************************************************************************************/
    public static testMethod void insertCaseComment()
    {
        try
        {
            Test.startTest();
            Case caseRecord = [select Id from Case Limit 1];
            caseComment caseCommentRecord = new caseComment();
            caseCommentRecord.ParentId = caseRecord.Id;
            caseCommentRecord.CommentBody = 'TestValue';
            insert caseCommentRecord;
            Test.stopTest();
        }
        catch(DmlException ex)
        {
            system.debug('DmlException : ' + ex.getMessage());
        }
    }
}