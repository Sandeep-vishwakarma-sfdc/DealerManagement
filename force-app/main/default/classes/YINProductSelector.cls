/**
 * @description       : This class is used to query on Product2 object.
 * @author            : saurabh.pandey@skinternational.com
 * @group             : SKI
 * @last modified on  : 03-12-2024
 * @last modified by  : saurabh.pandey@skinternational.com
**/
public with sharing class YINProductSelector extends LibSObjectSelector{
    public Schema.SObjectType getSObjectType() {
        return Product2.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Product2.Name,
            Product2.ProductCode, 
            Product2.Description, 
            Product2.IsActive, 
            Product2.DisplayUrl, 
            Product2.Product_Code__c, 
            Product2.Minimum_Quantity__c, 
            Product2.Size__c, 
            Product2.Tread_Pattern__c, 
            Product2.StockKeepingUnit,
            Product2.Item_Category_Code__c,
            Product2.Additional_Spec_Code__c,
            Product2.Plant_Code__c,
            Product2.Spec_Code__c,
            Product2.Tire_Size__c,
            Product2.Size__c,
            Product2.Original_Groove_Depth__c,
            Product2.GST_Group__c,
            Product2.GST__c,
            Product2.Description_2__c,
            Product2.Image_Url__c
        };
    }

    /**
     * @description: Retrieves Product2 records based on a set of record IDs.
     * @param recordIds: Set of record IDs to filter the Product2 records.
     * @return List<Product2>: List of Product2 records filtered by the provided record IDs.
    */
    public List<Product2> selectById(Set<Id> recordIds){
        return (List<Product2>) selectSObjectsById(recordIds);
    }

    /**
     * @description: Retrieves Product2 records with specified fields where Product_Code__c is not null.
     * @return List<Product2>: List of Product2 records filtered by the condition where Product_Code__c is not null.
    */
     public List<Product2> getProductData() {
        return Database.query(
            newQueryFactory()
            .selectField('Id')
            .selectField('Product_Code__c')
            .setCondition('Product_Code__c !=null')
            .toSOQL()
        );
     }


    /**
     * @description: Retrieves all Product2 records with specified fields.
     * @return List<Product2>: List of all Product2 records with specified fields.
    */
    public List<Product2> fetchProductData() {
        return Database.query(
            newQueryFactory()
            .selectField('Id')
            .selectField('Name')
            .selectField('Product_Code__c')
            .selectField('size__c')
            .toSOQL()
        );
     }

     /**
     * @description: This method creates a query factory to retrieve Product2 records based on a set of product codes.
     * @param productSet: Set of product codes to filter the Product2 records.
     * @return fflib_QueryFactory: Query factory to retrieve Product2 records.
     */
    public List<Product2> getProductForSKU(Set<String> productSet) {
        return Database.query(
            newQueryFactory()
            .selectField('Id')
            .selectField('Name')
            .selectField('Product_Code__c')
            .setCondition('Product_Code__c IN :productSet')
            .toSOQL()
        );    
    } 
    
    /**
     * @description This method creates a query factory to retrieve Product2 records based on a set of product codes.
     * @param productSet Set of product codes to filter the Product2 records.
     * @return List<Product2> A list of Product2 records filtered by the specified product codes.
     */
    public List<Product2> getProductForOrderItem() {
        return Database.query(
            newQueryFactory()
            .selectField('Id')
            .selectField('Name')
            .selectField('Product_Code__c')
            .setCondition('Id IN (SELECT Product2Id FROM PriceBookEntry WHERE PriceBook2.Name = \'Promotional Activity\')')
            .toSOQL()
        );    
    }   
}