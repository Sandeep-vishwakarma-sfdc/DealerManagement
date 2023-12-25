public class OrderSelector extends LibSObjectSelector {
    public Schema.SObjectType getSObjectType() {
        return Order.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Order.Id,
            Order.Name,
            Order.Order_Status__c,
            Order.AccountId,
            Order.Status
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