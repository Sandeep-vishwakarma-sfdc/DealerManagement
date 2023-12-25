public with sharing class GetAllProductImpl implements IGetProducts {
    
    public List<ProductWrapper> getProducts(String accountId){
        // Declaring variables
        List<ProductWrapper> productsWrapper = new List<ProductWrapper>();
        List<Id> priceBookIds = new List<Id>();
        Account currentAccount = null;

        Id locationTrendingType = Schema.SObjectType.Location_Product_Mapping__c.getRecordTypeInfosByName().get('Trending Product').getRecordTypeId();
        Id locationProductOfMonthType = Schema.SObjectType.Location_Product_Mapping__c.getRecordTypeInfosByName().get('Product of the Month').getRecordTypeId();
        
        Map<String,Account_product_Mapping__c> locationProductsTrending = new Map<String,Account_product_Mapping__c>();
        Map<String,Account_product_Mapping__c> locationProductsOfMonth = new Map<String,Account_product_Mapping__c>();
        
        Map<Id,Account_product_Mapping__c> accountProductMappingByProduct = new Map<Id,Account_product_Mapping__c>();
        Map<Id,Account_product_Mapping__c> locationProductByProduct = new Map<Id,Account_product_Mapping__c>();
        Map<Id,Account_product_Mapping__c> locationFrequentlyByProduct = new Map<Id,Account_product_Mapping__c>();
        
        AccountProductMappingSelector accountProductselector = (AccountProductMappingSelector)Application.selector.newInstance(Account_product_Mapping__c.SObjectType);
        AccountSelector accountSelector = (AccountSelector)Application.selector.newInstance(Account.SObjectType);

        // 1. Get PriceBook and repective Price book Enteries
        List<PriceBook2> priceBooks = OrderManagementController.getPriceBook(accountId);

        for(PriceBook2 pricebook : priceBooks){
            priceBookIds.add(pricebook.Id);
        }
        
        List<PricebookEntry> pricebookEntries = OrderManagementController.getPriceBookEntries(priceBookIds);

        // 2. Creating Trending Product and Product of the Month Mapping , so that we can use them to create Wrapper.
        List<Account> accounts = accountSelector.getAccounts(new List<String>{accountId});
        if(accounts.size()>0){
            currentAccount = accounts[0];
        }
        /*List<Location_Product_Mapping__c> locationProducts = [Select Id,Name,Product__c,Location__c,Status__c,recordTypeId from Location_Product_Mapping__c where Location__c=:currentAccount.Location__c];

        for(Location_Product_Mapping__c locationProduct : locationProducts){
            if(locationProduct.recordTypeId==locationTrendingType){
                locationProductsTrending.put(locationProduct.Product__c,locationProduct);
            }
            if(locationProduct.recordTypeId==locationProductOfMonthType){
                locationProductsOfMonth.put(locationProduct.Product__c,locationProduct);
            }
        }*/

        
        // 3. Creating Product configutaion Mapping like Maximum order Quantity,Minimum Order Quantity
        List<Account_product_Mapping__c> accountProducts = accountProductselector.selectByAccount(accountId);
        for (Account_product_Mapping__c accountProduct : accountProducts) {
            accountProductMappingByProduct.put(accountProduct.Product__c,accountProduct);
        }

        for (Account_product_Mapping__c accountProduct : accountProducts) {
            switch on accountProduct.Type__c {
                when 'Locking Product'{
                    accountProductMappingByProduct.put(accountProduct.Product__c,accountProduct);
                }
                when 'Trending Product'{
                    //locationProductsTrending.put(accountProduct.Product__c,accountProduct);
                }
                when 'Product of The Month'{
                    locationProductsOfMonth.put(accountProduct.Product__c,accountProduct);
                }
                when 'Frequently Brought Product'{
                    locationFrequentlyByProduct.put(accountProduct.Product__c,accountProduct);
                }
            }
            accountProductMappingByProduct.put(accountProduct.Product__c,accountProduct);
        }

        // 4. Create Wrapper
        for(PricebookEntry priceBookEntry:pricebookEntries){

            ProductWrapper productWrapper = new ProductWrapper();
            productWrapper.pricebookEntry = priceBookEntry;
            productWrapper.productId = priceBookEntry.Product2Id;
            productWrapper.maximum_Order_Quantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Maximum_Order_Quantity__c;
            productWrapper.minimum_Order_Quantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Minimum_Order_Quantity__c;
            productWrapper.quantity = 1; // Default Quantity value when Order page loads

            // TODO : Add/Edit some logic below
            productWrapper.discountPercentage = 0;
            // productWrapper.lockingSKU = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Locking_status__c;
            // productWrapper.trendingSKU = locationProductsTrending.get(priceBookEntry.Product2Id)?.Status__c;
            // productWrapper.productOfTheMonth = locationProductsOfMonth.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.lineItemSubTotal = 0;
            productWrapper.GSTPercentage = 28;// Need to Bring value Dynamically
            productWrapper.combinationKey = priceBookEntry.Product2.ProductCode;
            // productWrapper.cappingSKU = accountProductMappingByProduct.get(priceBookEntry.Product2Id);

            // Adding productWrapper to List
            productsWrapper.add(productWrapper);
        }
        return productsWrapper;
    }
}