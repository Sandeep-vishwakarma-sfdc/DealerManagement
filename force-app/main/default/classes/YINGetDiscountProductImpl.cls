/**
 * YINGetDiscountProductImpl - Implementation class for YINIGetProducts interface responsible for retrieving
 * discounted product details for a given account in the YINOrderManagement system.
 *
 * Description: This class extends the functionality of YINIGetProducts by providing methods to fetch
 * discounted product details. It brings together normal and discounted products, applies appropriate
 * discounts, and organizes the data into YINProductWrapper instances.
 *
 * Access: This class is declared as "public with sharing" to enforce sharing rules when interacting with data,
 * making it suitable for scenarios where sharing rules need to be considered.
 */
public with sharing class YINGetDiscountProductImpl implements YINIGetProducts {

    /**
     * Retrieves a list of YINProductWrapper instances containing discounted product details for the specified account.
     *
     * @param accountId - Id of the account for which discounted products need to be retrieved.
     * @return List<YINProductWrapper> - List of YINProductWrapper instances containing discounted product details.
     */
    public List<YINProductWrapper> getProducts(String accountId) {

        // 1. Bring all Normal Products in a wrapper (let's say productWrappers)
        List<YINProductWrapper> productWrappers = new YINGetAllProductImpl().getProducts(accountId);

        // 2. Bring all Discounted Products in a wrapper (let's say discountedPriceList)
        List<YIN_Price_List__c> discountedPriceList = getDiscountedPriceList(accountId);

        // 3. Store Product and its related prices in a Map
        Map<String, List<YIN_Price_List__c>> priceListByProductId = new Map<String, List<YIN_Price_List__c>>();
        for (YIN_Price_List__c price : discountedPriceList) {
            if (!priceListByProductId.containsKey(price.Product__c)) {
                priceListByProductId.put(price.Product__c, new List<YIN_Price_List__c>());
            }
            priceListByProductId.get(price.Product__c).add(price);
        }

        // 4. Filter productWrappers to minimize search processing time
        List<YINProductWrapper> newProductWrapper = new List<YINProductWrapper>();
        for (YINProductWrapper originalWrapper : productWrappers) {
            if (priceListByProductId.containsKey(originalWrapper.productId)) {
                // Adding productWrapper Which has Product same as PriceList
                newProductWrapper.add(originalWrapper);
            }
        }

        // 5. Finally creating Discounted Products
        List<YINProductWrapper> discountProductWrappersWithDiscounts = getDiscountedItems(newProductWrapper, priceListByProductId);

        return discountProductWrappersWithDiscounts;
    }

    /**
     * Retrieves discounted products based on the given product wrappers and price list by product ID.
     *
     * @param newProductWrapper - List of product wrappers with normal product details.
     * @param priceListByProductId - Map storing price list details by product ID.
     * @return List<YINProductWrapper> - List of YINProductWrapper instances containing discounted product details.
     */
    private static List<YINProductWrapper> getDiscountedItems(List<YINProductWrapper> newProductWrapper, Map<String, List<YIN_Price_List__c>> priceListByProductId) {
        List<YINProductWrapper> discountProductWrappers = new List<YINProductWrapper>();
        Map<String, List<YINProductWrapper.DiscountTable>> discountProductWrappersByKey = new Map<String, List<YINProductWrapper.DiscountTable>>();

        for (YINProductWrapper originalWrapper : newProductWrapper) {
            List<YIN_Price_List__c> prices = priceListByProductId.get(originalWrapper.productId);
            if (prices.size() > 0) {
                for (YIN_Price_List__c price : prices) {
                    YINProductWrapper discountWrapper = new YINProductWrapper();

                    // Copying common attributes from original wrapper
                    discountWrapper.pricebookEntry = originalWrapper.pricebookEntry;
                    discountWrapper.productId = originalWrapper.productId;
                    discountWrapper.productOfTheMonth = originalWrapper.productOfTheMonth;
                    discountWrapper.trendingSKU = originalWrapper.trendingSKU;
                    discountWrapper.lockingSKUAccount = originalWrapper.lockingSKUAccount;
                    discountWrapper.lockingSKULocation = originalWrapper.lockingSKULocation;
                    discountWrapper.maximumOrderQuantity = originalWrapper.maximumOrderQuantity;
                    discountWrapper.quantity = originalWrapper.quantity;
                    discountWrapper.unitPrice = originalWrapper.unitPrice;

                    // Copying discounted attributes from price list
                    discountWrapper.discountPercentage = price.Discount_Price__c;// TODO : Add Discount Percentage insted of Dicount Price
                    discountWrapper.discountType = price.Discount_Type__c;
                    discountWrapper.priceList = price;
                    discountWrapper.productName = originalWrapper.productName;
                    discountWrapper.productSize = originalWrapper.productSize;
                    discountWrapper.productPattern = originalWrapper.productPattern;
                    discountWrapper.minimumOrderQuantity = price.Minimum_Quantity__c;
                    discountWrapper.combinationKey = price.Product__r.Product_Code__c + price.Variant__r.Variant_Code__c;
                    discountWrapper.maximumCappingQuantity = originalWrapper.maximumCappingQuantity;

                    // Copying remaining attributes from original wrapper
                    discountWrapper.GSTPercentage = originalWrapper.GSTPercentage;
                    discountWrapper.tdsPercentage = originalWrapper.tdsPercentage;
                    discountWrapper.tcsPercentage = originalWrapper.tcsPercentage;
                    discountWrapper.locationCode = originalWrapper.locationCode;
                    discountWrapper.variantCode = price.Variant__r.Variant_Code__c;
                    discountWrapper.applyTCS = originalWrapper.applyTCS;

                    discountProductWrappers.add(discountWrapper);

                    // Building discountProductWrappersByKey map for later reference
                    if (!discountProductWrappersByKey.containsKey(price.Product__r.Product_Code__c + price.Variant__r.Variant_Code__c)) {
                        discountProductWrappersByKey.put(price.Product__r.Product_Code__c + price.Variant__r.Variant_Code__c, new List<YINProductWrapper.DiscountTable>());
                    }

                    YINProductWrapper.DiscountTable table = new YINProductWrapper.DiscountTable();
                    table.minimumOrderQuantity = price.Minimum_Quantity__c;
                    table.discountPercentage = price.Discount_Price__c;
                    discountProductWrappersByKey.get(price.Product__r.Product_Code__c + price.Variant__r.Variant_Code__c).add(table);
                }
            }
        }

        // Removing duplicate entries based on combinationKey
        List<YINProductWrapper> discountProductWrappersWithDiscounts = new List<YINProductWrapper>();
        Set<String> checkDuplicates = new Set<String>();
        for (YINProductWrapper discountWrapper : discountProductWrappers) {
            if (checkDuplicates.add(discountWrapper.combinationKey)) {
                discountWrapper.discountTable = discountProductWrappersByKey.get(discountWrapper.combinationKey);
                discountProductWrappersWithDiscounts.add(discountWrapper);
            }
        }

        return discountProductWrappersWithDiscounts;
    }

    /**
     * Retrieves discounted price list based on the specified account.
     *
     * @param accountId - Id of the account for which discounted price list needs to be retrieved.
     * @return List<YIN_Price_List__c> - List of YIN_Price_List__c instances containing discounted price details.
     */
    public static List<YIN_Price_List__c> getDiscountedPriceList(String accountId) {
        List<YIN_Price_List__c> priceList = new List<YIN_Price_List__c>();

        // 1. Check for customer price list
        priceList = getPriceListByCustomer(accountId);
        if (priceList.size() > 0) {
            return priceList;
        }

        // 2. Check for customer group price list
        List<String> customerGroups = YINGetAllProductImpl.getCustomerGroupByCustomer(accountId);
        priceList = getPriceListByCustomerGroup(customerGroups);
        if (priceList.size() > 0) {
            return priceList;
        }

        // 3. Check for common price list
        priceList = getCommonPriceList();
        return priceList;
    }

    /**
     * Retrieves discounted price list based on the specified customer.
     *
     * @param accountId - Id of the account for which discounted price list needs to be retrieved.
     * @return List<YIN_Price_List__c> - List of YIN_Price_List__c instances containing discounted price details.
     */
    private static List<YIN_Price_List__c> getPriceListByCustomer(String accountId) {
        YINPriceListSelector priceListSelector = (YINPriceListSelector) YINApplication.selector.newInstance(YIN_Price_List__c.SObjectType);
        List<YIN_Price_List__c> priceList = priceListSelector.selectPriceListByCustomer(accountId);
        return priceList;
    }

    /**
     * Retrieves discounted price list based on the specified customer groups.
     *
     * @param customerGroups - List of customer groups associated with the account.
     * @return List<YIN_Price_List__c> - List of YIN_Price_List__c instances containing discounted price details.
     */
    private static List<YIN_Price_List__c> getPriceListByCustomerGroup(List<String> customerGroups) {
        YINPriceListSelector priceListSelector = (YINPriceListSelector) YINApplication.selector.newInstance(YIN_Price_List__c.SObjectType);
        List<YIN_Price_List__c> priceList = priceListSelector.selectPriceListByCustomerGroup(customerGroups);
        return priceList;
    }

    /**
     * Retrieves common discounted price list.
     *
     * @return List<YIN_Price_List__c> - List of YIN_Price_List__c instances containing discounted price details.
     */
    private static List<YIN_Price_List__c> getCommonPriceList() {
        YINPriceListSelector priceListSelector = (YINPriceListSelector) YINApplication.selector.newInstance(YIN_Price_List__c.SObjectType);
        List<YIN_Price_List__c> priceList = priceListSelector.selectCommonPriceList();
        return priceList;
    }
}
