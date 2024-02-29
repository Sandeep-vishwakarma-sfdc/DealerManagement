/**
 * @description       : This is Selector class for query on YIN_Account_product_Mapping__c object.
 * @author            : saurabh.pandey@skinternational.com
 * @group             : SKI
 * @last modified on  : 02-23-2024
 * @last modified by  : saurabh.pandey@skinternational.com
**/
public with sharing class YINAccountProductMappingSelector extends LIBSObjectSelector{
    public Schema.SObjectType getSObjectType() {
        return YIN_Account_product_Mapping__c.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            YIN_Account_product_Mapping__c.Id,
            YIN_Account_product_Mapping__c.Name,
            YIN_Account_product_Mapping__c.Account__c,
            YIN_Account_product_Mapping__c.Product__c,
            YIN_Account_product_Mapping__c.Locations__c,
            YIN_Account_product_Mapping__c.Type__c,
            YIN_Account_product_Mapping__c.Status__c,
            YIN_Account_product_Mapping__c.Start_Date__c,
            YIN_Account_product_Mapping__c.Combination_Key__c,
            YIN_Account_product_Mapping__c.End_Date__c,
            YIN_Account_product_Mapping__c.Minimum_Order_Quantity__c,
            YIN_Account_product_Mapping__c.Maximum_Order_Quantity__c
        };
    }

    /**
     * @description: This method is used to get all fields with the help of Id.
     * @param  String: recId.
    */
    public List<YIN_Account_product_Mapping__c> selectById(Set<Id> recordIds){
        return (List<YIN_Account_product_Mapping__c>) selectSObjectsById(recordIds);
    }


    /**
     * @description: This method is used to retrieve records based on the Account field and its associated Product and Locations.
     * @param  String: accountId.
    */
    public List<YIN_Account_product_Mapping__c> selectByAccount(String accountId){
        String query = newQueryFactory()
        .setCondition('Product__c!=null and Account__c=:accountId')
        .toSOQL();
        return Database.query(query);
    }

    /**
     * @description: This method is used to retrieve all records.
     * @param  None
    */
    public List<YIN_Account_product_Mapping__c> selectAll(){
        String query = newQueryFactory()
        .setLimit(50000)
        .toSOQL();
        return Database.query(query);
    }


    /**
     * @description: This method is used to retrieve records based on a combination of fields.
     * @param  Set<String>: combinationKeys.
    */
    public List<YIN_Account_product_Mapping__c> getAccProdMappings(Set<String> combinationKeys){
        String query = newQueryFactory()
        .selectfield('Account__r.ERP_Customer_code__c')
        .selectfield('Product__r.Product_Code__c')
        .selectfield('Product__r.Name')
        .selectfield('Account__r.OwnerId')
        .selectfield('Account__r.Name')
        .selectfield('Locations__r.Location_Code__c')
        .selectfield('Locations__r.Name')
        .setCondition('Combination_Key__c IN: combinationKeys')
        .toSOQL();
        return Database.query(query);
    }


    /**
     * @description Retrieves specific fields based on Account and Product.
     * @param recType The record type to filter the results.
     * @return List<YIN_Account_product_Mapping__c> A list of records containing Account and Product fields.
    */

    public List<YIN_Account_product_Mapping__c> getAccProdDataByAccProd(String recType){
        String query = newQueryFactory()
        .selectfield('Account__r.ERP_Customer_code__c')
        .selectfield('Product__r.Product_Code__c')
        .setCondition('Type__c=:recType')
        .toSOQL();
        return Database.query(query);
    }

    /**
     * @description Retrieves specific fields based on Location and Product.
     * @param recType The record type to filter the results.
     * @return List<YIN_Account_product_Mapping__c> A list of records containing Location and Product fields.
    */
    public List<YIN_Account_product_Mapping__c> getAccProdDataByLocProd(String recType){
        String query = newQueryFactory()
        .selectfield('Account__r.SFDC_Customer_Code__c')
        .selectfield('Product__r.Product_Code__c')
        .selectfield('Locations__r.Location_Code__c')
        .setCondition('Type__c=:recType')
        .toSOQL();
        return Database.query(query);
    }
   
    /**
     * @description Retrieves record IDs based on record type.
     * @param recType The record type to filter the results.
     * @return List<YIN_Account_product_Mapping__c> A list of record IDs.
    */
     public List<YIN_Account_product_Mapping__c> getAccProdDataToDelete(String recType){
        String query = newQueryFactory()
        .selectfield('Id')
        .setCondition('Type__c=:recType')
        .toSOQL();
        return Database.query(query);
    }

}