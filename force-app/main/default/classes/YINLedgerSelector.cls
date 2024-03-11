/**
 * @description       : 
 * @author            : saurabh.pandey@skinternational.com
 * @group             : 
 * @last modified on  : 02-14-2024
 * @last modified by  : saurabh.pandey@skinternational.com
**/
public without sharing class YINLedgerSelector extends LibSObjectSelector{
    public Schema.SObjectType getSObjectType() {
        return YIN_Ledger__c.SObjectType;
    }

    public  List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            YIN_Ledger__c.Id,
            YIN_Ledger__c.Name,
            YIN_Ledger__c.Document_Type__c,
            YIN_Ledger__c.Remaining_Amount__c,
            YIN_Ledger__c.Open__c,
            YIN_Ledger__c.Posting_Date__c,
            YIN_Ledger__c.Dealer_Code__c,
            YIN_Ledger__c.Document_Number__c,
            YIN_Ledger__c.Credit_Amount__c,
            YIN_Ledger__c.Debit_Amount__c,
            YIN_Ledger__c.Cheque_Date__c,
            YIN_Ledger__c.Cheque_Number__c,
            YIN_Ledger__c.Amount__c,
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
       
        return Database.query('select dealer_code__c,dealer_code__r.ERP_Customer_code__c, sum(Remaining_Amount__c) from YIN_Ledger__c WHERE (recordtype.name =:ledgerRecordType OR recordtypeid = null) and open__c= true and dealer_code__c In :dealerCodes and Posting_Date__c <= :postingDate group by dealer_code__r.ERP_Customer_code__c,dealer_code__c');
    }
    
    public List<YIN_Ledger__c> getSecurityDeposit(Id dealerId,Id recordTypeId,Date datestr1, Date datestr2){
        LIBQueryFactory query = newQueryFactory();
        query.selectField('Dealer_Code__r.Id');
        query.selectfield('RecordType.Name');
        query.setCondition('Dealer_Code__c = : dealerId AND RecordTypeId =: recordTypeId AND Posting_Date__c >= :dateStr1 AND Posting_Date__c <= :dateStr2');
        System.debug('Query is'+query.toSOQL());
        return Database.query( query.toSOQL());     
    }
    
    public List<YIN_Ledger__c> getLedger(Id dealerId,Id recordTypeId,Date datestr1, Date datestr2){
        LIBQueryFactory query = newQueryFactory();
        query.selectField('Dealer_Code__r.Id');
        query.selectfield('RecordType.Name');
        query.setCondition('Dealer_Code__c = : dealerId AND RecordTypeId =: recordTypeId AND Posting_Date__c >= :dateStr1 AND Posting_Date__c <= :dateStr2');
        System.debug('Query is'+query.toSOQL());
        return Database.query( query.toSOQL());     
    }
    
     public List<YIN_Ledger__c> getSecDepositRec(Id dealerId,Id recordTypeId){
        LIBQueryFactory query = newQueryFactory();
        query.selectField('Dealer_Code__r.Id');
        query.selectfield('RecordType.Name');
        query.setCondition('Dealer_Code__c = : dealerId AND RecordTypeId =: recordTypeId');
        System.debug('Query is'+query.toSOQL());
        return Database.query( query.toSOQL());     
    }
    
     public List<YIN_Ledger__c> getLedgerRec(Id dealerId,Id recordTypeId){
        LIBQueryFactory query = newQueryFactory();
        query.selectField('Dealer_Code__r.Id');
        query.selectfield('RecordType.Name');
        query.setCondition('Dealer_Code__c = : dealerId AND RecordTypeId =: recordTypeId');
        System.debug('Query is'+query.toSOQL());
        return Database.query( query.toSOQL());     
    }

    public List<YIN_Ledger__c> selectOpenInvoice(List<string> accountIds){
        String documentType = 'Invoice';
        String accountId = accountIds[0];
        String query =  newQueryFactory()
            .setCondition('Open__c=true and Dealer_Code__c=:accountId and Document_Type__c=:documentType')
            .setOrdering(YIN_Ledger__c.Posting_Date__c,LIBQueryFactory.SortOrder.ASCENDING, false)
            .toSOQL();
        return Database.query(query);
    }
     public List<YIN_Ledger__c> getLedgerFromPayment(String paymentId){
        String query =  newQueryFactory()
            .setCondition('Payment__c=:paymentId')
            .toSOQL();
        return Database.query(query);
    }

}