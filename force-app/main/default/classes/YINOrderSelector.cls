/**
 * @description       : This is Selector class for querying on Order Object.
 * @author            : saurabh.pandey@skinternational.com
 * @group             : SKI
 * @last modified on  : 03-11-2024
 * @last modified by  : saurabh.pandey@skinternational.com
**/
public with sharing class YINOrderSelector extends LibSObjectSelector {
    public Schema.SObjectType getSObjectType() {
        return Order.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Order.Id,
            Order.Name,
            // Order.Order_Status__c,
            Order.AccountId,
            Order.Status,
            Order.GST_Amount__c,
            Order.TotalAmount,
            Order.EndDate,
            Order.OrderNumber,
            Order.RecordTypeId,
            Order.EffectiveDate,
            Order.Order_Status__c,
            Order.Type,
            Order.Ownership__c,
            Order.Posting_Date__c,
            Order.Ship_To_Party__c,
            Order.Ship_To_Party__c,
            Order.Status,
            Order.Sub_Status__c,
            Order.Pricebook2Id,
            Order.Total_Amount_with_Tax__c,
            Order.Total_Amount_without_Tax__c,
            Order.ERP_Order_Number__c,
            Order.Order_Total__c,
            Order.Remarks__c

        };
    }

    public List<Order> selectById(Set<Id> recordIds){
        return (List<Order>) selectSObjectsById(recordIds);
    }

    public List<Order> selectByExtraFields(Set<Id> recordIds){
        List<Order> orders = new List<Order>();
        String query =  newQueryFactory()
        .selectField('RecordType.Name')
        .selectField('Account.ERP_Customer_Code__c')
        .selectField('Account.Location__r.Location_Code__c')
        .setCondition('Id IN:recordIds')
        .setLimit(1)
        .toSOQL();  
        return (List<Order>) Database.query(query);
    }

    public List<Order> selectRecentOrderOfAccountByStatus(String accountId,String status,String recordTypeName){
        List<Order> orders = new List<Order>();
        String query =  newQueryFactory()
        .setCondition('AccountId = :accountId and Status = :status and recordType.Name =:recordTypeName')
        .addOrdering(Order.LastModifiedDate, LibQueryFactory.SortOrder.DESCENDING)
        .setLimit(1)
        .toSOQL();  
        return (List<Order>) Database.query(query);
    }
    //added by kalpesh
    public List<Order> getOrderDataForUpdate() {
        return Database.query(
            newQueryFactory()
                    .selectField('Id')
                    .selectField('ERP_Order_Number__c')
                    .setCondition('ERP_Order_Number__c!=null')
                    .toSOQL()
        );
    }
 
    // Added by Saurabh Pandey
    public List<Order> getRecentOrderForPromotionalActivity(String recType){
        List<Order> orders = new List<Order>();
        String query =  newQueryFactory()
        .setCondition('RecordType.Name =: recType')
        .addOrdering(Order.CreatedDate, LibQueryFactory.SortOrder.DESCENDING)
        .setLimit(1)
        .toSOQL();  
        return (List<Order>) Database.query(query);
    }
}