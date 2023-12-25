/*
Apex Class Name    : ProductWrapper
Created Date       : Nov 16, 2023
@description       : This is class is used for wrapping some properties from different objects.
@author            : Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
*/
public with sharing class ProductWrapper {
    @AuraEnabled public PricebookEntry  pricebookEntry; // for Normal product
    @AuraEnabled public Price_List__c  priceList; // for Discount Product
    @AuraEnabled public Id  productId;
    @AuraEnabled public String discountType;
    @AuraEnabled public Boolean  productOfTheMonth;
    @AuraEnabled public Boolean  trendingSKU;
    @AuraEnabled public Boolean  lockingSKU; // If it is true then product will lock.
    @AuraEnabled public Boolean  cappingSKU; // set limit on quantity of SKU.
    @AuraEnabled public Decimal  maximum_Order_Quantity;
    @AuraEnabled public Decimal  minimum_Order_Quantity;
    @AuraEnabled public Decimal  quantity; // Editable by User
    @AuraEnabled public Decimal  discountPercentage;
    @AuraEnabled public Decimal  lineItemSubTotal;
    @AuraEnabled public Decimal  GSTPercentage; // This is GST Percentage

    /*
        "For Normal Product" : Combination key will be product_code__c i.e combinationKey = product_code__c

        "For Discounted Product" : Combination key will be combination of product_code__c,Varient_code__c and minimum_Order_Quantity__c i.e combinationKey = product_code__c + Varient_code__c + Minimum_Quantity__c
     */
    @AuraEnabled public String  combinationKey; // Combination of product_code__c + Varient_code__c
}