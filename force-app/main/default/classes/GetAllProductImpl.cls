public with sharing class GetAllProductImpl implements IGetProducts {
    
    public List<ProductWrapper> getProducts(String accountId){
        List<Id> priceBookIds = new List<Id>();
        List<ProductWrapper> productsWrapper = new List<ProductWrapper>();
        // 1. Get PriceBook
        List<PriceBook2> priceBooks = OrderManagementController.getPriceBook(accountId);

        // 2. Loop Through PriceBook to Add Id in priceBookIds, Most Likely Only 1 PriceBook should found
        for(PriceBook2 pricebook : priceBooks){
            priceBookIds.add(pricebook.Id);
        }

        // 3. Getting PriceBookEntries
        List<PricebookEntry> pricebookEntries = OrderManagementController.getPriceBookEntries(priceBookIds);

        // Get SKU Configuration 
        // Map => {Key = Product__c,value = Account_product_Mapping__c}
        Map<Id,Account_product_Mapping__c> accountProductMappingByProduct = new Map<Id,Account_product_Mapping__c>();
        
        List<Account_product_Mapping__c> accountProducts = [select Id,Name,Account__c,Product__c,Locking_status__c,Locking_Start_Date__c,Locking_End_Date__c,Minimum_Order_Quantity__c,Maximum_Order_Quantity__c from Account_product_Mapping__c where Product__c!=null and Account__c=:accountId];

        for (Account_product_Mapping__c accountProduct : accountProducts) {
            accountProductMappingByProduct.put(accountProduct.Product__c,accountProduct);
        }

        // Create Wrapper
       
        for(PricebookEntry priceBookEntry:pricebookEntries){

            ProductWrapper productWrapper = new ProductWrapper();
            productWrapper.pricebookEntry = priceBookEntry;
            productWrapper.productId = priceBookEntry.Product2Id;
            productWrapper.lockingSKU = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Locking_status__c;
            productWrapper.maximum_Order_Quantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Maximum_Order_Quantity__c;
            productWrapper.minimum_Order_Quantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Minimum_Order_Quantity__c;
            productWrapper.quantity = 1; // Default Qunatity value when Order page loads

            // TODO : Add/Edit some logic below
            productWrapper.discountPercentage = 0;
            productWrapper.trendingSKU = false;// accountProductMappingByProduct.get(priceBookEntry.Product2Id);// use Map to bring value
            productWrapper.lineItemSubTotal = 0;
            productWrapper.GSTPercentage = 28;// Need to Bring value Dynamically
            productWrapper.combinationKey = priceBookEntry.Product2.ProductCode + priceBookEntry.Product2.Variant__r.Variant_Code__c;
            // productWrapper.weekOfTheSKU = false;
            // productWrapper.cappingSKU = accountProductMappingByProduct.get(priceBookEntry.Product2Id);

            // Adding productWrapper to List
            productsWrapper.add(productWrapper);
        }
        return productsWrapper;
    }
}