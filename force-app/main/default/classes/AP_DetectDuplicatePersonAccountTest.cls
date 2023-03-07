@Istest
public class AP_DetectDuplicatePersonAccountTest {
    @testSetup static void testData() {
        User u = [SELECT Id,Name FROM USer WHERE Name = 'ref360'];
        System.runAs(u) {
            List<Account> personAccList = new List<Account>();
            for(Integer i=0;i<10;i++){
                Account personAccount = new Account();
                personAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                personAccount.Salutation = 'Mr.';
                personAccount.FirstName='Test FName'+i;
                personAccount.LastName='Test LName'+i;
                personAccount.PersonMailingStreet='test@yahoo.com';
                personAccount.PersonMailingPostalCode='12345';
                personAccount.PersonMailingCity='SFO';
                personAccount.PersonEmail='test@yahoo.com';
                personAccount.PersonHomePhone='1234567';
                personAccount.PersonMobilePhone='12345678'; 
                personAccount.Phone='12345678';
                personAccount.Date_de_naissance__c = Date.newInstance(2000,10,10); 
                personAccount.Nom_de_naissance__pc = 'tesssst';
                personAccount.Nationalite__c = 'France';
                personAccount.Pays_de_naissance__c = 'France';
                personAccList.add(personAccount);
            }
            Insert personAccList;
        }
        
        List<Account> personAccList2 = new List<Account>();
        for(Integer i=0;i<10;i++){
            Account personAccount2 = new Account();
            personAccount2.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            personAccount2.Salutation = 'Mr.';
            personAccount2.FirstName='Test FName'+i;
            personAccount2.LastName='Test LName'+i;
            personAccount2.PersonMailingStreet='test@yahoo.com';
            personAccount2.PersonMailingPostalCode='12345';
            personAccount2.PersonMailingCity='SFO';
            personAccount2.PersonEmail='test@yahoo.com';
            personAccount2.PersonHomePhone='1234567';
            personAccount2.PersonMobilePhone='12345678'; 
            personAccount2.Phone='12345678';
            personAccount2.Nom_de_naissance__pc = 'tesssst';
            personAccount2.Date_de_naissance__c = Date.newInstance(2000,10,10); 
            personAccount2.Nationalite__c = 'France';
            personAccount2.Pays_de_naissance__c = 'France';
            personAccList2.add(personAccount2);
        }
        Insert personAccList2;
    }
    @Istest
    public static void replaceOldPersonAccountByNewTest(){
        Set<Account> PAListNotCreatedByRef = new Set<Account>();
        Set<Account> PAListCreatedByRef = new Set<Account>();
        List<Account> PAListNotCreatedByRefList = [SELECT Id,Name,IsPersonAccount,FirstName,LastName,Date_de_naissance__c,ShippingPostalCode FROM Account where IsPersonAccount = true AND createdby.Name !='ref360' and Date_de_naissance__c!=null];
        List<Account> PAListCreatedByRefList = [SELECT Id,Name,IsPersonAccount,FirstName,LastName,Date_de_naissance__c,ShippingPostalCode FROM Account where IsPersonAccount = true AND createdby.Name ='ref360' and Date_de_naissance__c!=null];
        PAListNotCreatedByRef.addAll(PAListNotCreatedByRefList);
        PAListCreatedByRef.addAll(PAListCreatedByRefList);
        Database.executeBatch(new AP_DetectDuplicatePersonAccountBatch(), 100);
        //AP_DetectDuplicatePersonAccount.replaceOldPersonAccountByNew(PAListNotCreatedByRef,PAListCreatedByRef);
    }
}