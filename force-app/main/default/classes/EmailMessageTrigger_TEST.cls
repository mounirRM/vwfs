@isTest
private class EmailMessageTrigger_TEST {
    @isTest static void TestInsertEmailMessage() {
        // Test data setup
        EmailMessage em = new EmailMessage();
        em.ToAddress = 'test@test.com';
        em.Subject = 'Objet du mail';

        // Perform test
        Test.startTest();
        Database.SaveResult result = Database.insert(em, false);
        Test.stopTest();
        
        //System.assert(result.isSuccess());
        
    }
    
}