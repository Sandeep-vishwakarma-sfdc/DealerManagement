@RestResource(urlMapping='/api/creditlimit')
global with sharing class YINOrderCreditLimitRestService {
    @HttpGet
    global static String getCreditLimits(){
        // 1. Get Both Parameter via URL
        String accountId = RestContext.request.params.get('accountId');

        // 2. Call Service Method
        String jsonCreditLimits  = YINOrderManagementController.getCartDetails(accountId);

        return jsonCreditLimits;
    }
}