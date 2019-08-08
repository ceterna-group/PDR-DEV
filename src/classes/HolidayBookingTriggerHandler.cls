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
    public static void beforeInsert (List<Holiday_Booking__c> newLeads) {

    }

    /**********************************************************************************************
    * @Author: Ceterna
    * @Date:
    * @Description: Hook for the 'afterInsert' of the Holiday Booking Trigger
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    *				07/08/2019 -
    ***********************************************************************************************/
    public static void afterInsert (Map<Id,Holiday_Booking__c> newRecordMap) {
        setLeadAndCampaign(newRecordMap);

    }


    /**********************************************************************************************
    * @Author: Ceterna
    * @Date:
    * @Description: Hook for the 'beforeUpdate' of the Holiday Booking Trigger
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    *				07/08/2019 -
    ***********************************************************************************************/
    public static void beforeUpdate (Map<Id,Holiday_Booking__c> oldLeadMap, Map<Id,Holiday_Booking__c> newLeadMap) {

    }


    /**********************************************************************************************
    * @Author: Ceterna
    * @Date:
    * @Description: Hook for the 'afterUpdate' of the Holiday Booking Trigger
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    *				07/08/2019 -
    ***********************************************************************************************/
    public static void afterUpdate (Map<Id,Holiday_Booking__c> oldRecordMap, Map<Id,Holiday_Booking__c> newRecordMap) {

        setLeadAndCampaign(newRecordMap);

    }

    /**********************************************************************************************
    * @Author: Ceternax
    * @Date:
    * @Description: Method to update lead owner to Sales Manager of Park and adding the lead to the campaign
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
    *				07/08/2019 -
    ***********************************************************************************************/
    public static void setLeadAndCampaign(Map<Id, Holiday_Booking__c> recordMap) {

        Map<String, String> leadParkMap = new Map<String, String>();
        Set<Id> leadIds = new Set<Id>();

        //filter out records that have a lookup relationship to a lead, have a rating of 1 - hot and a lookup to a park
        for(Holiday_Booking__c booking : recordMap.values()){
            if (booking.Park__c != null && booking.Lead__c != null && booking.Hot_Hols_Campaign__c == 1 ) {
                leadParkMap.put(booking.Lead__c, booking.Park__c);
                leadIds.add(booking.Lead__c);
            }
        }

        List<CampaignMember> campaignMembers    = new List<CampaignMember>();
        List<Lead> leadsToReassign              = new List<Lead>();
        Map<String, Campaign> parkToCampaignMap = new Map<String, Campaign>();

        for (Campaign campaign : [SELECT Id, Park__c, Park__r.Sales_Manager__c FROM Campaign WHERE Park__c IN :leadParkMap.values()]){
            parkToCampaignMap.put(campaign.Park__c, campaign);
        }

        List<Lead> leadsInTrigger = [SELECT Id, OwnerId,
                                    (SELECT Id FROM CampaignMembers)
                                    FROM Lead WHERE Id IN :leadIds];

        //iterate over the values of the holiday booking map
        for(Lead lead : leadsInTrigger){
            if (lead.CampaignMembers == null || lead.CampaignMembers.isEmpty()) {
                CampaignMember newMember = new CampaignMember();
                newMember.LeadId         = lead.Id;
                String parkId            = leadParkMap.get(lead.Id);
                newMember.CampaignId     = parkToCampaignMap.get(parkId).Id;

                campaignMembers.add(newMember);

                if (lead.OwnerId != parkToCampaignMap.get(parkId).Park__r.Sales_Manager__c) {
                    lead.OwnerId = parkToCampaignMap.get(parkId).Park__r.Sales_Manager__c;

                    leadsToReassign.add(lead);
                }
            }
        }

        insert campaignMembers;
        update leadsToReassign;

    }
}