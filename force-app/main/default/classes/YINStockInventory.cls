public with sharing class YINStockInventory {
    
    public static Map<String,YINStockinventoryWrap.YINData> withoutVariant(List<YINProductWrapper> productWrappers){
        //1. Preparing payload
        YINStockinventoryWrap payloadWrap = new YINStockinventoryWrap();
        List<YINStockinventoryWrap.YINRequestbody> requestBody = new List<YINStockinventoryWrap.YINRequestbody>();
        for(YINProductWrapper wrapper:productWrappers){
            YINStockinventoryWrap.YINRequestbody body = new YINStockinventoryWrap.YINRequestbody();
            body.itemCode = wrapper.pricebookEntry.Product2.Product_Code__c;
            body.locationCode = wrapper.locationCode;
            requestBody.add(body);
        }

        payloadWrap.requestbody = requestBody;
        String payload = JSON.serialize(payloadWrap);

        //2. Requesting for stockinventory without variant
        String response = executeCallout('GET','/stockinventory',payload);
        

        //3. Preparing Map where key = ProductCode and Value = Response Data
        YINStockinventoryWrap dataWrap = (YINStockinventoryWrap)JSON.deserialize(response,YINStockinventoryWrap.class);
        Map<String,YINStockinventoryWrap.YINData> dataByProductCode = new Map<String,YINStockinventoryWrap.YINData>();
        for(YINStockinventoryWrap.YINData data:dataWrap.data){
            dataByProductCode.put(data.itemCode,data);
            data.variantwise.sort();
        }
        // Test
        String test = JSON.serialize(dataWrap);
        System.debug('response '+test);
        return dataByProductCode;
    }

    public static Map<String,YINStockInventoryVarientWrap.YINData> withVariant(List<YINProductWrapper> productWrappers){
        //1. Preparing payload
        YINStockInventoryVarientWrap payloadWrap = new YINStockInventoryVarientWrap();
        List<YINStockInventoryVarientWrap.YINRequestbody> requestBody = new List<YINStockInventoryVarientWrap.YINRequestbody>();
        for(YINProductWrapper wrapper:productWrappers){
            YINStockInventoryVarientWrap.YINRequestbody body = new YINStockInventoryVarientWrap.YINRequestbody();
            body.itemCode = wrapper.pricebookEntry.Product2.Product_Code__c;
            body.locationCode = wrapper.locationCode;
            body.variant = wrapper.variantCode;
            requestBody.add(body);
        }

        payloadWrap.requestbody = requestBody;
        String payload = JSON.serialize(payloadWrap);

        //2. Requesting for stock inventory with variant
        String response = executeCallout('GET','/stockinventoryvariant',payload);
        System.debug('response '+response);

        //3. Preparing Map where key = ProductCode_VariantCode and Value = Response Data
        YINStockInventoryVarientWrap dataWrap = (YINStockInventoryVarientWrap)JSON.deserialize(response,YINStockInventoryVarientWrap.class);
        Map<String,YINStockInventoryVarientWrap.YINData> dataByProductCode = new Map<String,YINStockInventoryVarientWrap.YINData>();
        for(YINStockInventoryVarientWrap.YINData data:dataWrap.data){
            dataByProductCode.put(data.itemCode+'_'+data.variant,data);
        }
        return dataByProductCode;
    }

    public static String sendOrder(List<Order> orders){
        // Prepare JSON from Orders
        YINSalesOrderWrap wrap = new YINSalesOrderWrap();
        String response = executeCallout('POST','/salesorder',JSON.serialize(wrap));
        return response;
    }



    private static String executeCallout (String method, String resourceName, String requestBody) {

        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint('callout:someNameCredential' + '/api/'+resourceName);
        request.setHeader('Accept', 'application/json');
        request.setTimeout(120000);
        request.setHeader('headerKey', 'headerValue');

        // If the callout includes a body (POST and PUT requests)
        if (String.isNotBlank(requestBody)) {
            request.setBody(requestBody);
            request.setHeader('Content-Type', 'application/json');
        }

        system.debug('### Callout Endpoint: ' + request.getEndpoint());
        system.debug('### Callout Method: ' + request.getMethod());
        system.debug('### Callout Body: ' + request.getBody());

        /* Execute the callout
        HttpResponse response = new Http().send(request);
        system.debug('### Xero Response Status: ' + response.getStatusCode() + ': ' + response.getStatus());
        system.debug('### Xero Response Body: ' + response.getBody());
        */
        return generateFakeResponse(resourceName);
        // return response;
    }  

    private static String generateFakeResponse(String resourceName){
        if(resourceName=='/stockinventoryvariant'){
            YINStockInventoryVarientWrap wrap = new YINStockInventoryVarientWrap();
            List<YINStockInventoryVarientWrap.YINData> bodies = new List<YINStockInventoryVarientWrap.YINData>();
            YINStockInventoryVarientWrap.YINData body = new YINStockInventoryVarientWrap.YINData();
            body.responseCode = '200';
            body.itemCode = 'PC-002';
            body.locationCode = 'IN-DL-DEL';
            body.variant = 'suzukiXL62021';
            body.quantity = '5';
            body.transitQuantity = '75';

            YINStockInventoryVarientWrap.YINData body1 = new YINStockInventoryVarientWrap.YINData();
            body1.responseCode = '200';
            body1.itemCode = 'PC-001';
            body1.locationCode = 'IN-DL-DEL';
            body1.quantity = '10';
            body1.transitQuantity = '75';

            bodies.add(body);
            bodies.add(body1);
            wrap.data = bodies;
            return JSON.serialize(wrap);
        }

        if(resourceName=='/stockinventory'){
            YINStockinventoryWrap wrap = new YINStockinventoryWrap();
            List<YINStockinventoryWrap.YINData> bodies = new List<YINStockinventoryWrap.YINData>();
            YINStockinventoryWrap.YINData body = new YINStockinventoryWrap.YINData();
            body.responseCode = '200';
            body.itemCode = 'PC-004';
            body.locationCode = 'IN-DL-DEL';
            body.totalInventory = '21';

            YINStockinventoryWrap.YINVariantwise variantwise1 = new YINStockinventoryWrap.YINVariantwise();
            variantwise1.variant = 'suzukiXL62021';
            variantwise1.inventory = 18;

            YINStockinventoryWrap.YINVariantwise variantwise2 = new YINStockinventoryWrap.YINVariantwise();
            variantwise2.variant = 'suzukiXL62022';
            variantwise2.inventory = 1; 

            YINStockinventoryWrap.YINVariantwise variantwise3 = new YINStockinventoryWrap.YINVariantwise();
            variantwise3.variant = 'suzukiXL62020';
            variantwise3.inventory = 2; 

            body.variantwise = new List<YINStockinventoryWrap.YINVariantwise>{variantwise1,variantwise2,variantwise3};


            YINStockinventoryWrap.YINData body1 = new YINStockinventoryWrap.YINData();
            body1.responseCode = '200';
            body1.itemCode = 'PC-005';
            body1.locationCode = 'IN-DL-DEL';
            body1.totalInventory = '2';

            YINStockinventoryWrap.YINVariantwise variantwise4 = variantwise1.clone();
            YINStockinventoryWrap.YINVariantwise variantwise5 = variantwise2.clone();
            YINStockinventoryWrap.YINVariantwise variantwise6 = variantwise3.clone();
            variantwise4.inventory = 1;
            variantwise5.inventory = 1;
            variantwise6.inventory = 0;
            body1.variantwise = new List<YINStockinventoryWrap.YINVariantwise>{variantwise4,variantwise5,variantwise6};

            YINStockinventoryWrap.YINData body2 = new YINStockinventoryWrap.YINData();
            body2.responseCode = '200';
            body2.itemCode = 'PC-001';
            body2.locationCode = 'IN-DL-DEL';
            body2.totalInventory = '2';

            YINStockinventoryWrap.YINVariantwise variantwise7 = variantwise1.clone();
            YINStockinventoryWrap.YINVariantwise variantwise8 = variantwise2.clone();
            YINStockinventoryWrap.YINVariantwise variantwise9 = variantwise3.clone();

            variantwise7.inventory = 5;
            variantwise8.inventory = 5;
            variantwise9.inventory = 0;
            body2.variantwise = new List<YINStockinventoryWrap.YINVariantwise>{variantwise7,variantwise8,variantwise9};

            bodies.add(body);
            bodies.add(body1);
            bodies.add(body2);
            wrap.data = bodies;
            return JSON.serialize(wrap);
        }

        if(resourceName=='/salesorder'){
            YINSalesOrderWrap wrap = new YINSalesOrderWrap();
            
            wrap.responseCode = '200';	
            wrap.message = 'Order created successfully';	
            wrap.erpCustomrCode = 'C000000234';	
            wrap.sfdcOrderNumber = 'SF0000342';	
            wrap.erpOrderNumber = 'SF00122';
            wrap.orderStatus = 'Invoice';
            wrap.status = 'Success';
        }
        return null;
    }

   
}