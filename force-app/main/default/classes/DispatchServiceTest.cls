@isTest
private class DispatchServiceTest {

    @isTest
    static void nearestVolunteersAreFilteredAndOrdered() {
        Volunteer__c near = TestDataFactory.createVolunteer(
            'Near Medic', 'Medical', 'Available', 12.9800, 77.6000);
        TestDataFactory.createVolunteer('Mid Medic', 'Medical', 'Available',
            13.0500, 77.6500);
        TestDataFactory.createVolunteer('Far Medic', 'Medical', 'Available',
            15.3000, 75.1000);
        TestDataFactory.createVolunteer('Busy Medic', 'Medical', 'Busy',
            12.9710, 77.5940);
        TestDataFactory.createVolunteer('Near Rescuer', 'Rescue',
            'Available', 12.9720, 77.5950);

        List<Volunteer__c> result = DispatchService.findNearestVolunteers(
            TestDataFactory.INC_LAT, TestDataFactory.INC_LON, 'Medical', 5,
            new Set<Id>());

        System.assertEquals(2, result.size(),
            'Only available Medical volunteers within 50 km should match');
        System.assertEquals(near.Id, result[0].Id, 'The closest volunteer must come first');
    }

    @isTest
    static void newIncidentDispatchesNearestVolunteersAndMarksThemBusy() {
        Volunteer__c near = TestDataFactory.createVolunteer(
            'Near Rescuer', 'Rescue', 'Available', 12.9800, 77.6000);
        Volunteer__c mid = TestDataFactory.createVolunteer(
            'Mid Rescuer', 'Rescue', 'Available', 13.0500, 77.6500);
        TestDataFactory.createVolunteer('Far Rescuer', 'Rescue', 'Available',
            15.3000, 75.1000);

        Incident__c inc = TestDataFactory.buildIncident('Critical', 'Rescue', 2);

        Test.startTest();
        insert inc;
        Test.stopTest();

        List<Dispatch__c> dispatches = [
            SELECT Status__c, Distance_KM__c FROM Dispatch__c WHERE Incident__c = :inc.Id
        ];
        System.assertEquals(2, dispatches.size(), 'Two volunteers were needed and available');
        for (Dispatch__c d : dispatches) {
            System.assertEquals('Assigned', d.Status__c);
            System.assert(d.Distance_KM__c > 0 && d.Distance_KM__c < 50,
                'Distance should be recorded in km');
        }

        Set<Id> expected = new Set<Id>{ near.Id, mid.Id };
        System.assertEquals(2, [
            SELECT COUNT() FROM Volunteer__c WHERE Status__c = 'Busy' AND Id IN :expected
        ]);
        System.assertEquals('Assigned',
            [SELECT Status__c FROM Incident__c WHERE Id = :inc.Id].Status__c);
    }

    @isTest
    static void higherPriorityIncidentGetsTheOnlyVolunteer() {
        TestDataFactory.createVolunteer('Only Medic', 'Medical', 'Available',
            12.98, 77.60);
        Incident__c low = TestDataFactory.buildIncident('Low', 'Medical', 1);
        Incident__c critical = TestDataFactory.buildIncident('Critical', 'Medical', 1);

        Test.startTest();
        insert new List<Incident__c>{ low, critical };
        Test.stopTest();

        System.assertEquals(1,
            [SELECT COUNT() FROM Dispatch__c WHERE Incident__c = :critical.Id]);
        System.assertEquals(0,
            [SELECT COUNT() FROM Dispatch__c WHERE Incident__c = :low.Id]);
    }

    @isTest
    static void resolvingIncidentReleasesVolunteers() {
        Volunteer__c v = TestDataFactory.createVolunteer(
            'Rescuer', 'Rescue', 'Available', 12.98, 77.60);
        Incident__c inc = TestDataFactory.buildIncident('High', 'Rescue', 1);

        Test.startTest();
        insert inc;
        Test.stopTest();

        System.assertEquals('Busy', [SELECT Status__c FROM Volunteer__c WHERE Id = :v.Id].Status__c);

        inc.Status__c = 'Resolved';
        inc.Resolution_Notes__c = 'Residents evacuated safely.';
        update inc;

        System.assertEquals('Available',
            [SELECT Status__c FROM Volunteer__c WHERE Id = :v.Id].Status__c);
        System.assertEquals('Completed',
            [SELECT Status__c FROM Dispatch__c WHERE Incident__c = :inc.Id].Status__c);
    }

    @isTest
    static void bulkIncidentsNeverDoubleBookVolunteers() {
        TestDataFactory.createVolunteers(10, 'Medical');
        List<Incident__c> incidents = new List<Incident__c>();
        for (Integer i = 0; i < 20; i++) {
            incidents.add(TestDataFactory.buildIncident('Medium', 'Medical', 1));
        }

        Test.startTest();
        insert incidents;
        Test.stopTest();

        List<Dispatch__c> dispatches = [SELECT Volunteer__c FROM Dispatch__c];
        Set<Id> distinctVolunteers = new Set<Id>();
        for (Dispatch__c d : dispatches) {
            distinctVolunteers.add(d.Volunteer__c);
        }
        System.assertEquals(10, dispatches.size(), 'One dispatch per available volunteer');
        System.assertEquals(10, distinctVolunteers.size(), 'No volunteer is dispatched twice');
    }
}

