@RestResource(urlMapping='/order/createorder')
global with sharing class YINOrderRestCreate {
    @HttpPost
    global static string createOrder(String productWrappers,String wrapCommit){
        try{
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.createOrder(productWrappers,wrapCommit));
            return response;
        }catch(Exception e){
            return e.getMessage();
        }
        
    }
}