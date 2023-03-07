@isTest
public with sharing class TMT_TEST {
    @isTest static void TMT_TEST() {
        //Création groupe
        Group testGroup = new Group(Name='Recouvrement - Fleet', Type='Queue');
        insert testGroup;

        //Création file d'attente
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            //Associating queue with group AND to the Case object
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

        List<Case> caseInsert = new List<Case>();
        Case case1 = new Case(Status = 'En attente', OwnerId = testGroup.Id, Origin = 'Web', Equipe__c = 'Recouvrement - Fleet', Motif__c = 'Amiable', Sous_motif__c = 'AR');
        caseInsert.add(case1);

        Case case2 = new Case(Status = 'Closed', OwnerId = testGroup.Id, Origin = 'Web', Equipe__c = 'Recouvrement - Fleet', Motif__c = 'Amiable', Sous_motif__c = 'AR');
        caseInsert.add(case2);

        insert caseInsert;

        Test.startTest();      
        CaseTriggerHandler.handleAfterUpdate(caseInsert);
        Test.stopTest();
    }
}

/*Test
- Création d'une queue
- Création case 1 avec owner = file d'attente et statut = attente
- Création case 2 statut = closed
- Création Business Hours --> Pas besoin de créer, ce n'est pas une donnée utilisateur donc on peut récupérer celui par défaut
*/

/*Infos obligatoire pour création case
- Statut
- Case origin
- Case owner ?
*/

/*Questions
- Si j'appelle directement mon trigger, est ce que la file d'attente que j'ai créée dans ce test est prise en compte ?

*/