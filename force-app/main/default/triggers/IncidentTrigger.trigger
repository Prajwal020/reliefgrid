trigger IncidentTrigger on Incident__c (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        IncidentTriggerHandler.afterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        IncidentTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}

