public with sharing class YINContactSelector extends LIBSObjectSelector {
    public Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Contact.Id,
            Contact.FirstName,
            Contact.LastName,
            Contact.AccountId
        };
    }

    public List<Contact> selectById(Set<Id> recordIds){
        return (List<Contact>) selectSObjectsById(recordIds);
    }
}