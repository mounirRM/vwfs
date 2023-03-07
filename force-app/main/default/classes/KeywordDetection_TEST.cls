@IsTest
public class KeywordDetection_TEST {
    
    @isTest static void testRechercheObjetValable(){
        //Setup
       //Recordtype impRecordTypeId=[select id,DeveloperName from recordtype where DeveloperName='Requ_te_standard' limit 1 ];
        Case cse = createTestCase();
        cse.Equipe__c='Recouvrement - Retail';
        cse.Motif__c='Amiable';
        cse.Sous_motif__c='Amende';
        update cse;
        EmailMessage email = createEmail(cse.Id,'Objet','Manuel');
        
        //Test
        Test.startTest();
        Test.stopTest();
        
        //Asserts
        Case caseToAssert = [SELECT ID,Equipe__c,motif__c,sous_Motif__c FROM Case WHERE ID =: cse.Id];
        System.assertEquals('Recouvrement - Retail', caseToAssert.Equipe__c);
        System.assertEquals('Amiable', caseToAssert.Motif__c);
        System.assertEquals('Amende', caseToAssert.Sous_motif__c);
 
    }
        @isTest static void testRechercheObjetNonValable(){
        //Setup
        Recordtype impRecordTypeId=[select id,DeveloperName from recordtype where DeveloperName='Requ_te_standard' limit 1 ];
        Case cse = createTestCase();
        EmailMessage email = createEmail(cse.Id,'Objet','Tutu');
        
        //Test
        Test.startTest();
        Test.stopTest();
        
        //Asserts
        Case caseToAssert = [SELECT ID,Equipe__c,motif__c,sous_Motif__c FROM Case WHERE ID =: cse.Id];
        System.assertEquals('Acceptation Annexes', caseToAssert.Equipe__c);
        System.assertEquals('Divers', caseToAssert.Motif__c);
        System.assertEquals(null, caseToAssert.Sous_motif__c);
 
    }
    @isTest static void testRechercheCorpsValable(){
        //Setup
        //Recordtype impRecordTypeId=[select id,DeveloperName from recordtype where DeveloperName='Requ_te_standard' limit 1 ];
        Case cse = createTestCase();
        cse.Equipe__c='Fleet - Fins de contrat';
        cse.Motif__c='Cession';
        cse.Sous_motif__c='Demande info cession';
        update cse;        
        EmailMessage email = createEmail(cse.Id,'Corps','Demande info cession');
        
        //Test
        Test.startTest();
        Test.stopTest();
        
        //Asserts
        Case caseToAssert = [SELECT ID,Equipe__c,motif__c,sous_Motif__c FROM Case WHERE ID =: cse.Id];
        System.assertEquals('Fleet - Fins de contrat', caseToAssert.Equipe__c);
        System.assertEquals('Cession', caseToAssert.Motif__c);
        System.assertEquals('Demande info cession', caseToAssert.Sous_motif__c);
        
        
    }
    @isTest static void testRechercheCorpsNonValable(){
        //Setup
        Case cse = createTestCase();
        EmailMessage email = createEmail(cse.Id,'Corps','Tralala');
        
        //Test
        Test.startTest();
        Test.stopTest();
        
        //Asserts
        Case caseToAssert = [SELECT ID,Equipe__c,motif__c,sous_Motif__c FROM Case WHERE ID =: cse.Id];
        System.assertEquals('Acceptation Annexes', caseToAssert.Equipe__c);
        System.assertEquals('Divers', caseToAssert.Motif__c);
        System.assertEquals(null, caseToAssert.Sous_motif__c);
 
    }
    @isTest static void testRechercheObjetCorpsValable(){
        //Setup
        Case cse = createTestCase();
        cse.Equipe__c='Retail - Sinistres';
        cse.Motif__c='Gestion sinistre à la personne';
        cse.Sous_motif__c='Gestion décès';
        update cse;  
        //Test
        Test.startTest();
        EmailMessage email = createEmail(cse.Id,'Objet/Corps','Gestion sinistre à la personne');
        Test.stopTest();
        
        //Asserts
        Case caseToAssert = [SELECT ID,Equipe__c,motif__c,sous_Motif__c FROM Case WHERE ID =: cse.Id];
        System.assertEquals('Retail - Sinistres', caseToAssert.Equipe__c);
        System.assertEquals('Gestion sinistre à la personne', caseToAssert.Motif__c);
        System.assertEquals('Gestion décès', caseToAssert.Sous_motif__c);
        
        
    }
    @isTest static void testRechercheObjetCorpsNonValable(){
        //Setup
        Case cse = createTestCase();
        
        //Test
        Test.startTest();
        EmailMessage email = createEmail(cse.Id,'Objet/Corps','Rien à trouver');        
        Test.stopTest();
        
        //Asserts
        Case caseToAssert = [SELECT ID,Equipe__c,motif__c,sous_Motif__c FROM Case WHERE ID =: cse.Id];
        System.assertEquals('Acceptation Annexes', caseToAssert.Equipe__c);
        System.assertEquals('Divers', caseToAssert.Motif__c);
        System.assertEquals(null, caseToAssert.Sous_motif__c);
        
        
    }       
    
       @isTest static void testmatchingThePattern(){
        //Setup
        KeywordDetectionRule__mdt rulesList= [SELECT Destinataires__c, Expediteurs__c, Expression__c, File_d_attente__c, Motif__c, Sous_motif__c, Ou__c, Priorite__c, Operateur__c FROM KeywordDetectionRule__mdt  limit 1];
        Group sc =[select Id from Group where  Type = 'Queue' limit 1];
        //queueMap=[select developpername,Id from Group where  Type = 'Queue' limit 1];
        Map<String,Id> queueMap= new Map<String,String>();
            
            for (Group theGroup:[Select Id, Name from Group where Type = 'Queue' limit 1])
            {
               queueMap.put(theGroup.Name,theGroup.Id);
            }
        
        
        Pattern keywordPattern = Pattern.compile('a*b');
        //Map<String,Id> queueMap= new Map<String,Id> ();
        Case cse = createTestCase();
        cse.Equipe__c='Retail - Sinistres';
        cse.Motif__c='Gestion sinistre à la personne';
        cse.Sous_motif__c='Gestion décès';
        cse.ownerid=sc.id;
        update cse;  
        //Test
        Test.startTest();
        
        System.assert(KeywordDetection.matchingThePattern(rulesList, keywordPattern,'aaaaab','000833',queueMap,cse));
        Test.stopTest();

        
    } 
    
       @isTest static void testconstructRegexFromOperator(){
        //Setup
       // First, instantiate a new Pattern object "MyPattern"
            Pattern MyPattern = Pattern.compile('a*b');
            Matcher MyMatcher = MyPattern.matcher('aaaaab');
           Boolean Test = Pattern.matches('a*b', 'aaaaab');
        
        //Test
       // Test.startTest();
        
         KeywordDetection.constructRegexFromOperator('Commence par',''); 
         KeywordDetection.constructRegexFromOperator('Contient',''); 
         KeywordDetection.constructRegexFromOperator('Mot entier','');     
        //Test.stopTest();
        
        
        
    }  
    
    @isTest static void testRechercheObjetCorpsDestinataire(){
        //Setup
        Case cse = createTestCase();
        
        //Test
        Test.startTest();
        EmailMessage email = createEmail(cse.Id,'Objet/Corps','Rien à trouver');        
        Test.stopTest();
        
        //Asserts
        Case caseToAssert = [SELECT ID,Equipe__c,motif__c,sous_Motif__c FROM Case WHERE ID =: cse.Id];
        System.assertEquals('Acceptation Annexes', caseToAssert.Equipe__c);
        System.assertEquals('Divers', caseToAssert.Motif__c);
        System.assertEquals(null, caseToAssert.Sous_motif__c);
        
        
    } 
    
    //Test utilitary methods
     public static Case createTestCase(){
     Recordtype impRecordTypeId=[select id,DeveloperName from recordtype where DeveloperName='Requ_te_standard' limit 1 ];
        Case cas = new Case(Origin ='Email', Status ='A traiter',RecordTypeId=impRecordTypeId.id, Equipe__c = 'Acceptation Annexes', Motif__c = 'Divers');
        insert cas;
        return cas;
    }

    public static EmailMessage createEmail(String cseId,String lieuOuChercher,String valeurExpression){
        EmailMessage email = new EmailMessage();
        email.ToAddress = 'rcfleet-uat@vwfs.com';
        email.incoming=true;
        switch on lieuOuChercher{
            when 'Objet'{
                email.Subject = 'Test Contrat ' + valeurExpression;
                email.TextBody = 'le corps du mail ';
            }
            when 'Corps'{
                email.Subject = 'Test Contrat ';
                email.TextBody = 'le corps du mail et le mot ' + valeurExpression;
            }
            when 'Objet/Corps'{
                email.Subject = 'Test Contrat ' + valeurExpression;
                email.TextBody = 'le corps du mail et le mot ' + valeurExpression;
            }
        }
        email.ParentId = cseId;
        insert email;
        return email;
      }
}