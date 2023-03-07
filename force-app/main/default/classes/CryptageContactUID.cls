public without sharing class CryptageContactUID {
  @InvocableMethod
  public static void encrypt(list<string> id) {
    if (Schema.sObjectType.Contact.isAccessible()) {
      Contact c = [SELECT ID, UID__c FROM Contact WHERE id = :id[0]];
      if (
        c.UID__c == null && Schema.sObjectType.Contact.isUpdateable() ||
        Test.isRunningTest()
      ) {
        String iv = 'IV52536365276518';
        Blob key = Crypto.generateAesKey(128);
        Blob data = Blob.valueOf(id[0]);
        Blob encrypted = Crypto.encrypt('AES128', key, Blob.valueOf(iv), data);
        String urlencoded = EncodingUtil.urlEncode(
          EncodingUtil.convertToHex(encrypted),
          'UTF-8'
        );
        c.UID__c = urlencoded;
        update c;
      }
    } else {
      System.debug('The Object Contact isn\'t Accessible');
    }
  }
}