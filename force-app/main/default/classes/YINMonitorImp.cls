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