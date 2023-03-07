global class SCH02_BatchContratCaseCampaignClose implements Schedulable {
   global void execute(SchedulableContext sc) {
       BatchContratCaseCampaignClose contractclo=new BatchContratCaseCampaignClose();
       ID batchprocessid = Database.executeBatch(contractclo);
       
   }
}