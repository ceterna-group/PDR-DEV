@IsTest
public with sharing class HolidayBookingTriggerTest {

    @testSetup
    public static void doTestSetup(){
        Profile profile = [
                select Id
                from Profile
                where Name = 'Standard User'
        ];

        User testUser = new User(
                alias = 'testuser',
                email = 'testuser@myexample.com',
                emailencodingkey = 'UTF-8',
                lastname = 'Testing',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                profileid = profile.Id,

                timezonesidkey = 'America/New_York',
                username = 'testuser@myexample.com'
        );
        insert testUser;

        //insert 1 park
        Park__c p = new Park__c();
        p.Name = 'Test Park';
        insert p;

//        //insert 1 lead
//        Lead l = new Lead();
//        l.Salutation = 'Mr';
//        l.FirstName = 'Test';
//        l.LastName = 'Test';
//        insert l;
//
//        //insert 1 campaign
//        Campaign c = new Campaign();
//        c.Name = 'Test Campaign';
//        c.Park__c = p.Id;
//        insert c;
//
//        //!HotHol
//        Holiday_Booking__c b = new Holiday_Booking__c();
//        b.Lead__c = l.Id;
//        b.Park__c = p.Id;
//        b.Hot_Hols_Campaign__c = 0;

        //is HotHol
//        Holiday_Booking__c b = new Holiday_Booking__c();
//        b.Lead__c = l.Id;
//        b.Park__c = p.Id;
//        b.Hot_Hols_Campaign__c = 1;
    }

    @IsTest
    public static void sample(){
        System.debug([SELECT Id FROM Lead].size());
    }

    @IsTest
    public static void sample2(){
        System.debug([SELECT Id FROM Lead].size());
    }

    private static Lead newLead() {
        Lead l = new Lead();
        l.Salutation = 'Mr';
        l.FirstName = 'Test';
        l.LastName = 'Test';
        insert l;
        return l;
    }

    private static Park__c newPark() {
        Park__c p = new Park__c();
        p.Name = 'Test Park';
        insert p;
        return p;
    }

    private static Campaign newCampaign(String parkId) {
    Campaign c = new Campaign();
    c.Name = 'Test Campaign';
    c.Park__c = parkId;
    insert c;
    return c;
    }

    private static CampaignMember newMember(String campaignId, String leadId) {
    CampaignMember m = new CampaignMember();
    m.CampaignId = campaignId;
    m.LeadId = leadId;
    insert m;
    return m;
    }

    private static Holiday_Booking__c newBooking(String leadId, String parkId) {
    Holiday_Booking__c b = new Holiday_Booking__c();
    b.Lead__c = leadId;
    b.Park__c = parkId;
    b.Hot_Hols_Campaign__c = 1;
    return b;
    }

    @IsTest
    private static void testBookingTrigger() {
    Park__c p = newPark();
    Campaign m = newCampaign(p.Id);
    Lead l = newLead();
    Lead l2 = newLead();
    CampaignMember e = newMember(m.Id, l2.Id);
    Holiday_Booking__c b1 = newBooking(l.Id, p.Id);
    Holiday_Booking__c b2 = newBooking(null, p.Id);
    Test.startTest();
    insert b1;
    insert b2;
    update b1;
    update b2;
    Test.stopTest();
    System.assertNotEquals(null, b1.Id);
    System.assertNotEquals(null, b2.Id);
    }
}