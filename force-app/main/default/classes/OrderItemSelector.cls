public with sharing class OrderItemSelector extends LibSObjectSelector{
    public Schema.SObjectType getSObjectType() {
        return OrderItem.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            OrderItem.Id,
            OrderItem.OrderId,
            OrderItem.Quantity,
            OrderItem.Product2Id,
            OrderItem.UnitPrice,
            OrderItem.Discount_Percent__c,
            OrderItem.TotalPrice,
            OrderItem.GST__c,
            OrderItem.Description,
            OrderItem.PricebookEntryId
        };
    }

    public List<OrderItem> selectById(Set<Id> recordIds){
        return (List<OrderItem>) selectSObjectsById(recordIds);
    }

    public List<OrderItem> selectByOrder(Id orderId){
        List<OrderItem> orders = new List<OrderItem>();
        String query =  newQueryFactory()
                            .selectField('PricebookEntry.Pricebook2Id')
                            .selectField('Product2.ProductCode')
                            .setCondition('OrderId = :orderId')
                            .toSOQL();
        return (List<OrderItem>) Database.query(query);
    }

    public List<OrderItem> selectByOrderAndProduct(Id orderId,Id productId){
        List<OrderItem> orders = new List<OrderItem>();
        String query =  newQueryFactory()
                            .setCondition('OrderId = :orderId and Product2Id = :productId')
                            .toSOQL();
        return (List<OrderItem>) Database.query(query);
    }
}