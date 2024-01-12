public with sharing class YINOrderItemSelector extends LibSObjectSelector{
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
            OrderItem.PricebookEntryId,
            OrderItem.Total_Amount__c,
            OrderItem.GST_Amount__c,
            OrderItem.TCS__c,
            OrderItem.Variant__c,
            OrderItem.Discounted_Amount__c,
            OrderItem.TDS__c,
            OrderItem.TDS_Amount__c
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
                            .selectField('Product2.Size__c')
                            .selectField('Variant__r.Variant_Code__c')
                            .selectField('Order.AccountId')
                            .selectField('Order.Status')
                            .selectField('Order.Account.PAN_Status__c')
                            .selectField('Order.Account.Location__r.Location_Code__c')
                            .selectField('Order.Account.X1H_TCS__c')
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