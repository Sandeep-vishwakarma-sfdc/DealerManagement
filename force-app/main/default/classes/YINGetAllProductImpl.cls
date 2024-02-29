/**
 * YINGetAllProductImpl - Implementation class for YINIGetProducts interface responsible for retrieving
 * product details for a given account in the YINOrderManagement system.
 *
 * Description: This class contains methods to fetch and organize product details based on the specified
 * account. It utilizes various maps and selectors to gather information about price books, product mappings,
 * and other relevant configurations. The retrieved data is then encapsulated in YINProductWrapper instances
 * for easy handling within the system.
 *
 * Access: This class is declared as "public with sharing" to enforce sharing rules when interacting with data,
 * making it suitable for scenarios where sharing rules need to be considered.
 */
public with sharing class YINGetAllProductImpl implements YINIGetProducts {

    /**
     * Retrieves a list of YINProductWrapper instances containing product details for the specified account.
     *
     * @param accountId - Id of the account for which products need to be retrieved.
     * @return List<YINProductWrapper> - List of YINProductWrapper instances containing product details.
     * @throws YINOrderManagementException - Custom exception thrown in case of errors during the execution.
     */
    public List<YINProductWrapper> getProducts(String accountId) {
        
        // Declaring variables
        List<YINProductWrapper> productsWrapper = new List<YINProductWrapper>();
        List<Id> priceBookIds = new List<Id>();

        Map<String, YIN_Account_product_Mapping__c> locationProductsTrending = new Map<String, YIN_Account_product_Mapping__c>();
        Map<String, YIN_Account_product_Mapping__c> locationProductsOfMonth = new Map<String, YIN_Account_product_Mapping__c>();

        Map<String, YIN_Account_product_Mapping__c> accountProductMappingByProduct = new Map<String, YIN_Account_product_Mapping__c>();
        Map<String, YIN_Account_product_Mapping__c> locationProductMappingByProduct = new Map<String, YIN_Account_product_Mapping__c>();
        Map<Id, YIN_Account_product_Mapping__c> locationProductByProduct = new Map<Id, YIN_Account_product_Mapping__c>();
        Map<String, YIN_Account_product_Mapping__c> accountFrequentlyByProduct = new Map<String, YIN_Account_product_Mapping__c>();

        YINAccountProductMappingSelector accountProductSelector = (YINAccountProductMappingSelector) YINApplication.selector.newInstance(YIN_Account_product_Mapping__c.SObjectType);

        // 1. Get PriceBook and respective Price book Entries
        List<PriceBook2> priceBooks = getPriceBook(accountId);

        for (PriceBook2 pricebook : priceBooks) {
            priceBookIds.add(pricebook.Id);
        }

        System.debug('priceBookIds ' + priceBookIds);
        List<PricebookEntry> pricebookEntries = getPriceBookEntries(priceBookIds);
        System.debug('pricebookEntries ' + pricebookEntries);

        // 2. Creating Product configuration Mapping like Maximum order Quantity, Minimum Order Quantity, Trending Product, etc.
        List<YIN_Account_product_Mapping__c> accountProducts = accountProductSelector.selectAll();

        for (YIN_Account_product_Mapping__c accountProduct : accountProducts) {
            switch on accountProduct.Type__c {
                when 'Locking Account Product' {
                    accountProductMappingByProduct.put(accountProduct.Product__c+''+accountProduct.Account__c, accountProduct);
                }
                when 'Locking Location Product' {
                    locationProductMappingByProduct.put(accountProduct.Product__c+''+accountProduct.Locations__c, accountProduct);
                }
                when 'Trending Products' {
                    locationProductsTrending.put(accountProduct.Product__c+''+accountProduct.Locations__c, accountProduct);
                }
                when 'Product of the Month' {
                    locationProductsOfMonth.put(accountProduct.Product__c+''+accountProduct.Locations__c, accountProduct);
                }
                when 'Frequently Bought Product' {
                    accountFrequentlyByProduct.put(accountProduct.Product__c+''+accountProduct.Account__c, accountProduct);
                }
            }
        }

        List<YIN_Product_Capping__mdt> productsCapping = YIN_Product_Capping__mdt.getAll().values();
        Map<String, YIN_Product_Capping__mdt> productCappingBySize = new Map<String, YIN_Product_Capping__mdt>();
        for (YIN_Product_Capping__mdt capping : productsCapping) {
            productCappingBySize.put(capping.Tyre_Size__c, capping);
        }

        YINAccountSelector accountSelector = (YINAccountSelector) YINApplication.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.getAccounts(new List<String>{accountId});

        YIN_Tax_Constants__mdt taxConstant = YIN_Tax_Constants__mdt.getInstance('Tax_Constant');
        Decimal vTCSPercentage = 0;
        Decimal vTDSPercentage = 0;
        if (accounts[0].X1H_TCS__c == false) {
            vTCSPercentage = String.isEmpty(accounts[0].PAN_Status__c) && !String.isEmpty(accounts[0].PAN_Number__c)  ? taxConstant.TCS__c : taxConstant.Invalid_PAN_TCS__c;
        } else {
            vTDSPercentage = String.isEmpty(accounts[0].PAN_Status__c) && !String.isEmpty(accounts[0].PAN_Number__c) ? taxConstant.TDS__c : taxConstant.Invalid_PAN_TDS__c;
        }

        // 3. Create Wrapper to store all information at one place
        for (PricebookEntry priceBookEntry : pricebookEntries) {
            YINProductWrapper productWrapper = new YINProductWrapper();
            productWrapper.pricebookEntry = priceBookEntry;
            productWrapper.productId = priceBookEntry.Product2Id;
            productWrapper.maximumOrderQuantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id+'-'+accounts[0].Id)?.Maximum_Order_Quantity__c;
            productWrapper.minimumOrderQuantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id+''+accounts[0].Id)?.Minimum_Order_Quantity__c;
            productWrapper.quantity = 1; // Default Quantity value when Order page loads
            productWrapper.discountPercentage = 0;
            productWrapper.frequentlyBoughtProduct = accountFrequentlyByProduct.get(priceBookEntry.Product2Id+''+accounts[0].Id)?.Status__c;
            productWrapper.lockingSKUAccount = accountProductMappingByProduct.get(priceBookEntry.Product2Id+''+accounts[0].Id)?.Status__c;
            productWrapper.lockingSKULocation = locationProductMappingByProduct.get(priceBookEntry.Product2Id+''+accounts[0].Location__c)?.Status__c;
            productWrapper.trendingSKU = locationProductsTrending.get(priceBookEntry.Product2Id+''+accounts[0].Location__c)?.Status__c;
            productWrapper.productOfTheMonth = locationProductsOfMonth.get(priceBookEntry.Product2Id+''+accounts[0].Location__c)?.Status__c;
            productWrapper.unitPrice = priceBookEntry.UnitPrice;
            productWrapper.netPrice = (1 * priceBookEntry.UnitPrice);
            productWrapper.productName = priceBookEntry.Product2.Name;
            productWrapper.productSize = priceBookEntry.Product2.Size__c;
            productWrapper.productPattern = priceBookEntry.Product2.Tread_Pattern__c;
            productWrapper.combinationKey = priceBookEntry.Product2.Product_Code__c;
            productWrapper.maximumCappingQuantity = productCappingBySize.get(priceBookEntry.Product2.Size__c)!=null?Integer.valueOf(productCappingBySize.get(priceBookEntry.Product2.Size__c).Maximum_Order_Capping__c):0;
            productWrapper.GSTPercentage = taxConstant.GST__c;
            productWrapper.tdsPercentage = vTDSPercentage;
            productWrapper.tcsPercentage = vTCSPercentage;
            productWrapper.applyTCS = accounts[0].X1H_TCS__c;
            productWrapper.locationCode = accounts[0].Location__r?.Location_Code__c;
            // Adding productWrapper to List
            if(productWrapper.frequentlyBoughtProduct!=null && productWrapper.frequentlyBoughtProduct==true){
                productWrapper.priority = 1;
            }else if(productWrapper.productOfTheMonth!=null &&  productWrapper.productOfTheMonth==true){
                productWrapper.priority = 2;
            }else if(productWrapper.trendingSKU!=null &&  productWrapper.trendingSKU==true){
                productWrapper.priority = 3;
            }else{
                productWrapper.priority = 4;
            }
            productsWrapper.add(productWrapper);
        }
        productsWrapper.sort();

        return productsWrapper;
    }

    /**
     * Retrieves the PriceBook based on the specified account.
     *
     * @param accountId - Id of the account for which the PriceBook needs to be retrieved.
     * @return List<PriceBook2> - List of PriceBook2 instances associated with the account.
     * @throws YINOrderManagementException - Custom exception thrown in case of errors during the execution.
     */
    public static List<PriceBook2> getPriceBook(String accountId) {
        try {
            List<PriceBook2> allPriceBooks = new List<PriceBook2>();
            // 1. Check for Customer PriceBook
            List<PriceBook2> priceBooks = getPriceBookByCustomer(accountId);
            if (priceBooks.size() > 0) {
                allPriceBooks.addAll(priceBooks);
            }

            // 2. Check for Customer Group PriceBook If Step 1 Fails
            List<String> customGroups = getCustomerGroupByCustomer(accountId,'price');
            priceBooks = getPriceBookByCustomerGroup(customGroups);
            if (priceBooks.size() > 0) {
                allPriceBooks.addAll(priceBooks);
            }

            // 3. Check for Common PriceBook If Step 1 & 2 Fails
            priceBooks = getCommonPriceBook();
            if (priceBooks.size() > 0) {
                allPriceBooks.addAll(priceBooks);
            }
            return allPriceBooks;
        } catch (Exception e) {
            throw new YINOrderManagementException(e.getMessage() + ' Line Number ' + e.getLineNumber());
        }
    }

    /**
     * Retrieves the PriceBook based on the specified account.
     *
     * @param accountId - Id of the account for which the PriceBook needs to be retrieved.
     * @return List<PriceBook2> - List of PriceBook2 instances associated with the account.
     * @throws YINOrderManagementException - Custom exception thrown in case of errors during the execution.
     */
    @TestVisible
    private static List<PriceBook2> getPriceBookByCustomer(String accountId) {
        YINPriceBookSelector priceBookSelector = (YINPriceBookSelector) YINApplication.selector.newInstance(PriceBook2.SObjectType);
        List<PriceBook2> pricebooks = priceBookSelector.selectPriceBookByCustomer(accountId);
        return pricebooks;
    }

    /**
     * Retrieves the PriceBook based on the specified customer groups.
     *
     * @param customerGroups - List of customer groups associated with the account.
     * @return List<PriceBook2> - List of PriceBook2 instances associated with the customer groups.
     * @throws YINOrderManagementException - Custom exception thrown in case of errors during the execution.
     */
    private static List<PriceBook2> getPriceBookByCustomerGroup(List<String> customerGroups) {
        YINPriceBookSelector priceBookSelector = (YINPriceBookSelector) YINApplication.selector.newInstance(PriceBook2.SObjectType);
        List<PriceBook2> pricebooks = priceBookSelector.selectPriceBookByCustomerGroup(customerGroups);
        return pricebooks;
    }

    /**
     * Retrieves the Common PriceBook.
     *
     * @return List<PriceBook2> - List of PriceBook2 instances associated with the common PriceBook.
     * @throws YINOrderManagementException - Custom exception thrown in case of errors during the execution.
     */
    private static List<PriceBook2> getCommonPriceBook() {
        YINPriceBookSelector priceBookSelector = (YINPriceBookSelector) YINApplication.selector.newInstance(PriceBook2.SObjectType);
        List<PriceBook2> pricebooks = priceBookSelector.priceBookbyCustomerComman();
        return pricebooks;
    }

    /**
     * Retrieves customer groups associated with the specified account.
     *
     * @param accountId - Id of the account for which customer groups need to be retrieved.
     * @return List<String> - List of customer groups associated with the account.
     * @throws YINOrderManagementException - Custom exception thrown in case of errors during the execution.
     */
    public static List<String> getCustomerGroupByCustomer(String accountId,String priceType) {
        YINAccountSelector accountSelector = (YINAccountSelector) YINApplication.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.getAccounts(new List<String>{accountId});
        List<String> customerGroups = new List<String>();
        for (Account account : accounts) {
            if(priceType=='price'){
                customerGroups.add(account.Customer_Group__c);
            }else{
                customerGroups.add(account.Customer_Discount_Price_Group__c);
            }
        }
        return customerGroups;
    }

    /**
     * Retrieves PriceBookEntries based on the specified PriceBook IDs.
     *
     * @param priceBookIds - List of PriceBook IDs for which PriceBookEntries need to be retrieved.
     * @return List<PricebookEntry> - List of PricebookEntry instances associated with the specified PriceBook IDs.
     * @throws YINOrderManagementException - Custom exception thrown in case of errors during the execution.
     */
    public static List<PricebookEntry> getPriceBookEntries(List<Id> priceBookIds) {
        try {
            YINPriceBookEntrySelector priceBookEntrySelector = (YINPriceBookEntrySelector) YINApplication.selector.newInstance(PricebookEntry.SObjectType);
            List<PricebookEntry> pricebookEntriesWithUpdatePrice = new List<PricebookEntry>();
            // 1. Get pricebookEntries from All price book (Common,Group,Customer)
            List<PricebookEntry> pricebookEntries = priceBookEntrySelector.selectPriceBookEntriesByPricebook(priceBookIds);
            System.debug('All pricebookEntries '+pricebookEntries);
            Map<String,List<PricebookEntry>> entriesOfPriceBook = new Map<String,List<PricebookEntry>>();
            Map<String,PricebookEntry> groupEntriesOfPriceBook = new Map<String,PricebookEntry>();
            Map<String,PricebookEntry> customerEntriesOfPriceBook = new Map<String,PricebookEntry>();
           
            // 2. Map based on type of PriceBooks and its related entries
            for(PricebookEntry entries:pricebookEntries){
                if (!entriesOfPriceBook.containsKey(entries.Pricebook2.Type__c)) {
                    entriesOfPriceBook.put(entries.Pricebook2.Type__c, new List<PricebookEntry>());
                }
                System.debug('Type '+entries.Pricebook2.Type__c);
                entriesOfPriceBook.get(entries.Pricebook2.Type__c).add(entries);
            }
            // 3. Getting Entries of Customers and Group customers and preparing map based on productcode key and its entrie
            List<PricebookEntry> commonPriceBookEntries = entriesOfPriceBook.get('All Customer');
            List<PricebookEntry> groupPriceBookEntries = entriesOfPriceBook.get('Customer Price Group');
            System.debug('commonPriceBookEntries '+commonPriceBookEntries);
            System.debug('groupPriceBookEntries '+groupPriceBookEntries);
            if(groupPriceBookEntries!=null){
                for(PricebookEntry entries:groupPriceBookEntries){
                    groupEntriesOfPriceBook.put(entries.Product2.Product_Code__c,entries);
                }
            }
            List<PricebookEntry> customerPriceBookEntries = entriesOfPriceBook.get('Customer');
            if(customerPriceBookEntries!=null){
                for(PricebookEntry entries:customerPriceBookEntries){
                    customerEntriesOfPriceBook.put(entries.Product2.Product_Code__c,entries);
                }
            }
            // 4. virtually updating price in common price book entries
            if(commonPriceBookEntries!=null){
            for(PricebookEntry entries: commonPriceBookEntries){
                entries.Sales_Price__c = entries.UnitPrice;
                // A. If product found in groupPriceBook update unit price 
                PricebookEntry entriesOfGroup = groupEntriesOfPriceBook.get(entries.Product2.Product_Code__c);
                if(entriesOfGroup!=null){
                    entries.Sales_Price__c = entriesOfGroup.UnitPrice;
                }
                // B. If product found in customerPriceBook update unit price 
                PricebookEntry entriesOfCustomer = customerEntriesOfPriceBook.get(entries.Product2.Product_Code__c);
                if(entriesOfCustomer!=null){
                    entries.Sales_Price__c = entriesOfCustomer.UnitPrice;
                }
                pricebookEntriesWithUpdatePrice.add(entries);
            }
            }

            return pricebookEntriesWithUpdatePrice;
        } catch (Exception e) {
            throw new YINOrderManagementException(e.getMessage()+' '+e.getLineNumber());
        }
    }
}