@RestResource(urlMapping='/promotionalactivity/')
global with sharing class YINPromotionalActivityRestService {

    @HttpPost
    global static string createOrderAndItems(String orderJson){
        
            return YINPromotionalActivityController.createOrderAndItems(orderJson);
    }

}

/*
    Create Promotinal Order with Products.
    {
        "id": "",
        "status": "Pending",
        "subStatus": "",
        "allocatedAmount": 0,
        "accountId": "0010T00000fYTVBQA4",
        "description": "Test 02",
        "decision": "",
        "remarks": "",
        "availableBudget": 19600,
        "orderProduct": {
            "unitPrice": 0,
            "totalAmount": 0,
            "productId": "01t0T000002HGRfQAO",
            "quantity": 1
        }
    }

    Update Allocated Amount Promotinal Order
    {
        "id": "XXXXXXXXXXX",
        "status": "Approved",
        "subStatus": "",
        "allocatedAmount": 0,
        "accountId": "0010T00000fYTVBQA4",
        "description": "Test 02",
        "decision": "",
        "remarks": "",
        "availableBudget": 19600,
        "orderProduct": {
            "unitPrice": 0,
            "totalAmount": 0,
            "productId": "01t0T000002HGRfQAO",
            "quantity": 1
        }
    }

    
*/