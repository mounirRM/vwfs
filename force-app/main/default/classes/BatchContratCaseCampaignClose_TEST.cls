@IsTest
public class BatchContratCaseCampaignClose_TEST {
      @isTest static void TestBatchclose() {
        Recordtype rtaccid=[select id,DeveloperName from recordtype where DeveloperName='ClientB2B' limit 1 ];
        Recordtype rtcontid=[select id,DeveloperName from recordtype where DeveloperName='Contact_Client' limit 1 ];
        Recordtype impRecordTypeId=[select id,DeveloperName from recordtype where DeveloperName='Gestion_d_impay' limit 1 ];    
       //créer le compte B2B
         Account accou = new Account();
         accou.Name='TestBatcheclose';
         accou.RecordTypeId=rtaccid.id;
         insert accou;
      
      //créer le contact 
         Contact conta = new Contact();
         conta.FirstName='Contact';
         conta.LastName='batchclose';
         conta.RecordTypeId=rtcontid.id;
         conta.AccountId= accou.id; 
         insert conta;
          
          //créer le contrat
      List < Contract__c > insertcontra = new List< Contract__c >(); 
         Contract__c ctra = new Contract__c();
         ctra.Name='12341212LLD';
         ctra.Code_statut_contrat__c='RECAMIT';
         ctra.Compte_client_associe__c =accou.ID;
         ctra.Contact_client_associe__c = conta.Id;
         ctra.Produit_financier__c = 'LLD';
         ctra.Numero_de_contrat__c='12341212LLD';
         ctra.Date_de_l_alerte__c= date.parse('09/04/2022');     
         insertcontra.add(ctra);
          
           insert insertcontra;
          
          //créer le case
       
         Case cas = new Case();
         Database.DMLOptions dmo = new Database.DMLOptions();
         dmo.assignmentRuleHeader.useDefaultRule = true;
         cas.setOptions(dmo);
         cas.Subject = 'ctra Test';  
         cas.RecordTypeId=impRecordTypeId.id;   
         cas.Date_d_ch_ance__c= date.parse('04/04/2022'); 
         cas.Status ='A traiter';
         cas.Contrat__c = ctra.id;
         cas.AccountId= ctra.Contact_client_associe__r.AccountId;
         cas.ContactId=  ctra.Contact_client_associe__c;
         cas.Priority = 'Low';
         cas.Origin = 'Email'; 
         cas.Equipe__c = 'Acceptation Annexes';
         cas.Motif__c = 'Divers';
        
         insert cas;
      
          Test.startTest();
            BatchContratCaseCampaignClose obj = new BatchContratCaseCampaignClose();
            DataBase.executeBatch(obj);
        Test.stopTest(); 
    }
}