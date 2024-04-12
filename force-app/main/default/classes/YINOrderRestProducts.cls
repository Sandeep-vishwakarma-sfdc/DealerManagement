@RestResource(urlMapping='/order/products')
global with sharing class YINOrderRestProducts {
    @HttpGet
    global static String getProducts(){
        YINOrderRestCarts.ResponseWrapper res = new YINOrderRestCarts.ResponseWrapper();
        try{
            Map<String,String> params = RestContext.request.params;
            String accountId = params.get('accountId');
            String orderType = params.get('orderType');
            String orderModuleType = params.get('orderModuleType');
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.getProducts(accountId,orderType,orderModuleType));
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