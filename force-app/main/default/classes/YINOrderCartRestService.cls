@RestResource(urlMapping='/api/cart')
global with sharing class YINOrderCartRestService {
    @HttpGet
    global static String getCartLineItems(){
        // 1. Get Both Parameter via URL
        //String accountId = RestContext.request.params.get('orderType');

        // 2. Call Service Method
        //List<CartLineItem__c> cartLineItems = OrderManagementController.getCreditLimits(accountId);

        // 3. Convert and return JSON response
        //String jsonLineItems = JSON.serialize(cartLineItems);
        return 'Hello';
    }

    @HttpPost
    global static String addToCart (String requestBody,String recId){
        // 1. Get Body and Param
        String wrapperProduct = requestBody;
        String accountId = RestContext.request.params.get('accountId');

        // 2. Call Service Method
        //Boolean isSuccess = OrderManagementController.addToCart(wrapperProduct,accountId);
        return String.valueOf(true);
    }
}