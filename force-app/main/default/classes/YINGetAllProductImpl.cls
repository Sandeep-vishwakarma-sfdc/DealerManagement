public with sharing class YINGetAllProductImpl implements YINIGetProducts {
    
    public List<YINProductWrapper> getProducts(String accountId){
        // Declaring variables
        List<YINProductWrapper> productsWrapper = new List<YINProductWrapper>();
        List<Id> priceBookIds = new List<Id>();
        
        Map<String,YIN_Account_product_Mapping__c> locationProductsTrending = new Map<String,YIN_Account_product_Mapping__c>();
        Map<String,YIN_Account_product_Mapping__c> locationProductsOfMonth = new Map<String,YIN_Account_product_Mapping__c>();
        
        Map<Id,YIN_Account_product_Mapping__c> accountProductMappingByProduct = new Map<Id,YIN_Account_product_Mapping__c>();
        Map<Id,YIN_Account_product_Mapping__c> locationProductByProduct = new Map<Id,YIN_Account_product_Mapping__c>();
        Map<Id,YIN_Account_product_Mapping__c> locationFrequentlyByProduct = new Map<Id,YIN_Account_product_Mapping__c>();
        
        YINAccountProductMappingSelector accountProductselector = (YINAccountProductMappingSelector)YINApplication.selector.newInstance(YIN_Account_product_Mapping__c.SObjectType);
        YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);

        // 1. Get PriceBook and repective Price book Enteries
        List<PriceBook2> priceBooks = getPriceBook(accountId);

        for(PriceBook2 pricebook : priceBooks){
            priceBookIds.add(pricebook.Id);
        }
        
        List<PricebookEntry> pricebookEntries = getPriceBookEntries(priceBookIds);

        
        // 2. Creating Product configutaion Mapping like Maximum order Quantity,Minimum Order Quantity,Trending Product etc.
        List<YIN_Account_product_Mapping__c> accountProducts = accountProductselector.selectAll();
        
        for (YIN_Account_product_Mapping__c accountProduct : accountProducts) {
            switch on accountProduct.Type__c {
                when 'Locking Product'{
                    accountProductMappingByProduct.put(accountProduct.Product__c,accountProduct);
                }
                when 'Trending Products'{
                    locationProductsTrending.put(accountProduct.Product__c,accountProduct);
                }
                when 'Product of the Month'{
                    locationProductsOfMonth.put(accountProduct.Product__c,accountProduct);
                }
                when 'Frequently Bought Product'{
                    locationFrequentlyByProduct.put(accountProduct.Product__c,accountProduct);
                }
            }
        }

        // 3. Create Wrapper to store all information at one place
        for(PricebookEntry priceBookEntry:pricebookEntries){

            YINProductWrapper productWrapper = new YINProductWrapper();
            productWrapper.pricebookEntry = priceBookEntry;
            productWrapper.productId = priceBookEntry.Product2Id;
            productWrapper.maximum_Order_Quantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Maximum_Order_Quantity__c;
            productWrapper.minimum_Order_Quantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Minimum_Order_Quantity__c;
            productWrapper.quantity = 1; // Default Quantity value when Order page loads

            // TODO : Add/Edit some logic below
            productWrapper.discountPercentage = 0;
            productWrapper.lockingSKU = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.trendingSKU = locationProductsTrending.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.productOfTheMonth = locationProductsOfMonth.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.lineItemSubTotal = 0;
            productWrapper.GSTPercentage = 28;// Need to Bring value Dynamically
            productWrapper.combinationKey = priceBookEntry.Product2.ProductCode;
            // productWrapper.cappingSKU = accountProductMappingByProduct.get(priceBookEntry.Product2Id);

            // Adding productWrapper to List
            productsWrapper.add(productWrapper);
        }
        return productsWrapper;
    }

    // Utility Methods
    public static List<PriceBook2> getPriceBook(String accountId){
        try {
            // 1. Check for Customer PriceBook
            List<PriceBook2> priceBooks = getPriceBookByCustomer(accountId);
            if(priceBooks.size()>0){
                return priceBooks;
            }

            // 2. Check for Customer Group PriceBook If Step 1 Fails
            List<String> customeGroups = getCustomerGroupByCustomer(accountId);
            priceBooks = getPriceBookByCustomerGroup(customeGroups);
            if(priceBooks.size()>0){
                return priceBooks;
            }

            // 3. Check for Common PriceBook If Step 1 & 2 Fails
            priceBooks = getCommonPriceBook();
            if(priceBooks.size()>0){
                return priceBooks;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<PriceBook2> getPriceBookByCustomer(String accountId){
        YINPriceBookSelector priceBookSelector = (YINPriceBookSelector)YINApplication.selector.newInstance(PriceBook2.SObjectType);
        List<PriceBook2>  priceboooks = priceBookSelector.selectPriceBookByCustomer(accountId);
        return priceboooks;
    }

    private static List<PriceBook2> getPriceBookByCustomerGroup(List<String> customerGroups){
        YINPriceBookSelector priceBookSelector = (YINPriceBookSelector)YINApplication.selector.newInstance(PriceBook2.SObjectType);
        List<PriceBook2>  priceboooks = priceBookSelector.selectPriceBookByCustomerGroup(customerGroups);
        return priceboooks;
    }

    private static List<PriceBook2> getCommonPriceBook(){
        YINPriceBookSelector priceBookSelector = (YINPriceBookSelector)YINApplication.selector.newInstance(PriceBook2.SObjectType);
        List<PriceBook2>  priceboooks = priceBookSelector.priceBookbyCustomerComman();
        return priceboooks;
    }

    public static List<String> getCustomerGroupByCustomer(String accountId){
        YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.getAccounts(new List<String>{accountId});
        List<String> customerGroups = new List<String>();
        for(Account acount:accounts){
            customerGroups.add(acount.Customer_Group__c);
        }
        return customerGroups;
    }

    public static List<PricebookEntry> getPriceBookEntries(List<Id> priceBookIds){
        try {
            YINPriceBookEntrySelector priceBookEntrySelector1 = (YINPriceBookEntrySelector)YINApplication.selector.newInstance(PricebookEntry.SObjectType);
            List<PricebookEntry> pricebookEntries = priceBookEntrySelector1.selectPriceBookEntriesByPricebook(priceBookIds);
            return pricebookEntries;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}