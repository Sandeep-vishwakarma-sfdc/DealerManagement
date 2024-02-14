public with sharing class YINProductSelector extends LibSObjectSelector{
    public Schema.SObjectType getSObjectType() {
        return Product2.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Product2.Name,
            Product2.ProductCode, 
            Product2.Product_Code__c, 
            Product2.Description, 
            Product2.IsActive, 
            Product2.DisplayUrl, 
            Product2.Product_Code__c, 
            Product2.Minimum_Quantity__c, 
            Product2.Size__c, 
            Product2.Tread_Pattern__c, 
            Product2.StockKeepingUnit
        };
    }

    public List<Product2> selectById(Set<Id> recordIds){
        return (List<Product2>) selectSObjectsById(recordIds);
    }
}