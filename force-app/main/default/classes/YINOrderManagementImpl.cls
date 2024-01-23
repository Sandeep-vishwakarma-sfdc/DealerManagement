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
            List<Order> cartOrders = orderSelector.selectRecentOrderOfAccountByStatus(accountId,'Cart');

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
        
            // 1. Get Draft Cart of Current Account
            YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);
            List<Order> cartOrders = orderSelector.selectRecentOrderOfAccountByStatus(accountId,'Cart');

            

            // 2. Get CartLineItem__c By cart Order
            if(cartOrders.size()>0){
                 
                YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)YINApplication.selector.newInstance(OrderItem.SObjectType);
                List<OrderItem> orderProducts = orderItemSelector.selectByOrder(cartOrders[0].Id);

                return getCartItems(orderProducts,accountId);

            }
            return new List<YINProductWrapper>();
       
    }

    private static List<YINProductWrapper> getCartItems(List<OrderItem> orderProducts,String accountId){
        if(orderProducts.size()>0){

            List<PricebookEntry> pricebookentries = YINGetAllProductImpl.getPriceBookEntries(new List<Id>{orderProducts[0].PricebookEntry.Pricebook2Id});

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

    private static List<YINProductWrapper> setOrderItem(List<OrderItem> orderProducts,Map<String,List<YIN_Price_List__c>> priceListByKey,Map<Id,PricebookEntry> priceBookEntriesByProductId){
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

        Tax_Constants__mdt taxConstant = Tax_Constants__mdt.getInstance('Tax_Constant');
        Decimal vTCSPercentage = 0;
        Decimal vTDSPercentage = 0;
        if(orderProducts[0].Order.Account.X1H_TCS__c==true){
            vTCSPercentage = orderProducts[0].Order.Account.PAN_Status__c=='Valid'?taxConstant.TCS__c:taxConstant.Invalid_PAN_TCS__c;
        }else{
            vTDSPercentage = orderProducts[0].Order.Account.PAN_Status__c=='Valid'?taxConstant.TDS__c:taxConstant.Invalid_PAN_TDS__c;
        }

        Decimal totalPrice = 0;
        for(OrderItem item:orderProducts){
            YINProductWrapper wrapperProduct = new YINProductWrapper();
            List<YIN_Price_List__c> priceLists1 = priceListByKey.get(item.Product2Id+''+item.Variant__c);
            YIN_Price_List__c priceList = getActivePriceList(item,priceLists1);

            item.UnitPrice = priceBookEntriesByProductId.get(item.Product2Id)?.UnitPrice;
            if(item.TotalPrice!=(item.UnitPrice * item.Quantity) || vTDSPercentage!=item.TDS__c || vTCSPercentage!=item.TCS__c){
                
                
                totalPrice = item.UnitPrice * item.Quantity;
                Decimal netOrderValue = (totalPrice - item.Discounted_Amount__c);
                item.GST_Amount__c =  (netOrderValue * (item.GST__c/100));
                item.Total_Amount__c = netOrderValue + item.GST_Amount__c;
                item.TDS__c = vTDSPercentage;
                item.TCS__c = vTCSPercentage;
                item.TDS_Amount__c = (netOrderValue * (vTDSPercentage/100));
                item.TCS_Amount__c =  (netOrderValue * (vTCSPercentage/100)); 
                unitofwork.registerDirty(item);
            }

            wrapperProduct.discountPercentage = priceList?.Discount_Price__c!=null?priceList.Discount_Price__c:0;// TODO : Change Discount Price to Discount Percentage
            // wrapperProduct.discountPercentage = 0;
            wrapperProduct.orderItemId = item.Id;
            wrapperProduct.pricebookEntry = priceBookEntriesByProductId.get(item.Product2Id);
            wrapperProduct.productId = item.Product2Id;
            wrapperProduct.productOfTheMonth = false;
            wrapperProduct.trendingSKU = false;
            wrapperProduct.priceList = priceList;
            // wrapperProduct.lockingSKU = accountProductMappingByProduct.get(item.Product2Id)?.Locking_status__c;

            wrapperProduct.maximumCappingQuantity = Integer.valueOf(productCappingBySize.get(item.Product2.Size__c).Maximum_Order_Capping__c);
            wrapperProduct.maximumOrderQuantity = accountProductMappingByProduct.get(item.Product2Id)?.Maximum_Order_Quantity__c;
            wrapperProduct.minimumOrderQuantity = accountProductMappingByProduct.get(item.Product2Id)?.Minimum_Order_Quantity__c;
            wrapperProduct.quantity = item.Quantity;
            wrapperProduct.UnitPrice = item.UnitPrice;
            wrapperProduct.netPrice = item.TotalPrice;
            wrapperProduct.gstAmount = item.GST_Amount__c;
            wrapperProduct.gstPercentage = item.GST__c;
            wrapperProduct.totalAmount = item.Total_Amount__c;
            wrapperProduct.tcsPercentage = item.TCS__c;
            wrapperProduct.tdsPercentage = item.TDS__c;
            wrapperProduct.variantId = item.Variant__c;
            wrapperProduct.variantCode = item.Variant__r.Variant_Code__c;
            wrapperProduct.combinationKey = item.Product2.ProductCode;
            wrapperProduct.locationCode = item.Order.Account.Location__r?.Location_Code__c;
            wrapperProducts.add(wrapperProduct);
        }
        return wrapperProducts;
    }

    private static YIN_Price_List__c getActivePriceList(OrderItem item,List<YIN_Price_List__c> priceLists1){
        YIN_Price_List__c priceList = new YIN_Price_List__c();
        if(priceLists1!=null){
            for(YIN_Price_List__c price:priceLists1){
                priceList = (item.quantity >= price.Minimum_Quantity__c)?price:priceList;
            }
        }
        return priceList;
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
            List<Order> cartOrders = orderSelector.selectRecentOrderOfAccountByStatus(accountId,'Cart');
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

    

    public static string createOrder(String productWrapper,String wrapCommit){
        WrapCommit docommit = (WrapCommit)JSON.deserialize(wrapCommit,WrapCommit.class);
        String response = null;
        // 1. Getting the oldest ledger , Question What if No Ledger Present
        YINLedgerSelector ledgerSelector = (YINLedgerSelector)YINApplication.selector.newInstance(YIN_Ledger__c.SObjectType);
        List<YIN_Ledger__c> accountLedgers = ledgerSelector.selectByAccount(new Set<Id>{docommit.accountId});
        // 2. Check Credit Days
        Boolean checkCreditDays = checkCreditDays(accountLedgers);
        if(checkCreditDays){// TODO : Add Not Operator Once Credit Days Formula field is in working state
            throw new YINOrderManagementException('Credit days expired');
        }

        // 3. Check Credit Limit
        Boolean checkCreditLimit = checkCreditLimit(accountLedgers,docommit.grandTotal);
        if(!checkCreditLimit){
            throw new YINOrderManagementException('Credit Limit exceed');
        }

        List<YINProductWrapper> productWrappers = (List<YINProductWrapper>)JSON.deserialize(productWrapper,List<YINProductWrapper>.class);
        if(productWrappers.size()>0){
            response = processOrder(productWrappers,docommit);
        }


        return response;
    }
    static Map<String,List<OrderItem>> ordersByStatus = new Map<String,List<OrderItem>>();// Use to Virtually store Order Item to display prompt on LWC
    
    static  List<OrderItem> itemOpen = new List<OrderItem>();
    static  List<OrderItem> itemSubmitted = new List<OrderItem>();

    static List<OrderItem> itemToDelete = new  List<OrderItem>();
    static List<OrderItem> itemToadd = new  List<OrderItem>();
    static List<OrderItem> itemToUpdate = new  List<OrderItem>();
    static Boolean deleteOpenOrder = true; // If No. of orderLineItem for Open Order is 0, then delete openOrder
    static Map<String,YIN_Variant__c> variantByVariantCode = new Map<String,YIN_Variant__c>();
    static Order closedOrder = null;
    static Order openOrder = null;
    static LibISobjectUnitOfWork unitofworkProcessOrder = null;
    
    public static String processOrder(List<YINProductWrapper> productWrappers,WrapCommit docommit){
        // 1. Instance of UnitOfWork
        unitofworkProcessOrder = YINApplication.unitofwork.newInstance(); 

        // 2. Get Inventory ,Variants and Order information
        Map<String,YINStockinventoryWrap.YINData> normalProduct = YINStockInventory.withoutVariant(productWrappers);
        Map<String,YINStockInventoryVarientWrap.YINData> discountProduct = YINStockInventory.withVariant(productWrappers);
        // 2a. Getting Inventory from ERP
        YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)YINApplication.selector.newInstance(OrderItem.SObjectType);
        List<OrderItem> orderProducts = orderItemSelector.selectById(new Set<Id>{productWrappers[0].orderItemId});
        List<OrderItem> orderItems = orderItemSelector.selectByOrder(orderProducts[0].OrderId);
        // 2b. Getting Variant
        YINVariantSelector variantSelector = (YINVariantSelector)YINApplication.selector.newInstance(YIN_Variant__c.SObjectType);
        List<YIN_Variant__c> variants = variantSelector.selectAll();     
        for(YIN_Variant__c variant:variants){
            variantByVariantCode.put(variant.Variant_Code__c,variant);
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
        closedOrder.recordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Normal').getRecordTypeId();
        openOrder = closedOrder.clone();
        openOrder.Status = 'Open';
        closedOrder.Status = 'Submitted';
        unitofworkProcessOrder.registerNew(openOrder);
        unitofworkProcessOrder.registerDirty(closedOrder);

        System.debug('openOrder '+openOrder);
        System.debug('closedOrder '+closedOrder);

        // 5.loop thorough each item in cart , check if discount available call "processProductWithVariant" method , if discount is not available call "processProductWithoutVariant" method
        for(YINProductWrapper wrapper:productWrappers){
            YINStockinventoryWrap.YINData normalProductData = normalProduct.get(wrapper.pricebookEntry.ProductCode);
            YINStockInventoryVarientWrap.YINData discountedProductData = discountProduct.get(wrapper.pricebookEntry.ProductCode+'_'+wrapper.variantCode);
            OrderItem item = orderItemById.get(wrapper.orderItemId);

            if(wrapper.discountPercentage > 0 && discountedProductData!=null && wrapper.variantCode!=null){ // For Product With Discounts
                processProductWithVariant(wrapper,discountedProductData,item);
            }else if(normalProductData!=null){
                processProductWithoutVariant(wrapper,normalProductData,item);
            }else{
                System.debug('product '+wrapper.pricebookEntry.ProductCode+' is not available');
            }
        }
        unitofworkProcessOrder.registerDeleted(itemToDelete);
        itemToadd = reCalculate(itemToadd);
        itemToUpdate = reCalculate(itemToUpdate);
        
        unitofworkProcessOrder.registerNew(itemToadd);
        if(docommit.doCommit==true){
            unitofworkProcessOrder.commitWork();
        }
        if(deleteOpenOrder && docommit.doCommit==true){
            LibISobjectUnitOfWork unitofworkOpenOrder = YINApplication.unitofwork.newInstance(); 
            unitofworkOpenOrder.registerDeleted(openOrder);
            unitofworkOpenOrder.commitWork();
        }
        ordersByStatus.put('Open',itemOpen);
        ordersByStatus.put('Submitted',itemSubmitted);
        
        /* Unit Test  */
        String itemsString = JSON.serialize(itemToadd);
        YINStockInventory.sendOrder(new List<Order> {closedOrder});

        List<Order> orders = new List<Order>();
        orders.add(closedOrder);
        orders.add(openOrder);

        return JSON.serialize(ordersByStatus);
    }

    private static void processProductWithVariant(YINProductWrapper wrapper,YINStockInventoryVarientWrap.YINData discountedProductData,OrderItem item){
        Decimal inventoryQty = Decimal.valueOf(discountedProductData.quantity);
        
            System.debug('Discounted OrderLineItem where Order Status = Closed ');
            Decimal quantityNeed = wrapper.quantity;
            // closedLineItemDiscount++;
            if(inventoryQty>0 && inventoryQty>=quantityNeed){
                OrderItem newItem = item.clone();
                newItem.Variant__c = variantByVariantCode.get(wrapper.variantCode).Id;
                newItem.Quantity = quantityNeed;
                newItem.OrderId = closedOrder.Id;
                itemToadd.add(newItem);
                itemSubmitted.add(newItem);
                System.debug('OrderId 4'+newItem.OrderId+'  item Id '+newItem.Product2Id);
                quantityNeed = 0;
            }else if(quantityNeed!=0 && inventoryQty>0){
                OrderItem newItem = item.clone();
                newItem.Variant__c = variantByVariantCode.get(wrapper.variantCode).Id;
                newItem.Quantity = inventoryQty;
                newItem.OrderId = closedOrder.Id;
                itemToadd.add(newItem);
                itemSubmitted.add(newItem);
                System.debug('OrderId 4'+newItem.OrderId+'  item Id '+newItem.Product2Id);
                quantityNeed = quantityNeed - inventoryQty;
            }

            if(quantityNeed>0){
                // Create Discounted Order "Status = Open"
                // Creating OrderItem and Attaching to Open Order, deleting item from Cart/Closed Order
                System.debug('Discounted OrderLineItem where Order Status = Open ');
                // openLineItemDiscount++;
                OrderItem newItem = item.clone();
                newItem.orderId = null;
                newItem.Variant__c = variantByVariantCode.get(wrapper.variantCode).Id;
                newItem.Quantity = quantityNeed;
                unitofworkProcessOrder.registerNew(newItem, OrderItem.OrderId, openOrder);
                itemToUpdate.add(newItem);
                itemOpen.add(newItem);
                deleteOpenOrder = false;
                System.debug('OrderId 5'+newItem.OrderId+'  item Id '+newItem.Product2Id);
            }
        
        itemToDelete.add(item);
    }

    private static void processProductWithoutVariant(YINProductWrapper wrapper,YINStockinventoryWrap.YINData normalProductData,OrderItem item){       
        Decimal quantityNeed = wrapper.quantity;
        for(YINStockinventoryWrap.YINVariantwise variantWise : normalProductData.variantwise){//2,4
            Integer availableQty = variantWise.inventory;
            String variantCode = variantWise.variant;
            if (availableQty >= quantityNeed && quantityNeed!=0) { // 1. 5>=12:false ,2. 6>=7:false,3. 0>=2  
                System.debug('Normal OrderLineItem where Order Status = Closed ');
                //closedLineItemNormal++;
                OrderItem newItem = item.clone();
                newItem.Variant__c = variantByVariantCode.get(variantWise.variant).Id;
                newItem.Quantity = quantityNeed;
                newItem.OrderId = closedOrder.Id;
                itemToadd.add(newItem);
                itemSubmitted.add(newItem);
                System.debug('OrderId 1'+newItem.OrderId+'  item Id '+newItem.Product2Id);
                quantityNeed = 0;
            }else if(quantityNeed!=0 && availableQty>0){ // 1. 5>=6:true ,2. 
                System.debug('Normal OrderLineItem where Order Status = Closed ');
                //closedLineItemNormal++;
                System.debug('item '+item);
                OrderItem newItem = item.clone();
                System.debug('map '+'key '+variantWise.variant+' value '+variantByVariantCode.get(variantWise.variant));
                newItem.Variant__c = variantByVariantCode.get(variantWise.variant).Id;
                newItem.Quantity = availableQty;
                newItem.OrderId = closedOrder.Id;
                itemToadd.add(newItem);
                itemSubmitted.add(newItem);
                System.debug('OrderId 2'+newItem.OrderId+'  item Id '+newItem.Product2Id);
                quantityNeed = quantityNeed - availableQty;
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
    

    private static List<OrderItem> reCalculate(List<OrderItem> items){
        for(OrderItem item:items){
            System.debug('OrderId '+item.OrderId+'  item Id '+item.Product2Id);
            Decimal netPrice = item.UnitPrice * item.Quantity;
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

            // Calculate Total Order value
            item.Total_Amount__c = netOrderValue + item.GST_Amount__c;

            // Calculate TCS
            item.TCS_Amount__c =  (netOrderValue * (item.TCS__c/100)); 
        }
        return items;
    }

    private static boolean checkCreditDays(List<YIN_Ledger__c> accountLedgers){
        
        Integer numberDaysDue = 0;

        if(accountLedgers.size()>0){
            Date oldestOpenPostingDate = accountLedgers[0].Posting_Date__c;
            Integer creditDays = accountLedgers[0].Dealer_Code__r.Credit_Days_Group_Dealer__c!=null?Integer.valueOf(accountLedgers[0].Dealer_Code__r.Credit_Days_Group_Dealer__c.removeEnd('D')):0;
            numberDaysDue = oldestOpenPostingDate.daysBetween(System.today());
            System.debug('creditDays '+creditDays +' numberDaysDue '+numberDaysDue);
            return creditDays >= numberDaysDue;
        }else{
            return true;// if no transcation found
        }
    }

    private static boolean checkCreditLimit(List<YIN_Ledger__c> accountLedgers,Decimal grandTotal){
        return (accountLedgers[0].Dealer_Code__r?.Available_Credit_Limit__c >= grandTotal);
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

            Boolean isDiscounted = wrapperProduct?.discountTable!=null?true:false;
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
            lineItem.TDS__c = wrapperProduct.tdsPercentage;
            lineItem.TDS_Amount__c = (netOrderValue * (lineItem.TDS__c/100));

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

    
    public class WrapCommit{
        @AuraEnabled public Boolean doCommit;
        @AuraEnabled public Decimal grandTotal;
        @AuraEnabled public String accountId;
    }
    
}