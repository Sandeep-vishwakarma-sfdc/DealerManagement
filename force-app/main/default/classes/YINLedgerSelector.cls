/**
 * @description       : 
 * @author            : saurabh.pandey@skinternational.com
 * @group             : 
 * @last modified on  : 02-14-2024
 * @last modified by  : saurabh.pandey@skinternational.com
**/
public with sharing class YINLedgerSelector extends LibSObjectSelector{
    public Schema.SObjectType getSObjectType() {
        return YIN_Ledger__c.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            YIN_Ledger__c.Id,
            YIN_Ledger__c.Posting_Date__c,
            YIN_Ledger__c.Dealer_Code__c,
            YIN_Ledger__c.Document_Number__c,
            YIN_Ledger__c.Remaining_Amount_LCY__c
        };
    }

    public List<YIN_Ledger__c> selectById(Set<Id> recordIds){
        return (List<YIN_Ledger__c>) selectSObjectsById(recordIds);
    }

    public List<YIN_Ledger__c> selectByAccount(Set<Id> accountIds){
        Set<String> recordTypeIds = new Set<String>();
        recordTypeIds.add('Ledger');
        recordTypeIds.add('');
        String query =  newQueryFactory()
                            .selectField('Dealer_Code__r.Credit_Days_Group_Dealer__c')
                            .selectField('Dealer_Code__r.Available_Credit_Limit__c')
                            .setCondition('Dealer_Code__c IN :accountIds and RecordType.Name IN :recordTypeIds and Open__c=true')
                            .setOrdering('Posting_Date__c',LIBQueryFactory.SortOrder.ASCENDING, false)
                            .toSOQL();
        return Database.query(query);
    }
    //Added by kalpesh chande
    public List<YIN_Ledger__c> getLedgerIds(){
        String query =  newQueryFactory()
            .selectField('Id')
            .selectField('Document_Number__c')
            .selectField('Remaining_Amount_LCY__c')
            .setCondition('Document_Number__c!=null')
            .toSOQL();
        return Database.query(query);
    }

    public List<AggregateResult> getLedgerData(Set<Id> dealerCodes, Date postingDate , String ledgerRecordType) {
       
        return Database.query('select dealer_code__c,dealer_code__r.ERP_Customer_code__c, sum(Remaining_Amount__c) from YIN_Ledger__c WHERE(recordtype.name =:ledgerRecordType OR recordtypeid = null) and open__c= true and dealer_code__c In :dealerCodes and Posting_Date__c <= :postingDate group by dealer_code__r.ERP_Customer_code__c,dealer_code__c');
    }

}