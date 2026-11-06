public with sharing class MapMarkerController {
    public class Marker {
        @AuraEnabled public Double latitude;
        @AuraEnabled public Double longitude;
        @AuraEnabled public String title;
        @AuraEnabled public String description;
        @AuraEnabled public String kind; // 'incident' or 'volunteer'
    }

    private static Marker build(Double lat, Double lon, String title,
        String description, String kind) {
        Marker m = new Marker();
        m.latitude = lat;
        m.longitude = lon;
        m.title = title;
        m.description = description;
        m.kind = kind;
        return m;
    }

    private static Marker build(Decimal lat, Decimal lon, String title,
        String description, String kind) {
        Double dLat = lat != null ? lat.doubleValue() : null;
        Double dLon = lon != null ? lon.doubleValue() : null;
        return build(dLat, dLon, title, description, kind);
    }

    @AuraEnabled(cacheable=true)
    public static List<Marker> getMarkers() {
        List<Marker> markers = new List<Marker>();
        for (Incident__c inc : [
            SELECT Name, Incident_Type__c, Severity__c, Status__c,
                Location__Latitude__s, Location__Longitude__s
            FROM Incident__c WHERE Status__c != 'Resolved' LIMIT 200
        ]) {
            if (inc.Location__Latitude__s == null) continue;
            markers.add(build(inc.Location__Latitude__s,
                inc.Location__Longitude__s,
                inc.Name + ' (' + inc.Severity__c + ')',
                inc.Incident_Type__c + ' - ' + inc.Status__c, 'incident'));
        }
        for (Volunteer__c v : [
            SELECT Name, Skill__c, Status__c,
                Current_Location__Latitude__s,
                Current_Location__Longitude__s
            FROM Volunteer__c WHERE Status__c != 'Offline' LIMIT 200
        ]) {
            if (v.Current_Location__Latitude__s == null) continue;
            markers.add(build(v.Current_Location__Latitude__s,
                v.Current_Location__Longitude__s,
                v.Name, v.Skill__c + ' - ' + v.Status__c, 'volunteer'));
        }
        return markers;
    }
}

