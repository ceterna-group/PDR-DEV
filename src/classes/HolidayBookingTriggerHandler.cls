/**********************************************************************************************
* @Author: Ceterna
* @Date:
* @Description: Holiday Booking custom trigger handler class.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/

public with sharing class HolidayBookingTriggerHandler {

    /**********************************************************************************************
    * @Author: Ceterna
    * @Date:
    * @Description: Hook for the 'beforeInsert' of the Holiday Booking Trigger
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    *				07/08/2019 -
    ***********************************************************************************************/
    public static void beforeInsert(List<Holiday_Booking__c> newLeads) {

    }

    /**********************************************************************************************
    * @Author: Ceterna
    * @Date:
    * @Description: Hook for the 'afterInsert' of the Holiday Booking Trigger
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    *				07/08/2019 -
    ***********************************************************************************************/
    public static void afterInsert(Map<Id, Holiday_Booking__c> newRecordMap) {
        setLeadAndCampaign(newRecordMap, new Map<Id, Holiday_Booking__c>());
    }


    /**********************************************************************************************
    * @Author: Ceterna
    * @Date:
    * @Description: Hook for the 'beforeUpdate' of the Holiday Booking Trigger
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    *				07/08/2019 -
    ***********************************************************************************************/
    public static void beforeUpdate(Map<Id, Holiday_Booking__c> oldLeadMap, Map<Id, Holiday_Booking__c> newLeadMap) {

    }


    /**********************************************************************************************
    * @Author: Ceterna
    * @Date:
    * @Description: Hook for the 'afterUpdate' of the Holiday Booking Trigger
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    *				07/08/2019 -
    ***********************************************************************************************/
    public static void afterUpdate(Map<Id, Holiday_Booking__c> newRecordMap, Map<Id, Holiday_Booking__c> oldRecordMap) {
        setLeadAndCampaign(newRecordMap, oldRecordMap);
    }

    /**********************************************************************************************
    * @Author: Ceterna
    * @Date:
    * @Description: Method to update lead owner to Sales Manager of Park and adding the lead to the campaign
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    *				07/08/2019 -
    ***********************************************************************************************/
    public static void setLeadAndCampaign(Map<Id, Holiday_Booking__c> newRecordMap, Map<Id, Holiday_Booking__c> oldRecordMap) {

        Id LeadTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Holiday Maker').getRecordTypeId();
        Id CampaignTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Hot Holiday Campaign').getRecordTypeId();
        Map<String, String> leadParkMap = new Map<String, String>();
        Set<Id> campaignLeadIdsToRemove = new Set<Id>();

        //filter out records that have a lookup relationship to a lead, have a rating of 1 - hot and a lookup to a park
        for (Holiday_Booking__c booking : newRecordMap.values()) {
            if (booking.Park__c != null && booking.Lead__c != null) {
                if (!oldRecordMap.containsKey(booking.Id)) {
                    if (booking.Hot_Hols_Campaign__c == 1) {
                        leadParkMap.put(booking.Lead__c, booking.Park__c);
                    }
                } else {
                    if (booking.Hot_Hols_Campaign__c == 1 && oldRecordMap.get(booking.Id).Hot_Hols_Campaign__c == 0) {
                        leadParkMap.put(booking.Lead__c, booking.Park__c);
                    } else if (booking.Hot_Hols_Campaign__c == 0 && oldRecordMap.get(booking.Id).Hot_Hols_Campaign__c == 1) {
                        campaignLeadIdsToRemove.add(booking.Lead__c);
                    }
                }
            }
        }

        List<CampaignMember> newCampaignMembers    = new List<CampaignMember>();
        List<Lead> leadsToReassign              = new List<Lead>();
        Map<String, Campaign> parkToCampaignMap = new Map<String, Campaign>();

        for (Campaign campaign : [SELECT Id, Park__c, Park__r.Sales_Manager__c FROM Campaign WHERE Park__c IN :leadParkMap.values()]){
            parkToCampaignMap.put(campaign.Park__c, campaign);
        }

        List<Lead> leadsInTrigger = [SELECT Id, OwnerId,
                                    (SELECT Id FROM CampaignMembers)
                                    FROM Lead WHERE Id IN :leadParkMap.keySet() AND RecordTypeId = :LeadTypeId];

        //iterate over the values of the holiday booking map
        for(Lead lead : leadsInTrigger){
            if (lead.CampaignMembers == null || lead.CampaignMembers.isEmpty()) {
                CampaignMember newMember = new CampaignMember();
                newMember.LeadId         = lead.Id;
                String parkId            = leadParkMap.get(lead.Id);
                newMember.CampaignId     = parkToCampaignMap.get(parkId).Id;

                newCampaignMembers.add(newMember);

                if (lead.OwnerId != parkToCampaignMap.get(parkId).Park__r.Sales_Manager__c) {
                    lead.OwnerId = parkToCampaignMap.get(parkId).Park__r.Sales_Manager__c;

                    leadsToReassign.add(lead);
                }
            }
        }

        insert newCampaignMembers;
        update leadsToReassign;

        List<CampaignMember> campaignMembersToRemove = [SELECT Id FROM CampaignMember
                                                        WHERE Campaign.RecordTypeId = :CampaignTypeId
                                                        AND LeadId IN :campaignLeadIdsToRemove];

        delete campaignMembersToRemove;
    }
}