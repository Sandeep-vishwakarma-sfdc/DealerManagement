@RestResource(urlMapping='/order/deletecartitem')
global with sharing class YINOrderRestDelete {
    @HttpPost
    global static String deleteCartItem(String productWrapper,String accountId,String openOrderId){
        try{
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.deleteCartItem(productWrapper,accountId,openOrderId));
            return response;
        }catch(Exception e){
            return e.getMessage();
        }
    }
}