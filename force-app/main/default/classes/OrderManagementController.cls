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

    @AuraEnabled
    public static Account getAccount(String accountId){
        try {
            Account account = [Select Id, Name, BillingCity, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, Phone, Website from Account where Id=:accountId];
            return account;
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

    @AuraEnabled
    public static boolean addToCart(String productWrapper,String accountId){
        try {
            // 1. Get Cart of Current Account
            List<Order> cartOrders = [select Id,Name,Order_Status__c from Order where AccountId=:accountId and Status='Draft' limit 1];

            // 2. convert JSON to Apex class
            ProductWrapper wrapperProduct = (ProductWrapper)JSON.deserialize(productWrapper,ProductWrapper.class);
            if(cartOrders.size()>0){
                
                // 3. Add Product Wrapper to Cart Line Item and Create Cart Line Item
                return addToCartLineItem(cartOrders[0].Id,wrapperProduct);
            }else{

                // Getting Account Details to store information like Addresses in Cart Order
                Account accountDetails = getAccount(accountId); 

                // 3. Create a New Cart for Current Account
                Order cartOrder = new Order();
                cartOrder.AccountId = accountId;
                cartOrder.recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
                cartOrder.Status = 'Draft';
                cartOrder.EffectiveDate = System.today();// Default Start Date
                // Setting Billing Address
                cartOrder.BillingStreet = accountDetails.BillingStreet; 
                cartOrder.BillingCity = accountDetails.BillingCity;
                cartOrder.BillingState = accountDetails.BillingState;
                cartOrder.BillingPostalCode= accountDetails.BillingPostalCode;
                cartOrder.BillingCountry = accountDetails.BillingCountry;

                // Setting Shipping Address
                cartOrder.ShippingStreet = accountDetails.ShippingStreet; 
                cartOrder.ShippingCity = accountDetails.ShippingCity;
                cartOrder.ShippingState = accountDetails.ShippingState;
                cartOrder.ShippingPostalCode= accountDetails.ShippingPostalCode;
                cartOrder.ShippingCountry = accountDetails.ShippingCountry;

                cartOrder.Pricebook2Id = wrapperProduct.pricebookEntry.Pricebook2Id;

                    // add Some Extra field

                Database.SaveResult result =Database.insert(cartOrder);
                if(result.isSuccess()){
                    // 4. Add Product Wrapper to Cart Line Item and Create Cart Line Item
                    return addToCartLineItem(result.getId(),wrapperProduct);
                }
                return false;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Message '+e.getMessage() +' LineNumber '+e.getLineNumber());
        }
    }

    private static boolean addToCartLineItem(Id cartOrderId,ProductWrapper wrapperProduct){
        
        OrderItem lineItem = new OrderItem();
        lineItem.Product2Id = wrapperProduct.productId;
        // Add Some extra fields..
        lineItem.OrderId = cartOrderId;
        lineItem.Quantity = wrapperProduct.quantity;
        lineItem.UnitPrice = wrapperProduct.pricebookEntry.UnitPrice;
        lineItem.ListPrice = wrapperProduct.pricebookEntry.UnitPrice;
        lineItem.Description = wrapperProduct.pricebookEntry.Product2.Description;
        lineItem.PricebookEntryId =  wrapperProduct.pricebookEntry.Id;
        Database.SaveResult result = Database.insert(lineItem);
        return result.isSuccess();
    } 
    
    @AuraEnabled
    public static List<ProductWrapper> getCartDetails(String accountId){
        try {
            // 1. Get Cart of Current Account
            List<Order> cartOrders = [select Id,Name,Order_Status__c from Order where AccountId=:accountId and Status='Draft' limit 1];

            // Map => {Key = Product__c,value = Account_product_Mapping__c}
            Map<Id,Account_product_Mapping__c> accountProductMappingByProduct = new Map<Id,Account_product_Mapping__c>();
            
            List<Account_product_Mapping__c> accountProducts = [select Id,Name,Account__c,Product__c,Locking_status__c,Locking_Start_Date__c,Locking_End_Date__c,Minimum_Order_Quantity__c,Maximum_Order_Quantity__c from Account_product_Mapping__c where Product__c!=null and Account__c=:accountId];

            for (Account_product_Mapping__c accountProduct : accountProducts) {
                accountProductMappingByProduct.put(accountProduct.Product__c,accountProduct);
            }

            // 2. Get CartLineItem__c By cart Order
            if(cartOrders.size()>0){
                List<OrderItem> orderProducts = [Select id,OrderId,Quantity,UnitPrice,Discount_Percent__c,TotalPrice,GST__c,Description,PricebookEntryId,PricebookEntry.Pricebook2Id from OrderItem where OrderId=:cartOrders[0].Id];

                if(orderProducts.size()>0){

                    List<PricebookEntry> pricebookentries = getPriceBookEntries(new List<Id>{orderProducts[0].PricebookEntry.Pricebook2Id});
                    if(pricebookentries.size()>0){
                        List<ProductWrapper>  wrapperProducts = new List<ProductWrapper>();
                        for(OrderItem item:orderProducts){
                            ProductWrapper wrapperProduct = new ProductWrapper();
                            wrapperProduct.pricebookEntry = pricebookentries[0];
                            wrapperProduct.productId = pricebookentries[0].Product2Id;
                            wrapperProduct.weekOfTheSKU = false;
                            wrapperProduct.trendingSKU = false;
                            wrapperProduct.lockingSKU = accountProductMappingByProduct.get(pricebookentries[0].Product2Id)?.Locking_status__c;
                            wrapperProduct.cappingSKU = false;
                            wrapperProduct.maximum_Order_Quantity = accountProductMappingByProduct.get(pricebookentries[0].Product2Id)?.Maximum_Order_Quantity__c;
                            wrapperProduct.minimum_Order_Quantity = accountProductMappingByProduct.get(pricebookentries[0].Product2Id)?.Minimum_Order_Quantity__c;
                            wrapperProduct.quantity = item.Quantity;
                            wrapperProduct.discountPercentage = item.Discount_Percent__c;
                            wrapperProduct.lineItemSubTotal = item.TotalPrice;
                            wrapperProduct.GSTPercentage = item.GST__c;
                            wrapperProduct.combinationKey = pricebookentries[0].Product2.ProductCode + pricebookentries[0].Product2.Variant__r.Variant_Code__c;

                            wrapperProducts.add(wrapperProduct);
                        }
                        return wrapperProducts;  
                    }else{
                       // TODO: Add to Monitor log
                       System.debug('No PriceBook found in the cart');
                       return new List<ProductWrapper>();
                    }
                }else{
                    // TODO: Add to Monitor log
                    System.debug('No Product found in the cart');
                    return new List<ProductWrapper>();
                }
            }
            return new List<ProductWrapper>();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
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
        List<PriceBook2>  priceboooks = [select id,Customer__c,Customer_Group__c,Is_Discount_Price_Book__c,Type__c,Combination_Key__c,IsActive from PriceBook2 where Customer__c=:accountId and Type__c='Customer' and IsActive=true];
        return priceboooks;
    }

    private static List<PriceBook2> getPriceBookByCustomerGroup(List<String> customerGroups){
        List<PriceBook2>  priceboooks = [select id,Customer__c,Customer_Group__c,Is_Discount_Price_Book__c,Type__c,Combination_Key__c,IsActive from PriceBook2 where Customer_Group__c IN:customerGroups and Type__c='Customer Group'  and IsActive=true];
        return priceboooks;
    }

    private static List<PriceBook2> getCommonPriceBook(){
        List<PriceBook2>  priceboooks = [select id,Customer__c,Customer_Group__c,Is_Discount_Price_Book__c,Type__c,Combination_Key__c,IsActive from PriceBook2 where Customer_Group__c=null and Customer__c=null and Type__c='Common'  and IsActive=true];
        return priceboooks;
    }

    public static List<String> getCustomerGroupByCustomer(String accountId){
        List<Account>  accounts = [select id,Name,Customer_Group__c from Account where Id=:accountId limit 1];
        List<String> customerGroups = new List<String>();
        for(Account acount:accounts){
            customerGroups.add(acount.Customer_Group__c);
        }
        return customerGroups;
    }

    public static List<PricebookEntry> getPriceBookEntries(List<Id> priceBookIds){
        try {
            List<PricebookEntry> pricebookEntries = [SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice, IsActive, UseStandardPrice, ProductCode, End_Date__c, Start_Date__c, Combination_Key__c, Product2.Name,Product2.ProductCode, Product2.Description, Product2.IsActive, Product2.DisplayUrl, Product2.Product_Code__c, Product2.Variant__c, Product2.Minimum_Quantity__c, Product2.Size__c, Product2.Thread__c, Product2.StockKeepingUnit,Product2.Variant__r.Name,Product2.Variant__r.Variant_Code__c,Product2.Variant__r.Description__c FROM PricebookEntry where IsActive=true and Pricebook2Id IN:priceBookIds];
            return pricebookEntries;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}