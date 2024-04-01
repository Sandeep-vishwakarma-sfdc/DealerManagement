/**
 * @description       : This class show all methods of interface so we can use in another class.                                          
 * @author            : prashant.kumbhar@skinternational.com
 * @last modified on  : 10-11-2023
 * @last modified by  :  prashant.kumbhar@skinternational.com
**/


public without Sharing  class YINMonitorService extends YINMonitorImp {

    /**
    * @description: Create Monitor record for Integration Class.
    * @param headers: Used to store headers in Monitor Log.
    * @param request: Used to store request in Monitor Log.
    * @param response: Used to store response in Monitor Log.
    * @param statusCode: Used to store StatusCode in Monitor Log.
    * @param apexClass: Used to store apex class name in Monitor Log.
    * @param recordId: Used to store recordId in Monitor Log.
    * @param module: Used to store module name on which we are working like Account, Sales order etc.
    * @param userId: Used to store logged in user information.
    * @param message: Used to store error or success message in Monitor Log.
    * @param typeOfIntegration: Used to store Which Type of Integration.
    * @param method: Used to store method in Monitor Log.
    * @param requestURL: Used to store url in Monitor Log.
    * @param remoteAddress: Used to store remote Address in Monitor Log.
    * @param headers: Used to store header in Monitor Log.
    * @param dataSource: Used to store dataSource in Monitor Log.
    * @param externalSystemName: Used to store externalSystemName in Monitor Log.
    * @return void. 
    */
    
    public override  void requestResponseLog(YINMonitorLogWrap wrap) {
        
        LIBISObjectUnitOfWork uow=YINApplication.unitOfWork.newInstance();
        String recordtypeId= Schema.SObjectType.YIN_Monitor_Log__c.getRecordTypeInfosByName().get('Log').getRecordTypeId();
        DateTime todayDate=DateTime.now();
        YIN_Monitor_Log__c monObj = new YIN_Monitor_Log__c();
        monObj.Name=wrap.apexClass;                                         
        monObj.Request_JSON__c=wrap.request;
        monObj.Response_JSON__c=wrap.response;
        monObj.Status_Code__c=wrap.statusCode;
        monObj.Apex_Class__c=wrap.apexClass;
        monObj.RecordId__c=wrap.recordId;
        monObj.Module__c=wrap.module;
        monObj.Loggin_User__c=wrap.userId;
        monObj.Error_Message__c=wrap.message;
        monObj.Date_Time__c=System.today();
        monObj.RecordTypeId=recordtypeId;
        monObj.Record_Type__c='Log';
        monObj.Type_Of_Integration__c=wrap.typeOfIntegration;
        monObj.Method__c=wrap.method;
        monObj.Request_URL__c=wrap.requestURL;
        monObj.Remote_Address__c=wrap.remoteAddress;
        monObj.Headers__c=wrap.headers;
        monObj.Data_Source__c=wrap.dataSource;
        monObj.External_System_Name__c=wrap.externalSystemName;
        uow.registerNew(monObj);   
        uow.commitWork();
        attachment(wrap.request,monObj,wrap.response);
    }
    public static void attachment(String request,YIN_Monitor_Log__c monObj,String response){
        LIBISObjectUnitOfWork uow=YINApplication.unitOfWork.newInstance();
        
        DateTime d = DateTime.Now() ;
        String dateString =  d.format('dd/MM/yyyy hh:mm a') ;
        System.debug(dateString);
        
        Attachment attObj = new Attachment();
        attObj.Name = 'Request '+dateString+'.csv';
        attObj.Body = Blob.valueOf(request);
        System.debug('Blob value is'+Blob.valueOf(request));
        attObj.ParentId = monObj.Id;
        uow.registerNew(attObj);
        System.debug('Attachet is'+attObj);        
        Attachment attObj2 = new Attachment();
        attObj2.Name = 'Response '+dateString+'.csv';
        attObj2.Body = Blob.valueOf(response);
        attObj2.ParentId = monObj.Id;
        uow.registerNew(attObj2);
        uow.commitWork();
    }
    
    /**
    * @description: Create Monitor record for Normal class.
    * @param apexClass: Used to store apex class name in Monitor Log.
    * @param recordId: Used to store recordId in Monitor Log.
    * @param module: Used to store module name on which we are working like Account, Sales order etc.
    * @param userId: Used to store logged in user information.
    * @param message: Used to store error or success message in Monitor Log.
    * @param method: Used to store method in Monitor Log.
    * @param headers: Used to store headers in Monitor Log.
    * @return void.
    */
    
    
    public  override void log(YINMonitorLogWrap wrap)
    {
        LIBISObjectUnitOfWork uow=YINApplication.unitOfWork.newInstance();
        YIN_Monitor_Log__c monObj = new YIN_Monitor_Log__c();
        monObj.Apex_Class__c=wrap.apexClass;
        monObj.Name=wrap.apexClass;
        monObj.RecordId__c=wrap.recordId;
        monObj.Module__c=wrap.module;
        monObj.Loggin_User__c=wrap.userId;
        monObj.Error_Message__c=wrap.message;
        monObj.Record_Type__c='Log';
        monObj.Headers__c=wrap.headers;
        monObj.Date_Time__c=DateTime.now();
        uow.registerNew(monObj);
        uow.commitWork();    
    }
    
    /**
    * @description: This method is used to create record in MonitorLog for Exception Handling 
    * @param exObj: Used to store exception error in Monitor log.
    * @param recordId: Used to store recordId in Monitor Log.
    * @param request: Used to store http request in Monitor log.
    * @param response: Used to  store http response in Monitor log.
    * @param apexClass: Used to store apex class name in Monitor Log.
    * @param module: Used to store module name on which we are working like Account, Sales order etc.
    * @return void.
    */
    
    public override void exceptionHandler(YINMonitorLogWrap wrap){
        
        LIBISObjectUnitOfWork uow=YINApplication.unitOfWork.newInstance();
        YIN_Monitor_Log__c monObj = new YIN_Monitor_Log__c(); 
        String recordtypeId= Schema.SObjectType.YIN_Monitor_Log__c.getRecordTypeInfosByName().get('Log').getRecordTypeId();
       // System.debug('The cause of error is'+wrap.exObj.getCause());
       // System.debug('The cause of error Line is'+wrap.exObj.getLineNumber());
       // System.debug('The cause of error Message is'+wrap.exObj.getMessage());
        
        if(wrap.exObj!=null){
            monObj.Error_Message__c = String.valueOf(wrap.exObj.getMessage());
            monObj.Name=wrap.apexClass; 
            monObj.RecordTypeId=recordtypeId;
            monObj.Module__c = wrap.module;
            monObj.Request_JSON__c=wrap.request;
            monObj.Response_JSON__c=wrap.response;
            monObj.RecordId__c=wrap.recordId; 
            monObj.Loggin_User__c = UserInfo.getUserId();
            monObj.Record_Type__c='Log';
            monObj.Apex_Class__c=wrap.apexClass;
            monObj.Module__c=wrap.module;
            monObj.Date_Time__c=DateTime.now();
            monObj.Status_Code__c=wrap.statusCode;
            uow.registerNew(monObj);
            uow.commitWork();              
        }     
    }
    
    /**
    * @Description - This method is used to reload records in MonitorLog from File. 
    * @param monitorId: Id of Monnitor Object.
    * @return  -    void
    */         
    public static void reloadRecords(String monitorId){    
        try{
            System.debug('Monitor Id is'+monitorId);
            LIBISObjectUnitOfWork uow=YINApplication.unitOfWork.newInstance();
            
            //Getting Content Document link based on Object Id. 
            
            LIBISObjectSelector selector= YINApplication.selector.newInstance(ContentDocumentLink.sObjectType);
            YINContentDocumentLinkSelector selectorObj=(YINContentDocumentLinkSelector)selector;
            ContentDocumentLink link=selectorObj.selectById(monitorId); 
            System.debug('ContentDocumentLink Is '+link);
            //Getting Content Version based on Content Document Id.
            Id docId=link.ContentDocumentId;
            System.debug('Doc Id is'+docId);
            
            LIBISObjectSelector selector1= YINApplication.selector.newInstance(ContentVersion.sObjectType);
            YINContentVersionSelector selectorObj1=(YINContentVersionSelector)selector1;
            ContentVersion con=selectorObj1.selectById(docId); 
            System.debug('ContentVersion is '+con);
            
            String stringBody = con.VersionData.tostring();
            list<String> filelines = stringBody.split('\n');
            list<YIN_Monitor_Log__c> monitorInsert = new list<YIN_Monitor_Log__c>();
            for (Integer i=1;i<filelines.size();i++)
            {
                list<String> columnValues = new list<String>();
                columnValues = filelines[i].split(',');
                system.debug('->'+columnValues);
                YIN_Monitor_Log__c a = new YIN_Monitor_Log__c();
                a.Name = columnValues[1];
                a.Apex_Class__c = columnValues[2];
                a.Concern__c=boolean.valueOf(columnValues[3]);   
                a.Concern_Person__c=(!String.isEmpty(String.valueof(columnValues[4]))  ? columnValues[4] :null);
                a.Date_Time__c=dateTime.valueOf(columnValues[5]);
                a.Error_Message__c=(!String.isEmpty(String.valueof(columnValues[6]))  ? columnValues[6] :null);
                a.Except_Module_Log__c=columnValues[7];
                a.Keep_log_for_last_X_days__c=Decimal.valueof((!String.isEmpty(String.valueof(columnValues[8]))  ? columnValues[8] :'0'));
                a.Loggin_User__c=(!String.isEmpty(String.valueof(columnValues[9]))  ? columnValues[9] :null);        
                a.Logging_Type__c=columnValues[10];
                a.Module__c=columnValues[11];
                a.Notification__c=boolean.valueOf(columnValues[12]);
                a.Notification_Email__c=columnValues[13];
                a.Purged_file_Name__c=columnValues[14];
                a.Purged_Status__c=columnValues[15];
                a.Purging_Mode__c=columnValues[16];
                a.Purging_Schedule__c=columnValues[17];
                a.Record_Type__c=columnValues[18];
                a.RecordId__c=columnValues[19];
                a.Request_JSON__c=columnValues[20];
                a.Response_JSON__c=columnValues[21];
                a.Schedule_Job_Id__c=columnValues[22];
                a.Status_Code__c=columnValues[23];
                a.Type_Of_Integration__c=columnValues[24];
                a.Method__c=columnValues[25];
                a.Request_URL__c=columnValues[26];
                a.Remote_Address__c=columnValues[27];
                a.Headers__c=columnValues[28];
                a.Data_Source__c=columnValues[29];
                a.External_System_Name__c=columnValues[30];
                a.Status__c=boolean.valueOf(columnValues[31]);
                
                monitorInsert.add(a);
            }
            if(monitorInsert.size()>0){
                uow.registerNew(monitorInsert);
                uow.commitWork();
                updateRecords(monitorId,'try');
            }
        }
        catch(Exception e)
        {
            System.debug('Message is'+e.getMessage());
            System.debug('Cause of Error is'+e.getCause());
            System.debug('Line Number'+e.getLineNumber());
            updateRecords(monitorId,'catch');
        }
    }
    
    /**
    * @Description - This method is used to update records in MonitorLog during Reloading of File. 
    * @param String -monitorId,trycatch
    * @return  -    void
    */     
    @future
    public static void updateRecords(String monitorId,String trycatch)
    {
        YIN_Monitor_Log__c monitor=new YIN_Monitor_Log__c();
        LIBISObjectUnitOfWork uow=YINApplication.unitOfWork.newInstance();
        
        if(trycatch=='try'){
            monitor.id=monitorId;
            monitor.ReloadStatus__c='Completed';
            uow.registerDirty(monitor);
            
            YIN_Monitor__mdt emailIds=[select MasterLabel,Email__c from YIN_Monitor__mdt where MasterLabel=:'EmailIds'];
            YIN_Monitor_Log__c getSchedularRecords=[select Id,Notification_Email__c,Notification__c from YIN_Monitor_Log__c where Id =:monitorId];
            
            String userEmailIds='';
            if(getSchedularRecords.Notification_Email__c !=null && getSchedularRecords.Notification__c==true)
            {
                userEmailIds=getSchedularRecords.Notification_Email__c;
            }
            else
            {
                userEmailIds=emailIds.Email__c;   
            }
            
            /*   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                   
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {userEmailIds});
            mail.setSubject('Monitor Log Records Reloaded Successfully');
            mail.setHtmlBody('Dear User,<br /><br />Your Monitor Log Records are Reloaded Successfully.<br /><br />Regards,<br/>Salesforce Administrator<br />');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });     */
        }
        else {
            monitor.id=monitorId;
            monitor.ReloadStatus__c='Failed';
            uow.registerDirty(monitor);
            YIN_Monitor__mdt emailIds=[select MasterLabel,Email__c from YIN_Monitor__mdt where MasterLabel=:'EmailIds'];
    /*         String userEmailIds=emailIds.Email__c;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                   
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] {userEmailIds});
            mail.setSubject('Monitor Log Records Reloaded Failed');
            mail.setHtmlBody('Dear User,<br /><br />Your Monitor Log Records are not Reloaded Successfully.<br /><br />Regards,<br/>Salesforce Administrator<br />');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });      */
            }
        uow.commitWork();
    }
    
    public static String getClassName(String line){
        if (line.startsWith('Class.')){
            line = line.substringAfter('Class.');
        }
        return line.substringBefore(':').substringBeforeLast('.');
        
    }
    public static String getMethod(String line){
        return line.substringBefore(':').substringAfterLast('.');
    }
    
    
    // Not in Use Start
    public override void requestResponseLog(String request, String response,String statusCode,String apexClass,String recordId,String module,String userId,
                                String message,String typeOfIntegration,String method,String requestURL,String remoteAddress,String headers,
                                String dataSource,String externalSystemName){ 
        }
    
     public override void log(String apexClass,String recordId,String module,String userId,String message,String headers){        
        }
    
     public override void exceptionHandler(Exception exObj,String recordId, String request,String response,String apexClass,String module){
            
        }
    
    // Not in Use End
    
    
    
    
    
    }