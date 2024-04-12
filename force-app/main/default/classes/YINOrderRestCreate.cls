@RestResource(urlMapping='/order/createorder')
global with sharing class YINOrderRestCreate {
    @HttpPost
    global static string createOrder(String productWrappers,String wrapCommit){
        YINOrderRestCarts.ResponseWrapper res = new YINOrderRestCarts.ResponseWrapper();
        try{
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.createOrder(productWrappers,wrapCommit));
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