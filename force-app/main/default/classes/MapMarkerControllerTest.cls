@isTest
private class MapMarkerControllerTest {
    @isTest
    static void returnsActiveIncidentsAndNonOfflineVolunteers() {
        TestDataFactory.createVolunteer('Map Medic', 'Medical', 'Available',
            12.98, 77.60);
        TestDataFactory.createVolunteer('Off Medic', 'Medical', 'Offline',
            12.97, 77.59);

        Test.startTest();
        insert TestDataFactory.buildIncident('High', 'Rescue', 1);
        Test.stopTest();

        List<MapMarkerController.Marker> markers =
            MapMarkerController.getMarkers();
        Integer incidents = 0;
        Integer volunteers = 0;
        for (MapMarkerController.Marker m : markers) {
            if (m.kind == 'incident') incidents++;
            if (m.kind == 'volunteer') volunteers++;
        }
        System.assertEquals(1, incidents, 'The open incident should appear');
        System.assertEquals(1, volunteers, 'Offline volunteers must be hidden');
    }
}

