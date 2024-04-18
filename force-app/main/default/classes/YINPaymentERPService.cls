/**
* @description    :  This class provides methods to interact with the ERP service for payment processing.
* 					 It includes methods for making callouts to the ERP service and handling responses.
* @author            : Kalpesh.Chande@skinternational.com
* @group             : SKI
* @last modified on  : 10-01-2024
* @last modified by  : Kalpesh.Chande@skinternational.com
**/
global without sharing class YINPaymentERPService {
    /**
* @description :Makes a callout to the ERP service to process payments.
* @param : recordId List of record IDs for payments to process.
* @return List of Responsewrapper objects containing response information.
*/
    @InvocableMethod(label='Call to erp service')
    public static List<Responsewrapper> callToERPService(List<String> recordId){
        YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
        YINMonitorService x=new  YINMonitorService();
        try{
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HTTPResponse res = new HTTPResponse();
            YINPaymentSelector PaymentSelector = (YINPaymentSelector)YINApplication.selector.newInstance(YIN_Payment__c.SObjectType);
            List<YIN_Payment__c> paymentList=PaymentSelector.getPaymentFromId(recordId[0]);
            YINUserSelector userSelector = (YINUserSelector)YINApplication.selector.newInstance(User.SObjectType);
            List<User> userList=userSelector.getUsersByAccountId(paymentList[0].Customer_Number__c);
             system.debug('userList>>>'+userList);
             Set<String> userSet=new Set<String>();
            if(!test.isRunningTest()){
            userSet.add(userList[0].Id);
            }
            system.debug('userSet>>>'+userSet);
            string jsonInput = '';
            string jsonstart =  '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Body>';
            string jsonend = '</Body></Envelope>';
            
            PaymentRequest reqWrap=new PaymentRequest();
            if(paymentList[0].RecordType.Name=='Security Deposit'){
                reqWrap.PaymentType = 'SD';
            }else if(paymentList[0].RecordType.Name=='Invoice'){
                reqWrap.PaymentType = 'Normal';
            }else{
                reqWrap.PaymentType = paymentList[0].RecordType.Name;
            }
            reqWrap.CustomerNo = paymentList[0].Customer_Number__r.ERP_Customer_Code__c;
            reqWrap.paymentCode =paymentList[0].Name;
            if(paymentList[0].Payment_Mode__c=='netbanking'){
              reqWrap.paymentMode = 'RTGS';  
            }else{
               reqWrap.paymentMode = paymentList[0].Payment_Mode__c; 
            }
            reqWrap.paymentDate = paymentList[0].Received_Date__c;
            reqWrap.paymentTime = paymentList[0].LastModifiedDate.format('HH:mm:ss');
            reqWrap.amount = paymentList[0].Amount__c;
            reqWrap.remittersName = paymentList[0].Remitters_Name__r.Name;
            reqWrap.id = paymentList[0].Razor_Pay_Order_Id__c	;
            reqWrap.orderId = paymentList[0].Order_Id__c;
            reqWrap.rrn = paymentList[0].rrn__c;
            reqWrap.upiTransactionId = paymentList[0].UPI_Transaction_Id__c;
            reqWrap.created_at =paymentList[0].created_at__c;
            reqWrap.fee = paymentList[0].Fee__c;
            reqWrap.tax = paymentList[0].Tax__c;
            reqWrap.cardId = paymentList[0].Card_Id__c; 
            reqWrap.bank =paymentList[0].Bank_Name__c;
            reqWrap.wallet = paymentList[0].Wallet__c;
            reqWrap.vpa = paymentList[0].Vpa__c;
            reqWrap.email = paymentList[0].Email__c;
            reqWrap.contact = paymentList[0].Contact_Number__c;
            reqWrap.razorpay_id=paymentList[0].Razor_Pay_Payment_Id__c;
            
            jsonInput='<GetPayment xmlns="urn:microsoft-dynamics-schemas/codeunit/SFDCIntegration"><requestMsg>'
                +JSON.serialize(reqWrap)+'</requestMsg></GetPayment>';
            string requestBody =  jsonstart+jsonInput+jsonend;
            req.setEndpoint('callout:YINErpServiceEx');
            req.setMethod('POST');
            System.debug('req body:' +requestBody);
            req.setBody(requestBody);
            res = http.send(req);
            System.debug('res body:' +res.getbody());
            String soapResponse = res.getbody();
            Dom.Document doc = new Dom.Document();
            doc.load(soapResponse);
            Dom.XmlNode root = doc.getRootElement();
            String nms1 = root.getNameSpace();
            string nms2 =''; 
            DOM.XmlNode body = root.getChildElement('Body', nms1);
            List<DOM.XMLNode> bodyChildrenList = body.getChildElements();
            for (DOM.XMLNode passRes : bodyChildrenList) {
                nms2 = passRes.getnamespace();
            }
            Dom.XmlNode result = body.getChildElement('GetPayment_Result', nms2);
            Dom.XmlNode requestMsgNode = result.getChildElement('requestMsg', nms2);
            String requestMsg = requestMsgNode.getText();
            system.debug('requestMsg>>>>'+requestMsg);
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(requestMsg);
            system.debug('jsonMap>>>>'+jsonMap);
            String success = (String)jsonMap.get('message');
            system.debug('success>>>>'+success);
            if(success=='success') { 
                paymentList[0].Erp_Service__c=true;
                update paymentList[0];
                List<YIN_Guest_User_Send_Notification__e> eventList =new List<YIN_Guest_User_Send_Notification__e>();
                for (String u : userSet) {
                    YIN_Guest_User_Send_Notification__e event = new YIN_Guest_User_Send_Notification__e();
                    event.Payment_Id__c = paymentList[0].Id;
                    event.User_Id__c = u;
                    event.Amount__c= paymentList[0].Amount__c;
                    eventList.add(event);
                }
                system.debug('success>>>>'+eventList);
                EventBus.publish(eventList);
                exceptionLog.apexClass = 'YINPaymentERPService';
                exceptionLog.recordId = paymentList[0].id;
                exceptionLog.module = 'YINPaymentERPService';
                exceptionLog.userId = UserInfo.getUserId();
                exceptionLog.request = requestBody;
                exceptionLog.response = res.getbody();
                exceptionLog.statusCode = '200';
                exceptionLog.typeOfIntegration = 'Outbound';
                exceptionLog.externalSystemName = 'YINErpServiceEx';
                exceptionLog.method = 'POST';
                exceptionLog.requestURL=requestBody;
                exceptionLog.typeOfIntegration='SFDC';
                x.requestResponseLog(exceptionLog);
            } else {
                String errorMsg = (String)jsonMap.get('error');
                Exception exception1 = new System.MathException();
                exception1.setMessage(errorMsg);
                exceptionLog.exObj = exception1;
                exceptionLog.statusCode = '400';
                exceptionLog.apexClass = 'YINPaymentERPService';
                exceptionLog.module = 'YINPaymentERPService';
                exceptionLog.userId = UserInfo.getUserId();
                x.exceptionHandler(exceptionLog);
            }
            //YINPaymentERPService.paymentERPServiceCallOut(requestBody);
        }catch(exception e){
            system.debug('exception>>>'+e);
            system.debug('exception>>>'+e.getLineNumber());
            exceptionLog.exObj = e;
            exceptionLog.statusCode = '400';
            exceptionLog.apexClass = 'YINPaymentERPService';
            exceptionLog.module = 'YINPaymentERPService';
            exceptionLog.userId = UserInfo.getUserId();
            x.exceptionHandler(exceptionLog);
        }
        return null;
    }
    webservice static void callErpService(Id payId){
        List<String> payList=new List<String>();
        payList.add(payId);
        YINPaymentERPService.callToERPService(payList);
    }
   
    /*  @future(callout=true)
private static void paymentERPServiceCallOut(string request) {
System.debug('inside' +request);
Http http = new Http();
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:YINErpServiceEx');
req.setMethod('POST');
req.setBody(request);
HttpResponse response = http.send(req);
System.debug('response' +response);
}*/
    public class PaymentRequest {
        public String PaymentType;
        public String CustomerNo;
        public String paymentCode;
        public String paymentMode;
        public Date paymentDate;
        public String paymentTime;
        public Decimal amount;
        public String remittersName;
        public String id;
        public String orderId;
        public String rrn;
        public String upiTransactionId;
        public Decimal created_at;
        public Decimal fee;
        public Decimal tax;
        public String cardId;
        public String bank;
        public decimal wallet;
        public String vpa;
        public String email;
        public String contact;
        public String razorpay_id;
    }
    
    public class Responsewrapper{
        @InvocableVariable public string massage;
        @InvocableVariable public String success;
    }
}