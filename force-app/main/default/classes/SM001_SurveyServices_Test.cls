@isTest
public class SM001_SurveyServices_Test {
    //On active le "seeAllData" pour s'assurer que le Survey "VWFS_Survey" ET que la communauté "VWFS public community"
    // existent dans notre pllateforme
    @isTest(SeeAllData=true)
    public static void surveyInvitationTest(){
        // On crée un contact et un case avant d'appeler notre méthode. Champs obligatoires case : Equipe__c, Motif__c, Sous_motif__c
        Contact contactAlpha = new Contact(LastName='Test Contact',UID__c='UidTestClass00x21Cap');
        insert contactAlpha;
        Case case1= new Case(ContactId=contactAlpha.id, Equipe__c = 'Recouvrement - Retail', Motif__c = 'Amiable', Sous_motif__c = 'Amende');
        insert case1;
        list <id> casesid= new list <id>();
        casesid.add(case1.Id);
        //On appelle la méthode qui permet de générer une invitation du survey rattachée à la requête "case1" du contact "contactAlpha"
        SM001_SurveyServices.createSurveyInvitation(casesid);
        //On teste que l'invitation du survey a été créée en cherchant une invitation qui contient l'Id du "case1"
        System.assertEquals(case1.id,[Select Case__c from SurveyInvitation WHERE Case__c=:case1.id][0].Case__c,'The SurveyInvitation was not created');       

    }

}