public class ContentDocumentLinkTriggerHandler {
    public static void handleAfterInsert(Map<Id,ContentDocumentLink> oldMap, Map<Id,ContentDocumentLink> newMap) {
        System.debug('handleAfterInsert');
        Map<Id,String> oldContentDOcIdUniqueId = new Map<Id,String>();
        Map<Id,Set<Id>> linkEntityIdContentDOcIds = new Map<Id,Set<Id>>();
        Map<Id,ContentVersion> contentDOcIdcontVer = new Map<Id,ContentVersion>();
        Map<String,String> uniqueIdContentVerId = new Map<String,String>();
        Set<Id> ContentDOcIdSet = new Set<Id>();
        Set<Id> ContentVerIdSet = new Set<Id>();
        List<contentVersion> contentVersionList = new List<contentVersion>();
        List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
        for(ContentDocumentLink cntDoclink : newMap.values()){
            System.debug('cntDoclink :'+cntDoclink);
            String sObjName = cntDoclink.LinkedEntityId.getSObjectType().getDescribe().getName();
            if(sObjName == 'DU_ContractOffer__c'){
                if(linkEntityIdContentDOcIds.containsKey(cntDoclink.LinkedEntityId)){
                    Set<Id> existingIdSet = linkEntityIdContentDOcIds.get(cntDoclink.LinkedEntityId);
                    existingIdSet.add(cntDoclink.ContentDocumentId);
                    linkEntityIdContentDOcIds.put(cntDoclink.LinkedEntityId,existingIdSet);
                }else{
                    Set<Id> newIdSet = new Set<Id>();
                    newIdSet.add(cntDoclink.ContentDocumentId);
                    linkEntityIdContentDOcIds.put(cntDoclink.LinkedEntityId,newIdSet);
                }
                ContentDOcIdSet.add(cntDoclink.ContentDocumentId);
            }
        }
        System.debug('linkEntityIdContentDOcIds :'+linkEntityIdContentDOcIds);
        
        List<ContentVersion> contentVerList = [SELECT Id,ContentDocumentId,FileExtension,FileType,PathOnClient,Title,VersionData FROM ContentVersion WHERE ContentDocumentId IN:ContentDOcIdSet];
        System.debug('contentVerList :'+contentVerList);
        
        for(ContentVersion cv : contentVerList){
            contentDOcIdcontVer.put(cv.ContentDocumentId,cv);
        }
        
        if(linkEntityIdContentDOcIds.size() > 0){
            List<Case> CaseList = [SELECT Id,Contract_Offer__c FROM Case WHERE Contract_Offer__c IN:linkEntityIdContentDOcIds.keyset()];
            for(Case cs : CaseList){
                for(Id ids : linkEntityIdContentDOcIds.get(cs.Contract_Offer__c)){
                    String uniqueId = contentDOcIdcontVer.get(ids).Title+ String.valueof(contentDOcIdcontVer.get(ids).PathOnClient)+String.valueOf(contentDOcIdcontVer.get(ids).VersionData);
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.Title = contentDOcIdcontVer.get(ids).Title;
                    contentVersion.PathOnClient = contentDOcIdcontVer.get(ids).PathOnClient;
                    contentVersion.VersionData = contentDOcIdcontVer.get(ids).VersionData;
                    oldContentDOcIdUniqueId.put(ids,uniqueId);
					contentVersionList.add(contentVersion);                    
                }
            }   
            System.debug('contentVersionList :'+contentVersionList);
            Insert contentVersionList;
            for(ContentVersion cnv : contentVersionList){
                ContentVerIdSet.add(cnv.Id);
            }
            List<ContentVersion> contverList = [SELECT Id, ContentDocumentId,Title,PathOnClient,VersionData FROM ContentVersion WHERE Id IN:ContentVerIdSet];
            
            for(ContentVersion cv1 : contverList){
                String uniqueId = cv1.Title+ String.valueof(cv1.PathOnClient)+String.valueOf(cv1.VersionData);
                uniqueIdContentVerId.put(uniqueId, cv1.ContentDocumentId);
            }
            for(Case cs : CaseList){
                for(Id ids : linkEntityIdContentDOcIds.get(cs.Contract_Offer__c)){
                    String uniqueId = contentDOcIdcontVer.get(ids).Title+ String.valueof(contentDOcIdcontVer.get(ids).PathOnClient)+String.valueOf(contentDOcIdcontVer.get(ids).VersionData);
                        ContentDocumentLink contentDocLink = new ContentDocumentLink();
                        contentDocLink.LinkedEntityId = cs.Id;
                        contentDocLink.ContentDocumentId = uniqueIdContentVerId.get(uniqueId);
                        ContentDocumentLinkList.add(contentDocLink); 
                }
            }   
            System.debug('ContentDocumentLinkList :'+ContentDocumentLinkList);
            Insert ContentDocumentLinkList;
        }
    }
}