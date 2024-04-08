@RestResource(urlMapping='/promotionalactivity')
global with sharing class YINPromotionalActivityRestService {
/*
    POST : /services/apexrest/promotionalactivity/

    Create Promotinal Order with Products.
    req : {"orderJson":"{\"id\":\"\",\"status\":\"Pending\",\"subStatus\":\"\",\"allocatedAmount\":0,\"accountId\":\"0010T00000fYTVBQA4\",\"description\":\"Test02\",\"decision\":\"\",\"remarks\":\"\",\"availableBudget\":19600,\"orderProduct\":{\"unitPrice\":0,\"totalAmount\":0,\"productId\":\"01t0T000002HGRfQAO\",\"quantity\":1}}"}

    res: "{\"userAccount\":\"\",\"status\":\"Success\",\"prodList\":[],\"orderList\":[{\"subStatus\":null,\"status\":\"Pending\",\"remarks\":\"\",\"orderProduct\":{\"unitPrice\":0,\"totalAmount\":0,\"quantity\":1,\"productId\":\"01t0T000002HGRfQAO\",\"pricebookEntry\":\"01u0T000004B7fRQAS\"},\"id\":\"8010T000000NBAwQAO\",\"description\":\"Test 02\",\"decision\":\"\",\"availableBudget\":19600,\"allocatedAmount\":0,\"accountName\":\"Mahesh Tyres Pvt Ltd\",\"accountId\":\"0010T00000fYTVBQA4\"}],\"message\":\"Order created successfully.\"}"

    Update Allocated Amount Promotinal Order (Note , unitPrice & totalAmount must be equal to allocatedAmount)
    Req:
    {"orderJson":"{\"id\":\"8010T000000NBAwQAO\",\"status\":\"Approved\",\"subStatus\":\"ApprovedbyBRM\",\"allocatedAmount\":1000,\"accountId\":\"0010T00000fYTVBQA4\",\"description\":\"Test02\",\"decision\":\"Agree\",\"remarks\":\"ABC\",\"availableBudget\":19600,\"orderProduct\":{\"unitPrice\":1000,\"totalAmount\":1000,\"productId\":\"01t0T000002HGRfQAO\",\"quantity\":1}}"}

    Res: 
    "{\"userAccount\":\"\",\"status\":\"Success\",\"prodList\":[],\"orderList\":[{\"subStatus\":\"ApprovedbyBRM\",\"status\":\"Approved\",\"remarks\":\"ABC\",\"orderProduct\":{\"unitPrice\":1000,\"totalAmount\":1000,\"quantity\":1,\"productId\":\"01t0T000002HGRfQAO\",\"pricebookEntry\":null},\"id\":\"8010T000000NBAwQAO\",\"description\":\"Test02\",\"decision\":\"Agree\",\"availableBudget\":19600,\"allocatedAmount\":1000,\"accountName\":null,\"accountId\":\"0010T00000fYTVBQA4\"}],\"message\":\"Order created successfully.\"}"

    
*/

    @HttpPost
    global static string createOrderAndItems(String orderJson){
        try{
            return YINPromotionalActivityController.createOrderAndItems(orderJson);
        }catch(Exception e){
            return e.getMessage();
        }
    }



}