// Demo Part 2: Step c (validation rule check) & Step d (resolve with notes)
Incident__c inc1 = [SELECT Id, Status__c, Resolution_Notes__c FROM Incident__c WHERE Name = 'INC-0001' LIMIT 1];

// Step c: Attempt to resolve without notes
Boolean validationCaught = false;
try {
    inc1.Status__c = 'Resolved';
    update inc1;
    System.debug('FAILURE: Validation rule did not fire!');
} catch (DmlException e) {
    if (e.getMessage().contains('Resolution Notes') || e.getMessage().contains('Resolution_Notes_Required') || e.getMessage().contains('Add resolution notes before resolving an incident')) {
        validationCaught = true;
        System.debug('SUCCESS: Validation rule caught as expected: ' + e.getMessage());
    } else {
        System.debug('Unexpected DML exception: ' + e.getMessage());
    }
}

if (!validationCaught) {
    throw new CalloutException('Validation rule Resolution_Notes_Required was expected to fire but did not.');
}

// Step d: Resolve with notes
inc1.Status__c = 'Resolved';
inc1.Resolution_Notes__c = 'Flooding subsided, all 120 residents safely evacuated to Central Relief Camp.';
update inc1;
System.debug('SUCCESS: Incident INC-0001 resolved with notes.');
