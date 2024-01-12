public with sharing class YINVariantSelector extends LibSObjectSelector{
    public Schema.SObjectType getSObjectType() {
        return YIN_Variant__c.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            YIN_Variant__c.Id,
            YIN_Variant__c.Variant_Code__c
        };
    }

    public List<YIN_Variant__c> selectById(Set<Id> recordIds){
        return (List<YIN_Variant__c>) selectSObjectsById(recordIds);
    }

    public List<YIN_Variant__c> selectAll(){
        String query =  newQueryFactory().toSOQL();
        return Database.query(query);
    }
}