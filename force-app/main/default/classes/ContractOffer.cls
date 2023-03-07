public class ContractOffer {
  public static void caseCreateContractOffer(
    List<QueueSobject> queueVenteEnLigne,
    Map<Id,DU_ContractOffer__c> contractOfferMap
  ) {
    List<Case> caseToInsert = new List<Case>();
    List<ContentDocumentLink> contentDocumentLinkToUpdate = new List<ContentDocumentLink>();
    for (DU_ContractOffer__c co : contractOfferMap.values()) {
      Case newCase = new Case(
        OwnerId = queueVenteEnLigne[0].QueueId,
        Subject = co.Name,
        Equipe__c = 'Acceptation Retail Vente en ligne',
        Motif__c = 'Vente en ligne',
        Sous_motif__c = 'Nouvelle adhésion',
        Origin = 'Web',
        Contract_Offer__c = co.Id
      );
      caseToInsert.add(newCase);
    }
    insert (caseToInsert);
  }
}