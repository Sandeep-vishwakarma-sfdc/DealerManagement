@RestResource(urlMapping='/order/carts')
global with sharing class YINOrderRestCarts {
    @HttpGet
    global static String getCartDetails(){
        Map<String,String> params = RestContext.request.params;
        String accountId = params.get('accountId');
        String openOrderId = params.get('openOrderId');
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        String response = JSON.serialize(orderService.getCartDetails(accountId,openOrderId));
        return response;
    }

    @HttpPost
    global static String addToCart(String productWrapper,String accountId,String openOrderId){
        YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
        String response = JSON.serialize(orderService.addToCart(productWrapper,accountId,openOrderId));
        return response;
    }
           
    
}