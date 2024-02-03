@RestResource(urlMapping='/order/deletecartitem')
global with sharing class YINOrderRestDelete {
    @HttpPost
    global static String deleteCartItem(String productWrapper,String accountId,String openOrderId){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        String response = JSON.serialize(orderService.deleteCartItem(productWrapper,accountId,openOrderId));
        return response;
    }
}