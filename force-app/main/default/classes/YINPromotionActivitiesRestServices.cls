@RestResource(urlMapping='/promotionalactivity/activities')
global with sharing class YINPromotionActivitiesRestServices {
    /*
    GET /services/apexrest/promotionalactivity/activities
    */

    @HttpGet
    global static String getActivities(){
        try{
            YINProductSelector productSelector = (YINProductSelector)YINApplication.selector.newInstance(Product2.SObjectType);
            return JSON.serialize(productSelector.getProductForOrderItem());
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
}