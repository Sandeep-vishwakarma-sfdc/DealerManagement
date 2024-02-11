@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields')
public with sharing class YINProductWrapper implements Comparable{

    @AuraEnabled public Id  orderItemId;

    @AuraEnabled public PricebookEntry  pricebookEntry; // for Normal product
    @AuraEnabled public YIN_Price_List__c  priceList; // for Discount Product
    @AuraEnabled public Id  productId;
    @AuraEnabled public String discountType;
    @AuraEnabled public Boolean  productOfTheMonth;
    @AuraEnabled public Boolean  frequentlyBoughtProduct;
    @AuraEnabled public Boolean  trendingSKU;
    @AuraEnabled public Boolean  lockingSKUAccount; // If it is true then product will lock.
    @AuraEnabled public Boolean  lockingSKULocation; // If it is true then product will lock.
    @AuraEnabled public Integer  maximumCappingQuantity; // set limit on quantity of SKU Depends on Size.
    @AuraEnabled public Decimal  maximumOrderQuantity;
    @AuraEnabled public Decimal  minimumOrderQuantity;
    @AuraEnabled public Decimal  quantity; // Editable by User
    
    @AuraEnabled public String  productName;
    @AuraEnabled public String  productSize;
    @AuraEnabled public String  productPattern;
    
    @AuraEnabled public Decimal  discountPercentage;
    @AuraEnabled public Decimal  unitPrice; // Actual Product Price for 1 Quantity
    @AuraEnabled public Decimal  netPrice; // SUM of Unit Price (Quantity will be changed by UI(LWC) and hence netPrice will Calculated on LWC )
    @AuraEnabled public Decimal  totalAmount;

    
    @AuraEnabled public Decimal  gstPercentage; // This is GST Percentage
    @AuraEnabled public Decimal  gstAmount;
    @AuraEnabled public Decimal  tdsPercentage;
    @AuraEnabled public Decimal  tcsPercentage;

    @AuraEnabled public Id  variantId; // use to map Discount Product and Cart Item
    @AuraEnabled public String  variantCode;
    @AuraEnabled public Boolean  applyTCS;

    @AuraEnabled public String  locationCode;// Customer Location Code
    
    @AuraEnabled public List<DiscountTable> discountTable;
    /*
        "For Normal Product" : Combination key will be product_code__c i.e combinationKey = product_code__c

        "For Discounted Product" : Combination key will be combination of product_code__c,Varient_code__c and minimum_Order_Quantity__c i.e combinationKey = product_code__c + Varient_code__c + Minimum_Quantity__c
     */
    @AuraEnabled public String  combinationKey; // Combination of product_code__c + Varient_code__c

    public class DiscountTable{
        @AuraEnabled public Decimal minimumOrderQuantity;
        @AuraEnabled public Decimal discountPercentage;
    }

    public Integer compareTo(Object compareTo){
        YINProductWrapper warpper = (YINProductWrapper) compareTo;
        Integer returnValue = 0;
        if(frequentlyBoughtProduct == false || frequentlyBoughtProduct==null){
            return 1;
        }else if(frequentlyBoughtProduct == true){
            return -1;
        }  
        return returnValue;     
    }
}