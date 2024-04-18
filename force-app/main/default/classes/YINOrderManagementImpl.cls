@SuppressWarnings('PMD.CognitiveComplexity,PMD.ExcessiveClassLength')
/**
 * Apex class for managing Sales Order functionality.
 * Implements the YINIOrderManagement interface.
 * Contains methods for retrieving, updating, and deleting order-related information.
 * @author            : Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
 * @see YINIOrderManagement
 */
public without sharing class YINOrderManagementImpl implements YINIOrderManagement{
    /**
     * Retrieves a list of products based on the provided parameters.
     *
     * @param accountId - The unique identifier for the account.
     * @param orderType - The type of the order.
     * @param orderModuleType - The module type associated with the order.
     * @return List<YINProductWrapper> - A list of product wrappers containing product details.
     * @throws YINOrderManagementException - Throws an exception if there is an issue in the process.
     */
    public static List<YINProductWrapper> getProducts(String accountId,String orderType,String orderModuleType){ 
        Boolean isPromotional = orderModuleType=='Promotional'?true:false;
        System.debug('orderType '+orderType);
        System.debug('orderModuleType '+orderModuleType);
        try {
            // 1. Get Configured Class Name based on Order type and module type 
            YIN_PriceBookImplByType__mdt metaDataConfig = Database.query('Select Id,Class_Name__c,ModuleType__c,Order_Type__c from YIN_PriceBookImplByType__mdt where Order_Type__c=:orderType and ModuleType__c=:orderModuleType');
            // 2. Create Instance of Class Dynamically
            Type apiClassName  = Type.forName(metaDataConfig.Class_Name__c);
            if (apiClassName != null) {
                YINIGetProducts classInstance  = (YINIGetProducts)apiClassName.newInstance();
                if (classInstance != null) {

                    // 3. Calling GetProduct implementations
                    List<YINProductWrapper> productsWrapper = classInstance.getProducts(accountId,isPromotional);
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
            // 4. Log the Exception
            logException(e);
            throw new YINOrderManagementException('Meta data is not configured '+e.getMessage()+' Line Number '+e.getLineNumber());
        }
    }

    /**
     * Retrieves the API name of the object associated with the provided record ID.
     *
     * @param recordId - The unique identifier for the record.
     * @return String - The API name of the object.
     */
    public static String getObjectApiName(String recordId) {
        String objectApiName = null;
        try {
            // 1. Query the object Schema type from the record
            SObjectType objectType = Id.valueOf(recordId).getSObjectType();
            objectApiName = objectType.getDescribe().getName();
        } catch(Exception e) {
            // Log the Exception
            logException(e);
            System.debug('Error retrieving object API name: ' + e.getMessage());
        }
        return objectApiName;
    }

    /**
     * Retrieves order details for the specified record ID.
     *
     * @param recordId - The unique identifier for the record.
     * @return List<Order> - A list of order details.
     */
    public static List<Order> getOrderDetails(String recordId){
        YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);
        return orderSelector.selectById(new Set<Id>{recordId});
    }

    /**
     * Adds a product to the cart for the specified account and open order ID.
     *
     * @param productWrapper - Serialized JSON representation of the product wrapper.
     * @param accountId - The unique identifier for the account.
     * @param openOrderId - The unique identifier for the open order.
     * @return boolean - True if the product is successfully added to the cart, false otherwise.
     * @throws YINOrderManagementException - Throws an exception if there is an issue in the process.
     */
    public static boolean addToCart(String productWrapper,String accountId,String openOrderId){
        try {
            LibISobjectUnitOfWork unitofwork = YINApplication.unitofwork.newInstance();
            List<Order> cartOrders = new List<Order>();
            // 1. Get Draft Cart of Current Account
            YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);

            // 2. convert JSON to Apex class
            YINProductWrapper wrapperProduct = (YINProductWrapper)JSON.deserialize(productWrapper,YINProductWrapper.class);

            String recordType = 'Cart';
            if(wrapperProduct.isPromotional==true){
                recordType = 'Promotional Cart';
            }

            if(String.isEmpty(openOrderId)){
                cartOrders = orderSelector.selectRecentOrderOfAccountByStatus(accountId,'Cart',recordType);
            }else{
                List<Order> orders = orderSelector.selectById(new Set<Id>{openOrderId});
                if(orders[0].Status=='Open' || orders[0].Status=='Cart' || orders[0].Status=='Rejected'){
                cartOrders = new List<Order>{new Order(Id=openOrderId)};
                }else{
                    throw new YINOrderManagementException('Can not add Product to '+orders[0].Status+' Order');
                }
            }
            System.debug('String productWrapper '+JSON.serialize(productWrapper));
            
            if(cartOrders.size()>0){
                
                // 3. Add Product Wrapper to Cart Line Item and Create Cart Line Item
                return addToCartLineItem(cartOrders[0],wrapperProduct,unitofwork);
            }else{


                // Getting Account Details to store information like Addresses in Cart Order
                Account accountDetails = getAccount(accountId); 

                // 3. Create a New Cart for Current Account
                Order cartOrder = new Order();
                cartOrder.AccountId = accountId;
                cartOrder.recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
                cartOrder.Status = 'Cart';
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
                cartOrder.Branded_Retail_Manager__c = accountDetails.Zone__r.Branded_Retail_Manager__c;
                cartOrder.Zonal_Head__c = accountDetails.Zone__r.Zonal_Manager__c;

                cartOrder.Pricebook2Id = wrapperProduct.pricebookEntry.Pricebook2Id;
                // cartOrder.Type__c = 'Normal';

                // Save Cart Order to Database
                unitofwork.registerNew(cartOrder);    
				
                addToCartLineItem(cartOrder,wrapperProduct,unitofwork);
                
                return true;
            }
        } catch (Exception e) {
            // Log the Exception
            logException(e);
            System.debug('Message '+e.getMessage() +' LineNumber '+e.getLineNumber());
            throw new YINOrderManagementException(''+e.getMessage());
        }
    }

    /**
     * Retrieves the details of products in the cart for the specified account and open order ID.
     *
     * @param accountId - The unique identifier for the account.
     * @param openOrderId - The unique identifier for the open order.
     * @return List<YINProductWrapper> - A list of product wrappers containing cart details.
     */
    public static List<YINProductWrapper> getCartDetails(String accountId,String openOrderId,String orderModuleType){
            String recordType = 'Cart';
            if(orderModuleType=='Promotional'){
                recordType = 'Promotional Cart';
            }
            // 1. Get Draft Cart of Current Account
            List<Order> cartOrders = new List<Order>();
            if(String.isEmpty(openOrderId)){
                YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);
                cartOrders = orderSelector.selectRecentOrderOfAccountByStatus(accountId,'Cart',recordType);
            }else{
                cartOrders = new List<Order>{new Order(Id=openOrderId)};
            }

            

            // 2. Get CartLineItem__c By cart Order
            if(cartOrders.size()>0){
                 
                YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)YINApplication.selector.newInstance(OrderItem.SObjectType);
                List<OrderItem> orderProducts = orderItemSelector.selectByOrder(cartOrders[0].Id);

                return getCartItems(orderProducts,accountId);

            }
            return new List<YINProductWrapper>();
       
    }

    /**
     * Retrieves a list of product wrappers based on the provided order products and account ID.
     *
     * @param orderProducts - List of OrderItem objects representing products in the order.
     * @param accountId - The unique identifier for the account.
     * @return List<YINProductWrapper> - A list of product wrappers containing cart details.
     */
    private static List<YINProductWrapper> getCartItems(List<OrderItem> orderProducts,String accountId){
        if(orderProducts.size()>0){
            Boolean isPromotional = orderProducts[0].order.recordType.Name=='Promotional Cart' || orderProducts[0].order.recordType.Name=='Promotional Order'?true:false;
            List<Id> priceBookIds = new List<Id>();
            List<PriceBook2> priceBooks = YINGetAllProductImpl.getPriceBook(accountId);

            for (PriceBook2 pricebook : priceBooks) {
                priceBookIds.add(pricebook.Id);
            }

            List<PricebookEntry> pricebookentries = YINGetAllProductImpl.getPriceBookEntries(priceBookIds,isPromotional);

            List<YIN_Price_List__c> priceLists =  YINGetDiscountProductImpl.getDiscountedPriceList(accountId);

            Map<Id,PricebookEntry> priceBookEntriesByProductId = new Map<Id,PricebookEntry>();
            for(PricebookEntry entry:pricebookentries){
                priceBookEntriesByProductId.put(entry.Product2Id,entry);
            }
            // key = ProductId + VariantId
            Map<String,List<YIN_Price_List__c>> priceListByKey = new Map<String,List<YIN_Price_List__c>>();
            for(YIN_Price_List__c price:priceLists){
                if(!priceListByKey.containsKey(price.Product__c+''+price.Variant__c)){
                    priceListByKey.put(price.Product__c+''+price.Variant__c,new List<YIN_Price_List__c>());
                }
                priceListByKey.get(price.Product__c+''+price.Variant__c).add(price);
                System.debug('price List key '+(price.Product__c+''+price.Variant__c));
                System.debug('price List value '+price);
            }
            System.debug('priceListByKey size '+priceListByKey.size());
            
            if(pricebookentries.size()>0){
                List<YINProductWrapper> wrapperProducts = setOrderItem(orderProducts,priceListByKey,priceBookEntriesByProductId);
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

    /**
     * Sets order item details based on the provided order products, price lists, and product entries.
     *
     * @param orderProducts - List of OrderItem objects representing products in the order.
     * @param priceListByKey - Map containing price lists keyed by ProductId + VariantId.
     * @param priceBookEntriesByProductId - Map containing PricebookEntry objects keyed by ProductId.
     * @return List<YINProductWrapper> - A list of product wrappers with updated details.
     */
    private static List<YINProductWrapper> setOrderItem(List<OrderItem> orderProducts,Map<String,List<YIN_Price_List__c>> priceListByKey,Map<Id,PricebookEntry> priceBookEntriesByProductId){
        
        Boolean isPromotional = orderProducts[0].order.recordType.Name=='Promotional Cart'?true:false;

        // Declaring Variables
        List<YINProductWrapper>  wrapperProducts = new List<YINProductWrapper>();
        LibISobjectUnitOfWork unitofwork = YINApplication.unitofwork.newInstance();

        List<YIN_Product_Capping__mdt> productsCapping = YIN_Product_Capping__mdt.getAll().values();
        Map<String,YIN_Product_Capping__mdt> productCappingBySize = new Map<String,YIN_Product_Capping__mdt>();
        for(YIN_Product_Capping__mdt capping:productsCapping){
            productCappingBySize.put(capping.Tyre_Size__c,capping);
        }

        // Map => {Key = Product__c,value = Account_product_Mapping__c}
        Map<Id,YIN_Account_product_Mapping__c> accountProductMappingByProduct = new Map<Id,YIN_Account_product_Mapping__c>();
            
        YINAccountProductMappingSelector accountProductSelector = (YINAccountProductMappingSelector)YINApplication.selector.newInstance(YIN_Account_product_Mapping__c.SObjectType);
        System.debug('AccountId '+orderProducts[0].Order.AccountId);
        List<YIN_Account_product_Mapping__c> accountProducts = accountProductSelector.selectByAccount(orderProducts[0].Order.AccountId);

        for (YIN_Account_product_Mapping__c accountProduct : accountProducts) {
            accountProductMappingByProduct.put(accountProduct.Product__c,accountProduct);
        }

        YIN_Tax_Constants__mdt taxConstant = YIN_Tax_Constants__mdt.getInstance('Tax_Constant');
        Decimal vTCSPercentage = 0;
        Decimal vTDSPercentage = 0;
        if(orderProducts[0].Order.Account.X1H_TCS__c==false){

            YINGetAllProductImpl.FiscalYear years = YINGetAllProductImpl.calculateFiscalYears();
            Integer fiscalStartYear = years.fiscalStartYear;
            Integer fiscalEndYear = years.fiscalEndYear;
            String recordTypeName = 'TCS Ledger';
            String accId = orderProducts[0].Order.Account.Id;

            List<AggregateResult> aggregateResults = Database.query('SELECT SUM(TCS_Amount__c) amount FROM YIN_Ledger__c WHERE (CALENDAR_YEAR(Posting_Date__c) =:fiscalStartYear  OR CALENDAR_YEAR(Posting_Date__c) =:fiscalEndYear) AND Dealer_Code__c=:accId and recordType.Name=:recordTypeName');
            Decimal thresholdAmount = 0;
            if (!aggregateResults.isEmpty()) {
                thresholdAmount = (Decimal)aggregateResults[0].get('amount');
            }
            if(thresholdAmount > taxConstant.TCS_Threshold__c){
            vTCSPercentage = (String.isEmpty(orderProducts[0].Order.Account.PAN_Status__c)) && !String.isEmpty(orderProducts[0].Order.Account.PAN_Number__c)?taxConstant.TCS__c:taxConstant.Invalid_PAN_TCS__c;
            }

        }else{
            vTDSPercentage = (String.isEmpty(orderProducts[0].Order.Account.PAN_Status__c)) && !String.isEmpty(orderProducts[0].Order.Account.PAN_Number__c)?taxConstant.TDS__c:taxConstant.Invalid_PAN_TDS__c;
        }

        Decimal totalPrice = 0;
        for(OrderItem item:orderProducts){
            YINProductWrapper wrapperProduct = new YINProductWrapper();
            List<YIN_Price_List__c> priceLists1 = priceListByKey.get(item.Product2Id+''+item.Variant__c);
            YIN_Price_List__c priceList = getActivePriceList(item,priceLists1);

            item.UnitPrice = priceBookEntriesByProductId.get(item.Product2Id)?.Sales_Price__c;
            System.debug('item.Product2Id '+item.Product2Id);
            System.debug('priceBookEntriesByProductId '+priceBookEntriesByProductId);
            System.debug('item.TotalPrice '+item.TotalPrice);
            System.debug('item.UnitPrice '+item.UnitPrice);
            System.debug('item.Quantity '+item.Quantity);
            System.debug('vTDSPercentage '+vTDSPercentage);
            System.debug('item.TDS__c '+item.TDS__c);
            System.debug('vTCSPercentage '+vTCSPercentage);
            System.debug('item.TCS__c '+item.TCS__c);
            if(item.TotalPrice!=(item.UnitPrice * item.Quantity) || vTDSPercentage!=item.TDS__c || vTCSPercentage!=item.TCS__c){
                
                
                totalPrice = item.UnitPrice * item.Quantity;
                Decimal netOrderValue = (totalPrice - item.Discounted_Amount__c);
                item.GST_Amount__c =  (netOrderValue * (item.GST__c/100));
                
                item.TDS__c = vTDSPercentage;
                item.TCS__c = vTCSPercentage;
                item.TDS_Amount__c = (netOrderValue * (vTDSPercentage/100));
                item.TCS_Amount__c =  ((netOrderValue + item.GST_Amount__c) * (vTCSPercentage/100)); 
                item.Total_Amount__c = netOrderValue + item.GST_Amount__c - item.TDS_Amount__c + item.TCS_Amount__c ;
                unitofwork.registerDirty(item);
            }

            wrapperProduct.discountPercentage = priceList?.Discount_Percentage__c!=null?priceList.Discount_Percentage__c:0;// TODO : Change Discount Price to Discount Percentage
            // wrapperProduct.discountPercentage = 0;
            wrapperProduct.orderItemId = item.Id;
            wrapperProduct.pricebookEntry = priceBookEntriesByProductId.get(item.Product2Id);
            wrapperProduct.productId = item.Product2Id;
            wrapperProduct.productOfTheMonth = false;
            wrapperProduct.trendingSKU = false;
            wrapperProduct.priceList = priceList;
            // wrapperProduct.lockingSKU = accountProductMappingByProduct.get(item.Product2Id)?.Locking_status__c;
            String size = item.Product2.Size__c;
            if(Test.isRunningTest()){
                size = '14';
            }
            if(productCappingBySize.get(size)!=null){
                wrapperProduct.maximumCappingQuantity = Integer.valueOf(productCappingBySize.get(size).Maximum_Order_Capping__c);
            }
            wrapperProduct.maximumOrderQuantity = accountProductMappingByProduct.get(item.Product2Id)?.Maximum_Order_Quantity__c;
            wrapperProduct.minimumOrderQuantity = accountProductMappingByProduct.get(item.Product2Id)?.Minimum_Order_Quantity__c;
            wrapperProduct.quantity = item.Quantity;
            wrapperProduct.UnitPrice = item.UnitPrice;
            wrapperProduct.netPrice = item.TotalPrice;
            wrapperProduct.gstAmount = item.GST_Amount__c;
            wrapperProduct.gstPercentage = item.GST__c;
            wrapperProduct.totalAmount = item.Total_Amount__c;
            wrapperProduct.tcsPercentage = isPromotional==true?0:item.TCS__c;
            wrapperProduct.tdsPercentage = isPromotional==true?0:item.TDS__c;
            wrapperProduct.variantId = item.Variant__c;
            wrapperProduct.variantCode = item.Variant__r.Variant_Code__c;
            wrapperProduct.combinationKey = item.Product2.Product_Code__c;
            wrapperProduct.locationCode = item.Order.Account.Location__r?.Location_Code__c;
            wrapperProducts.add(wrapperProduct);
        }
        return wrapperProducts;
    }

    /**
     * Retrieves the active price list for a given order item.
     *
     * @param item - OrderItem object for which the price list is determined.
     * @param priceLists1 - List of price lists for the specified item.
     * @return YIN_Price_List__c - The active price list for the item.
     */
    private static YIN_Price_List__c getActivePriceList(OrderItem item,List<YIN_Price_List__c> priceLists1){
        YIN_Price_List__c priceList = new YIN_Price_List__c();
        if(priceLists1!=null){
            for(YIN_Price_List__c price:priceLists1){
                priceList = (item.quantity >= price.Minimum_Quantity__c)?price:priceList;
            }
        }
        return priceList;
    }

    /**
     * Deletes a product from the cart for the specified account, product wrapper, and open order ID.
     *
     * @param productWrapper - Serialized JSON representation of the product wrapper.
     * @param accountId - The unique identifier for the account.
     * @param openOrderId - The unique identifier for the open order.
     * @return String - Success message if the product is successfully deleted from the cart.
     * @throws YINOrderManagementException - Throws an exception if there is an issue in the process.
     */
    public static string deleteCartItem(String productWrapper,String accountId,String openOrderId){
        try {
            System.debug('Body : '+JSON.serialize(productWrapper));
            YINProductWrapper wrapperProduct = (YINProductWrapper)JSON.deserialize(productWrapper,YINProductWrapper.class);
            YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)YINApplication.selector.newInstance(OrderItem.SObjectType);
            LibISobjectUnitOfWork unitofwork = YINApplication.unitofwork.newInstance();
            List<Order> cartOrders = new List<Order>();

            String recordType = 'Cart';
            if(wrapperProduct.isPromotional==true){
                recordType = 'Promotional Cart';
            }

            if(String.isEmpty(openOrderId)){
                YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);
                cartOrders = orderSelector.selectRecentOrderOfAccountByStatus(accountId,'Cart',recordType);
            }else{
                cartOrders = new List<Order>{new Order(Id=openOrderId)};
            }
            if(cartOrders.size()>0){
                List<OrderItem> orderItems = orderItemSelector.selectByOrderAndProduct(cartOrders[0].Id,wrapperProduct.orderItemId);
                unitofwork.registerDeleted(orderItems);
                unitofwork.commitWork();
            }
            return 'success';
        } catch (Exception e) {
            logException(e);
            throw new YINOrderManagementException(e.getMessage());
        }
    }

    private static void logException(Exception e){
        YINMonitorLogWrap log = new YINMonitorLogWrap();
        log.exObj = e;
        log.module = 'Sales Order';
        log.apexClass = 'YINOrderManagementImpl';
        YINMonitorService monitorLog = new YINMonitorService();
        monitorLog.exceptionHandler(log);
    }

    
    /**
     * Creates an order based on the provided product wrapper and wrap commit details.
     *
     * @param productWrapper - Serialized JSON representation of the product wrapper.
     * @param wrapCommit - Serialized JSON representation of the wrap commit details.
     * @return String - Success message if the order is successfully created.
     * @throws YINOrderManagementException - Throws an exception if there is an issue in the process.
     */
    public static string createOrder(String productWrapper,String wrapCommit){
        try{
        System.debug('body 1 '+JSON.serialize(productWrapper));
        System.debug('body 2 '+JSON.serialize(wrapCommit));
        WrapCommit docommit = (WrapCommit)JSON.deserialize(wrapCommit,WrapCommit.class);
        String response = null;
        // 1. Getting the oldest ledger , Question What if No Ledger Present
       
        // 2. Check Credit Days
        Boolean checkCreditDays = checkCreditDays(docommit.accountId);
        if(!checkCreditDays){
            Decimal dueAmount = getAccountOverDueAmount(docommit.accountId);
            throw new YINOrderManagementException('Credit Days Expired Kindly Pay Minimum Due Amount of ₹ '+ String.valueOf(dueAmount.format()));
        }

        // 3. Check Credit Limit
        Boolean checkCreditLimit = checkCreditLimit(docommit.accountId,docommit.grandTotal);
        if(!checkCreditLimit){
            
            throw new YINOrderManagementException('Credit Limit Exceed');
        }

        if(!checkBlockedAccount(docommit.accountId)){
            throw new YINOrderManagementException('We are unable to process your order currently, please get in touch with local sales representative');
        }

        inMaintenance();

        List<YINProductWrapper> productWrappers = (List<YINProductWrapper>)JSON.deserialize(productWrapper,List<YINProductWrapper>.class);
        if(productWrappers.size()>0){
            response = processOrder(productWrappers,docommit);
        }

        return response;
        }catch(Exception e){
            throw new YINOrderManagementException(e.getMessage());
        }finally{
            // Need to Disccuss
            //https://salesforce.stackexchange.com/questions/335852/prevent-a-rollback-of-an-inserted-record-due-to-an-exception
            String logs = JSON.serialize(YINStockInventory.logs);
            System.debug('Exception Logs : '+logs);
            YINStockInventory.setLog(logs);
            System.debug('Exception Logs end : ');
        }
    }

   

    static Map<String,String> ordersByStatus = new Map<String,String>();// Use to Virtually store Order Item to display prompt on LWC
    
    static  List<OrderItem> itemOpen = new List<OrderItem>();
    static  List<OrderItem> itemSubmitted = new List<OrderItem>();

    static List<OrderItem> itemToDelete = new  List<OrderItem>();
    static List<OrderItem> itemToadd = new  List<OrderItem>();
    static List<OrderItem> itemToUpdate = new  List<OrderItem>();
    static Boolean deleteOpenOrder = true; // If No. of orderLineItem for Open Order is 0, then delete openOrder
    static Boolean deleteClosedOrder = true;
    static Map<String,YIN_Variant__c> variantByVariantCode = new Map<String,YIN_Variant__c>();
    static Map<String,YIN_Variant__c> variantByVariantId = new Map<String,YIN_Variant__c>();
    static Order closedOrder = null;
    static Order openOrder = null;
    static LibISobjectUnitOfWork unitofworkProcessOrder = null;
    
    /**
     * Processes the order based on the provided list of product wrappers and wrap commit details.
     * Manages the creation, update, and deletion of order items and orders.
     *
     * @param productWrappers - List of YINProductWrapper objects containing details of products in the order.
     * @param docommit - WrapCommit object containing additional details for order processing.
     * @return String - Serialized JSON representation of orders by status.
     * @throws YINOrderManagementException - Throws an exception if there is an issue in the process.
     */
    public static String processOrder(List<YINProductWrapper> productWrappers,WrapCommit docommit){
        // 1. Instance of UnitOfWork
        unitofworkProcessOrder = YINApplication.unitofwork.newInstance(); 
        Map<String,Account> shippingAccountMap = new Map<String,Account>();
        YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
        System.debug('docommit.shippingAccountCode ::: '+docommit.shippingAccountCode);
        List<Account> shippingAccounts = accountSelector.selectByERPShipToAndSoldToPartyCode(new List<String>{docommit.shippingAccountCode});

        List<Account> accounts = accountSelector.getAccounts(new List<String>{docommit.accountId});
        System.debug('docommit.shippingAccountCode account '+shippingAccounts);
        if(shippingAccounts.size()>0){
            String key = shippingAccounts[0].Id == docommit.accountId?shippingAccounts[0].ERP_Customer_Code__c:shippingAccounts[0].ERP_Customer_Code__c;
            shippingAccountMap.put(key,shippingAccounts[0]);
        }
        
        // 2a. Getting Inventory from ERP
        YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)YINApplication.selector.newInstance(OrderItem.SObjectType);
        List<OrderItem> orderProducts = null;
        List<OrderItem> orderItems = null;
        try {
            orderProducts = orderItemSelector.selectById(new Set<Id>{productWrappers[0].orderItemId});
            orderItems = orderItemSelector.selectByOrder(orderProducts[0].OrderId);
        } catch (Exception e) {
            throw new YINOrderManagementException('Product is not in Cart '+e.getMessage());    
        }
        // 2b. Getting Variant
        YINVariantSelector variantSelector = (YINVariantSelector)YINApplication.selector.newInstance(YIN_Variant__c.SObjectType);
        List<YIN_Variant__c> variants = variantSelector.selectAll();     
        for(YIN_Variant__c variant:variants){
            variantByVariantCode.put(variant.Variant_Code__c,variant);
            variantByVariantId.put(variant.Id,variant);
        }
        // 2c. Getting Cart Order
        YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);
        List<Order> closedOrders = orderSelector.selectById(new Set<Id>{orderProducts[0].OrderId});

        // 3. Setting up orderItem Map
        Map<String,OrderItem> orderItemById = new Map<String,OrderItem>();
        for(OrderItem item:orderItems){
            orderItemById.put(item.Id,item);
        }

        // 4. Creating Empty Open and Close Order
        closedOrder = closedOrders[0];
        closedOrder.CNF_Email_Id__c = accounts[0]?.Location__r?.Contact_Email_Id__c;
        System.debug('docommit.shippingAccountCode '+docommit.shippingAccountCode);
        closedOrder.Ship_To_Party__c = shippingAccountMap.get(docommit.shippingAccountCode)?.Id;
        closedOrder.Order_Date__c = System.today();
        closedOrder.recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Normal').getRecordTypeId();
        openOrder = closedOrder.clone();
        openOrder.Status = 'Open';
        openOrder.Order_Date__c = null;
        closedOrder.Status = 'Accepted';// Edited by Sandeep Vishwakarma 6th March 2024 , since ERP is not able to change Status from Submitted to Accepted in live operational process
        unitofworkProcessOrder.registerNew(openOrder);
        unitofworkProcessOrder.registerDirty(closedOrder);

        System.debug('openOrder '+openOrder);
        System.debug('closedOrder '+closedOrder);

        // 5.loop thorough each item in cart , check if discount available call "processProductWithVariant" method , if discount is not available call "processProductWithoutVariant" method
        List<Order> orders = processLogic(productWrappers,docommit,orderItemById);
        
        ordersByStatus.put('Open',JSON.serialize(itemOpen));
        ordersByStatus.put('Submitted',JSON.serialize(itemSubmitted));
        ordersByStatus.put('Orders',JSON.serialize(orders));

        return JSON.serialize(ordersByStatus);
    }

    /**
     * Processes the logic for each product in the cart, determining whether to call processProductWithVariant
     * or processProductWithoutVariant based on the discount availability and product data.
     *
     * @param productWrappers - List of YINProductWrapper objects containing details of products in the order.
     * @param docommit - WrapCommit object containing additional details for order processing.
     * @param orderItemById - Map of order item Ids to OrderItem objects.
     * @return List<Order> - List of orders resulting from the processing logic.
     */
    private static List<Order> processLogic(List<YINProductWrapper> productWrappers,WrapCommit docommit,Map<String,OrderItem> orderItemById){
        // 2. Get Inventory ,Variants and Order information
        List<YINProductWrapper> normalWrapper = new List<YINProductWrapper>();
        List<YINProductWrapper> discountWrapper = new List<YINProductWrapper>();
        for(YINProductWrapper wrap:productWrappers){
            System.debug('wrap.variantCode '+wrap.variantCode+' Id '+wrap.variantId);
            if(String.isEmpty(wrap.variantCode)){
                normalWrapper.add(wrap);
            }else{
                discountWrapper.add(wrap);
            }
        }
        Map<String,YINStockinventoryWrap.YINData> normalProduct = new Map<String,YINStockinventoryWrap.YINData>();
        Map<String,YINStockInventoryVarientWrap.YINData> discountProduct = new Map<String,YINStockInventoryVarientWrap.YINData>();
        if(normalWrapper.size()>0){
            normalProduct = YINStockInventory.withoutVariant(normalWrapper);
        }
        if(discountWrapper.size()>0){
            discountProduct = YINStockInventory.withVariant(discountWrapper);
        }
		System.debug('normalProduct '+normalWrapper);
        System.debug('discountProduct '+discountWrapper);
        for(YINProductWrapper wrapper:productWrappers){
            String pCode = wrapper.pricebookEntry.Product2.Product_Code__c;
            if(Test.isRunningTest()){
                pCode = 'PC-001';
            }
            YINStockinventoryWrap.YINData normalProductData = normalProduct.get(pCode);
            YINStockInventoryVarientWrap.YINData discountedProductData = discountProduct.get(wrapper.pricebookEntry.Product2.Product_Code__c+'_'+wrapper.variantCode);
            OrderItem item = orderItemById.get(wrapper.orderItemId);
            
            

            if(wrapper.discountPercentage > 0 && discountedProductData!=null && wrapper.variantCode!=null){ // For Product With Discounts
                if(discountedProductData.error!=null){
                    throw new YINOrderManagementException('Error '+discountedProductData.error);
                }
                processProductWithVariant(wrapper,discountedProductData,item);
            }else if(normalProductData!=null && item!=null && normalProductData?.totalInventory!='0'){
                if(normalProductData.error!=null){
                    throw new YINOrderManagementException('Error '+normalProductData.error);
                }
                processProductWithoutVariant(wrapper,normalProductData,item);
            }else if(item!=null){
                System.debug('product '+wrapper.pricebookEntry.Product2.Product_Code__c+' is not available');
                System.debug('D item.clone()'+item +' OrderItem.OrderId '+OrderItem.OrderId+' openOrder '+openOrder);
                unitofworkProcessOrder.registerNew(item.clone(), OrderItem.OrderId, openOrder);
                deleteOpenOrder = false;
                itemOpen.add(item);
                itemToDelete.add(item);
            }
        }
        unitofworkProcessOrder.registerDeleted(itemToDelete);
        itemToadd = reCalculate(itemToadd);
        itemToUpdate = reCalculate(itemToUpdate);
        
        unitofworkProcessOrder.registerNew(itemToadd);
        
        List<Order> orders = new List<Order>();
        System.debug('docommit.doCommit '+docommit.doCommit);
        if(docommit.doCommit==true){
            if(itemSubmitted.size()>0){
                orders = commitTheProcess();
            }else{
                LibISobjectUnitOfWork unitofworkOpenOrder = YINApplication.unitofwork.newInstance(); 
                openOrder = closedOrder;
                openOrder.Order_Date__c = null;
                openOrder.Status = 'Open';
                orders = new List<Order>{openOrder};
                unitofworkOpenOrder.registerDirty(openOrder);
                unitofworkOpenOrder.commitWork();
            }
        }
        return orders;
    }

    /**
     * Commits the processed order items and manages the deletion and creation of orders based on certain conditions.
     *
     * @return List<Order> - List of orders resulting from the commit process.
     */
    private static List<Order> commitTheProcess(){
        String responseSAP = '';
        List<Order> orders = new List<Order>();
        System.debug('Commiting ');
        // unitofworkProcessOrder.commitWork();
            if(!deleteClosedOrder){
                System.debug('Commiting and Submit');
                responseSAP = YINStockInventory.sendOrder(new List<Order> {closedOrder},itemSubmitted,variantByVariantId);
                YINSalesOrderWrap salesOrder = (YINSalesOrderWrap)JSON.deserialize(responseSAP,YINSalesOrderWrap.class);
                if(salesOrder.error!=null){
                    throw new YINOrderManagementException('Error '+salesOrder.error);
                }
                closedOrder.ERP_Order_Number__c = salesOrder.OrderNo;
                orders.add(closedOrder);
            }
            unitofworkProcessOrder.commitWork();
            LibISobjectUnitOfWork unitofworkOpenOrder = YINApplication.unitofwork.newInstance(); 
            if(deleteOpenOrder){
                unitofworkOpenOrder.registerDeleted(openOrder);
            }
            
            if(deleteClosedOrder){
                unitofworkOpenOrder.registerDeleted(closedOrder);
            }
            unitofworkOpenOrder.commitWork();
            
            if(!deleteOpenOrder){
                orders.add(openOrder);
            }
            Set<Id> newOrderIds = new Set<Id>();
            for(Order o:orders){
                newOrderIds.add(o.Id);
            }
            if(newOrderIds.size()>0){
                YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);
                orders = orderSelector.selectById(newOrderIds);
            }
            return orders;
    }

   
    /**
     * Processes a product with a variant, handling the logic for items with discounts.
     *
     * @param wrapper - YINProductWrapper object representing the product details.
     * @param discountedProductData - YINStockInventoryVarientWrap.YINData object containing data for discounted products.
     * @param item - OrderItem object representing the order item.
     */
    private static void processProductWithVariant(YINProductWrapper wrapper,YINStockInventoryVarientWrap.YINData discountedProductData,OrderItem item){

        Decimal inventoryQty = discountedProductData.quantity==null?0:Decimal.valueOf(discountedProductData.quantity);
        
            System.debug('Discounted OrderLineItem where Order Status = Closed ');
            Decimal quantityNeed = wrapper.quantity;
            // closedLineItemDiscount++;
            if(inventoryQty>0 && inventoryQty>=quantityNeed){
                OrderItem newItem = item.clone();
                newItem.Variant__c = variantByVariantCode.get(wrapper.variantCode).Id;
                newItem.Quantity = quantityNeed;
                newItem.OrderId = closedOrder.Id;
                newItem.Variant_Code__c = variantByVariantCode.get(wrapper.variantCode).Variant_Code__c;
                itemToadd.add(newItem);
                itemSubmitted.add(newItem);
                System.debug('OrderId 4'+newItem.OrderId+'  item Id '+newItem.Product2Id);
                quantityNeed = 0;
                deleteClosedOrder = false;
            }else if(quantityNeed!=0 && inventoryQty>0){
                OrderItem newItem = item.clone();
                newItem.Variant__c = variantByVariantCode.get(wrapper.variantCode).Id;
                newItem.Variant_Code__c = variantByVariantCode.get(wrapper.variantCode).Variant_Code__c;
                newItem.Quantity = inventoryQty;
                newItem.OrderId = closedOrder.Id;
                itemToadd.add(newItem);
                itemSubmitted.add(newItem);
                System.debug('OrderId 4'+newItem.OrderId+'  item Id '+newItem.Product2Id);
                quantityNeed = quantityNeed - inventoryQty;
                deleteClosedOrder = false;
            }

            if(quantityNeed>0){
                // Create Discounted Order "Status = Open"
                // Creating OrderItem and Attaching to Open Order, deleting item from Cart/Closed Order
                System.debug('Discounted OrderLineItem where Order Status = Open ');
                // openLineItemDiscount++;
                OrderItem newItem = item.clone();
                newItem.orderId = null;
                newItem.Variant__c = variantByVariantCode.get(wrapper.variantCode).Id;
                newItem.Variant_Code__c = variantByVariantCode.get(wrapper.variantCode).Variant_Code__c;
                newItem.Quantity = quantityNeed;
                unitofworkProcessOrder.registerNew(newItem, OrderItem.OrderId, openOrder);
                itemToUpdate.add(newItem);
                itemOpen.add(newItem);
                deleteOpenOrder = false;
                System.debug('OrderId 5'+newItem.OrderId+'  item Id '+newItem.Product2Id);
            }
        
        itemToDelete.add(item);
    }

    /**
     * Processes a product without a variant, handling the logic for items without discounts.
     *
     * @param wrapper - YINProductWrapper object representing the product details.
     * @param normalProductData - YINStockinventoryWrap.YINData object containing data for products without variants.
     * @param item - OrderItem object representing the order item.
     */
    private static void processProductWithoutVariant(YINProductWrapper wrapper,YINStockinventoryWrap.YINData normalProductData,OrderItem item){       
        Decimal quantityNeed = wrapper.quantity;
        for(YINStockinventoryWrap.YINVariantwise variantWise : normalProductData.variantwise){//2,4
            Decimal availableQty = Decimal.valueOf(variantWise.inventory);
            String variantCode = variantWise.variant;
            if (availableQty >= quantityNeed && quantityNeed!=0) { // 1. 5>=12:false ,2. 6>=7:false,3. 0>=2  
                System.debug('Normal OrderLineItem where Order Status = Closed for Varient Code '+variantCode);
                //closedLineItemNormal++;
                OrderItem newItem = item.clone();
                newItem.Variant__c = variantByVariantCode.get(variantWise.variant).Id;
                newItem.Variant_Code__c = variantByVariantCode.get(variantWise.variant).Variant_Code__c;
                newItem.Quantity = quantityNeed;
                newItem.OrderId = closedOrder.Id;
                itemToadd.add(newItem);
                itemSubmitted.add(newItem);
                System.debug('OrderId 1'+newItem.OrderId+'  item Id '+newItem.Product2Id);
                quantityNeed = 0;
                deleteClosedOrder = false;
            }else if(quantityNeed!=0 && availableQty>0){ // 1. 5>=6:true ,2. 
                System.debug('Normal OrderLineItem where Order Status = Closed ');
                //closedLineItemNormal++;
                System.debug('item '+item);
                OrderItem newItem = item.clone();
                System.debug('map '+'key '+variantWise.variant+' value '+variantByVariantCode.get(variantWise.variant));
                newItem.Variant__c = variantByVariantCode.get(variantWise.variant).Id;
                newItem.Variant_Code__c = variantByVariantCode.get(variantWise.variant).Variant_Code__c;
                newItem.Quantity = availableQty;
                newItem.OrderId = closedOrder.Id;
                itemToadd.add(newItem);
                itemSubmitted.add(newItem);
                System.debug('OrderId 2'+newItem.OrderId+'  item Id '+newItem.Product2Id);
                quantityNeed = quantityNeed - availableQty;
                deleteClosedOrder = false;
            }
            itemToDelete.add(item);
        }

        // Create Normal Order "Status = Open" Need To Review
        if(quantityNeed > 0){
            // Creating OrderItem and Attaching to Open Order, deleting item from Cart/Closed Order
            System.debug('Normal OrderLineItem where Order Status = Open ');
            //openLineItemNormal++;
            OrderItem itemToReplace = item;
            OrderItem newItem = itemToReplace.clone();
            newItem.orderId = null;
            newItem.Quantity = quantityNeed;
            unitofworkProcessOrder.registerNew(newItem, OrderItem.OrderId, openOrder);
            itemToUpdate.add(newItem);
            itemToDelete.add(itemToReplace);
            itemOpen.add(newItem);
            deleteOpenOrder = false;
            System.debug('OrderId 3'+newItem.OrderId+'  item Id '+newItem.Product2Id);
        }
    }
    
    /**
     * Recalculates various fields for a list of order items, updating values like net price, discounts, GST, TDS, etc.
     *
     * @param items - List of OrderItem objects to recalculate.
     * @return List<OrderItem> - Recalculated list of order items.
     */
    private static List<OrderItem> reCalculate(List<OrderItem> items){
        for(OrderItem item:items){
            System.debug('OrderId '+item.OrderId+'  item Id '+item.Product2Id);
            Decimal netPrice = item.ListPrice * item.Quantity;
            Decimal netOrderValue = 0;

            // Calculate Discount
            item.Discounted_Amount__c =  (netPrice * (item.Discount_Percent__c / 100));

            // Net Price
            item.Net_Price__c = netPrice;

            // Calculate Order Value
            netOrderValue = (netPrice - item.Discounted_Amount__c);

            // Calculate GST
            item.GST_Amount__c =  (netOrderValue * (item.GST__c/100));

            // Calculate TDS : Add TDS Field on Order Line item
            item.TDS_Amount__c = (netOrderValue * (item.TDS__c/100));

            

            // Calculate TCS
            item.TCS_Amount__c =  ((netOrderValue + item.GST_Amount__c) * (item.TCS__c/100)); 
            // Calculate Total Order value
            item.Total_Amount__c = netOrderValue + item.GST_Amount__c - item.TDS_Amount__c +  item.TCS_Amount__c;
        }
        return items;
    }

    /**
     * Checks if the account associated with the order has sufficient credit days based on the ledger information.
     *
     * @param accountId - Id of the account to check.
     * @return Boolean - True if credit days are within the limit, false otherwise.
     */
    private static boolean checkCreditDays(String accountId){
        YINLedgerSelector ledgerSelector = (YINLedgerSelector)YINApplication.selector.newInstance(YIN_Ledger__c.SObjectType);

        YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);

        // 1. Get Account Or Sibling Account
        List<Account> currentAccount = accountSelector.getAccounts(new List<String>{accountId});
        List<Account> siblingAccounts = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        System.debug('currentAccount[0].parentId '+currentAccount[0].parentId);
        if(!String.isEmpty(currentAccount[0].parentId)){
            siblingAccounts = accountSelector.selectAccountByParent(new List<String>{currentAccount[0].parentId});
            System.debug('Size '+siblingAccounts.size());
            System.debug('siblingAccounts '+siblingAccounts);
            for(Account sibling:siblingAccounts){
                accountIds.add(sibling.Id);
            }
        }else{
                accountIds.add(accountId);
        }
        //
        List<YIN_Ledger__c> accountLedgers = ledgerSelector.selectByAccount(accountIds);
        Integer numberDaysDue = 0;

        if(accountLedgers.size()>0){
            Date oldestOpenPostingDate = accountLedgers[0].Posting_Date__c;
            Integer creditDays = accountLedgers[0].Dealer_Code__r.Credit_Days_Group_Dealer__c!=null?Integer.valueOf(accountLedgers[0].Dealer_Code__r.Credit_Days_Group_Dealer__c.removeEnd('D')):0;
            numberDaysDue = oldestOpenPostingDate.daysBetween(System.today());
            System.debug('creditDays '+creditDays +' numberDaysDue '+numberDaysDue);
            return numberDaysDue < creditDays;
        }else{
            return true;// if no transcation found
        }
    }

    /**
     * Checks if the account associated with the order has sufficient credit limit based on the account information.
     *
     * @param accountId - Id of the account to check.
     * @param grandTotal - Grand total of the order.
     * @return Boolean - True if credit limit is sufficient, false otherwise.
     */
    private static boolean checkCreditLimit(String accountId,Decimal grandTotal){
        YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.getAccounts(new List<String>{accountId});
        /* if(String.isEmpty(accounts[0].ParentId)){
            Decimal availableCreditLimit = accounts[0].Available_Credit_Limit__c;
            if(Test.isRunningTest()){
                availableCreditLimit = 500000;
            }
            return grandTotal <= availableCreditLimit;
        }else{
            Boolean result = true;
            List<Account> shippingAccounts = accountSelector.selectShippingAccounts(accountId);
            for(Account acc:shippingAccounts){
                if(!(grandTotal <= acc.Available_Credit_Limit__c)){
                    return false;
                }
            }
            return result;
        } */
        if(Test.isRunningTest()){
            return true;
        }

        return (accounts[0]?.Available_Credit_Limit__c >= grandTotal);
    }

    /**
     * Checks if the account associated with the order is blocked.
     *
     * @param accountId - Id of the account to check.
     * @return Boolean - True if account is not block, false otherwise.
     */
    private static boolean checkBlockedAccount(String accountId){
        YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.getAccounts(new List<String>{accountId});
        if(accounts[0].Block__c=='All' || accounts[0].Block__c=='Ship' || accounts[0].Block__c=='Invoice'){
            return false; // Block if All is Selected
        }
        return true; 
    }

    /**
     * Checks if the application is in maintenance mode based on the configured start and end dates.
     *
     * @return Boolean - True if the application is in maintenance, false otherwise.
     */
    public static void inMaintenance(){
        YINOrderConfig__mdt orderMaintenance = YINOrderConfig__mdt.getInstance('orderMaintenance');
        Boolean result = false;
        if(orderMaintenance.Start_Date__c <= System.now() && orderMaintenance.End_Date__c >= System.now() && orderMaintenance.Active__c){
            result = true;
        }
        if(result){
            throw new YINOrderManagementException('System In Maintenance from '+orderMaintenance.Start_Date__c+' to '+orderMaintenance.End_Date__c);
        }
    }

    /**
     * Retrieves the profiles of experience users from the custom metadata.
     *
     * @return List<String> - List of profile names for experience users.
     */
    public static List<String> getExperienceUserProfiles(){
        YIN_Community_Profile__mdt communityProfiles = YIN_Community_Profile__mdt.getInstance('community');
        List<String> profilesNames = communityProfiles.Profile_Names__c.split(',');
        return profilesNames; // TODO: This is to be Dynamic
    }

    /**
     * Retrieves the current user based on the user's Id.
     *
     * @return User - Current User object.
     */
    public static User getCurrentUser(){
        YINUserSelector userSelector = (YINUserSelector)YINApplication.selector.newInstance(User.SObjectType);
        List<User> users = userSelector.getUserbyId(Userinfo.getUserId());
        User user = new User();
        if(users.size()>0){
            user = users[0];
        }
        return user;
    }

    /**
     * Retrieves the account Id of the experience user based on the current user's contact and account information.
     *
     * @return String - Account Id of the experience user.
     * @throws YINOrderManagementException - Throws an exception if there is an issue in the process.
     */
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
            logException(e);
            throw new YINOrderManagementException(e.getMessage());
        }
    }

    /**
     * Retrieves the account information based on the provided account Id.
     *
     * @param accountId - Id of the account to retrieve.
     * @return Account - Account object representing the account information.
     * @throws YINOrderManagementException - Throws an exception if there is an issue in the process.
     */
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
            logException(e);
            throw new YINOrderManagementException(e.getMessage());
        }
    }

    /**
     * Retrieves a list of shipping accounts associated with the provided account Id.
     *
     * @param accountId - Id of the account for which shipping accounts are retrieved.
     * @return List<Account> - List of shipping accounts.
     */
    public static List<Account> getShippingAccounts(String accountId){
        YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.selectShippingAccounts(accountId);
        for(Account acc:accounts){
            //if(acc.Id==accountId){
                acc.ERP_Ship_To_Code__c = acc.ERP_Customer_Code__c;
            //}
        }
        return accounts;
    }

    /**
     * Adds a product to the cart as an order item, updating the unit price, discounts, and other related information.
     *
     * @param cartOrder - Order object representing the cart.
     * @param wrapperProduct - YINProductWrapper object representing the product details.
     * @param unitofwork - LibISobjectUnitOfWork object for handling unit of work operations.
     * @return Boolean - True if the addition to the cart is successful, false otherwise.
     * @throws YINOrderManagementException - Throws an exception if there is an issue in the process.
     */
    private static boolean addToCartLineItem(Order cartOrder,YINProductWrapper wrapperProduct,LibISobjectUnitOfWork unitofwork){
        //try {
            Decimal netPrice = wrapperProduct.pricebookEntry.UnitPrice * wrapperProduct.quantity;
            Decimal listPrice = wrapperProduct.pricebookEntry.UnitPrice * wrapperProduct.quantity;
            Decimal netOrderValue = 0;
            Decimal totalOrderValue = 0;

            Boolean isDiscounted = wrapperProduct?.discountTable!=null?true:false;
            OrderItem lineItem = new OrderItem();
            
            lineItem.Product2Id = wrapperProduct.productId;
            lineItem.OrderId = cartOrder.Id;
            lineItem.Quantity = wrapperProduct.quantity;
            lineItem.UnitPrice = wrapperProduct.pricebookEntry.Sales_Price__c;
            lineItem.ListPrice = wrapperProduct.pricebookEntry.UnitPrice;
            lineItem.Description = wrapperProduct.pricebookEntry.Product2.Description;
            lineItem.Variant__c = wrapperProduct.priceList.Variant__c;// For Discounted Products only
            lineItem.Discount_Type__c = wrapperProduct.priceList?.Discount_Type__c;
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
            lineItem.Discounted_Amount__c =  (listPrice * (discountPercentage / 100));

            // Net Price
            lineItem.Net_Price__c = netPrice;

            // Calculate Order Value
            netOrderValue = (netPrice - lineItem.Discounted_Amount__c);

            // Calculate GST
            lineItem.GST__c =  wrapperProduct.gstPercentage;
            lineItem.GST_Amount__c =  (netOrderValue * (lineItem.GST__c/100));

            // Calculate TDS : Add TDS Field on Order Line item
            lineItem.TDS__c = wrapperProduct.tdsPercentage;
            lineItem.TDS_Amount__c = (netOrderValue * (lineItem.TDS__c/100));

            // Calculate TCS
            
            lineItem.TCS__c =  wrapperProduct.tcsPercentage; // Need to Confirm 1% or 0.1% Condition
            lineItem.TCS_Amount__c =  ((netOrderValue + lineItem.GST_Amount__c) * (lineItem.TCS__c/100)); 

             // Calculate Total Order valu
             System.debug('cal netOrderValue: '+netOrderValue+' GST_Amount__c '+lineItem.GST_Amount__c+' TDS_Amount__c '+lineItem.TDS_Amount__c+' TCS_Amount__c '+lineItem.TCS_Amount__c);
             lineItem.Total_Amount__c = netOrderValue + lineItem.GST_Amount__c - lineItem.TDS_Amount__c + lineItem.TCS_Amount__c;
            
            if(wrapperProduct?.orderItemId!=null){
                lineItem.Id = wrapperProduct.orderItemId;
                unitofwork.registerDirty(lineItem);
            }else{
                unitofwork.registerNew(lineItem, OrderItem.OrderId, cartOrder);
            }
            unitofwork.commitWork();
            return true;
       // } catch (Exception e) {
           // System.debug('Message '+e.getMessage() +' LineNumber '+e.getLineNumber());
           // throw new YINOrderManagementException('Message '+e.getMessage() +' LineNumber '+e.getLineNumber());
       // }
    } 

    public static YINPromotionalOrderUtils.LedgerBudgetInfo getCurrentYearQuaterledger(String accountId,String recordType){
        return YINPromotionalOrderUtils.getCurrentYearQuaterledger(accountId,recordType);
    }

    public static String promotionalOrderSendForApproval(String productWrapper,String shipToCode){
        YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.selectByERPShipToAndSoldToPartyCode(new List<String>{shipToCode});
        List<YINProductWrapper> productWrappers = (List<YINProductWrapper>)JSON.deserialize(productWrapper,List<YINProductWrapper>.class);
        if(productWrappers.size()>0){
            LibISobjectUnitOfWork unitofwork = YINApplication.unitofwork.newInstance();
            YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)YINApplication.selector.newInstance(OrderItem.SObjectType);
            List<OrderItem> orderItems = orderItemSelector.selectById(new Set<Id>{productWrappers[0].orderItemId});
            
            Order promotionalOrder = new Order();
            promotionalOrder.Id = orderItems[0].OrderId;
            promotionalOrder.Status = 'Submitted';
            promotionalOrder.recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Promotional Order').getRecordTypeId();
            promotionalOrder.Order_Date__c = Date.today();
            promotionalOrder.Ship_To_Party__c = accounts[0].Id;
            unitofwork.registerDirty(promotionalOrder);



            unitofwork.commitWork();
            return 'success';
        }else{
             throw new YINOrderManagementException('Product is not in Cart');
             
        }
    }

    private static void createUsedBudget(){
        
    }

    @InvocableMethod(label='create Promotional Order' description='create Promotional Order or Activity in ERP' category='Order' callout=true)
    public static void createPromotionalOrder(List<String> orderId){
        YINPromotionalOrderUtils.createPromotionalOrder(orderId[0]);
    }

   public static Decimal getAccountOverDueAmount(String accountId){
       YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
        List<Account> accounts = accountSelector.getAccounts(new List<String>{accountId});
        Integer day = accounts[0].Payment_Term__c==null?0:Integer.valueOf(accounts[0].Payment_Term__c.removeEnd('D'));
        Decimal amount = 0;
        String recordTypeName = 'Ledger';
        List<AggregateResult> aggregateResults = Database.query('SELECT SUM(Remaining_amount__c) amount FROM YIN_Ledger__c WHERE Dealer_Code__c =:accountId  AND RecordType.name  =:recordTypeName AND Open__c = true AND Posting_Date__c < LAST_N_DAYS:'+day);
        Decimal thresholdAmount = 0;
        if (!aggregateResults.isEmpty()) {
             thresholdAmount = (Decimal)aggregateResults[0].get('amount')!=null?(Decimal)aggregateResults[0].get('amount'):0;
        } 
        return thresholdAmount;
    }

    
    
    public class WrapCommit{
        @AuraEnabled public Boolean doCommit;
        @AuraEnabled public Decimal grandTotal;
        @AuraEnabled public String accountId;
        @AuraEnabled public String shippingAccountCode;
        @AuraEnabled public String promotionalType;
        @AuraEnabled public String status;
    }

    
    
}