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
            Order.Pricebook2Id,
            Order.Total_Amount_with_Tax__c,
            Order.Total_Amount_without_Tax__c,
            Order.OrderNumber

        };
    }

    public List<Order> selectById(Set<Id> recordIds){
        return (List<Order>) selectSObjectsById(recordIds);
    }

    public List<Order> selectRecentOrderOfAccountByStatus(String accountId,String status){
        List<Order> orders = new List<Order>();
        String query =  newQueryFactory()
        .setCondition('AccountId = :accountId and Status = :status')
        .addOrdering(Order.LastModifiedDate, LibQueryFactory.SortOrder.DESCENDING)
        .setLimit(1)
        .toSOQL();  
        return (List<Order>) Database.query(query);
    }
}