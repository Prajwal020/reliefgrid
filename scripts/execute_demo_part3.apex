// Demo Part 3: Step e (Batch Escalation & Flow 3) & Step f (Resource Request Approval & Flow 2)

// Step e: Backdate INC-0002 Reported Date and run escalation batch
Incident__c inc2 = [SELECT Id, Severity__c, Status__c, Escalated__c, Reported_Date__c FROM Incident__c WHERE Name = 'INC-0002' LIMIT 1];
inc2.Reported_Date__c = Datetime.now().addHours(-4);
update inc2;
System.debug('INC-0002 Reported_Date__c updated to 4 hours ago.');

Id batchJobId = Database.executeBatch(new IncidentEscalationBatch(), 200);
System.debug('IncidentEscalationBatch enqueued with Job ID: ' + batchJobId);

// Step f: Create Resource Request and approve it
Relief_Center__c rc = [SELECT Id, Name, Contact_Email__c FROM Relief_Center__c WHERE Name = 'Central Relief Camp' LIMIT 1];
Resource_Request__c rr = new Resource_Request__c(
    Incident__c = inc2.Id,
    Relief_Center__c = rc.Id,
    Resource_Type__c = 'Food Packets',
    Quantity__c = 100,
    Status__c = 'Requested'
);
insert rr;
System.debug('Resource Request created: ' + rr.Id);

rr.Status__c = 'Approved';
update rr;
System.debug('Resource Request approved: ' + rr.Id + ' - Flow 2 triggered.');
