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
        String jsonWrap = JSON.serialize(payloadWrap);
        jsonWrap = removeNullValues(jsonWrap);
        String startXml = '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Body><GetInventoryNormalOrder xmlns="urn:microsoft-dynamics-schemas/codeunit/SFDCIntegration"><requestMsg>';
        String endXml = '</requestMsg></GetInventoryNormalOrder></Body></Envelope>';

        String payload = startXml+jsonWrap+endXml;
        System.debug('Payload '+payload);

        //2. Requesting for stockinventory without variant
        String response = executeCallout('GET','/stockinventory',payload);
        

        //3. Preparing Map where key = ProductCode and Value = Response Data
        YINStockinventoryWrap dataWrap = (YINStockinventoryWrap)JSON.deserialize(response,YINStockinventoryWrap.class);
        Map<String,YINStockinventoryWrap.YINData> dataByProductCode = new Map<String,YINStockinventoryWrap.YINData>();
        for(YINStockinventoryWrap.YINData data:dataWrap.data){
            dataByProductCode.put(data.itemCode,data);
            if(data.totalInventory!='0'){
                data.variantwise.sort();
            }
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
        String jsonWrap = JSON.serialize(payloadWrap);
        jsonWrap = removeNullValues(jsonWrap);
        String startXml = '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Body><GetInventory xmlns="urn:microsoft-dynamics-schemas/codeunit/SFDCIntegration"><requestMsg>';
        String endXml = '</requestMsg></GetInventory></Body></Envelope>';
        String payload = startXml+jsonWrap+endXml;

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

    public static String extractJsonData(String soapResponse,String childElementNode) {
        Dom.Document doc = new Dom.Document();
        doc.load(soapResponse);
        Dom.XmlNode root = doc.getRootElement();
        String nms1 = root.getNameSpace();
        string nms2 =''; 
        DOM.XmlNode body = root.getChildElement('Body', nms1);
        List<DOM.XMLNode> bodyChildrenList = body.getChildElements();
        for (DOM.XMLNode passRes : bodyChildrenList) {
        nms2 = passRes.getnamespace();
        }
        DOM.XmlNode getCustomerDetailsResult = body.getChildElement(childElementNode, nms2);
        DOM.XmlNode requestMsgNode = getCustomerDetailsResult.getChildElement('requestMsg', nms2);

        return requestMsgNode.getText();
    }

    public static String sendOrder(List<Order> orders){
        // Prepare JSON from Orders
        YINSalesOrderWrap reqBody = new YINSalesOrderWrap(); 
        if(orders.size()>0){
            Order submittingOrder = orders[0];
            Date dToday = Date.today();
            DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
            String orderedDate = dt.format('dd-MM-YYYY');
            System.debug('Date '+orderedDate);

            

            YINSalesOrderWrap.YINHeader wrap = new YINSalesOrderWrap.YINHeader();
            YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)YINApplication.selector.newInstance(OrderItem.SObjectType);
            
            YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
            List<Account> customers = accountSelector.getAccounts(new List<String>{submittingOrder.AccountId});
            List<Account> shipTo = accountSelector.getAccounts(new List<String>{submittingOrder.Ship_To_Party__c});
            List<OrderItem> items = orderItemSelector.selectByOrder(orders[0].Id);

            wrap.sfdcOrderNumber = submittingOrder.Name;	//SF0000342
            wrap.erpOrderNumber = '';	//
            wrap.erpCustomerCode = customers[0].SFDC_Customer_Code__c;	//C000000234
            wrap.orderDate = orderedDate;	//25-01-2024
            wrap.externalDocumentNumber = '';	//
            wrap.status = 'Closed';	//Closed
            wrap.erpShipToCode = shipTo[0].SFDC_Customer_Code__c;	//C000343
            wrap.remark = '';	//

            List<YINSalesOrderWrap.YINLines> lines = new List<YINSalesOrderWrap.YINLines>();
            for(OrderItem item:items){
                YINSalesOrderWrap.YINLines line = new YINSalesOrderWrap.YINLines();
                line.itemNumber = item.Id;	//10
                line.itemCode = item.Product2.ProductCode;	//FG-R1249
                line.variant = item.Variant__r.Variant_Code__c;	//2023
                line.quantity = String.valueOf(item.Quantity);	//4
                line.discount = String.valueOf(item.Discount_Percent__c);	//4
                line.discountAmount = String.valueOf(item.Discounted_Amount__c);	//
                line.unitPrice = String.valueOf(item.UnitPrice);	//1000
                line.tdstcsPercent=  String.valueOf(item.TDS__c);	//1
                line.tdstcsBaseAmount = '';	//
                line.tdstcsAmount = String.valueOf(item.TDS_Amount__c);	//
                line.type = submittingOrder.recordType.Name;	//Normal Order
                line.docketNo = '';	//
                line.discountType = '';	//Aged Discount
                line.discountRemark = '';	//
                line.gstPercent = String.valueOf(item.GST__c);	//28
                line.gstAmount = String.valueOf(item.GST_Amount__c);	//
                line.totalAmount = String.valueOf(item.Total_Amount__c);	//
                lines.add(line);
            }
            reqBody.header = wrap;
            reqBody.lines = lines;
        }
        
        String response = executeCallout('POST','/salesorder',JSON.serialize(reqBody));
        return response;
    }



    private static String executeCallout (String method, String resourceName, String requestBody) {
        Map<String,String> xmlChildNodeByResourceName = new Map<String,String>();
        xmlChildNodeByResourceName.put('/stockinventory','GetInventoryNormalOrder_Result');
        xmlChildNodeByResourceName.put('/stockinventoryvariant','GetInventory_Result');
        xmlChildNodeByResourceName.put('/salesorder','GetOrderDetails_Result');

        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint('callout:YINErpServiceEx');
        // request.setHeader('Accept', 'application/json');
        request.setTimeout(120000);
        // request.setHeader('headerKey', 'headerValue');

        // If the callout includes a body (POST and PUT requests)
        if (String.isNotBlank(requestBody)) {
            request.setBody(requestBody);
        }

        system.debug('### Callout Endpoint: ' + request.getEndpoint());
        system.debug('### Callout Method: ' + request.getMethod());
        system.debug('### Callout Body: ' + request.getBody());

        // Execute the callout
        HttpResponse response = new Http().send(request);
        system.debug('### Xero Response Status: ' + response.getStatusCode() + ': ' + response.getStatus());
        String body = response.getBody();
        system.debug('### Xero Response Body: ' + body);
        String jsonData = extractJsonData(response.getBody(),xmlChildNodeByResourceName.get(resourceName));
        return jsonData;
        //return generateFakeResponse(resourceName);
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
            variantwise1.inventory = '18';

            YINStockinventoryWrap.YINVariantwise variantwise2 = new YINStockinventoryWrap.YINVariantwise();
            variantwise2.variant = 'suzukiXL62022';
            variantwise2.inventory = '1'; 

            YINStockinventoryWrap.YINVariantwise variantwise3 = new YINStockinventoryWrap.YINVariantwise();
            variantwise3.variant = 'suzukiXL62020';
            variantwise3.inventory = '2'; 

            body.variantwise = new List<YINStockinventoryWrap.YINVariantwise>{variantwise1,variantwise2,variantwise3};


            YINStockinventoryWrap.YINData body1 = new YINStockinventoryWrap.YINData();
            body1.responseCode = '200';
            body1.itemCode = 'PC-005';
            body1.locationCode = 'IN-DL-DEL';
            body1.totalInventory = '2';

            YINStockinventoryWrap.YINVariantwise variantwise4 = variantwise1.clone();
            YINStockinventoryWrap.YINVariantwise variantwise5 = variantwise2.clone();
            YINStockinventoryWrap.YINVariantwise variantwise6 = variantwise3.clone();
            variantwise4.inventory = '1';
            variantwise5.inventory = '1';
            variantwise6.inventory = '0';
            body1.variantwise = new List<YINStockinventoryWrap.YINVariantwise>{variantwise4,variantwise5,variantwise6};

            YINStockinventoryWrap.YINData body2 = new YINStockinventoryWrap.YINData();
            body2.responseCode = '200';
            body2.itemCode = 'PC-001';
            body2.locationCode = 'IN-DL-DEL';
            body2.totalInventory = '2';

            YINStockinventoryWrap.YINVariantwise variantwise7 = variantwise1.clone();
            YINStockinventoryWrap.YINVariantwise variantwise8 = variantwise2.clone();
            YINStockinventoryWrap.YINVariantwise variantwise9 = variantwise3.clone();

            variantwise7.inventory = '5';
            variantwise8.inventory = '5';
            variantwise9.inventory = '0';
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
            return JSON.serialize(wrap);
        }
        return null;
    }

    public static String removeNullValues(String jsonString) {
        // Parse JSON string into a Map
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

        // Filter out null values
        jsonMap = removeNullValuesFromMap(jsonMap);

        // Serialize the Map back to JSON
        String updatedJsonString = JSON.serialize(jsonMap);

        return updatedJsonString;
    }

    private static Map<String, Object> removeNullValuesFromMap(Map<String, Object> inputMap) {
        Map<String, Object> resultMap = new Map<String, Object>();

        for (String key : inputMap.keySet()) {
            Object value = inputMap.get(key);

            // Recursively remove null values from nested maps
            if (value instanceof Map<String, Object>) {
                value = removeNullValuesFromMap((Map<String, Object>) value);
            }

            if (value != null) {
                resultMap.put(key, value);
            }
        }

        return resultMap;
    }

   
}