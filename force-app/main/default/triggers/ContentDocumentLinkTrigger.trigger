trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    switch on Trigger.operationType {
        when BEFORE_UPDATE {
        }
        when AFTER_UPDATE {
        }
        when BEFORE_DELETE {
        }
        when AFTER_INSERT {
            ContentDocumentLinkTriggerHandler.handleAfterInsert(Trigger.oldMap, Trigger.newMap);
        }
    }
}