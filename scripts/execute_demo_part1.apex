// ReliefGrid End-to-End Demo Script (Section 13)
System.debug('=== RELIEFGRID DEMO START ===');

// --- Step a: Create Critical Flood incident needing 2 Rescue volunteers ---
System.debug('--- STEP A: Creating Critical Flood Incident ---');
Incident__c inc1 = new Incident__c(
    Incident_Type__c = 'Flood',
    Severity__c = 'Critical',
    Required_Skill__c = 'Rescue',
    Volunteers_Needed__c = 2,
    People_Affected__c = 120,
    Address__c = 'Riverside Colony',
    Location__Latitude__s = 12.9250,
    Location__Longitude__s = 77.6200
);
insert inc1;
System.debug('Incident 1 created with Id: ' + inc1.Id);

// --- Step b: Create far-away High Medical incident ---
System.debug('--- STEP B: Creating Far-Away High Medical Incident ---');
Incident__c inc2 = new Incident__c(
    Incident_Type__c = 'Medical Emergency',
    Severity__c = 'High',
    Required_Skill__c = 'Medical',
    Volunteers_Needed__c = 1,
    People_Affected__c = 15,
    Address__c = 'Remote Hill Station',
    Location__Latitude__s = 15.3000,
    Location__Longitude__s = 75.1000
);
insert inc2;
System.debug('Incident 2 created with Id: ' + inc2.Id);
