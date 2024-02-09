/**
 * @description       : This is interface class for Monitor Class.                                          
 * @author            : prashant.kumbhar@skinternational.com
 * @last modified on  : 10-11-2023
 * @last modified by  :  prashant.kumbhar@skinternational.com
**/

public interface YINIMonitor {
    
    /**
    * @description: Create Monitor record for Integration Class.
    * @param MonitorLogWrap: Used to store exception error in Monitor log.
    * @return void.
    */
      
    void requestResponseLog(YINMonitorLogWrap wrap);                            
    
    /**
    * @description: Create Monitor record for Normal class.
    * @param MonitorLogWrap: Used to store exception error in Monitor log.
    * @return void.
    */
    
    void log(YINMonitorLogWrap wrap);
    
    /**
    * @description: This method is used to create record in MonitorLog for Exception Handling 
    * @param MonitorLogWrap: Used to store exception error in Monitor log.
    * @return void.
    */
    
    void exceptionHandler(YINMonitorLogWrap wrap);
    
    }