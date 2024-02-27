@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields')
/**
 * YINProductWrapper - A wrapper class for representing product details in the YINOrderManagement system.
 *
 * Description: This class encapsulates information related to a product, including its ID, pricebook entry,
 * price list, discount type, and various attributes. It is designed to be used within the context of the
 * YINOrderManagement system for handling order-related functionalities.
 *
 * Access: This class is declared as "public with sharing" to enforce sharing rules when interacting with data,
 * making it suitable for scenarios where sharing rules need to be considered.
 */
public with sharing class YINProductWrapper implements Comparable {

    /**
     * Order Item Id associated with the product.
     */
    @AuraEnabled
    public Id orderItemId;

    /**
     * Pricebook entry for normal products.
     */
    @AuraEnabled
    public PricebookEntry pricebookEntry;

    /**
     * Price list for discount products.
     */
    @AuraEnabled
    public YIN_Price_List__c priceList;

    /**
     * Product Id.
     */
    @AuraEnabled
    public Id productId;

    /**
     * Type of discount associated with the product.
     */
    @AuraEnabled
    public String discountType;

    /**
     * Indicates whether the product is the product of the month.
     */
    @AuraEnabled
    public Boolean productOfTheMonth;

    /**
     * Indicates whether the product is frequently bought.
     */
    @AuraEnabled
    public Boolean frequentlyBoughtProduct;

    /**
     * Indicates whether the product is a trending SKU.
     */
    @AuraEnabled
    public Boolean trendingSKU;

    /**
     * If true, the product will be locked at the account level.
     */
    @AuraEnabled
    public Boolean lockingSKUAccount;

    /**
     * If true, the product will be locked at the location level.
     */
    @AuraEnabled
    public Boolean lockingSKULocation;

    /**
     * Maximum quantity allowed for the SKU, dependent on size.
     */
    @AuraEnabled
    public Integer maximumCappingQuantity;

    /**
     * Maximum order quantity allowed.
     */
    @AuraEnabled
    public Decimal maximumOrderQuantity;

    /**
     * Minimum order quantity allowed.
     */
    @AuraEnabled
    public Decimal minimumOrderQuantity;

    /**
     * Editable quantity for the product, modified by the user.
     */
    @AuraEnabled
    public Decimal quantity;

    /**
     * Name of the product.
     */
    @AuraEnabled
    public String productName;

    /**
     * Size of the product.
     */
    @AuraEnabled
    public String productSize;

    /**
     * Pattern of the product.
     */
    @AuraEnabled
    public String productPattern;

    /**
     * Discount percentage applicable to the product.
     */
    @AuraEnabled
    public Decimal discountPercentage;

    /**
     * Actual unit price of the product for one quantity.
     */
    @AuraEnabled
    public Decimal unitPrice;

    /**
     * Net price calculated based on the unit price and user-modified quantity.
     */
    @AuraEnabled
    public Decimal netPrice;

    /**
     * Total amount calculated based on the net price.
     */
    @AuraEnabled
    public Decimal totalAmount;

    /**
     * GST (Goods and Services Tax) percentage applicable to the product.
     */
    @AuraEnabled
    public Decimal gstPercentage;

    /**
     * GST amount calculated based on the net order value and GST percentage.
     */
    @AuraEnabled
    public Decimal gstAmount;

    /**
     * TDS (Tax Deducted at Source) percentage applicable to the product.
     */
    @AuraEnabled
    public Decimal tdsPercentage;

    /**
     * TCS (Tax Collected at Source) percentage applicable to the product.
     */
    @AuraEnabled
    public Decimal tcsPercentage;

    /**
     * Variant Id associated with the product, used to map discount products and cart items.
     */
    @AuraEnabled
    public Id variantId;

    /**
     * Variant code associated with the product.
     */
    @AuraEnabled
    public String variantCode;

    /**
     * Indicates whether TCS should be applied to the product.
     */
    @AuraEnabled
    public Boolean applyTCS;

    /**
     * Location code of the customer.
     */
    @AuraEnabled
    public String locationCode;

    /**
     * List of discount table entries, specifying minimum order quantity and corresponding discount percentage.
     */
    @AuraEnabled
    public List<DiscountTable> discountTable;

    /**
     * Combination key of product code and variant code.
     */
    @AuraEnabled
    public String combinationKey;

    /**
     * DiscountTable - Inner class representing entries in the discount table.
     */
    public class DiscountTable {

        /**
         * Minimum order quantity for the discount entry.
         */
        @AuraEnabled
        public Decimal minimumOrderQuantity;

        /**
         * Discount percentage for the specified minimum order quantity.
         */
        @AuraEnabled
        public Decimal discountPercentage;
    }

    /**
     * Implementation of the Comparable interface to enable sorting of YINProductWrapper instances.
     *
     * @param compareTo - Object to compare with.
     * @return Integer - Result of the comparison.
     */
    public Integer compareTo(Object compareTo) {
        YINProductWrapper wrapper = (YINProductWrapper) compareTo;
        Integer returnValue = 0;

        // Sort frequently bought products first
        if (frequentlyBoughtProduct == false || frequentlyBoughtProduct == null) {
            return 1;
        }else if (trendingSKU == false) {
            return 1;
        } else if (productOfTheMonth == false) {
            return 1;
        }else if(frequentlyBoughtProduct==true || productOfTheMonth==true || trendingSKU==true){
            return -1;
        }

        return returnValue;
    }
}