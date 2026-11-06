@isTest
private class IncidentEscalationBatchTest {

    @isTest
    static void escalatesOnlyOverdueUnattendedIncidents() {
        Incident__c overdueCritical =
            TestDataFactory.buildIncident('Critical', 'Rescue', 1);
        overdueCritical.Reported_Date__c = Datetime.now().addHours(-2);
        Incident__c recentCritical =
            TestDataFactory.buildIncident('Critical', 'Rescue', 1);
        Incident__c overdueLow = TestDataFactory.buildIncident('Low', 'Rescue', 1);
        overdueLow.Reported_Date__c = Datetime.now().addHours(-10);
        insert new List<Incident__c>{ overdueCritical, recentCritical, overdueLow };

        Test.startTest();
        Database.executeBatch(new IncidentEscalationBatch(), 200);
        Test.stopTest();

        Map<Id, Incident__c> result = new Map<Id, Incident__c>([
            SELECT Status__c, Escalated__c FROM Incident__c
        ]);
        System.assertEquals('Escalated',
            result.get(overdueCritical.Id).Status__c);
        System.assert(result.get(overdueCritical.Id).Escalated__c);
        System.assertEquals('New', result.get(recentCritical.Id).Status__c,
            'A recent Critical incident should not be escalated yet');
        System.assertEquals('New', result.get(overdueLow.Id).Status__c,
            'Low severity incidents are never escalated');
    }

    @isTest
    static void jobCanBeScheduledHourly() {
        Test.startTest();
        Id jobId = System.schedule('Test Escalation Job', '0 0 * * * ?',
            new IncidentEscalationBatch());
        Test.stopTest();

        CronTrigger ct = [SELECT CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 * * * ?', ct.CronExpression);
    }
}

