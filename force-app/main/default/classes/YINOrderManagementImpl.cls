public with sharing class YINOrderManagementImpl implements YINIOrderManagement{
    public static List<YINProductWrapper> getProducts(String accountId,String OrderType){ 
        try {
            // Get class for which Instance should create by OrderType
            YIN_PriceBookImplByType__mdt metaDataConfig = YIN_PriceBookImplByType__mdt.getInstance(OrderType);

            // Create Instance of Class Dynamically
            Type apiClassName  = Type.forName(metaDataConfig.Class_Name__c);
            if (apiClassName != null) {
                YINIGetProducts classInstance  = (YINIGetProducts)apiClassName.newInstance();
                if (classInstance != null) {

                    // Calling GetProduct implementations
                    List<YINProductWrapper> productsWrapper = classInstance.getProducts(accountId);
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

    public static boolean addToCart(String productWrapper,String accountId){
        try {
            LibISobjectUnitOfWork unitofwork = YINApplication.unitofwork.newInstance();

            // 1. Get Draft Cart of Current Account
            YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);
            List<Order> cartOrders = orderSelector.selectRecentOrderOfAccountByStatus(accountId,'Draft');

            // 2. convert JSON to Apex class
            YINProductWrapper wrapperProduct = (YINProductWrapper)JSON.deserialize(productWrapper,YINProductWrapper.class);
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

    public static List<YINProductWrapper> getCartDetails(String accountId){
        try {
            // 1. Get Draft Cart of Current Account
            YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);
            List<Order> cartOrders = orderSelector.selectRecentOrderOfAccountByStatus(accountId,'Draft');

            // Map => {Key = Product__c,value = Account_product_Mapping__c}
            Map<Id,YIN_Account_product_Mapping__c> accountProductMappingByProduct = new Map<Id,YIN_Account_product_Mapping__c>();
            
            YINAccountProductMappingSelector accountProductSelector = (YINAccountProductMappingSelector)YINApplication.selector.newInstance(YIN_Account_product_Mapping__c.SObjectType);
            List<YIN_Account_product_Mapping__c> accountProducts = accountProductSelector.selectByAccount(accountId);

            for (YIN_Account_product_Mapping__c accountProduct : accountProducts) {
                accountProductMappingByProduct.put(accountProduct.Product__c,accountProduct);
            }

            // 2. Get CartLineItem__c By cart Order
            if(cartOrders.size()>0){
                 
                YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)YINApplication.selector.newInstance(OrderItem.SObjectType);
                List<OrderItem> orderProducts = orderItemSelector.selectByOrder(cartOrders[0].Id);

                if(orderProducts.size()>0){

                    List<PricebookEntry> pricebookentries = YINGetAllProductImpl.getPriceBookEntries(new List<Id>{orderProducts[0].PricebookEntry.Pricebook2Id});

                    Map<Id,PricebookEntry> priceBookEntriesByProductId = new Map<Id,PricebookEntry>();
                    for(PricebookEntry entry:pricebookentries){
                        priceBookEntriesByProductId.put(entry.Product2Id,entry);
                    }

                    if(pricebookentries.size()>0){
                        List<YINProductWrapper>  wrapperProducts = new List<YINProductWrapper>();
                        for(OrderItem item:orderProducts){
                            YINProductWrapper wrapperProduct = new YINProductWrapper();
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
                       return new List<YINProductWrapper>();
                    }
                }else{
                    // TODO: Add to Monitor log
                    System.debug('No Product found in the cart');
                    return new List<YINProductWrapper>();
                }
            }
            return new List<YINProductWrapper>();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
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

    public static string deleteCartItem(String productWrapper,String accountId){
        try {
            YINProductWrapper wrapperProduct = (YINProductWrapper)JSON.deserialize(productWrapper,YINProductWrapper.class);
            YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);
            YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)YINApplication.selector.newInstance(OrderItem.SObjectType);
            LibISobjectUnitOfWork unitofwork = YINApplication.unitofwork.newInstance();
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

    public static string createOrder(String productWrapper,String accountId){
        return '';
    }

    public static List<String> getExperienceUserProfiles(){
        return new List<String>{'DMS','Customer Service'}; // TODO: This is to be Dynamic
    }

    public static User getCurrentUser(){
        YINUserSelector userSelector = (YINUserSelector)YINApplication.selector.newInstance(User.SObjectType);
        List<User> users = userSelector.getUserbyId(Userinfo.getUserId());
        User user = new User();
        if(users.size()>0){
            user = users[0];
        }
        return user;
    }

    public static string getExperienceUserAccount(){
        try {
            String contactId = '';
            String accountId = '';
            YINUserSelector userSelector = (YINUserSelector)YINApplication.selector.newInstance(User.SObjectType);
            YINContactSelector contactSelector = (YINContactSelector)YINApplication.selector.newInstance(Contact.SObjectType);
            
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

    public static Account getAccount(String accountId){
        try {

            YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
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

    // Private Methods
    private static boolean addToCartLineItem(Order cartOrder,YINProductWrapper wrapperProduct,LibISobjectUnitOfWork unitofwork){
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

    

    
}