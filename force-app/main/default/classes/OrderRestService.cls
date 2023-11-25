@RestResource(urlMapping='api/order')
global with sharing class OrderRestService {
    @Httpost
    global static String createOrder(){
        // 1. Get Both Parameter via URL
        String accountId = RestContext.request.params.get('accountId');

        // 2. Call Service Method
        Order__c order = OrderManagementController.createOrder(accountId);
        String jsonOrder = JSOn.serialize(order);
        return jsonOrder;
    }
}