/**
 * @description       : This class show all Query of Price Book Entry Object.                                          
 * @author            : prashant.kumbhar@skinternational.com
 * @last modified on  : 03-09-2024
 * @last modified by  : saurabh.pandey@skinternational.com
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
        public List<PricebookEntry> getStandardPriceBookEntry(Id standPriceBookId){
            LIBQueryFactory query = newQueryFactory();
            query.setCondition('Pricebook2Id=:standPriceBookId And IsActive = true');
            System.debug('Query is'+query.toSOQL());
            return Database.query( query.toSOQL());    
        }
        
        
        public PricebookEntry getPriceBookEntryforUpdate(Id priceBookId,Id productId){
            LIBQueryFactory query = newQueryFactory();
            query.setCondition('Pricebook2Id=:priceBookId And Product2Id=:productId');
            System.debug('Query in PriceBook Entry is'+query.toSOQL());
            return Database.query( query.toSOQL());
        }
    
        
        public List<PricebookEntry> selectPriceBookEntriesByPricebook(List<Id> priceBookIds,Boolean isPromotional){
            String categoryCode = 'TIRE_I';
            if(isPromotional){
                categoryCode = 'NON_TRADIN';
            }
            LIBQueryFactory query = newQueryFactory();
            LIBSObjectSelector productSelector =  new YINProductSelector();
            LIBSObjectSelector priceBookSelector =  new YINPriceBookSelector();
            priceBookSelector.configureQueryFactoryFields(query,'Pricebook2');
            productSelector.configureQueryFactoryFields(query, 'Product2');
            query.setCondition('IsActive=true and Product2.IsActive=true and Product2.Item_Category_Code__c=:categoryCode and Pricebook2Id IN:priceBookIds and Start_Date__c <=TODAY and End_Date__c >=TODAY');
            query.addOrdering(Order.LastModifiedDate, LIBQueryFactory.SortOrder.DESCENDING);
            return Database.query(query.toSOQL());
        }

        /**
         * @author:Nikhil Dhoke
         * @description - get unit price based on product code.
         * @param List<String> : product codes.
         * @return  - List<PricebookEntry>.
         */
        public List<PricebookEntry> getUnitPriceByProductCode(List<String> productCodes){
            return Database.query(
                newQueryFactory()
                        .selectField('Product2.Product_Code__c')
                        .setCondition('Pricebook2.Type__c = \'All Customer\' AND Start_Date__c <= TODAY AND End_Date__c >= TODAY AND Pricebook2.IsDiscount__c = false AND Product2.Product_Code__c IN: productCodes')
                        .toSOQL()
            );
        }

         /**
         * @author:Saurabh Pandey
         * @description : Retrieves a list of PricebookEntry records based on the specified Product Id. 
         * @param productId The Id of the Product2 record..
         * @return - List<PricebookEntry> A list of PricebookEntry records associated with the specified Product Id..
         */

        public List<PricebookEntry> getPriceBookEntryId(String productId){
            return Database.query(
                newQueryFactory()
                        .selectField('Product2.Product_Code__c')
                        .setCondition('Product2.Id =: productId')
                        .toSOQL()
            );
        }
    
    }