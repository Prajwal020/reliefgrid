// Create active Critical Incident for Home Page Map & Sidebar List View
Incident__c inc = new Incident__c(
    Incident_Type__c = 'Flood',
    Severity__c = 'Critical',
    Required_Skill__c = 'Rescue',
    Volunteers_Needed__c = 2,
    People_Affected__c = 85,
    Address__c = 'Indiranagar 100ft Road, Bengaluru',
    Location__Latitude__s = 12.9716,
    Location__Longitude__s = 77.6412
);
insert inc;
System.debug('Created active Critical incident for Home page: ' + inc.Id);
