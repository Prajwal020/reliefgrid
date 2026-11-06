public with sharing class IncidentTriggerHandler {
    public static void afterInsert(List<Incident__c> newIncidents) {
        List<Id> toDispatch = new List<Id>();
        for (Incident__c inc : newIncidents) {
            if (inc.Location__Latitude__s != null &&
                inc.Location__Longitude__s != null) {
                toDispatch.add(inc.Id);
            }
        }
        if (!toDispatch.isEmpty()) {
            System.enqueueJob(new DispatchAssignmentJob(toDispatch));
        }
    }

    public static void afterUpdate(List<Incident__c> newIncidents,
        Map<Id, Incident__c> oldMap) {
        Set<Id> resolvedIds = new Set<Id>();
        for (Incident__c inc : newIncidents) {
            if (inc.Status__c == 'Resolved' && oldMap.get(inc.Id).Status__c != 'Resolved') {
                resolvedIds.add(inc.Id);
            }
        }
        if (!resolvedIds.isEmpty()) {
            DispatchService.releaseVolunteers(resolvedIds);
        }
    }
}

