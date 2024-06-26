/**
 * @description       : This is selector class for querying on OrderItem Object.
 * @author            : saurabh.pandey@skinternational.com
 * @group             : SKI
 * @last modified on  : 03-15-2024
 * @last modified by  : saurabh.pandey@skinternational.com
**/
public without sharing class YINOrderItemSelector extends LibSObjectSelector{
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
            OrderItem.TDS_Amount__c,
            OrderItem.TCS_Amount__c,
            OrderItem.Discount_Type__c,
            OrderItem.ListPrice
        };
    }

    public List<OrderItem> selectById(Set<Id> recordIds){
        return (List<OrderItem>) selectSObjectsById(recordIds);
    }

    public List<OrderItem> selectByOrder(Id orderId){
        List<OrderItem> orders = new List<OrderItem>();
        String query =  newQueryFactory()
                            .selectField('PricebookEntry.Pricebook2Id')
                            .selectField('Product2.Product_Code__c')
                            .selectField('Product2.Name')
                            .selectField('Product2.Description')
                            .selectField('Product2.Description_2__c')
                            .selectField('Product2.Size__c')
                            .selectField('Product2.GST_Group__c')
                            .selectField('Product2.HSNSAC__c')
                            .selectField('Variant__r.Variant_Code__c')
                            .selectField('Order.AccountId')
                            .selectField('Order.Status')
                            .selectField('Order.Account.PAN_Status__c')
                            .selectField('Order.Account.Location__r.Location_Code__c')
                            .selectField('Order.Account.PAN_Number__c')
                            .selectField('Order.Account.X1H_TCS__c')
                            .selectField('Order.Description')
                            .selectField('order.recordType.Name')
                            .setCondition('OrderId = :orderId')
                            .toSOQL();
        return (List<OrderItem>) Database.query(query);
    }

    public List<OrderItem> selectByOrderAndProduct(Id orderId,Id itemId){
        List<OrderItem> orders = new List<OrderItem>();
        String query =  newQueryFactory()
                            .setCondition('OrderId = :orderId and Id = :itemId')
                            .toSOQL();
        return (List<OrderItem>) Database.query(query);
    }
    
    
    public List<OrderItem> fetchDealerAccountData(Id accountId){
        List<OrderItem> openOrderItems = new List<OrderItem>();
        String query =  newQueryFactory()
              .selectField('Product2.Name')
              .selectField('Product2.product_Code__c')
              .selectField('Variant__r.variant_code__c')
              .selectField('Order.Account.Location__r.Location_Code__c')
              .selectField('Order.Account.Owner.Name')
              .setCondition('Order.Status = \'open\' AND Order.Account.Id = :accountId')
              .toSOQL();
            return (List<OrderItem>) Database.query(query);
            }

    // Added by Saurabh Pandey
    /**
      * @Description -  * Retrieves the most recent Order Item records associated with a specific Record Type.
      * @param recType The name of the Record Type.
      * @return List<OrderItem> A list of Order Item records filtered by the specified Record Type.
    */

    public override String getOrderBy() {
        return '';
    }

    public List<OrderItem> getRecentOrderItemForPromotionalActivity(String recType,String recordId){
        List<OrderItem> orders = new List<OrderItem>();
        String query =  'SELECT Id, Order.AccountId, Order.Account.Name,Order.Sub_Status__c,Order.TotalAmount, Order.Allocated_Amount__c, Order.Description, Order.Remarks__c, Order.Status, OrderId, PricebookEntryId, Product2.Name, Product2Id, Quantity,TotalPrice, Total_Amount__c, UnitPrice FROM OrderItem WHERE Order.RecordType.Name =: recType and Order.Id =: recordId';
        return (List<OrderItem>) Database.query(query);
    }

    
}