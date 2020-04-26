@isTest
private class ProjectRESTServiceTest {
  
    @TestSetup
    static void loadServiceData(){
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.CloseDate = Date.today();
        opp.StageName = 'Submitted Project';
        
        insert opp;
    
    }
  
    @isTest
    static void testPositiveProjectRESTService(){
    
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id, DeliveryInstallationStatus__c FROM Opportunity];
        
        System.assertEquals(1, oppList.size(), 'The number of opportunities is not correct');
        
        String returnMessage = ProjectRESTService.postProjectData(
            'ProjectRef', 'ProjectName', String.valueOf(oppList[0].Id),
            Date.today(), Date.today(), 1000, 'Running'
        );
            
        Test.stopTest();

        Opportunity opp = [SELECT DeliveryInstallationStatus__c FROM Opportunity];

        System.assertEquals('OK', returnMessage, 'There is an error in the return message');

        System.assertEquals('In progress', opp.DeliveryInstallationStatus__c, 'The delivery installation status is not correct');

        System.assertEquals(1, [SELECT count() FROM Project__c WHERE Opportunity__c =: opp.Id], 'The number of projects is not correct');
    }

    @IsTest
    static void theStartDateCannotBeGreaterThanEndDate(){
        
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity];
        
        String returnMessage = ProjectRESTService.postProjectData(
            'ProjectRef', 'ProjectName', String.valueOf(opp.Id),
            Date.today().addDays(10), Date.today(), 1000, 'Running'
        );
            
        Test.stopTest();

        System.assertEquals(
            true, 
            returnMessage.contains('Project End Date cannot be before Start Date'), 
            'The error message is not expected'
        );

        System.assertEquals(0, [SELECT count() FROM Project__c], 'The number of projects is not correct');
        
    }
}