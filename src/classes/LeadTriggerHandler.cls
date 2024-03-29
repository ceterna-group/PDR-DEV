/**********************************************************************************************
* @Author: Ceterna
* @Date:        
* @Description: Lead custom trigger handler class that extends the TriggerHandler 
*   class. You must keep the extends attribute for this class to work.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/  
public with sharing class LeadTriggerHandler extends TriggerHandler {
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:        
  * @Description: Hook for the 'beforeInsert' of the Lead Trigger
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  *				22/07/2019 - B0054 - Elliott TN - Added setParkIds() method to beforeInsert and beforeUpdate
  ***********************************************************************************************/  
  public override void beforeInsert() {
    // set field based on multiselect picklist
    LeadHandler.setPark(Trigger.new);
    // set Park_IDs__c field
    LeadHandler.setParkIds(Trigger.new);
  }

  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:        
  * @Description: Hook for the 'afterInsert' of the Lead Trigger
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/  
  public override void afterInsert() {
    // assign the lead to a queue, and set the business hours / sla deadline
    LeadHandler.assignToQueue(Trigger.new);
    // send changes to ODI, only if we're not ODI
    String ODI = [SELECT Id FROM User WHERE Name = 'ODI' LIMIT 1].Id;
    if (UserInfo.getUserId() != ODI) {
      LeadHandler.postChanges(Trigger.new, 'CREATE');  
    }
  }
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:        
  * @Description: Hook for the 'afterInsert' of the Lead Trigger
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  *				22/07/2019 - B0054 - Elliott TN - Added setParkIds() method to beforeInsert and beforeUpdate
  ***********************************************************************************************/ 
  public override void beforeUpdate() {
    // set field based on multiselect picklist
    LeadHandler.setPark(Trigger.new);

    // set Park_IDs__c field
    LeadHandler.setParkIds(Trigger.new);
  }
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:        
  * @Description: Hook for the 'afterInsert' of the Lead Trigger
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/ 
  public override void afterUpdate() {
    // assign the lead to a queue, and set the business hours / sla deadline
    LeadHandler.assignToQueue(Trigger.new);
    // send changes to ODI, only if we're not ODI
    String ODI = [SELECT Id FROM User WHERE Name = 'ODI' LIMIT 1].Id;
    if (UserInfo.getUserId() != ODI) {
      LeadHandler.postChanges(Trigger.new, 'UPDATE');  
    }  
  }

}