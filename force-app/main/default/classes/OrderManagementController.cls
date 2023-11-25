/*
Apex Class Name    : OrderManagementController
Created Date       : Nov 16, 2023
@description       : This is class is used for handling LWC request.
@author            : Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
*/
public with sharing class OrderManagementController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getExperienceUserProfiles(){
        return new List<String>{'DMS','Customer Service'}; // TODO: This is to be Dynamic
    }

    @AuraEnabled(cacheable=true)
    public static User getCurrentUser(){
        User user = [select id,Profile.Name from User where Id=:Userinfo.getUserId()];
        return user;
    }

    @AuraEnabled
    public static string getExperienceUserAccount(){
        try {
            String contactId = [Select contactid from User where id =: Userinfo.getUserid()].contactId;
            String accountId  = [Select AccountID from Contact where id =: contactId].AccountId;
            return accountId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    @param accountId : Account or Customer Id
    @param OrderType : Type of Order, like Discount,Promotional, etc..
    */
    @AuraEnabled
    public static List<ProductWrapper> getProducts(String accountId,String OrderType){ 
        try {
            // Get class for which Instance should create by OrderType
            PriceBookImplByType__mdt metaDataConfig = PriceBookImplByType__mdt.getInstance(OrderType);

            // Create Instance of Class Dynamically
            Type apiClassName  = Type.forName(metaDataConfig.Class_Name__c);
            if (apiClassName != null) {
                IGetProducts classInstance  = (IGetProducts)apiClassName.newInstance();
                if (classInstance != null) {

                    // Calling GetProduct implementations
                    List<ProductWrapper> productsWrapper = classInstance.getProducts(accountId);
                    return productsWrapper;
                } else {
                    System.debug('Failed to create an instance of the class.');
                    return null;
                }
            }else{
                System.debug('Failed to find MetaData Configurations');
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Commented because Cart__c Object is not created Yet
    @AuraEnabled
    public static boolean addToCart(String productWrapper,String accountId){
        try {
            // 1. Get Cart of Current Account
            List<Cart__c> carts = [select Id,Name from Cart__c where Account__c=accountId limit 1];

            // 2. convert JSON to Apex class
            ProductWrapper wrapperProduct = (ProductWrapper)JSON.deserialize(productWrapper,ProductWrapper.class);
            if(carts.size()>0){
                
                // 3. Add Product Wrapper to Cart Line Item and Create Cart Line Item
                return addToCartLineItem(carts[0].Id,wrapperProduct);
            }else{

                // 3. Create a New Cart for Current Account
                Cart__c cart = new Cart();
                cart.Account__c = accountId;
                    // add Some Extra field

                Database.SaveResult result =Database.insert(cart,wrapperProduct);
                if(result.isSuccess()){
                    // 4. Add Product Wrapper to Cart Line Item and Create Cart Line Item
                    return addToCartLineItem(result.getId(),)
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    /* Commented because CartLineItem__c Object is not created Yet
    @AuraEnabled
    public static List<CartLineItem__c> getCartDetails(String accountId){
        try {
            // 1. Get CartLineItem__c By Account Id
            return new List<CartLineItem__c>();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    */
    @AuraEnabled
    public static string getCreditLimits(String accountId){
        try {
            // 1. Get Credit Limits from Api
            // return them in JSON String format
            String jsonCreditLimits = '';
            return jsonCreditLimits;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }  
    }

    /* Commented because Order__c Object is not created Yet
    @AuraEnabled
    public static Order__c createOrder(String accountId){
        try {
            // 1. convert cart and cartLineItem to Order and OrderLineItem
            return new Order__c();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    */

    /* Commented because CartLineItem__c Object is not created Yet
    private static boolean addToCartLineItem(Id cartId,ProductWrapper wrapperProduct){
        CartLineItem__c lineItem = new CartLineItem__c();
        lineItem.Product__c = wrapperProduct.Product__c;
        // Add Some extra fields..
        lineItem.cartId = cartId;
        Database.SaveResult result = Database.insert(lineItem);
        return result.isSuccess();
    }
    */

    
    
    

/*
    *********************************************************
    @Method Name    : getPriceBook
    @description    : method will return priceBook for given Account, It will check in different type of price book i.e (Customer, Customer Group and common)
    @param          : String : accountId
    @return         : Output
    ********************************************************
*/
   
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
        List<PriceBook2>  priceboooks = [select id,Customer__c,Customer_Group__c,IsDiscount__c,Type__c,Combination_Key__c,IsActive from PriceBook2 where Customer__c=:accountId and Type__c='Customer' and IsActive=true];
        return priceboooks;
    }

    private static List<PriceBook2> getPriceBookByCustomerGroup(List<String> customerGroups){
        List<PriceBook2>  priceboooks = [select id,Customer__c,Customer_Group__c,IsDiscount__c,Type__c,Combination_Key__c,IsActive from PriceBook2 where Customer_Group__c IN:customerGroups and Type__c='Customer Group'  and IsActive=true];
        return priceboooks;
    }

    private static List<PriceBook2> getCommonPriceBook(){
        List<PriceBook2>  priceboooks = [select id,Customer__c,Customer_Group__c,IsDiscount__c,Type__c,Combination_Key__c,IsActive from PriceBook2 where Customer_Group__c=null and Customer__c=null and Type__c='Common'  and IsActive=true];
        return priceboooks;
    }

    private static List<String> getCustomerGroupByCustomer(String accountId){
        List<Account>  accounts = [select id,Name,Customer_Group__c from Account where Id=:accountId limit 1];
        List<String> customerGroups = new List<String>();
        for(Account acount:accounts){
            customerGroups.add(acount.Customer_Group__c);
        }
        return customerGroups;
    }

    private static List<PricebookEntry> getPriceBookEntries(List<Id> priceBookIds){
        try {
            List<PricebookEntry> pricebookEntries = [SELECT Id, Name,Name__c, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, UseStandardPrice, ProductCode, Sales_Price__c, End_Date__c, Start_Date__c, Combination_Key__c FROM PricebookEntry where IsActive=true and Pricebook2Id IN:priceBookIds];
            return pricebookEntries;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}