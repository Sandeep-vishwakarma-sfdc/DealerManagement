public with sharing class YINLedgerSelector extends LibSObjectSelector{
    public Schema.SObjectType getSObjectType() {
        return YIN_Ledger__c.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            YIN_Ledger__c.Id,
            YIN_Ledger__c.Posting_Date__c,
            YIN_Ledger__c.Dealer_Code__c 
        };
    }

    public List<YIN_Ledger__c> selectById(Set<Id> recordIds){
        return (List<YIN_Ledger__c>) selectSObjectsById(recordIds);
    }

    public List<YIN_Ledger__c> selectByAccount(Set<Id> accountIds){
        String query =  newQueryFactory()
                            .selectField('Dealer_Code__r.Credit_Days_Group_Dealer__c')
                            .selectField('Dealer_Code__r.Available_Credit_Limit__c')
                            .setCondition('Dealer_Code__c IN :accountIds')
                            .setOrdering('Posting_Date__c',LIBQueryFactory.SortOrder.ASCENDING, false)
                            .toSOQL();
        return Database.query(query);
    }


}