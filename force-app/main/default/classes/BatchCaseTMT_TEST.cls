@IsTest
public class BatchCaseTMT_TEST {
    @isTest
    static void BatchCaseTMT_TEST() {
        Case ca = new Case();
        ca.Subject = 'ctr Test';
        ca.Status = 'A traiter';
        ca.Priority = 'Low';
        ca.Origin = 'Email';
        ca.Equipe__c = 'Recouvrement - Retail';
        ca.Motif__c = 'Amiable';
        ca.Sous_motif__c = 'Amende';
        insert ca;

        Test.startTest();
        BatchCaseTMT obj = new BatchCaseTMT();
        DataBase.executeBatch(obj);
        Test.stopTest();
    }
}