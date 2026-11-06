String myEmail = '4mt23cs135@mite.ac.in';

List<Relief_Center__c> centersToInsert = new List<Relief_Center__c>();
Map<String, Relief_Center__c> centersMap = new Map<String, Relief_Center__c>{
    'Central Relief Camp' => new Relief_Center__c(Name = 'Central Relief Camp', Capacity__c = 500, Status__c = 'Active', Contact_Email__c = myEmail, Location__Latitude__s = 12.9716, Location__Longitude__s = 77.5946),
    'North Shelter' => new Relief_Center__c(Name = 'North Shelter', Capacity__c = 300, Status__c = 'Active', Contact_Email__c = myEmail, Location__Latitude__s = 13.0827, Location__Longitude__s = 77.5877),
    'East Supply Depot' => new Relief_Center__c(Name = 'East Supply Depot', Capacity__c = 800, Status__c = 'Active', Contact_Email__c = myEmail, Location__Latitude__s = 12.9600, Location__Longitude__s = 77.6400)
};

Set<String> existingCenterNames = new Set<String>();
for (Relief_Center__c rc : [SELECT Name FROM Relief_Center__c WHERE Name IN :centersMap.keySet()]) {
    existingCenterNames.add(rc.Name);
}
for (String name : centersMap.keySet()) {
    if (!existingCenterNames.contains(name)) {
        centersToInsert.add(centersMap.get(name));
    }
}
if (!centersToInsert.isEmpty()) {
    insert centersToInsert;
    System.debug('Inserted ' + centersToInsert.size() + ' Relief Centers.');
}

List<String> rows = new List<String>{
    'Anita Rao|Medical|12.9780|77.6010|Available',
    'Karthik S|Medical|13.0350|77.5970|Available',
    'Meera Nair|Rescue|12.9352|77.6245|Available',
    'Imran Khan|Rescue|12.9141|77.6101|Available',
    'Divya P|Logistics|12.9850|77.5533|Available',
    'Suresh Kumar|Logistics|13.0827|77.5877|Available',
    'Farah Ali|Food Distribution|12.9600|77.6400|Available',
    'Rohit Gowda|Communication|12.9279|77.6271|Available',
    'Neha Joshi|Medical|12.8456|77.6603|Busy',
    'Arun Das|Rescue|13.1986|77.7066|Offline'
};

Set<String> volNames = new Set<String>();
for (String r : rows) {
    volNames.add(r.split('\\|')[0]);
}
Set<String> existingVolNames = new Set<String>();
for (Volunteer__c v : [SELECT Name FROM Volunteer__c WHERE Name IN :volNames]) {
    existingVolNames.add(v.Name);
}

List<Volunteer__c> vols = new List<Volunteer__c>();
Integer i = 10;
for (String r : rows) {
    List<String> p = r.split('\\|');
    if (!existingVolNames.contains(p[0])) {
        vols.add(new Volunteer__c(
            Name = p[0], Skill__c = p[1], Status__c = p[4],
            Email__c = p[0].deleteWhitespace().toLowerCase() + '@example.com',
            Phone__c = '98450000' + String.valueOf(i++),
            Current_Location__Latitude__s = Decimal.valueOf(p[2]),
            Current_Location__Longitude__s = Decimal.valueOf(p[3])
        ));
    } else {
        i++;
    }
}
if (!vols.isEmpty()) {
    insert vols;
    System.debug('Inserted ' + vols.size() + ' Volunteers.');
}

