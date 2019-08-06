public without sharing class LeadSearch {
    
  @AuraEnabled
  public static Map<String, Object> runFullSearch(String firstName, String lastName, String email, String postcode) {
    RecordType holidayMakerRT = new RecordType();
    if (!Test.isRunningTest()) {
      holidayMakerRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'Holiday_Maker' LIMIT 1];
    } else {
      holidayMakerRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' LIMIT 1];
    }
    // get holiday makers
    List<Lead> holidayMakers = new List<Lead>();
    String holidayQuery = 'SELECT Id, FirstName, LastName, Email, PostalCode FROM Lead WHERE RecordTypeId = \'' + holidayMakerRT.Id + '\' ';
    holidayQuery = addQuery('Lead', holidayQuery, firstName, lastName, email, postcode);
    holidayMakers = Database.query(holidayQuery);
    // get leads
    List<Lead> leads = new List<Lead>();
    String leadQuery = 'SELECT Id, FirstName, LastName, Email, PostalCode FROM Lead WHERE RecordTypeId != \'' + holidayMakerRT.Id + '\' ';
    leadQuery = addQuery('Lead', leadQuery, firstName, lastName, email, postcode);
    leads = Database.query(leadQuery);
    // get contacts
    List<Contact> contacts = new List<Contact>();
    String contactQuery = 'SELECT Id, FirstName, LastName, Email, MailingPostalCode FROM Contact WHERE Id != null ';
    contactQuery = addQuery('Contact', contactQuery, firstName, lastName, email, postcode);
    contacts = Database.query(contactQuery);
    Map<String, Object> results = new Map<String, Object>();
    results.put('holiday_makers', holidayMakers);
    results.put('leads', leads);
    results.put('contacts', contacts);
    return results;
  }
    
  @AuraEnabled
  public static String changeRT(String recordId) {
    String userId = UserInfo.getUserId();
    User u = [
      SELECT Id, Team__c
      FROM User
      WHERE Id =: userId
    ];
    String team = u.Team__c == 'Park' ? 'Park' : 'Central';
    RecordType rt = new RecordType();
    if (!Test.isRunningTest()) {
      rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName =: team LIMIT 1];
    } else {
      rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' LIMIT 1];
    }
    Lead l = [
      SELECT Id, RecordTypeId
      FROM Lead
      WHERE Id =: recordId
      LIMIT 1
    ];
    l.RecordTypeId = rt.Id;
    l.OwnerId = u.Id;
    try {
      update l;
      return 'Success';
    } catch(DMLException e) {
      return 'Error: ' + e;
    }
  }
    
  private static String addQuery(String obj, String query, String firstName, String lastName, String email, String postcode) {
    String post = obj == 'Contact' ? 'MailingPostalCode' : 'PostalCode';
    if (firstName != '' && firstName != null) query += ' AND FirstName LIKE \'%' + firstName + '%\'';
    if (lastName != '' && lastName != null) query += ' AND LastName LIKE \'%' + LastName + '%\'';
    if (email != '' && email != null) query += ' AND Email LIKE \'%' + email + '%\'';
    if (postcode != '' && postcode != null) query += ' AND ' + post + ' LIKE \'%' + postcode + '%\'';
    return query;
  }
    

}