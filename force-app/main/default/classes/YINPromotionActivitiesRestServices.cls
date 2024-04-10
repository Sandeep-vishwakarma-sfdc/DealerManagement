@RestResource(urlMapping='/promotionalactivity/activities')
global with sharing class YINPromotionActivitiesRestServices {
    
    @HttpGet
    global static String getActivities(){
            YINProductSelector productSelector = (YINProductSelector)YINApplication.selector.newInstance(Product2.SObjectType);
            return JSON.serialize(productSelector.getProductForOrderItem());
    }
    
}