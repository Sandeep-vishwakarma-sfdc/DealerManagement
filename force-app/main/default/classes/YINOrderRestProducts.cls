@RestResource(urlMapping='/order/products')
global with sharing class YINOrderRestProducts {
    @HttpGet
    global static String getProducts(){
        try{
            Map<String,String> params = RestContext.request.params;
            String accountId = params.get('accountId');
            String orderType = params.get('orderType');
            String orderModuleType = params.get('orderModuleType');
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.getProducts(accountId,orderType,orderModuleType));
            return response;
        }catch(Exception e){
            return e.getMessage();
        }
    }
}