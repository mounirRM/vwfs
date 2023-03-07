@isTest
public class SCH01_BatchCtrCaseCampaignCreate_TEST {
 @isTest static void TestBatchcreatesch() {
    
         Integer nextYear = System.Today().year() + 1;
         String cronExpr = '0 0 0 15 9 ? ' + String.valueof(nextYear);
         //'15 sept of next year';

         Test.startTest();
             SCH01_BatchContratCaseCampaignCreate obj = new SCH01_BatchContratCaseCampaignCreate();
             String jobId = System.schedule('myJobTestJobName', cronExpr, obj);
             obj.execute(null);
         Test.stopTest();
    }
}