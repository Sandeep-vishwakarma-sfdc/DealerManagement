@RestResource(urlMapping='/promotionalorder')
global with sharing class YINPromotionalOrderRestService {
    @HttpGet
    global static String getLedgerInfo(){
        YINOrderRestCarts.ResponseWrapper res = new YINOrderRestCarts.ResponseWrapper();
        try{
            Map<String,String> params = RestContext.request.params;
            String accountId = params.get('accountId');
            String recordType = params.get('recordType');
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.getCurrentYearQuaterledger(accountId,recordType));
            res.status = 'success';
            res.data = response;
            return JSON.serialize(res);
        }catch(Exception e){
            res.status = 'error';
            res.message = e.getMessage();
            return JSON.serialize(res);
        }
    }

    @HttpPost
    global static string sendForApproval(String productWrappers,String shipToCode){
        YINOrderRestCarts.ResponseWrapper res = new YINOrderRestCarts.ResponseWrapper();
        try{
            YINIOrderManagement orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
            String response = JSON.serialize(orderService.promotionalOrderSendForApproval(productWrappers,shipToCode));
            res.status = 'success';
            res.data = response;
            return JSON.serialize(res);
        }catch(Exception e){
            res.status = 'error';
            res.message = e.getMessage();
            return JSON.serialize(res);
        }
    }

}
/*


1) To get Products
GET : /services/apexrest/order/products
parameters :
accountId : '001XXXXXXXXXX'
orderType : 'All'
orderModuleType : 'Promotional'

2) To get Promotional budget info for a Dealer e.g 
GET : /services/apexrest/promotionalorder/
parameters :
accountId : '001XXXXXXXXXX'
recordType : 'Promotional_Budget'

3) To get Cart Details
GET : /services/apexrest/order/carts
parameters :
accountId : '001XXXXXXXXXX'
openOrderId : '' // keep blank for promotional order
orderModuleType : 'Promotional'

4) Add to Cart (Same as Order Api)
GET : /services/apexrest/addToCart (see order api parameters)

5) To send promotional order for approval
POST : /services/apexrest/promotionalorder/
body : {"productWrappers":"[{\"combinationKey\":\"PC-003\",\"discountPercentage\":0,\"gstAmount\":100800,\"gstPercentage\":28,\"locationCode\":\"IN-DL-DEL\",\"maximumCappingQuantity\":24,\"netPrice\":360000,\"orderItemId\":\"8020T000001VMJlQAO\",\"pricebookEntry\":{\"Combination_Key__c\":\"CommonPriceBookPricePC-003\",\"End_Date__c\":\"2024-04-06\",\"Id\":\"01u0T0000048vSCQAY\",\"IsActive\":true,\"Name\":\"XL6 Alpha 2022\",\"Pricebook2Id\":\"01s0T000000BMp9QAG\",\"Product2Id\":\"01t0T000001inuxQAA\",\"ProductCode\":\"PC-003\",\"Sales_Price__c\":5399,\"Start_Date__c\":\"2024-02-25\",\"UnitPrice\":8000,\"UseStandardPrice\":false,\"Pricebook2\":{\"Combination_Key__c\":\"CommonPriceBookPrice\",\"Id\":\"01s0T000000BMp9QAG\",\"IsActive\":true,\"IsDiscount__c\":false,\"Is_Discount_Price_Book__c\":false,\"Name\":\"PriceBook-Common\",\"Type__c\":\"All Customer\"},\"Product2\":{\"Description\":\"185/65/R15\r\nFRONT/REAR\r\nXL6\r\nAlpha\r\nPETROL\r\n2022\",\"GST_Group__c\":\"G28%\",\"GST__c\":28,\"Image_Url__c\":\"https://yokohama-india--dev.sandbox.my.site.com/smartconnect//resource/Earth_1\",\"IsActive\":true,\"Item_Category_Code__c\":\"TIRE_I\",\"Minimum_Quantity__c\":10,\"Name\":\"XL6 Alpha 2022\",\"ProductCode\":\"PC-003\",\"Product_Code__c\":\"PC-003\",\"Size__c\":\"14\",\"Tire_Size__c\":\"175/65R14 82H\",\"Tread_Pattern__c\":\"Pattern-2022\",\"Id\":\"01t0T000001inuxQAA\"}},\"priceList\":{},\"productId\":\"01t0T000001inuxQAA\",\"productOfTheMonth\":false,\"quantity\":45,\"tcsPercentage\":0.1,\"tdsPercentage\":0,\"totalAmount\":\"460800.00\",\"trendingSKU\":false,\"unitPrice\":5399,\"discountAmount\":\"0.00\"}]"}

*/