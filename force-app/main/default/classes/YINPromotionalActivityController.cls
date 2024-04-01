/**
 * @description       : Controller class for YINPromotionalActivityImpl class.
 * @author            : saurabh.pandey@skinternational.com
 * @group             : SKI
 * @last modified on  : 03-20-2024
 * @last modified by  : saurabh.pandey@skinternational.com
**/
public without sharing class YINPromotionalActivityController{

    /**
     * Retrieves a list of Order Item records for promotional activity.
     * @return List<OrderItem> The list of Order Item records.
     */
    @AuraEnabled (cacheable = true)
    public static List<OrderItem> getOrderItemRecordsData(String recId){
        System.debug('recId'+recId);
        YINPromotionalActivityImpl impl = (YINPromotionalActivityImpl)YINApplication.service.newInstance(YINIPromotionalActivity.class);
        List<OrderItem> orderItemList = new List<OrderItem>();
        try {  
            orderItemList = impl.getCurrentOrderItemRecordData('Promotional Activity',recId);
            System.debug('orderlist'+orderItemList);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
        }
        return orderItemList;
    }

    @AuraEnabled
    public static List<Profile> getProfileById(){
        YINPromotionalActivityImpl impl = (YINPromotionalActivityImpl)YINApplication.service.newInstance(YINIPromotionalActivity.class);
        List<Profile> profileList = new List<Profile>();
        try {
            profileList = impl.getProfileName(new List<String>{userInfo.getProfileId()});
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            
        }
        return profileList;
    }

    /**
     * Retrieves product data and user account information for initializing the UI.
     * @return String Serialized JSON response containing product data and user account information.
    */
    @AuraEnabled
    public static string getOnLoadProductData(){
        YINMonitorService x=new  YINMonitorService();
        YINPromotionalActivityImpl impl = (YINPromotionalActivityImpl)YINApplication.service.newInstance(YINIPromotionalActivity.class);
        List<Product2> prodList= new List<Product2>(); 
        ResponseWrapper resWrap = new ResponseWrapper();
        List<ProductWrapper> prodWrapList =  new List<ProductWrapper>();
        List<User> userList = new List<User>();
        try {
            userList = impl.getCurrentUserAccount(userinfo.getUserId());
            resWrap.userAccount = userList[0].accountId??'0010T00000fYTVBQA4';
            System.debug('User Account'+resWrap.userAccount);
            prodList= impl.getPAProducts();
            if(prodList.size()>0){
                for(product2 p:prodList){
                    ProductWrapper pWrap = new ProductWrapper();
                    pWrap.id = p.id;
                    pWrap.name = p.Name;
                    prodWrapList.add(pWrap);
                }
                resWrap.status = 'Success';
                resWrap.message = '';
                resWrap.prodList = prodWrapList;
            }else {
                resWrap.status = 'Error';
                resWrap.message = 'No Records Found';
                resWrap.prodList = new List<ProductWrapper>();
            }
   

        } catch (Exception e) {
           System.debug(e.getMessage());
           System.debug(e.getLineNumber());
           YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
           exceptionLog.exObj = e;
           exceptionLog.recordId = '';
           exceptionLog.apexClass = 'YINPromotionalActivityController';
           exceptionLog.module = 'Promotional Activity';
           exceptionLog.userId = UserInfo.getUserId();
           x.exceptionHandler(exceptionLog);
           resWrap.status = 'Error';
           resWrap.message = e.getMessage();
           resWrap.prodList = new List<ProductWrapper>();
        }
        return Json.serialize(resWrap);
    }


    /**
     * Creates Order and OrderItem records based on the provided JSON data.
     * @param orderJson The JSON string containing order data.
     * @return String Serialized JSON response indicating the success or failure of the operation.
    */
    @AuraEnabled(cacheable=false)
    public static String createOrderAndItems(String orderJson) {
        YINMonitorService x=new  YINMonitorService();
        YINPromotionalActivityImpl impl = (YINPromotionalActivityImpl)YINApplication.service.newInstance(YINIPromotionalActivity.class);
        // Logic to create Order and OrderItem records
        ResponseWrapper response = new ResponseWrapper();
        OrderItemWrapper ordItemWrap = new OrderItemWrapper();
        try{
        OrderCreationWrapper ordWrap = (OrderCreationWrapper)Json.deserialize(orderJson,OrderCreationWrapper.class);
        String recTypeId = '';
        List<PriceBookEntry> pbList = new List<PriceBookEntry>();
        if(ordWrap != null){
            pbList = impl.getPriceBookEntry(ordWrap.orderProduct.productId);
            recTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Promotional_Activity').getRecordTypeId();
            Order orderRecord = new Order();
            if(String.isNotBlank(ordWrap.id)){
             orderRecord.id = ordWrap.id;
            }
            orderRecord.AccountId = ordWrap.accountId;
            orderRecord.RecordTypeId = recTypeId;
            orderRecord.EffectiveDate =System.today();
            orderRecord.Order_Date__c = System.today();
            System.debug('Order Date'+orderRecord.Order_Date__c );
            orderRecord.Description = ordWrap.description;
            orderRecord.Status = ordWrap.status;
            orderRecord.PriceBook2Id = pbList[0].PriceBook2Id;
            if(ordWrap.status == 'Approved' || ordWrap.status == 'Approved by Dealer' || ordWrap.status == 'Rejected by Dealer'){
                orderRecord.Allocated_Amount__c =ordWrap.allocatedAmount;
                orderRecord.Remarks__c = ordWrap.remarks;
            }
           
           List<Order> orderList =  impl.upsertOrderRecords(new List<Order> {orderRecord});
           System.debug('orderlist'+orderList);
           if(orderList.size()>0 && String.isBlank(ordWrap.Id)){
            System.debug('orderlist1'+orderList);
            OrderItem orderItemRecord = new OrderItem();

            orderItemRecord.OrderId = orderList[0].Id;
            System.debug('OrderId'+orderList);
            orderItemRecord.UnitPrice = ordWrap.orderProduct.unitPrice;
            System.debug('UnitPrice'+ ordWrap.orderProduct.unitPrice);
            orderItemRecord.Quantity = ordWrap.orderProduct.quantity;
            System.debug('Quantity'+orderList);
            orderItemRecord.Product2Id = ordWrap.orderProduct.productId;
            System.debug('Product2Id'+orderList);
            orderItemRecord.PricebookEntryId = pbList[0].id;
            System.debug('PricebookEntryId'+orderList);
            List<OrderItem> orderitemList =  impl.insertOrderItemRecords(new List<OrderItem>{orderItemRecord}); 
            System.debug('orderlist 123'+orderList);
           
           ordWrap.id = orderList[0].id;
          // ordWrap.name = orderList[0].name;
           ordWrap.status = orderList[0].Status;
           ordWrap.allocatedAmount = orderList[0].Allocated_Amount__c;
           ordWrap.accountId = orderList[0].accountId;
           ordWrap.description = orderList[0].Description;
           ordWrap.remarks = orderList[0].Remarks__c;
          // ordWrap.decision = ordWrap.decision;
          
           ordItemWrap.unitPrice = orderitemList[0].UnitPrice;
           ordItemWrap.productId =orderitemList[0].Product2Id;
            ordItemWrap.quantity = Integer.valueOf(orderitemList[0].Quantity);
            ordItemWrap.pricebookEntry = pbList[0].id;
            ordWrap.orderProduct = ordItemWrap;
           }
            
            response.status = 'Success';
            response.message = 'Order created successfully.';
            response.orderList = new List<OrderCreationWrapper>{ ordWrap };
           

        } 
        }catch (Exception e) {
            System.debug('Inside Catch'+e.getMessage());
            System.debug('Inside Catch'+e.getLineNumber());
            YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
            exceptionLog.exObj = e;
            exceptionLog.recordId = '';
            exceptionLog.apexClass = 'YINPromotionalActivityController';
            exceptionLog.module = 'Promotional Activity';
            exceptionLog.userId = UserInfo.getUserId();
            x.exceptionHandler(exceptionLog);
            response.status = 'Error';
            response.message = 'Error occurred while processing the request: ' + e.getMessage();

           
        }
        return Json.serialize(response);
        
    }

    public class OrderCreationWrapper {
        @AuraEnabled
        public String id { get; set; }
        // @AuraEnabled
        // public String name { get; set; }
        // @AuraEnabled
        // public String availableBudget { get; set; }
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public Decimal allocatedAmount { get; set; }
        @AuraEnabled
        public String accountId { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public String decision { get; set; }
        @AuraEnabled
        public String remarks { get; set; }
        @AuraEnabled
        public OrderItemWrapper orderProduct { get; set; }
        

        public OrderCreationWrapper(){
            id ='';
            status = '';
            allocatedAmount = 0;
            accountId = '';
            description ='';
            decision ='';
            remarks = '';
            orderProduct = new OrderItemWrapper();
           
        }
    }

    public class OrderItemWrapper{
   
        @AuraEnabled
        public Decimal unitPrice {get; set;}
        @AuraEnabled
        public String productId {get; set;}
        @AuraEnabled
        public Integer quantity {get; set;}
        @AuraEnabled
        public String pricebookEntry {get; set;}

        public OrderItemWrapper() {
            unitPrice = 0;
            productId ='';
            quantity = 0;
            pricebookEntry ='';
        }

    }

    public class ResponseWrapper{
		@AuraEnabled public String status;
		@AuraEnabled public String message;
        @AuraEnabled public String userAccount;
        @AuraEnabled public List<OrderCreationWrapper> orderList;
        @AuraEnabled public List<ProductWrapper> prodList;

		public ResponseWrapper(){
            
			status = '';
			message = '';
            userAccount = '';
            orderList = new List<OrderCreationWrapper>();
            prodList = new List<ProductWrapper>();
           
		}
	}

    public class ProductWrapper{
		@AuraEnabled public String id;
		@AuraEnabled public String name;

		public ProductWrapper(){
            
			id = '';
			name = '';
           
		}
	}
}