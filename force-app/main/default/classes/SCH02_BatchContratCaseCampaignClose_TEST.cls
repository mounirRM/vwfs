@IsTest
public class SCH02_BatchContratCaseCampaignClose_TEST {
    @isTest static void TestBatchclosesch() {
        Test.startTest();
        String cronExpr = '0 0 23 * * ?';
        SCH02_BatchContratCaseCampaignClose obj = new SCH02_BatchContratCaseCampaignClose();
        String jobId = System.schedule('myJobTestJobName', cronExpr, obj);
        obj.execute(null);
        Test.stopTest(); 
    }
}