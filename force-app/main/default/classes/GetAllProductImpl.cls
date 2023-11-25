public with sharing class GetAllProductImpl implements IGetProducts {
    
    public List<ProductWrapper> getProducts(String accountId){
        List<Id> priceBookIds = new List<Id>();
        List<ProductWrapper> productsWrapper = new List<ProductWrapper>();
        // 1. Get PriceBook
        List<PriceBook2> priceBooks = OrderManagementController.getPriceBook(accountId);

        // 2. Loop Through PriceBook to Add Id in priceBookIds, Most Likely Only 1 PriceBook should found
        for(PriceBook pricebook : priceBooks){
            priceBookIds.add(pricebook.Id);
        }

        // 3. Getting PriceBookEntries
        List<PricebookEntry> pricebookEntries = OrderManagementController.getPriceBookEntries(priceBookIds);

        // Get SKU Configuration 
        // Map => {Key = Product__c,value = Account_product_Mapping__c}
        Map<Id,Account_product_Mapping__c> accountProductMappingByProduct = new Map<Id,Account_product_Mapping__c>([select Id,Name,Account__c,Product__c,Locking_status__c,Minimum_Order_Quantity__c,Maximum_Order_Quantity__c from Account_product_Mapping__c where Product__c!=null and Group By Product__c]);

        // Create Wrapper
        for(PricebookEntry priceBookEntry:pricebookEntries){
            ProductWrapper productWrapper = new ProductWrapper();
            productWrapper.pricebookEntry = priceBookEntry;
            productWrapper.Id = priceBookEntry.productId;
            // TODO : Add/Edit some logic below
            productWrapper.trendingSKU = accountProductMappingByProduct.get(priceBookEntry.productId);// use Map to bring value
            productWrapper.lockingSKU = accountProductMappingByProduct.get(priceBookEntry.productId);
            productWrapper.cappingSKU = accountProductMappingByProduct.get(priceBookEntry.productId);

            // Adding productWrapper to List
            productsWrapper.add(productWrapper);
        }
        return productsWrapper;
    }
}