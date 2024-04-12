@RestResource(urlMapping='/order/deletecartitem')
global with sharing class YINOrderRestDelete {
    @HttpPost
    global static String deleteCartItem(String productWrapper,String accountId,String openOrderId){
        YINOrderRestCarts.ResponseWrapper res = new YINOrderRestCarts.ResponseWrapper();
        try{
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.deleteCartItem(productWrapper,accountId,openOrderId));
            res.status = 'success';
            res.data = response;
            return JSON.serialize(res);
        }catch(Exception e){
            res.status = 'error';
            res.message = e.getMessage();
            return JSON.serialize(res);
        }
    }
}