public with sharing class DispatchAssignmentJob implements Queueable {
    private List<Id> incidentIds;

    public DispatchAssignmentJob(List<Id> incidentIds) {
        this.incidentIds = incidentIds;
    }

    public void execute(QueueableContext ctx) {
        // Most urgent incidents get volunteers first.
        List<Incident__c> incidents = [
            SELECT Id, Required_Skill__c, Volunteers_Needed__c,
                Location__Latitude__s, Location__Longitude__s
            FROM Incident__c
            WHERE Id IN :incidentIds AND Status__c = 'New'
            ORDER BY Priority_Score__c DESC
        ];

        List<Id> deferred = DispatchService.assignVolunteers(incidents);

        // Chain a new job for anything we ran out of queries for.
        if (!deferred.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new DispatchAssignmentJob(deferred));
        }
    }
}

