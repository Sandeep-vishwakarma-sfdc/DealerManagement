public with sharing class AccountProductMappingSelector extends LibSObjectSelector{
    public Schema.SObjectType getSObjectType() {
        return Account_product_Mapping__c.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Account_product_Mapping__c.Id,
            Account_product_Mapping__c.Name,
            Account_product_Mapping__c.Account__c,
            Account_product_Mapping__c.Product__c,
            Account_product_Mapping__c.Type__c,
            // Account_product_Mapping__c.Locking_status__c,
            // Account_product_Mapping__c.Locking_Start_Date__c,
            // Account_product_Mapping__c.Locking_End_Date__c,
            Account_product_Mapping__c.Minimum_Order_Quantity__c,
            Account_product_Mapping__c.Maximum_Order_Quantity__c
        };
    }

    public List<Account_product_Mapping__c> selectById(Set<Id> recordIds){
        return (List<Account_product_Mapping__c>) selectSObjectsById(recordIds);
    }

    public List<Account_product_Mapping__c> selectByAccount(String accountId){
        String query = newQueryFactory()
        .setCondition('Product__c!=null and Account__c=:accountId')
        .toSOQL();
        return Database.query(query);
    }
}