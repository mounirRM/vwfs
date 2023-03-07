public without sharing class SM001_SurveyServices {
    @InvocableMethod
    public static void createSurveyInvitation(list <string> id) {
        if(Schema.sObjectType.Case.isAccessible() && Schema.sObjectType.Network.isAccessible() && Schema.sObjectType.Survey.isAccessible()&& Schema.sObjectType.SurveyInvitation.isAccessible() ){
            List<Case> thisCase = [SELECT Id,ContactId,CaseNumber FROM Case WHERE id=:id[0] LIMIT 1];
            //Change %Consumer% in the following line to a unique keyword for the Community Name where your surveys are published
            List<Network> thisCommunity = [SELECT Id FROM Network WHERE Name LIKE 'VWFS public community' LIMIT 1];
            //Change %Hutch% in the following line to a unique keyword for the Survey you want to show your chat users
            List<Survey> thisSurvey = [SELECT Id FROM Survey WHERE Name LIKE 'VWFS_Survey' LIMIT 1];
                        //Creates a new instance of SurveyInvition and populate the required fields
            SurveyInvitation newSurveyInvitation = new SurveyInvitation();
            Case c=thisCase[0];
            newSurveyInvitation.Name ='VWFS_Invitation_Survey_'+Datetime.now()+'_'+c.CaseNumber;
            newSurveyInvitation.SurveyId = thisSurvey[0].Id;
            newSurveyInvitation.Case__c=c.id;
            newSurveyInvitation.CommunityId = thisCommunity[0].Id;
            newSurveyInvitation.OptionsAllowGuestUserResponse = true;
            newSurveyInvitation.ParticipantId = c.ContactId;
            try{
                if(Schema.sObjectType.Case.isUpdateable() && Schema.sObjectType.SurveyInvitation.isCreateable() ){
                    insert newSurveyInvitation;
                    c.Survey_URL__c=[SELECT InvitationLink from SurveyInvitation WHERE Id=:newSurveyInvitation.id LIMIT 1][0].InvitationLink;
                    update c;
                }
            } catch(dmlexception e){
                system.debug('SurveyInvitation creation error: ' + e);
            }
        }
    }
}