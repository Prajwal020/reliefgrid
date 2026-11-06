public with sharing class IncidentEscalationBatch
    implements Database.Batchable<SObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime criticalCutoff = Datetime.now().addHours(-1);
        Datetime highCutoff = Datetime.now().addHours(-3);
        return Database.getQueryLocator([
            SELECT Id FROM Incident__c
            WHERE Status__c = 'New' AND Escalated__c = false
            AND ((Severity__c = 'Critical' AND Reported_Date__c < :criticalCutoff)
              OR (Severity__c = 'High' AND Reported_Date__c < :highCutoff))
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Incident__c> scope) {
        for (Incident__c inc : scope) {
            inc.Status__c = 'Escalated';
            inc.Escalated__c = true;
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {}

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 200);
    }
}

