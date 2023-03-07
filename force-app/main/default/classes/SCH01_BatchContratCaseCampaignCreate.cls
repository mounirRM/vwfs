global class SCH01_BatchContratCaseCampaignCreate implements Schedulable {
   global void execute(SchedulableContext sc) {
       BatchContratCaseCampaignCreate contractInse=new BatchContratCaseCampaignCreate();
       ID batchprocessid = Database.executeBatch(contractInse, 200);   
   }
}