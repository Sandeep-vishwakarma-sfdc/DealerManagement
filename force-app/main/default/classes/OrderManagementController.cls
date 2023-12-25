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
        UserSelector userSelector = (UserSelector)Application.selector.newInstance(User.SObjectType);
        List<User> users = userSelector.getUserbyId(Userinfo.getUserId());
        User user = new User();
        if(users.size()>0){
            user = users[0];
        }
        return user;
    }

    @AuraEnabled
    public static string getExperienceUserAccount(){
        try {
            String contactId = '';
            String accountId = '';
            UserSelector userSelector = (UserSelector)Application.selector.newInstance(User.SObjectType);
            ContactSelector contactSelector = (ContactSelector)Application.selector.newInstance(Contact.SObjectType);
            
            List<User> users = userSelector.getUserbyId(Userinfo.getUserid());
            if(users.size()>0){
                contactId = users[0].contactId;
                List<Contact> contacts = contactSelector.selectById(new Set<Id>{contactId});
                if(contacts.size()>0){
                    accountId = contacts[0].AccountId;
                }else{
                    // Monitor Log Exception : No contact found
                }
            }else{
                    // Monitor Log Exception : No User found
            }
            return accountId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Account getAccount(String accountId){
        try {

            AccountSelector accountSelector = (AccountSelector)Application.selector.newInstance(Account.SObjectType);
            List<Account> accounts = accountSelector.getAccounts(new List<String>{accountId});
            Account account = new Account();
            if(accounts.size()>0){
                account = accounts[0];
            }
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
            LibISobjectUnitOfWork unitofwork = Application.unitofwork.newInstance();

            // 1. Get Draft Cart of Current Account
            OrderSelector orderSelector = (OrderSelector)Application.selector.newInstance(Order.SObjectType);
            List<Order> cartOrders = orderSelector.selectRecentOrderOfAccountByStatus(accountId,'Draft');

            // 2. convert JSON to Apex class
            ProductWrapper wrapperProduct = (ProductWrapper)JSON.deserialize(productWrapper,ProductWrapper.class);
            if(cartOrders.size()>0){
                
                // 3. Add Product Wrapper to Cart Line Item and Create Cart Line Item
                return addToCartLineItem(cartOrders[0],wrapperProduct,unitofwork);
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

                // Save Cart Order to Database
                unitofwork.registerNew(cartOrder);    

                addToCartLineItem(cartOrder,wrapperProduct,unitofwork);
                
                return true;
            }
        } catch (Exception e) {
            System.debug('Message '+e.getMessage() +' LineNumber '+e.getLineNumber());
            throw new AuraHandledException('Message '+e.getMessage() +' LineNumber '+e.getLineNumber());
        }
    }

    private static boolean addToCartLineItem(Order cartOrder,ProductWrapper wrapperProduct,LibISobjectUnitOfWork unitofwork){
        try {
            OrderItem lineItem = new OrderItem();
            lineItem.Product2Id = wrapperProduct.productId;
            // Add Some extra fields..
            lineItem.OrderId = cartOrder.Id;
            lineItem.Quantity = wrapperProduct.quantity;
            lineItem.UnitPrice = wrapperProduct.pricebookEntry.UnitPrice;
            lineItem.ListPrice = wrapperProduct.pricebookEntry.UnitPrice;
            lineItem.Description = wrapperProduct.pricebookEntry.Product2.Description;
            lineItem.PricebookEntryId =  wrapperProduct.pricebookEntry.Id;
            
            unitofwork.registerNew(lineItem, OrderItem.OrderId, cartOrder);
            unitofwork.commitWork();
            return true;
        } catch (Exception e) {
            System.debug('Message '+e.getMessage() +' LineNumber '+e.getLineNumber());
            throw new AuraHandledException('Message '+e.getMessage() +' LineNumber '+e.getLineNumber());
        }
    } 
    
    @AuraEnabled
    public static List<ProductWrapper> getCartDetails(String accountId){
        try {
            // 1. Get Draft Cart of Current Account
            OrderSelector orderSelector = (OrderSelector)Application.selector.newInstance(Order.SObjectType);
            List<Order> cartOrders = orderSelector.selectRecentOrderOfAccountByStatus(accountId,'Draft');

            // Map => {Key = Product__c,value = Account_product_Mapping__c}
            Map<Id,Account_product_Mapping__c> accountProductMappingByProduct = new Map<Id,Account_product_Mapping__c>();
            
            AccountProductMappingSelector accountProductSelector = (AccountProductMappingSelector)Application.selector.newInstance(Account_product_Mapping__c.SObjectType);
            List<Account_product_Mapping__c> accountProducts = accountProductSelector.selectByAccount(accountId);

            for (Account_product_Mapping__c accountProduct : accountProducts) {
                accountProductMappingByProduct.put(accountProduct.Product__c,accountProduct);
            }

            // 2. Get CartLineItem__c By cart Order
            if(cartOrders.size()>0){
                 
                 OrderItemSelector orderItemSelector = (OrderItemSelector)Application.selector.newInstance(OrderItem.SObjectType);
                List<OrderItem> orderProducts = orderItemSelector.selectByOrder(cartOrders[0].Id);

                if(orderProducts.size()>0){

                    List<PricebookEntry> pricebookentries = getPriceBookEntries(new List<Id>{orderProducts[0].PricebookEntry.Pricebook2Id});

                    Map<Id,PricebookEntry> priceBookEntriesByProductId = new Map<Id,PricebookEntry>();
                    for(PricebookEntry entry:pricebookentries){
                        priceBookEntriesByProductId.put(entry.Product2Id,entry);
                    }

                    if(pricebookentries.size()>0){
                        List<ProductWrapper>  wrapperProducts = new List<ProductWrapper>();
                        for(OrderItem item:orderProducts){
                            ProductWrapper wrapperProduct = new ProductWrapper();
                            wrapperProduct.pricebookEntry = priceBookEntriesByProductId.get(item.Product2Id);
                            wrapperProduct.productId = item.Product2Id;
                            wrapperProduct.productOfTheMonth = false;
                            wrapperProduct.trendingSKU = false;
                            // wrapperProduct.lockingSKU = accountProductMappingByProduct.get(item.Product2Id)?.Locking_status__c;
                            wrapperProduct.cappingSKU = false;
                            wrapperProduct.maximum_Order_Quantity = accountProductMappingByProduct.get(item.Product2Id)?.Maximum_Order_Quantity__c;
                            wrapperProduct.minimum_Order_Quantity = accountProductMappingByProduct.get(item.Product2Id)?.Minimum_Order_Quantity__c;
                            wrapperProduct.quantity = item.Quantity;
                            wrapperProduct.discountPercentage = item.Discount_Percent__c;
                            wrapperProduct.lineItemSubTotal = item.TotalPrice;
                            wrapperProduct.GSTPercentage = item.GST__c;
                            wrapperProduct.combinationKey = item.Product2.ProductCode;

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

    @AuraEnabled
    public static string deleteCartItem(String productWrapper,String accountId){
        try {
            ProductWrapper wrapperProduct = (ProductWrapper)JSON.deserialize(productWrapper,ProductWrapper.class);
            OrderSelector orderSelector = (OrderSelector)Application.selector.newInstance(Order.SObjectType);
            OrderItemSelector orderItemSelector = (OrderItemSelector)Application.selector.newInstance(OrderItem.SObjectType);
            LibISobjectUnitOfWork unitofwork = Application.unitofwork.newInstance();
            List<Order> cartOrders = orderSelector.selectRecentOrderOfAccountByStatus(accountId,'Draft');
            if(cartOrders.size()>0){
                List<OrderItem> orderItems = orderItemSelector.selectByOrderAndProduct(cartOrders[0].Id,wrapperProduct.productId);
                unitofwork.registerDeleted(orderItems);
                unitofwork.commitWork();
            }
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

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
        PriceBookSelector priceBookSelector = (PriceBookSelector)Application.selector.newInstance(PriceBook2.SObjectType);
        List<PriceBook2>  priceboooks = priceBookSelector.selectPriceBookByCustomer(accountId);
        return priceboooks;
    }

    private static List<PriceBook2> getPriceBookByCustomerGroup(List<String> customerGroups){
        PriceBookSelector priceBookSelector = (PriceBookSelector)Application.selector.newInstance(PriceBook2.SObjectType);
        List<PriceBook2>  priceboooks = priceBookSelector.selectPriceBookByCustomerGroup(customerGroups);
        return priceboooks;
    }

    private static List<PriceBook2> getCommonPriceBook(){
        PriceBookSelector priceBookSelector = (PriceBookSelector)Application.selector.newInstance(PriceBook2.SObjectType);
        List<PriceBook2>  priceboooks = priceBookSelector.priceBookbyCustomerComman();
        return priceboooks;
    }

    public static List<String> getCustomerGroupByCustomer(String accountId){
        AccountSelector accountSelector = (AccountSelector)Application.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.getAccounts(new List<String>{accountId});
        List<String> customerGroups = new List<String>();
        for(Account acount:accounts){
            customerGroups.add(acount.Customer_Group__c);
        }
        return customerGroups;
    }

    public static List<PricebookEntry> getPriceBookEntries(List<Id> priceBookIds){
        try {
            PriceBookEntrySelector priceBookEntrySelector1 = (PriceBookEntrySelector)Application.selector.newInstance(PricebookEntry.SObjectType);
            List<PricebookEntry> pricebookEntries = priceBookEntrySelector1.selectPriceBookEntriesByPricebook(priceBookIds);
            return pricebookEntries;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}