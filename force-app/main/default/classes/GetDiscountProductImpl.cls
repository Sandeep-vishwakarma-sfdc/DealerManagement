public with sharing class GetDiscountProductImpl implements IGetProducts {
    public List<ProductWrapper> getProducts(String accountId){
        
        List<ProductWrapper> discountProductWrappers = new List<ProductWrapper>();

        //1. Bring all Normal Products in a wrapper (let's say productWrappers)
        List<ProductWrapper> productWrappers = new GetAllProductImpl().getProducts(accountId);

        //2. Bring all Discounted Product in a wrapper (let's say discountedpriceList)
        List<Price_List__c> discountedpriceList = getDiscountedPriceList(accountId);

        //3. create a Map<combinationKey,Price_List__c> where {key='combinationKey',value=Price_List__c}
        Map<String,Price_List__c> priceListByCombinationKey = new Map<String,Price_List__c>();
        for(Price_List__c priceList:discountedpriceList){
            priceListByCombinationKey.put(priceList.SKU__r.Product_Code__c+priceList.SKU__r.Variant__r.Variant_Code__c,priceList);
        }

        //4. Add only those product which exist in discount product wrapper
        for (ProductWrapper productWrapper : productWrappers) {
            if(priceListByCombinationKey.get(productWrapper.combinationKey)!=null){
                // setting Discount Price TODO: update Unit_price__c with Discount Percentage Field
                productWrapper.discountPercentage = priceListByCombinationKey.get(productWrapper.combinationKey).Unit_Price__c;
                discountProductWrappers.add(productWrapper);
            }
        }

        return discountProductWrappers;
    }

    private List<Price_List__c> getDiscountedPriceList(String accountId){
        List<Price_List__c> priceList = new List<Price_List__c>();
        
        //1. check for customer price List
        priceList = getPriceListByCustomer(accountId);
        if(priceList.size()>0){
            return priceList;
        }

        //2. check for customer Group price List
        List<String> customeGroups = OrderManagementController.getCustomerGroupByCustomer(accountId);
        priceList = getPriceListByCustomerGroup(customeGroups);
        if(priceList.size()>0){
            return priceList;
        }

        //3. check for common price List
        priceList = getCommonPriceList();
        return priceList;
    }

    private static List<Price_List__c> getPriceListByCustomer(String accountId){
        List<Price_List__c> priceList = [select Id,Name,Dealer__c,Unit_Price__c,Customer_Group__c,SKU__c,SKU__r.Product_Code__c,SKU__r.Variant__r.Variant_Code__c,SKU__r.Variant__c,Discount_Type__c from Price_List__c where Dealer__c=:accountId and Start_Date__c <= TODAY and End_Date__c>=TODAY];
        return priceList;
    }

    private static List<Price_List__c> getPriceListByCustomerGroup(List<String> customerGroups){
        List<Price_List__c> priceList = [select Id,Name,Dealer__c,Unit_Price__c,Customer_Group__c,SKU__c,SKU__r.Product_Code__c,SKU__r.Variant__r.Variant_Code__c,SKU__r.Variant__c,Discount_Type__c from Price_List__c where Customer_Group__c IN:customerGroups and Start_Date__c <= TODAY and End_Date__c>= TODAY];
        return priceList;
    }

    private static List<Price_List__c> getCommonPriceList(){
        List<Price_List__c> priceList = [select Id,Name,Dealer__c,Unit_Price__c,Customer_Group__c,SKU__c,SKU__r.Product_Code__c,SKU__r.Variant__r.Variant_Code__c,SKU__r.Variant__c,Discount_Type__c from Price_List__c where Customer_Group__c=null and Dealer__c=null and Start_Date__c <= TODAY and End_Date__c>= TODAY];
        return priceList;
    }
}