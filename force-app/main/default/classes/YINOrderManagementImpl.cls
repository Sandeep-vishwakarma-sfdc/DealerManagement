public with sharing class YINOrderManagementImpl implements YINIOrderManagement{
    public static List<YINProductWrapper> getProducts(String accountId,String orderType){ 
        try {
            // Get class for which Instance should create by OrderType
            YIN_PriceBookImplByType__mdt metaDataConfig = YIN_PriceBookImplByType__mdt.getInstance(orderType);

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

                return getCartItems(orderProducts,accountProductMappingByProduct);

            }
            return new List<YINProductWrapper>();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<YINProductWrapper> getCartItems(List<OrderItem> orderProducts,Map<Id,YIN_Account_product_Mapping__c> accountProductMappingByProduct){
        if(orderProducts.size()>0){

            List<PricebookEntry> pricebookentries = YINGetAllProductImpl.getPriceBookEntries(new List<Id>{orderProducts[0].PricebookEntry.Pricebook2Id});

            Map<Id,PricebookEntry> priceBookEntriesByProductId = new Map<Id,PricebookEntry>();
            for(PricebookEntry entry:pricebookentries){
                priceBookEntriesByProductId.put(entry.Product2Id,entry);
            }

            List<YIN_Product_Capping__mdt> productsCapping = YIN_Product_Capping__mdt.getAll().values();
            Map<String,YIN_Product_Capping__mdt> productCappingBySize = new Map<String,YIN_Product_Capping__mdt>();
            for(YIN_Product_Capping__mdt capping:productsCapping){
                productCappingBySize.put(capping.Tyre_Size__c,capping);
            }

            if(pricebookentries.size()>0){
                List<YINProductWrapper>  wrapperProducts = new List<YINProductWrapper>();
                for(OrderItem item:orderProducts){
                    YINProductWrapper wrapperProduct = new YINProductWrapper();
                    wrapperProduct.orderItemId = item.Id;
                    wrapperProduct.pricebookEntry = priceBookEntriesByProductId.get(item.Product2Id);
                    wrapperProduct.productId = item.Product2Id;
                    wrapperProduct.productOfTheMonth = false;
                    wrapperProduct.trendingSKU = false;
                    // wrapperProduct.lockingSKU = accountProductMappingByProduct.get(item.Product2Id)?.Locking_status__c;

                    wrapperProduct.maximumCappingQuantity = Integer.valueOf(productCappingBySize.get(item.Product2.Size__c).Maximum_Order_Capping__c);
                    wrapperProduct.maximumOrderQuantity = accountProductMappingByProduct.get(item.Product2Id)?.Maximum_Order_Quantity__c;
                    wrapperProduct.minimumOrderQuantity = accountProductMappingByProduct.get(item.Product2Id)?.Minimum_Order_Quantity__c;
                    wrapperProduct.quantity = item.Quantity;
                    wrapperProduct.discountPercentage = item.Discount_Percent__c;
                    wrapperProduct.UnitPrice = item.UnitPrice;
                    wrapperProduct.netPrice = item.TotalPrice;
                    wrapperProduct.gstAmount = item.GST_Amount__c;
                    wrapperProduct.gstPercentage = item.GST__c;
                    wrapperProduct.totalAmount = item.Total_Amount__c;
                    wrapperProduct.tcsPercentage = item.TCS__c;
                    wrapperProduct.variantId = item.Variant__c;
                    wrapperProduct.variantCode = item.Variant__r.Variant_Code__c;
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
                    System.debug('No contact found');
                }
            }else{
                    // Monitor Log Exception : No User found
                    System.debug('No User found');
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

    public static List<Account> getShippingAccounts(String accountId){
        YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.selectShippingAccounts(accountId);
        return accounts;
    }

    // Private Methods
    private static boolean addToCartLineItem(Order cartOrder,YINProductWrapper wrapperProduct,LibISobjectUnitOfWork unitofwork){
        //try {
            Decimal netPrice = wrapperProduct.pricebookEntry.UnitPrice * wrapperProduct.quantity;
            Decimal netOrderValue = 0;
            Decimal totalOrderValue = 0;

            Boolean isDiscounted = wrapperProduct?.priceList!=null?true:false;
            OrderItem lineItem = new OrderItem();
            
            lineItem.Product2Id = wrapperProduct.productId;
            lineItem.OrderId = cartOrder.Id;
            lineItem.Quantity = wrapperProduct.quantity;
            lineItem.UnitPrice = wrapperProduct.pricebookEntry.UnitPrice;
            lineItem.ListPrice = wrapperProduct.pricebookEntry.UnitPrice;
            lineItem.Description = wrapperProduct.pricebookEntry.Product2.Description;
            lineItem.Variant__c = wrapperProduct.priceList.Variant__c;// For Discounted Products only
            lineItem.PricebookEntryId =  wrapperProduct.pricebookEntry.Id;

            // Check for available discountes
            Decimal discountPercentage = 0;
            if(isDiscounted==true){
                Decimal selectedMinimumQuantity = 0;
                List<YINProductWrapper.discountTable> discountTable = wrapperProduct?.discountTable;
                for(YINProductWrapper.discountTable table :discountTable){

                    // select discount Percentage for Quanity enter by user
                    if(wrapperProduct.quantity >= table.minimumOrderQuantity && (wrapperProduct.quantity >=selectedMinimumQuantity || selectedMinimumQuantity==0)){
                        discountPercentage = table.discountPercentage;
                        selectedMinimumQuantity = table.minimumOrderQuantity;
                    }
                    
                }

            }

            // Calculate Discount
            lineItem.Discount_Percent__c =  discountPercentage;
            lineItem.Discounted_Amount__c =  (netPrice * (discountPercentage / 100));

            // Net Price
            lineItem.Net_Price__c = netPrice;

            // Calculate Order Value
            netOrderValue = (netPrice - lineItem.Discounted_Amount__c);

            // Calculate GST
            lineItem.GST__c =  wrapperProduct.gstPercentage;
            lineItem.GST_Amount__c =  (netOrderValue * (lineItem.GST__c/100));

            // Calculate TDS : Add TDS Field on Order Line item
                // lineItem.TDS__c = wrapperProduct.tdsPercentage;
                // lineItem.TDS_Amount__c = (netOrderValue * (lineItem.TDS__c/100));

            // Calculate Total Order value
            lineItem.Total_Amount__c = netOrderValue + lineItem.GST_Amount__c;

            // Calculate TCS
            
            lineItem.TCS__c =  wrapperProduct.tcsPercentage; // Need to Confirm 1% or 0.1% Condition
            lineItem.TCS_Amount__c =  (netOrderValue * (lineItem.TCS__c/100)); 
            
            if(wrapperProduct?.orderItemId!=null){
                lineItem.Id = wrapperProduct.orderItemId;
                unitofwork.registerDirty(lineItem);
            }else{
                unitofwork.registerNew(lineItem, OrderItem.OrderId, cartOrder);
            }
            unitofwork.commitWork();
            return true;
       // } catch (Exception e) {
        //    System.debug('Message '+e.getMessage() +' LineNumber '+e.getLineNumber());
       //     throw new AuraHandledException('Message '+e.getMessage() +' LineNumber '+e.getLineNumber());
       // }
    } 

    

    
}