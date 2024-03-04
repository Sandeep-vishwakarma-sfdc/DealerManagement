@RestResource(urlMapping='/api/cart')
global with sharing class YINOrderCartRestService {
    

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