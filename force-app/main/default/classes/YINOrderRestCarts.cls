@RestResource(urlMapping='/order/carts')
global with sharing class YINOrderRestCarts {
    @HttpGet
    global static String getCartDetails(){
        try{
            Map<String,String> params = RestContext.request.params;
            String accountId = params.get('accountId');
            String openOrderId = params.get('openOrderId');
            String orderModuleType = params.get('orderModuleType');
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.getCartDetails(accountId,openOrderId,orderModuleType));
            return response;
        }catch(Exception e){
            return e.getMessage();
        }
    }

    @HttpPost
    global static String addToCart(String productWrapper,String accountId,String openOrderId){
        try{
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.addToCart(productWrapper,accountId,openOrderId));
            return response;
        }catch(Exception e){
            return e.getMessage();
        }
    }
           
    
}