public with sharing class DispatchService {
    public static final Double SEARCH_RADIUS_KM = 50;

    // Nearest available volunteers with the right skill, closest first.
    public static List<Volunteer__c> findNearestVolunteers(
        Double lat, Double lon, String skill, Integer maxResults, Set<Id> excludeIds) {
        return [
            SELECT Id, Name,
                Current_Location__Latitude__s,
                Current_Location__Longitude__s
            FROM Volunteer__c
            WHERE Status__c = 'Available'
            AND Skill__c = :skill
            AND Id NOT IN :excludeIds
            AND DISTANCE(Current_Location__c, GEOLOCATION(:lat, :lon), 'km') < :SEARCH_RADIUS_KM
            ORDER BY DISTANCE(Current_Location__c, GEOLOCATION(:lat, :lon), 'km')
            LIMIT :maxResults
        ];
    }

    public static List<Volunteer__c> findNearestVolunteers(
        Decimal lat, Decimal lon, String skill, Integer maxResults, Set<Id> excludeIds) {
        Double dLat = lat != null ? lat.doubleValue() : null;
        Double dLon = lon != null ? lon.doubleValue() : null;
        return findNearestVolunteers(dLat, dLon, skill, maxResults, excludeIds);
    }

    public static Decimal distanceKm(Double lat1, Double lon1, Double lat2, Double lon2) {
        Double km = Location.newInstance(lat1, lon1)
            .getDistance(Location.newInstance(lat2, lon2), 'km');
        return Decimal.valueOf(km).setScale(2);
    }

    public static Decimal distanceKm(Decimal lat1, Decimal lon1, Decimal lat2, Decimal lon2) {
        Double dLat1 = lat1 != null ? lat1.doubleValue() : null;
        Double dLon1 = lon1 != null ? lon1.doubleValue() : null;
        Double dLat2 = lat2 != null ? lat2.doubleValue() : null;
        Double dLon2 = lon2 != null ? lon2.doubleValue() : null;
        return distanceKm(dLat1, dLon1, dLat2, dLon2);
    }

    // Creates dispatches and marks volunteers Busy. Returns the Ids of incidents
    // it could not process before running low on SOQL queries.
    public static List<Id> assignVolunteers(List<Incident__c> incidents) {
        List<Dispatch__c> dispatches = new List<Dispatch__c>();
        Map<Id, Volunteer__c> toBusy = new Map<Id, Volunteer__c>();
        List<Incident__c> toAssigned = new List<Incident__c>();
        Set<Id> used = new Set<Id>();
        List<Id> deferred = new List<Id>();

        for (Incident__c inc : incidents) {
            if (Limits.getQueries() >= Limits.getLimitQueries() - 5) {
                deferred.add(inc.Id);
                continue;
            }
            Integer needed = inc.Volunteers_Needed__c == null
                ? 1 : inc.Volunteers_Needed__c.intValue();

            List<Volunteer__c> nearest = findNearestVolunteers(
                inc.Location__Latitude__s, inc.Location__Longitude__s,
                inc.Required_Skill__c, needed, used);

            for (Volunteer__c v : nearest) {
                used.add(v.Id); // never give one volunteer to two incidents
                toBusy.put(v.Id, new Volunteer__c(Id = v.Id, Status__c = 'Busy'));
                dispatches.add(new Dispatch__c(
                    Incident__c = inc.Id,
                    Volunteer__c = v.Id,
                    Status__c = 'Assigned',
                    Distance_KM__c = distanceKm(
                        inc.Location__Latitude__s,
                        inc.Location__Longitude__s,
                        v.Current_Location__Latitude__s,
                        v.Current_Location__Longitude__s)
                ));
            }
            if (!nearest.isEmpty()) {
                toAssigned.add(new Incident__c(Id = inc.Id, Status__c = 'Assigned'));
            }
        }
        insert dispatches;
        update toBusy.values();
        update toAssigned;
        return deferred;
    }

    // Called when incidents are resolved: close dispatches, free volunteers.
    public static void releaseVolunteers(Set<Id> incidentIds) {
        List<Dispatch__c> open = [
            SELECT Id, Volunteer__c FROM Dispatch__c
            WHERE Incident__c IN :incidentIds
            AND Status__c NOT IN ('Completed', 'Cancelled')
        ];
        Map<Id, Volunteer__c> toFree = new Map<Id, Volunteer__c>();
        for (Dispatch__c d : open) {
            d.Status__c = 'Completed';
            toFree.put(d.Volunteer__c,
                new Volunteer__c(Id = d.Volunteer__c, Status__c = 'Available'));
        }
        update open;
        update toFree.values();
    }
}
