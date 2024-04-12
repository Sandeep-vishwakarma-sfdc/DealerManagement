@RestResource(urlMapping='/order/carts')
global with sharing class YINOrderRestCarts {
    @HttpGet
    global static String getCartDetails(){
        ResponseWrapper res = new ResponseWrapper();
        try{
            Map<String,String> params = RestContext.request.params;
            String accountId = params.get('accountId');
            String openOrderId = params.get('openOrderId');
            String orderModuleType = params.get('orderModuleType');
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.getCartDetails(accountId,openOrderId,orderModuleType));
            res.status = 'success';
            res.data = response;
            return JSON.serialize(res);
        }catch(Exception e){
            res.status = 'error';
            res.message = e.getMessage();
            return JSON.serialize(res);
        }
    }

    @HttpPost
    global static String addToCart(String productWrapper,String accountId,String openOrderId){
        ResponseWrapper res = new ResponseWrapper();
        try{
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.addToCart(productWrapper,accountId,openOrderId));
            
            res.status = 'success';
            res.data = response;
            return JSON.serialize(res);
        }catch(Exception e){
            res.status = 'error';
            res.message = e.getMessage();
            return JSON.serialize(res);
        }
    }
           
    public class ResponseWrapper{
        public String status;
        public String data;
        public String message;
    }
}