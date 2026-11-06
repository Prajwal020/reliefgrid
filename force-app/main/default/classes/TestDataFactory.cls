@isTest
public class TestDataFactory {
    // Incident location used throughout the tests.
    public static final Double INC_LAT = 12.9716;
    public static final Double INC_LON = 77.5946;

    public static Volunteer__c createVolunteer(String name, String skill,
        String status, Double lat, Double lon) {
        Volunteer__c v = new Volunteer__c(
            Name = name, Skill__c = skill, Status__c = status,
            Email__c = name.deleteWhitespace().toLowerCase() + '@example.com',
            Phone__c = '9845000000',
            Current_Location__Latitude__s = lat,
            Current_Location__Longitude__s = lon
        );
        insert v;
        return v;
    }

    public static Volunteer__c createVolunteer(String name, String skill,
        String status, Decimal lat, Decimal lon) {
        Double dLat = lat != null ? lat.doubleValue() : null;
        Double dLon = lon != null ? lon.doubleValue() : null;
        return createVolunteer(name, skill, status, dLat, dLon);
    }

    public static List<Volunteer__c> createVolunteers(Integer count, String skill) {
        List<Volunteer__c> volunteers = new List<Volunteer__c>();
        for (Integer i = 0; i < count; i++) {
            volunteers.add(new Volunteer__c(
                Name = 'Bulk Volunteer ' + i, Skill__c = skill, Status__c = 'Available',
                Email__c = 'bulk' + i + '@example.com', Phone__c = '9845000000',
                Current_Location__Latitude__s = 12.98 + (i * 0.001),
                Current_Location__Longitude__s = 77.60
            ));
        }
        insert volunteers;
        return volunteers;
    }

    // Not inserted: the caller decides when to insert.
    public static Incident__c buildIncident(String severity, String skill, Integer needed) {
        return new Incident__c(
            Incident_Type__c = 'Flood', Severity__c = severity, Status__c = 'New',
            Required_Skill__c = skill, Volunteers_Needed__c = needed,
            People_Affected__c = 40, Address__c = 'Test Street',
            Location__Latitude__s = INC_LAT, Location__Longitude__s = INC_LON
        );
    }
}
