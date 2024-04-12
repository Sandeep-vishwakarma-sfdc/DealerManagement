/**
 * @description       : This class extends the inerface so we can use in another class.                                          
 * @author            : prashant.kumbhar@skinternational.com
 * @last modified on  : 10-11-2023
 * @last modified by  :  prashant.kumbhar@skinternational.com
**/



public virtual  class  YINMonitorImp implements YINIMonitor{

    /**
    * @description: Create Monitor record for Integration Class.
    * @param MonitorLogWrap: Used to store exception error in Monitor log.
    * @return void.
    */
       
    public virtual void requestResponseLog(YINMonitorLogWrap wrap){
        System.debug('requestResponseLog');
    }
    
    // Not in Use Start
    public virtual void requestResponseLog(String request, String response,String statusCode,String apexClass,String recordId,String module,String userId,
                                String message,String typeOfIntegration,String method,String requestURL,String remoteAddress,String headers,
                                String dataSource,String externalSystemName){ 
        }
    
     public virtual void log(String apexClass,String recordId,String module,String userId,String message,String headers){        
        }
    
     public virtual void exceptionHandler(Exception exObj,String recordId, String request,String response,String apexClass,String module){
            
        }
    
    // Not in Use End
    
    /**
    * @description: Create Monitor record for Normal class.
    * @param YINMonitorLogWrap: Used to store exception error in Monitor log.
    * @return void.
    */
        
    public virtual void log(YINMonitorLogWrap wrap){
        System.debug('log');
    }
    
    /**
    * @description: This method is used to create record in MonitorLog for Exception Handling 
    * @param YINMonitorLogWrap: Used to store exception error in Monitor log.
    * @return void.
    */
        
    public virtual void exceptionHandler(YINMonitorLogWrap wrap){
        System.debug('exceptionHandler');
    }
    }