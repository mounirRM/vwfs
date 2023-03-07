@Istest
public class ContentDocumentLinkTriggerHandlerTest {
    @Istest
    public static void testContentDocLink(){
        DU_ContractOffer__c conOffer = new DU_ContractOffer__c();
        conOffer.DU_Product__c = 'skodaserviceinspection';
        conOffer.DU_TransactionId__c = '91c6426e-dcc6-4164-be86-b92f87a26193';
        Insert conOffer;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion; 
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
        ContentDocumentLink contentDocLink = new ContentDocumentLink();
        contentDocLink.LinkedEntityId = conOffer.Id;
        contentDocLink.ContentDocumentId = documents[0].Id;
        contentDocLink.shareType = 'V';
        contentDocLink.visibility = 'AllUsers';
        ContentDocumentLinkList.add(contentDocLink);
        Insert ContentDocumentLinkList;
    }
}