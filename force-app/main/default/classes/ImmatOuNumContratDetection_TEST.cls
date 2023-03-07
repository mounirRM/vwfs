@IsTest
public class ImmatOuNumContratDetection_TEST {
    
    @isTest static void TestImmatContratDetection(){
        //Setup
        String resultatImmatErronee,
            resultatImmatCorrecte,
            resultatVide,
            resultatNumContratErrone,
            resultatNumContratCorrect; 

        
        //Testing
        Test.startTest();
        resultatImmatErronee = ImmatOuNumContratDetection.immatContratDetection('AAA1243/RR');
        resultatImmatCorrecte = ImmatOuNumContratDetection.immatContratDetection('FN.028 TX');
        resultatVide = ImmatOuNumContratDetection.immatContratDetection('');
        resultatNumContratErrone = ImmatOuNumContratDetection.immatContratDetection('123456GFJ08');
        resultatNumContratCorrect = ImmatOuNumContratDetection.immatContratDetection('12345678ABC0');
        Test.stopTest();
        
        //Assertions
        System.assertEquals(null, resultatImmatErronee);
        System.assertEquals('FN-028-TX', resultatImmatCorrecte);
        System.assertEquals(null, resultatVide);
        System.assertEquals(null, resultatNumContratErrone);        
        System.assertEquals('12345678ABC0', resultatNumContratCorrect);
        
    }
    
    
    @isTest static void TestLinkContrat(){
        //Setup
        Account acc = new Account(Name ='Test Account');
        insert acc;
        Contract__c cont = new Contract__c(Immatriculation__c ='FN-028-TX',Name = 'Test Contrat',Numero_de_contrat__c ='12345678LOA',Compte_client_associe__c=acc.Id);
        insert cont;

        //Testing
        Test.startTest();
        Contract__c contRetourneImmatCorrecte = ImmatOuNumContratDetection.linkContrat('FN-028-TX');
        Contract__c contRetourneNumContratCorrect = ImmatOuNumContratDetection.linkContrat('12345678LOA');
        Contract__c contRetourneValeurErronee = ImmatOuNumContratDetection.linkContrat('12435GG90');
        Contract__c contRetourneValeureNulle = ImmatOuNumContratDetection.linkContrat('');
        Test.stopTest();
        
        //Assertions
        System.assertEquals(cont.Id, contRetourneImmatCorrecte.Id);
        System.assertEquals(cont.Id, contRetourneNumContratCorrect.Id);
        System.assertEquals(null, contRetourneValeurErronee);
        System.assertEquals(null, contRetourneValeureNulle);
        
    }
    
}