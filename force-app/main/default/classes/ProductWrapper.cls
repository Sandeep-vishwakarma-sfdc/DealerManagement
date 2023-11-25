/*
Apex Class Name    : ProductWrapper
Created Date       : Nov 16, 2023
@description       : This is class is used for wrapping some properties from different objects.
@author            : Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
*/
public with sharing class ProductWrapper {
    @AuraEnabled public PricebookEntry  pricebookEntry;
    @AuraEnabled public Id  productId;
    @AuraEnabled public Boolean  weekOfTheSKU;
    @AuraEnabled public Boolean  trendingSKU;
    @AuraEnabled public Boolean  lockingSKU; // If it is true then product will lock.
    @AuraEnabled public Boolean  cappingSKU; // set limit on quantity of SKU.
    @AuraEnabled public Integer  quantity; // Editable by User
}