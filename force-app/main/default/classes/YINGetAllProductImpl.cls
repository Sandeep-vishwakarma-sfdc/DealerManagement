public with sharing class YINGetAllProductImpl implements YINIGetProducts {
    
    public List<YINProductWrapper> getProducts(String accountId){
        // Declaring variables
        List<YINProductWrapper> productsWrapper = new List<YINProductWrapper>();
        List<Id> priceBookIds = new List<Id>();
        
        Map<String,YIN_Account_product_Mapping__c> locationProductsTrending = new Map<String,YIN_Account_product_Mapping__c>();
        Map<String,YIN_Account_product_Mapping__c> locationProductsOfMonth = new Map<String,YIN_Account_product_Mapping__c>();
        
        Map<Id,YIN_Account_product_Mapping__c> accountProductMappingByProduct = new Map<Id,YIN_Account_product_Mapping__c>();
        Map<Id,YIN_Account_product_Mapping__c> locationProductMappingByProduct = new Map<Id,YIN_Account_product_Mapping__c>();
        Map<Id,YIN_Account_product_Mapping__c> locationProductByProduct = new Map<Id,YIN_Account_product_Mapping__c>();
        Map<Id,YIN_Account_product_Mapping__c> locationFrequentlyByProduct = new Map<Id,YIN_Account_product_Mapping__c>();
        
        YINAccountProductMappingSelector accountProductselector = (YINAccountProductMappingSelector)YINApplication.selector.newInstance(YIN_Account_product_Mapping__c.SObjectType);
        

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
                when 'Locking Account Product'{
                    accountProductMappingByProduct.put(accountProduct.Product__c,accountProduct);
                }
                when 'Locking Location Product'{
                    locationProductMappingByProduct.put(accountProduct.Product__c,accountProduct);
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

        List<YIN_Product_Capping__mdt> productsCapping = YIN_Product_Capping__mdt.getAll().values();
        Map<String,YIN_Product_Capping__mdt> productCappingBySize = new Map<String,YIN_Product_Capping__mdt>();
        for(YIN_Product_Capping__mdt capping:productsCapping){
            productCappingBySize.put(capping.Tyre_Size__c,capping);
        }

        YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.getAccounts(new List<String>{accountId});

        Tax_Constants__mdt taxConstant = Tax_Constants__mdt.getInstance('Tax_Constant');
        Decimal vTDSPercentage = accounts[0].PAN_Status__c=='Valid'?taxConstant.TDS__c:taxConstant.Invalid_PAN_TCS__c;
        Decimal vTCSPercentage = accounts[0].PAN_Status__c=='Valid'?taxConstant.TCS__c:taxConstant.Invalid_PAN_TDS__c;

        

        // 3. Create Wrapper to store all information at one place
        for(PricebookEntry priceBookEntry:pricebookEntries){

            YINProductWrapper productWrapper = new YINProductWrapper();
            productWrapper.pricebookEntry = priceBookEntry;
            productWrapper.productId = priceBookEntry.Product2Id;
            productWrapper.maximumOrderQuantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Maximum_Order_Quantity__c;
            productWrapper.minimumOrderQuantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Minimum_Order_Quantity__c;
            productWrapper.quantity = 1; // Default Quantity value when Order page loads
            productWrapper.discountPercentage = 0;
            productWrapper.lockingSKUAccount = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.lockingSKULocation = locationProductMappingByProduct.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.trendingSKU = locationProductsTrending.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.productOfTheMonth = locationProductsOfMonth.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.unitPrice = priceBookEntry.UnitPrice;
            productWrapper.netPrice = (1 * priceBookEntry.UnitPrice);
            productWrapper.productName = priceBookEntry.Product2.Name;
            productWrapper.productSize = priceBookEntry.Product2.Size__c;
            productWrapper.productPattern = priceBookEntry.Product2.Tread_Pattern__c;
            productWrapper.combinationKey = priceBookEntry.Product2.ProductCode;
            productWrapper.maximumCappingQuantity = Integer.valueOf(productCappingBySize.get(priceBookEntry.Product2.Size__c).Maximum_Order_Capping__c);
            productWrapper.GSTPercentage = taxConstant.GST__c;
            productWrapper.tdsPercentage = vTDSPercentage;
            productWrapper.tcsPercentage = vTCSPercentage;
            productWrapper.applyTCS = accounts[0].X1H_TCS__c;

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