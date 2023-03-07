/**
* @author Yves RUMURI
* @date Creation 10/05/2021
* @description CaseTrigger
*/
trigger CaseTrigger on Case (after insert, after update,before update) {

  if (PAD.bypassAllTriggers ) return;
  CaseTriggerHandler.handleTrigger(Trigger.new, Trigger.operationType,Trigger.oldMap,Trigger.newMap);
}