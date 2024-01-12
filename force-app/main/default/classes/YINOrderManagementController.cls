/*
Apex Class Name    : OrderManagementController
Created Date       : Nov 16, 2023
@description       : This is class is used for handling LWC request.
@author            : Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
*/

public with sharing class YINOrderManagementController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getExperienceUserProfiles(){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        return orderService.getExperienceUserProfiles();
    }

    @AuraEnabled(cacheable=true)
    public static User getCurrentUser(){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        return orderService.getCurrentUser();
    }

    @AuraEnabled
    public static string getExperienceUserAccount(){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        return orderService.getExperienceUserAccount();
    }

    @AuraEnabled
    public static Account getAccount(String accountId){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        return orderService.getAccount(accountId);
    }

    /*
    @param accountId : Account or Customer Id
    @param OrderType : Type of Order, like Discount,Promotional, etc..
    */
    @AuraEnabled
    public static List<YINProductWrapper> getProducts(String accountId,String orderType){ 
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        return orderService.getProducts(accountId,OrderType);
    }

    @AuraEnabled
    public static boolean addToCart(String productWrapper,String accountId){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        return orderService.addToCart(productWrapper,accountId);
    }

    @AuraEnabled
    public static List<YINProductWrapper> getCartDetails(String accountId){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        return orderService.getCartDetails(accountId);
    }
    
    @AuraEnabled
    public static string getCreditLimits(String accountId){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        return orderService.getCreditLimits(accountId);
    }

    @AuraEnabled
    public static string deleteCartItem(String productWrapper,String accountId){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        return orderService.deleteCartItem(productWrapper,accountId);
    }

    @AuraEnabled
    public static List<Account> getShippingAccounts(String accountId){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        return orderService.getShippingAccounts(accountId);
    }

    @AuraEnabled
    public static String createOrder(String productWrapper,String accountId,Decimal grandTotal){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        return orderService.createOrder(productWrapper,accountId,grandTotal);
    }
    
}