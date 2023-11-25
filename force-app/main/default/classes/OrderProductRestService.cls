@RestResource(urlMapping='/api/products')
public with sharing class OrderProductRestService {
    @HttpGet
    global static String getProducts(){
        // 1. Get Both Parameter via URL
        String accountId = RestContext.request.params.get('accountId');
        String orderType = RestContext.request.params.get('orderType');

        // 2. Call Service Method
        List<ProductWrapper> productsWrapper = OrderManagementController.getProducts(accountId,String orderType);
        
        // 3. Convert and return JSON response
        String jsonProducts = JSON.serialize(productsWrapper);
        return jsonProducts;
    }

}