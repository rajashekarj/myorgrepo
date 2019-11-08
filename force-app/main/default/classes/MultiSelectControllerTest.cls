@isTest
public class MultiSelectControllerTest {
  
    public static testMethod void TestController(){
          List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('US','US'));
            options.add(new SelectOption('CANADA','Canada'));
            options.add(new SelectOption('MEXICO','Mexico'));  
         
        List<SelectOption> Loptions = new List<SelectOption>();
        	Loptions.add(new SelectOption('US','US'));
            Loptions.add(new SelectOption('CANADA','Canada'));
            Loptions.add(new SelectOption('MEXICO','Mexico'));  
        
         List<SelectOption> Roptions = new List<SelectOption>();
        	Roptions.add(new SelectOption('US','US'));
            Roptions.add(new SelectOption('CANADA','Canada'));
            Roptions.add(new SelectOption('MEXICO','Mexico'));    
        
        test.startTest();
          MultiSelectController MSP = new MultiSelectController();
          MSP.setOptions(options,'HYD&Bang&Delhi');
          MSP.leftOptions=Loptions;
          MSP.rightOptions=	Roptions;
          String left = MSP.leftOptionsHidden;
          String right = MSP.rightOptionsHidden;
          
          MSP.rightOptionsHidden= 'Test';
          MSP.leftOptionsHidden= 'Test 1';
          test.stopTest();
    }
}