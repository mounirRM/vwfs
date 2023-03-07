Global class AP_DetectDuplicatePersonAccount{
    Public static void replaceOldPersonAccountByNew(Set<Account> PAListNotCreatedByRef,Set<Account> PAListCreatedByRef){
        System.debug('PAListNotCreatedByRef :'+PAListNotCreatedByRef);
        System.debug('PAListCreatedByRef :'+PAListCreatedByRef);
        
        Set<Id> accIdNotcreatedbyRefSet = new Set<Id>();
        Set<Id> accIdCreatedbyRefSet = new Set<Id>();
        Map<String,Contact> keyIdAContactCreatedByRef = new Map<String,Contact>();
        Map<String,Account> keyIdAccNotCreatedByRef = new Map<String,Account>();
        Map<String,Account> keyIdAccCreatedByRef = new Map<String,Account>();
        List<Case> caseListToUpdate = new List<Case>();
        List<Contract__c> ContractListToUpdate = new List<Contract__c>();
        List<Contact> ContactListToUpdate = new List<Contact>();
        List<Account> accountsToDelete = new List<Account>();
        for(Account acc : PAListNotCreatedByRef){
            keyIdAccNotCreatedByRef.put((acc.firstname+acc.LastName).toUpperCase()+acc.Date_de_naissance__c,acc);
            accIdNotcreatedbyRefSet.add(acc.Id);
        }
        System.debug('keyIdAccNotCreatedByRef :'+keyIdAccNotCreatedByRef);
        System.debug('accIdNotcreatedbyRefSet :'+accIdNotcreatedbyRefSet);
        for(Account acc1 : PAListCreatedByRef){
            accIdCreatedbyRefSet.add(acc1.Id);
            keyIdAccCreatedByRef.put((acc1.firstname+acc1.LastName).toUpperCase()+acc1.Date_de_naissance__c,acc1);
        }
        System.debug('accIdCreatedbyRefSet :'+accIdCreatedbyRefSet);
        System.debug('keyIdAccCreatedByRef :'+keyIdAccCreatedByRef);
        
        List<Case> getCaseList = [SELECT Id,AccountId,Account.FirstName,Account.LastName,Account.Date_de_naissance__c,ContactId,Contact.Account.FirstName,Contact.Account.LastName,Contact.Account.Date_de_naissance__c FROM Case Where (AccountId IN: accIdNotcreatedbyRefSet OR ContactId IN: accIdNotcreatedbyRefSet)];
        List<Contract__c> getContractList = [SELECT Id,Compte_client_associe__c,Compte_client_associe__r.FirstName,Compte_client_associe__r.LastName,Compte_client_associe__r.Date_de_naissance__c FROM Contract__c Where Compte_client_associe__c IN: accIdNotcreatedbyRefSet];
        List<Contact> getContactList = [SELECT Id,AccountId,Account.FirstName,Account.LastName,Account.Date_de_naissance__c FROM Contact Where AccountId IN: accIdCreatedbyRefSet];
        for(Contact con : getContactList){
            keyIdAContactCreatedByRef.put((con.Account.firstname+con.Account.LastName).toUpperCase()+con.Account.Date_de_naissance__c,con);
        }
        System.debug('getCaseList :'+getCaseList);
        for(Case cs : getCaseList){
            cs.AccountId = keyIdAccCreatedByRef.containsKey((cs.Account.FirstName+cs.Account.LastName).toUpperCase()+cs.Account.Date_de_naissance__c)?keyIdAccCreatedByRef.get((cs.Account.FirstName+cs.Account.LastName).toUpperCase()+cs.Account.Date_de_naissance__c).Id:cs.AccountId;
        	cs.ContactId = keyIdAContactCreatedByRef.containsKey((cs.Contact.Account.firstname+cs.Contact.Account.LastName).toUpperCase()+cs.Contact.Account.Date_de_naissance__c)?keyIdAContactCreatedByRef.get((cs.Contact.Account.firstname+cs.Contact.Account.LastName).toUpperCase()+cs.Contact.Account.Date_de_naissance__c).Id:cs.ContactId;
            caseListToUpdate.add(cs);
        }
        System.debug('caseListToUpdate :'+caseListToUpdate);
        update caseListToUpdate;
        
        for(Contract__c cntract : getContractList){
            cntract.Compte_client_associe__c = keyIdAccCreatedByRef.containsKey((cntract.Compte_client_associe__r.FirstName+cntract.Compte_client_associe__r.LastName).toUpperCase()+cntract.Compte_client_associe__r.Date_de_naissance__c)?keyIdAccCreatedByRef.get((cntract.Compte_client_associe__r.FirstName+cntract.Compte_client_associe__r.LastName).toUpperCase()+cntract.Compte_client_associe__r.Date_de_naissance__c).Id:cntract.Compte_client_associe__c;
       		ContractListToUpdate.add(cntract);
        }
        System.debug('ContractListToUpdate :'+ContractListToUpdate);
        update ContractListToUpdate;
        
        /*
        for(Contact cntct : getContactList){
            cntct.AccountId = keyIdAccCreatedByRef.containsKey(cntct.Account.FirstName+cntct.Account.LastName+cntct.Account.Date_de_naissance__c)?keyIdAccCreatedByRef.get(cntct.Account.FirstName+cntct.Account.LastName+cntct.Account.Date_de_naissance__c).Id:cntct.AccountId;
        	ContactListToUpdate.add(cntct);
        }*/
        //update ContactListToUpdate;
    }
}