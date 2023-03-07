/**
* @author Clément ROCHER
* @date Creation 13/11/2020
* @description EmailMessageTrigger
*/

trigger EmailMessageTrigger on EmailMessage (before insert, after insert) {
    if (PAD.bypassAllTriggers ) return;
    EmailMessageTriggerHandler.handleTrigger(Trigger.new, Trigger.operationType);
}