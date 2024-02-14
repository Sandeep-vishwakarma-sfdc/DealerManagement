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

        Map<Id, YIN_Account_product_Mapping__c> accountProductMappingByProduct = new Map<Id, YIN_Account_product_Mapping__c>();
        Map<Id, YIN_Account_product_Mapping__c> locationProductMappingByProduct = new Map<Id, YIN_Account_product_Mapping__c>();
        Map<Id, YIN_Account_product_Mapping__c> locationProductByProduct = new Map<Id, YIN_Account_product_Mapping__c>();
        Map<Id, YIN_Account_product_Mapping__c> locationFrequentlyByProduct = new Map<Id, YIN_Account_product_Mapping__c>();

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
                    accountProductMappingByProduct.put(accountProduct.Product__c, accountProduct);
                }
                when 'Locking Location Product' {
                    locationProductMappingByProduct.put(accountProduct.Product__c, accountProduct);
                }
                when 'Trending Products' {
                    locationProductsTrending.put(accountProduct.Product__c, accountProduct);
                }
                when 'Product of the Month' {
                    locationProductsOfMonth.put(accountProduct.Product__c, accountProduct);
                }
                when 'Frequently Bought Product' {
                    locationFrequentlyByProduct.put(accountProduct.Product__c, accountProduct);
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

        Tax_Constants__mdt taxConstant = Tax_Constants__mdt.getInstance('Tax_Constant');
        Decimal vTCSPercentage = 0;
        Decimal vTDSPercentage = 0;
        if (accounts[0].X1H_TCS__c == true) {
            vTCSPercentage = accounts[0].PAN_Status__c == 'Valid' ? taxConstant.TCS__c : taxConstant.Invalid_PAN_TCS__c;
        } else {
            vTDSPercentage = accounts[0].PAN_Status__c == 'Valid' ? taxConstant.TDS__c : taxConstant.Invalid_PAN_TDS__c;
        }

        // 3. Create Wrapper to store all information at one place
        for (PricebookEntry priceBookEntry : pricebookEntries) {
            YINProductWrapper productWrapper = new YINProductWrapper();
            productWrapper.pricebookEntry = priceBookEntry;
            productWrapper.productId = priceBookEntry.Product2Id;
            productWrapper.maximumOrderQuantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Maximum_Order_Quantity__c;
            productWrapper.minimumOrderQuantity = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Minimum_Order_Quantity__c;
            productWrapper.quantity = 1; // Default Quantity value when Order page loads
            productWrapper.discountPercentage = 0;
            productWrapper.frequentlyBoughtProduct = locationFrequentlyByProduct.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.lockingSKUAccount = accountProductMappingByProduct.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.lockingSKULocation = locationProductMappingByProduct.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.trendingSKU = locationProductsTrending.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.productOfTheMonth = locationProductsOfMonth.get(priceBookEntry.Product2Id)?.Status__c;
            productWrapper.unitPrice = priceBookEntry.UnitPrice;
            productWrapper.netPrice = (1 * priceBookEntry.UnitPrice);
            productWrapper.productName = priceBookEntry.Product2.Name;
            productWrapper.productSize = priceBookEntry.Product2.Size__c;
            productWrapper.productPattern = priceBookEntry.Product2.Tread_Pattern__c;
            productWrapper.combinationKey = priceBookEntry.Product2.Product_Code__c;
            productWrapper.maximumCappingQuantity = Integer.valueOf(productCappingBySize.get(priceBookEntry.Product2.Size__c).Maximum_Order_Capping__c);
            productWrapper.GSTPercentage = taxConstant.GST__c;
            productWrapper.tdsPercentage = vTDSPercentage;
            productWrapper.tcsPercentage = vTCSPercentage;
            productWrapper.applyTCS = accounts[0].X1H_TCS__c;
            productWrapper.locationCode = accounts[0].Location__r?.Location_Code__c;
            // Adding productWrapper to List
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
            // 1. Check for Customer PriceBook
            List<PriceBook2> priceBooks = getPriceBookByCustomer(accountId);
            if (priceBooks.size() > 0) {
                return priceBooks;
            }

            // 2. Check for Customer Group PriceBook If Step 1 Fails
            List<String> customGroups = getCustomerGroupByCustomer(accountId);
            priceBooks = getPriceBookByCustomerGroup(customGroups);
            if (priceBooks.size() > 0) {
                return priceBooks;
            }

            // 3. Check for Common PriceBook If Step 1 & 2 Fails
            priceBooks = getCommonPriceBook();
            if (priceBooks.size() > 0) {
                return priceBooks;
            }
            return null;
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
    public static List<String> getCustomerGroupByCustomer(String accountId) {
        YINAccountSelector accountSelector = (YINAccountSelector) YINApplication.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.getAccounts(new List<String>{accountId});
        List<String> customerGroups = new List<String>();
        for (Account account : accounts) {
            customerGroups.add(account.Customer_Group__c);
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
            List<PricebookEntry> pricebookEntries = priceBookEntrySelector.selectPriceBookEntriesByPricebook(priceBookIds);
            return pricebookEntries;
        } catch (Exception e) {
            throw new YINOrderManagementException(e.getMessage());
        }
    }
}
