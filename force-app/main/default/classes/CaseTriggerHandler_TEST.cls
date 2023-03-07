/**
* @author Yves RUMURI
* @date Creation 10/05/2021
* @description CaseTrigger
* Ver   Date         Author                               Modification
* 1.0   10-05-2021   YRU                             Initial Version [P002156-1609]
*/
@isTest
private class CaseTriggerHandler_TEST {





///*

    @isTest static void TestUpdateCaseTrigger() {


      Recordtype rtaccid=[select id,DeveloperName from recordtype where DeveloperName='ClientB2B' limit 1 ];
     Recordtype rtcontid=[select id,DeveloperName from recordtype where DeveloperName='Contact_Client' limit 1 ];
     Recordtype rtcaseid=[select id,DeveloperName from recordtype where DeveloperName='Requ_te_standard' limit 1 ];
     Group queuid =[SELECT DeveloperName,Id,Name,Type FROM Group WHERE Type = 'Queue' limit 1];
     Profile p =[Select id,Name From Profile  where Name=: 'System Administrator'].get(0);
     User u = new User(firstname= 'user',
                          lastname='adm',
                          Alias='usadm',
                          email = 'testuserad@test.fr',
                          username= 'testuserad@test.fr',
                          profileId= p.id,
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
                insert u;
         //créer le compte B2B
         Account acco = new Account();
         acco.Name='TOMerra';
         acco.RecordTypeId=rtaccid.id;
        insert acco;
         //créer le contact
         Contact conc = new Contact();
         conc.FirstName='mOMera';
         conc.LastName='tes';
         conc.RecordTypeId= rtcontid.id;
         conc.AccountId= acco.id;
        insert conc;


                 //créer le contrat
          Contract__c ctra = new Contract__c();
          ctra.Numero_de_contrat__c = '98989000LOA';
          ctra.Name='98989000LOA';
          ctra.Compte_client_associe__c= acco.Id;
          ctra.Contact_client_associe__c = conc.Id;
          insert ctra;

        List<case> cslist=new List<case>();
        List<casehistory> cshlist=new List<casehistory>();

        // Test data setup
        Case c0 = new Case();
         c0.Subject = 'ctr Test';
         c0.Status ='Closed';
         c0.Contrat__c = ctra.id;
         c0.RecordTypeId=rtcaseid.id;
         c0.ContactId=  ctra.Contact_client_associe__c;
         c0.AccountId= acco.id;
         c0.Priority = 'Low';
         c0.Origin = 'Email';
         c0.Tempspassenfiledattente__c=null;
         c0.Tempspassepourtraitement__c=null;
         c0.Tempspasssenstatutdattentejour__c=null;
         insert c0;
         c0.ownerid=queuid.id;
         update c0;
         c0.ownerid=u.id;
         update c0;

         cslist.add(c0);

        Case ca = new Case();
         ca.Subject = 'ctr Test';
         ca.Status ='Closed';
        ca.RecordTypeId=rtcaseid.id;
         ca.Contrat__c = ctra.id;
         ca.ContactId=  ctra.Contact_client_associe__c;
         ca.AccountId= ctra.Contact_client_associe__r.AccountId;
         ca.Priority = 'Low';
         ca.Origin = 'Email';
         ca.Tempspassenfiledattente__c=null;
         ca.Tempspassepourtraitement__c=null;
         ca.Tempspasssenstatutdattentejour__c=null;

         insert ca;
       Case ca1 = new Case();
         ca1.Subject = 'ctr Test';
         ca1.Status ='En Attente';
        ca1.RecordTypeId=rtcaseid.id;
         ca1.Contrat__c = ctra.id;
         ca1.ContactId=  ctra.Contact_client_associe__c;
         ca1.AccountId= ctra.Contact_client_associe__r.AccountId;
         ca1.Priority = 'Low';
         ca1.Origin = 'Email';
         ca1.Tempspassenfiledattente__c=null;
         ca1.Tempspassepourtraitement__c=null;
         ca1.Tempspasssenstatutdattentejour__c=null;

         insert ca1;

         Test.setCreatedDate(ca.id, DateTime.newInstance(2021,05,10));
         ca.ownerid=queuid.id;
         update ca;

         Test.setCreatedDate(ca1.id, DateTime.newInstance(2021,05,10));
         ca1.ownerid=queuid.id;
         update ca1;
       CaseHistory ho=new CaseHistory();
        ho.caseid=ca.id;
        ho.Field='Owner';

        insert ho;

         ca.ownerid=u.id;
         update ca;
       CaseHistory ho1=new CaseHistory();
        ho1.caseid=ca.id;
        ho1.Field='Owner';
        insert ho1;
        ca.Tempspassepourtraitement__c=1;
        update ca;
      CaseHistory ho2=new CaseHistory();
        ho2.caseid=ca.id;
        ho2.Field='Owner';
        insert ho2;
      ca.Tempspassepourtraitement__c=3;
        update ca;
      CaseHistory ho3=new CaseHistory();
        ho3.caseid=ca.id;
        ho3.Field='Owner';
        insert ho3;
       CaseHistory ho4=new CaseHistory();
        ho4.caseid=ca.id;
        ho4.Field='Owner';
        insert ho4;

        CaseHistory ho5=new CaseHistory();
        ho5.caseid=ca1.id;
        ho5.Field='Status';
        insert ho5;
        ca1.Tempspasssenstatutdattentejour__c=1;
        update ca1;
        ca1.status='Closed';
         update ca1;
        
         /*
        CaseHistory ho6=new CaseHistory();
        ho6.caseid=ca1.id;
        ho6.Field='Status';
        insert ho6;
        ca1.Tempspasssenstatutdattentejour__c=2;
        update ca1;

        CaseHistory ho7=new CaseHistory();
        ho7.caseid=ca1.id;
        ho7.Field='Status';
        insert ho7;
        ca1.Tempspasssenstatutdattentejour__c=3;
        update ca1;

        cshlist.add(ho);
        cshlist.add(ho1);
        cshlist.add(ho2);
        cshlist.add(ho3);
        cshlist.add(ho4);
        cshlist.add(ho5);
        //cshlist.add(ho6);
        //cshlist.add(ho7);
        cslist.add(ca);
        cslist.add(ca1);

        Test.startTest();
        CaseTriggerHandler.handleAfterUpdate(cslist);
        Test.stopTest();

    }
*/
    }
}