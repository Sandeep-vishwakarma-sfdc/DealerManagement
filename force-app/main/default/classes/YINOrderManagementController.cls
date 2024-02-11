/*
Apex Class Name    : OrderManagementController
Created Date       : Nov 16, 2023
@description       : This is class is used for handling LWC request.
@author            : Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
*/

public without sharing class YINOrderManagementController {

    private static YINIOrderManagement orderService;

    static {
        orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getExperienceUserProfiles(){
        return orderService.getExperienceUserProfiles();
    }

    @AuraEnabled
    public static string getObjectApiName(String recordId){
        return orderService.getObjectApiName(recordId);
    }

    @AuraEnabled
    public static List<Order> getOrderDetails(String recordId){
        return orderService.getOrderDetails(recordId);
    }

    @AuraEnabled(cacheable=true)
    public static User getCurrentUser(){
        return orderService.getCurrentUser();
    }

    @AuraEnabled
    public static string getExperienceUserAccount(){
        return orderService.getExperienceUserAccount();
    }

    @AuraEnabled
    public static Account getAccount(String accountId){
        return orderService.getAccount(accountId);
    }

    /*
    @param accountId : Account or Customer Id
    @param OrderType : Type of Order, like Discount,Promotional, etc..
    */
    @AuraEnabled
    public static List<YINProductWrapper> getProducts(String accountId,String orderType,String orderModuleType){ 
        return orderService.getProducts(accountId,OrderType,orderModuleType);
    }

    @AuraEnabled
    public static boolean addToCart(String productWrapper,String accountId,String openOrderId){
        return orderService.addToCart(productWrapper,accountId,openOrderId);
    }

    @AuraEnabled
    public static List<YINProductWrapper> getCartDetails(String accountId,String openOrderId){
        return orderService.getCartDetails(accountId,openOrderId);
    }
    
   

    @AuraEnabled
    public static string deleteCartItem(String productWrapper,String accountId,String openOrderId){
        return orderService.deleteCartItem(productWrapper,accountId,openOrderId);
    }

    @AuraEnabled
    public static List<Account> getShippingAccounts(String accountId){
        return orderService.getShippingAccounts(accountId);
    }

    @AuraEnabled
    public static String createOrder(String productWrapper,String wrapCommit){
        return orderService.createOrder(productWrapper,wrapCommit);
    }
}