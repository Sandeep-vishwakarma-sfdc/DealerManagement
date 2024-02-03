/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
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
            YIN_Account_product_Mapping__c.End_Date__c,
            YIN_Account_product_Mapping__c.Minimum_Order_Quantity__c,
            YIN_Account_product_Mapping__c.Maximum_Order_Quantity__c
        };
    }

    public List<YIN_Account_product_Mapping__c> selectById(Set<Id> recordIds){
        return (List<YIN_Account_product_Mapping__c>) selectSObjectsById(recordIds);
    }

    public List<YIN_Account_product_Mapping__c> selectByAccount(String accountId){
        String query = newQueryFactory()
        .setCondition('Product__c!=null and Account__c=:accountId')
        .toSOQL();
        return Database.query(query);
    }

    public List<YIN_Account_product_Mapping__c> selectAll(){
        String query = newQueryFactory()
        .setCondition('Start_Date__c<=TODAY and End_Date__c>=TODAY')
        .setLimit(50000)
        .toSOQL();
        return Database.query(query);
    }

    public List<YIN_Account_product_Mapping__c> selectLookUpFields(){
        String query = newQueryFactory()
        .selectfield('Account__r.SFDC_Customer_Code__c')
        .selectfield('Product__r.Product_Code__c')
        .selectfield('Locations__r.Location_Code__c')
        .toSOQL();
        return Database.query(query);
    }

}