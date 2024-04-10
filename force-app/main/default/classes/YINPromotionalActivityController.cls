/**
 * @description       : Controller class for YINPromotionalActivityImpl class.
 * @author            : saurabh.pandey@skinternational.com
 * @group             : SKI
 * @last modified on  : 04-04-2024
 * @last modified by  : saurabh.pandey@skinternational.com
**/
public without sharing class YINPromotionalActivityController{

    public static Map<String, User> userMap;
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

    
    
    /**
     * @description: Method to retrieve profiles by their IDs.
     * @return List<Profile>: A list of Profile records.
     */
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
            resWrap.userAccount = userList[0].accountId;
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
        system.debug('Orderjson'+orderJson);
        YINMonitorService x=new  YINMonitorService();
        List<EmailTemplate> emailtemp = new List<EmailTemplate>();
        Messaging.SendEmailResult[] emailResult = new List<Messaging.SendEmailResult>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        YINPromotionalActivityImpl impl = (YINPromotionalActivityImpl)YINApplication.service.newInstance(YINIPromotionalActivity.class);
        // Logic to create Order and OrderItem records
        ResponseWrapper response = new ResponseWrapper();
        OrderItemWrapper ordItemWrap = new OrderItemWrapper();
        try{
        OrderCreationWrapper ordWrap = (OrderCreationWrapper)Json.deserialize(orderJson,OrderCreationWrapper.class);
        String recTypeId = '';
        List<PriceBookEntry> pbList = new List<PriceBookEntry>();
        Account accountDetails = new Account();
        if(Test.isRunningTest() == false){
        accountDetails = YINOrderManagementImpl.getAccount(ordWrap.accountId); 
        }
        if(ordWrap != null){
            pbList = impl.getPriceBookEntry(ordWrap.orderProduct.productId);
            recTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Promotional_Activity').getRecordTypeId();
            Order orderRecord = new Order();
            if(String.isNotBlank(ordWrap.id)){
             orderRecord.id = ordWrap.id;
            }
            orderRecord.RecordTypeId = recTypeId;
            orderRecord.EffectiveDate =System.today();
            orderRecord.Order_Date__c = System.today();
            System.debug('Order Date'+orderRecord.Order_Date__c );
            orderRecord.Description = ordWrap.description;
            orderRecord.Status = ordWrap.status;
            system.debug('pblist'+pbList);
            orderRecord.PriceBook2Id = pbList[0].PriceBook2Id;
            orderRecord.Branded_Retail_Manager__c = accountDetails.Zone__r.Branded_Retail_Manager__c;
            orderRecord.Zonal_Head__c = accountDetails.Zone__r.Zonal_Manager__c;
            
            if(String.isNotBlank(ordWrap.AccountId)){
                 orderRecord.AccountId = ordWrap.accountId;
            }
           
           // orderRecord.TotalAmount = ordWrap.availableBudget;
            
            if(ordWrap.status == 'Approved' || ordWrap.status == 'Pending' || ordWrap.status == 'Approved by Dealer' || ordWrap.status == 'Rejected by Dealer'){
                orderRecord.Allocated_Amount__c =ordWrap.allocatedAmount;
                System.debug('Allocated_Amount__c'+orderRecord.Allocated_Amount__c);
                orderRecord.Remarks__c = ordWrap.remarks;
            }
           System.debug('OrderRecord'+orderRecord);
             List<Order> orderList = new List<Order>();
            if(!Test.IsRunningTest()){
               orderList =  impl.upsertOrderRecords(new List<Order> {orderRecord});
            }else{
                orderList = [select id,AccountId, RecordTypeId,EffectiveDate,Order_Date__c,Status,Sub_Status__c,Description,Pricebook2Id,Allocated_Amount__c,Remarks__c from Order];
            }
        
           System.debug('orderlist'+orderList);
           system.debug('ordwrap'+orderList.size());
           system.debug('ordwrap'+ordWrap.id);
           if(orderList.size()>0 && String.isBlank(ordWrap.Id)){
            
            System.debug('orderlist1'+orderList);
            OrderItem orderItemRecord = new OrderItem();

            orderItemRecord.OrderId = orderList[0].Id;
            System.debug('OrderId'+orderList);
            orderItemRecord.UnitPrice = orderList[0].Allocated_Amount__c;
            orderItemRecord.Total_Amount__c = orderList[0].Allocated_Amount__c;
            System.debug('UnitPrice'+ ordWrap.orderProduct.unitPrice);
            orderItemRecord.Quantity = ordWrap.orderProduct.quantity;
            System.debug('Quantity'+orderList);
            orderItemRecord.Product2Id = ordWrap.orderProduct.productId;
            System.debug('Product2Id'+orderList);
            orderItemRecord.PricebookEntryId = pbList[0].id;
            System.debug('PricebookEntryId'+orderList);
            List<OrderItem> orderitemList = new List<OrderItem>();
           if(Test.isRunningTest() == false){
           orderitemList =  impl.insertOrderItemRecords(new List<OrderItem>{orderItemRecord}); 
           }
            System.debug('orderlist 123'+orderList);
           List<Order> ordData = impl.getOrderData(orderList[0].id);
           ordWrap.id = orderList[0].id;
           ordWrap.subStatus = ordData[0].Sub_Status__c;
           ordWrap.status = orderList[0].Status;
           ordWrap.allocatedAmount = orderList[0].Allocated_Amount__c;
           System.debug('allocatedAmount'+orderList[0].Allocated_Amount__c);
           ordWrap.accountId = orderList[0].accountId;
           ordWrap.accountName = ordData[0].Account.Name;
           ordWrap.description = orderList[0].Description;
           ordWrap.remarks = orderList[0].Remarks__c;
          // ordWrap.decision = ordWrap.decision;
          
           ordItemWrap.unitPrice = orderList[0].Allocated_Amount__c;
           ordItemWrap.totalAmount = orderList[0].Allocated_Amount__c;
           ordItemWrap.productId =orderitemList[0].Product2Id;
            ordItemWrap.quantity = Integer.valueOf(orderitemList[0].Quantity);
            ordItemWrap.pricebookEntry = pbList[0].id;
            ordWrap.orderProduct = ordItemWrap;
           }else{
            OrderItem ordItem = new OrderItem();
            ordItem.id = [select id from OrderItem where OrderId =:orderList[0].id].id;
            ordItem.Total_Amount__c = orderList[0].Allocated_Amount__c;
            ordItem.UnitPrice = orderList[0].Allocated_Amount__c;
            //ordItem.ListPrice = orderList[0].Allocated_Amount__c;
            impl.updateOrderItemRecords(new List<OrderItem>{ordItem}); 
           }
           List<Order> ordData =  [select id,Status,Sub_Status__c,AccountId,Account.ownerId,Account.Name,Account.Contact_Person_Email__c,Allocated_Amount__c from Order where id = : orderList[0].id];
             // Send email notification based on decision
             if (ordWrap.decision == 'Agree') {
                system.debug('inside agree if');
                Messaging.SingleEmailMessage agreeEmail = sendAgreeEmailNotification(ordData[0]);
                if (agreeEmail != null) {
                    mails.add(agreeEmail);
                }
            } else if (ordWrap.decision == 'Disagree') {
                system.debug('inside idisagree if');
                Messaging.SingleEmailMessage disagreeEmail = sendDisagreeEmailNotification(ordData[0]);
                if (disagreeEmail != null) {
                    mails.add(disagreeEmail);
                }
            }
            
            if (!mails.isEmpty()) {
                emailResult = Messaging.sendEmail(mails);
                for (Messaging.SendEmailResult er : emailResult) {
                    if (!er.isSuccess()) {
                        System.debug('Error sending email: ' + er.getErrors()[0].getMessage());
                    }
                }
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


    
    /**
     * @description: Method to send Approval email notification to dealer.
     * @param ord: The Order record for which the email notification is to be sent.
     * @return Messaging.SingleEmailMessage: The email message to be sent.
     */
    public static Messaging.SingleEmailMessage sendAgreeEmailNotification(Order ord)
    {
        system.debug('inside single mail');
        YINPromotionalActivityImpl impl = (YINPromotionalActivityImpl)YINApplication.service.newInstance(YINIPromotionalActivity.class);
        //List<EmailTemplate> emailtemp = impl.getEmailTemplate('Allocated_Budget_Agreed');
        List<EmailTemplate> emailtemp = [SELECT Id, Name, DeveloperName, FolderName, Subject, HtmlValue, Body FROM EmailTemplate where DeveloperName = 'Allocated_Budget_Agreed'];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSenderDisplayName('Yokohama Smart services');                         
        email.setTemplateID(emailtemp[0].id);
        email.setTargetObjectId(ord.Account.ownerId);
        email.setToAddresses(new String[] {ord.Account.Contact_Person_Email__c});
        email.setWhatId(ord.Id);
        email.setSaveAsActivity(false);
        return email;        
    }

     /**
     * @description: Method to send Rejection email notification to dealer.
     * @param ord: The Order record for which the email notification is to be sent.
     * @return Messaging.SingleEmailMessage: The email message to be sent.
     */
     public static Messaging.SingleEmailMessage sendDisagreeEmailNotification(Order ord)
     {
         system.debug('inside single mail2');
         YINPromotionalActivityImpl impl = (YINPromotionalActivityImpl)YINApplication.service.newInstance(YINIPromotionalActivity.class);
        //  List<EmailTemplate> emailtemp = impl.getEmailTemplate('Allocated_Budget_Disagree')
        List<EmailTemplate> emailtemp = [SELECT Id, Name, DeveloperName, FolderName, Subject, HtmlValue, Body FROM EmailTemplate where DeveloperName = 'Allocated_Budget_Disagree'];
         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
         email.setSenderDisplayName('Yokohama Smart services');                         
         email.setTemplateID(emailtemp[0].id);
         email.setTargetObjectId(ord.Account.ownerId);
         email.setToAddresses(new String[] {ord.Account.Contact_Person_Email__c});
         email.setWhatId(ord.Id);
         email.setSaveAsActivity(false);
         return email;        
     }

     /**
     * @description: Method to create and send custom notifications for the provided list of Balance Confirmation records.
     * @param balanceConfirmationList: List of Balance Confirmation records for which custom notifications are sent.
     * @return void.
     */
    @AuraEnabled
    public static String createAndSendCustomNotifications(String orderList) {
        system.debug('inside notification '+orderList);
        String response= '';
        YINPromotionalActivityImpl impl = (YINPromotionalActivityImpl)YINApplication.service.newInstance(YINIPromotionalActivity.class);
        List<String> ordIds = (List<String>)Json.deserialize(orderList,List<String>.class);
        Set<Id> recordIds = new Set<Id>();
        Set<String> userIds = new Set<String>();
        try{
        for(String s:ordIds){
        recordIds.add(s);
        }
        List<order> ordList  = impl.getOrderList(recordIds);
        userMap = new Map<String,User>();
        List<User> userList = impl.getUserList(); 
        system.debug('userlist'+userList.size());
        for(User u : userList){
            userMap.put(u.AccountId,u);
        }
        system.debug('inside createAndSendCustomNotifications'+ordList.Size());
        system.debug('OrderList'+ordList);

       Messaging.CustomNotification notification = new Messaging.CustomNotification();
       CustomNotificationType notificationType = new CustomNotificationType();
        // Fetch all necessary custom notification types outside the loop
        CustomNotificationType allocatedBudgetAgreedNotification = impl.getCustomNotification('Allocated_Budget_Agreed_Notification');
        CustomNotificationType allocatedBudgetDisagreedNotification = impl.getCustomNotification('Allocated_Budget_disagreed_Notification');
        CustomNotificationType allocatedBudgetNotification = impl.getCustomNotification('Allocated_Budget_Notification');
        CustomNotificationType allocatedBudgetRejectedNotification = impl.getCustomNotification('Allocated_Budget_Rejected_Notification');
        //CustomNotificationType allocatedBudgetApprovedByBRHNotification = impl.getCustomNotification('Allocated_Budget_Approved_By_ZM');
        //CustomNotificationType allocatedBudgetRejectedByBRHNotification = impl.getCustomNotification('Allocated_Budget_Rejected_By_ZM');
        CustomNotificationType allocatedBudgetApprovedByBRHNotification = impl.getCustomNotification('Allocated_Budget_Approved_By_BRH_Notification');
        CustomNotificationType allocatedBudgetRejectedByBRHNotification = impl.getCustomNotification('Allocated_Budget_Rejected_By_BRH_Notification');

    for(Order ord:ordList){
    String targetId = ord.id; // Adjust this based on your requirements
    if(ord.RecordType.Name == 'Promotional Activity'){
        if (ord.status == 'Approved by Dealer' && ord.Sub_Status__c == 'Approved by BRM') {
            system.debug('inside if');
            notificationType = allocatedBudgetAgreedNotification;
            notification.setTitle('Allocated Budget Agreed  Notification'); // Update title based on notification type
           notification.setBody('Allocated Budget of '+ord.Allocated_Amount__c+' Rupees is agreed by dealer '+ord.Account.Name); // Update body based on notification type


        } else if (ord.status == 'Rejected by Dealer' && ord.Sub_Status__c == 'Approved by BRM') {
            system.debug('inside if1');
            notificationType = allocatedBudgetDisagreedNotification;
            notification.setTitle('Allocated Budget disagreed Notification'); // Update title based on notification type
            notification.setBody('Allocated Budget of '+ord.Allocated_Amount__c+' Rupees is disagreed by dealer '+ord.Account.Name); // Update body based on notification type


        } else if (ord.status == 'Approved' && ord.Sub_Status__c == 'Approved by BRM') {
            system.debug('inside if2');
            notificationType = allocatedBudgetNotification;
            notification.setTitle('Allocated Budget Notification'); // Update title based on notification type
        notification.setBody('Your Allocated Budget is '+ord.Allocated_Amount__c+' Rupees'); // Update body based on notification type

        } else if (ord.status == 'Rejected' && ord.Sub_Status__c == 'Rejected by BRM') {
            system.debug('inside if3');
            notificationType = allocatedBudgetRejectedNotification;
            notification.setTitle(' Allocated Budget Reject- Send Back Notification'); // Update title based on notification type
        notification.setBody('Allocated Budget of '+ord.Allocated_Amount__c+' Rupees is Reject - send Back for dealer '+ord.Account.Name); // Update body based on notification type

        }
        /*else if (ord.status == 'Approved by Dealer' && ord.Sub_Status__c == 'Approved by ZM') {
            system.debug('inside if4');
            notificationType = allocatedBudgetApprovedByBRHNotification;
            notification.setTitle('Allocated Budget Approved  Notification'); // Update title based on notification type
        notification.setBody('Allocated Budget of '+ord.Allocated_Amount__c+' Rupees is approved for dealer '+ord.Account.Name); // Update body based on notification type

        } else if (ord.status == 'Rejected by Dealer' && ord.Sub_Status__c == 'Rejected by ZM') {
            system.debug('inside 5');
            notificationType = allocatedBudgetRejectedByBRHNotification;
            notification.setTitle('Allocated Budget Rejected  Notification'); // Update title based on notification type
            notification.setBody('Allocated Budget of '+ord.Allocated_Amount__c+' Rupees is rejected for dealer '+ord.Account.Name); // Update body based on notification type

        }*/
        else if (ord.status == 'Approved by Dealer' && ord.Sub_Status__c == 'Approved by BRH') {
            system.debug('inside if4');
            notificationType = allocatedBudgetApprovedByBRHNotification;
            notification.setTitle('Allocated Budget Approved  Notification'); // Update title based on notification type
        notification.setBody('Allocated Budget of '+ord.Allocated_Amount__c+' Rupees is approved for dealer '+ord.Account.Name); // Update body based on notification type

        } else if (ord.status == 'Rejected by Dealer' && ord.Sub_Status__c == 'Rejected by BRH') {
            system.debug('inside 5');
            notificationType = allocatedBudgetRejectedByBRHNotification;
            notification.setTitle('Allocated Budget Rejected  Notification'); // Update title based on notification type
            notification.setBody('Allocated Budget of '+ord.Allocated_Amount__c+' Rupees is rejected for dealer '+ord.Account.Name); // Update body based on notification type


        }
        notification.setTargetId(targetId);
        userIds.add(userMap.get(ord.accountId).id);
    }
}
        if(notificationType != null){
            
            notification.setNotificationTypeId(notificationType.Id);
            // Populate userMap based on your logic
            // if (test.isRunningTest()) {
            //  userMap.put(ord.AccountId,[select id from User where id =: userInfo.getUserId()]);
            // }
            
            notification.send(userIds);
            response = 'success';
        }else{
           response = '';
        }
    }catch(Exception e){
        system.debug('Exception '+e.getMessage());
        system.debug('Exception Line Number '+e.getLineNumber());
        response = 'error';

    }
    return response;
        
    }
    
    

    

    public class OrderCreationWrapper {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public Decimal availableBudget { get; set; }
        @AuraEnabled
        public String subStatus { get; set; }
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public Decimal allocatedAmount { get; set; }
        @AuraEnabled
        public String accountId { get; set; }
        @AuraEnabled
        public String accountName { get; set; }
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
            availableBudget=0;
            status = '';
            subStatus = '';
            allocatedAmount = 0;
            accountId = '';
            accountName ='';
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
        public Decimal totalAmount {get; set;}
        @AuraEnabled
        public String productId {get; set;}
        @AuraEnabled
        public Integer quantity {get; set;}
        @AuraEnabled
        public String pricebookEntry {get; set;}

        public OrderItemWrapper() {
            unitPrice = 0;
            totalAmount =0;
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