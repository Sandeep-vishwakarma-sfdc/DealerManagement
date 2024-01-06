/**
 * @description       : This class show all Query of Price Book Entry Object.                                          
 * @author            : prashant.kumbhar@skinternational.com
 * @last modified on  : 10-11-2023
 * @last modified by  :  prashant.kumbhar@skinternational.com
**/

public without Sharing class YINPriceBookEntrySelector extends LIBSObjectSelector {

    public Schema.SObjectType getSObjectType(){
        return PricebookEntry.SObjectType;
    }
    
    /**
    * @description:This method is used to Define all price Book Entry Fields.
    * @return List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            PricebookEntry.Id,
            PricebookEntry.Name,
            PricebookEntry.Product2Id,
            PricebookEntry.Pricebook2Id,
            PricebookEntry.IsActive,
            PricebookEntry.UnitPrice,
            PricebookEntry.Sales_Price__c,
            PricebookEntry.Start_Date__c ,
            PricebookEntry.End_Date__c,
            PricebookEntry.Combination_Key__c,
            PricebookEntry.UseStandardPrice, 
            PricebookEntry.ProductCode
    
        };     
    }
        
    /**
    * @description:This method is used to get Standard Price Book Entry.
    * @param  standPriceBookId: Standard price Book Id
    * @param  productId: Product Id to retrive Data.
    * @return List<PricebookEntry>
    */           
        public List<PricebookEntry> getStandardPriceBookEntry(Id standPriceBookId,Id productId){
            LIBQueryFactory query = newQueryFactory();
            query.setCondition('Pricebook2Id=:standPriceBookId And Product2Id=:productId And IsActive = true');
            System.debug('Query is'+query.toSOQL());
            return Database.query( query.toSOQL());    
        }
        
        
        public PricebookEntry getPriceBookEntryforUpdate(Id priceBookId,Id productId){
            LIBQueryFactory query = newQueryFactory();
            query.setCondition('Pricebook2Id=:priceBookId And Product2Id=:productId');
            System.debug('Query in PriceBook Entry is'+query.toSOQL());
            return Database.query( query.toSOQL());
        }
    
        
        public List<PricebookEntry> selectPriceBookEntriesByPricebook(List<Id> priceBookIds){
            LIBQueryFactory query = newQueryFactory();
            LIBSObjectSelector productSelector =  new YINProductSelector();
            productSelector.configureQueryFactoryFields(query, 'Product2');
            query.setCondition('IsActive=true and Product2.IsActive=true and Pricebook2Id IN:priceBookIds and Start_Date__c <=TODAY and End_Date__c <=TODAY');
            query.addOrdering(Order.LastModifiedDate, LIBQueryFactory.SortOrder.DESCENDING);
            return Database.query(query.toSOQL());
        }
    
    }