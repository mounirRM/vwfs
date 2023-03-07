trigger BERTrigger on BER__c (after insert, after update, after delete) {
      if (PAD.bypassAllTriggers ) return;
    BERTriggerHandler.handleTrigger(Trigger.new,(Map<Id,BER__c> )Trigger.OldMap,  Trigger.operationType);
}