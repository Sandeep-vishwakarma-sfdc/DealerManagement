public with sharing class GetDiscountProductImpl implements IGetProducts {
    public List<ProductWrapper> getProducts(String accountId){
        
        List<ProductWrapper> discountProductWrappers = new List<ProductWrapper>();

        //1. Bring all Normal Products in a wrapper (let's say productWrappers)
        List<ProductWrapper> productWrappers = new GetAllProductImpl().getProducts(accountId);

        //2. Bring all Discounted Product in a wrapper (let's say discountedpriceList)
        List<Price_List__c> discountedPriceList = getDiscountedPriceList(accountId);

        //3. Store Product and its related prices in a Map
        Map<String,List<Price_List__c>> priceListByProductId = new Map<String,List<Price_List__c>>();
        for(Price_List__c price :discountedPriceList){
            if(!priceListByProductId.containsKey(price.Product__c)){
                priceListByProductId.put(price.Product__c,new List<Price_List__c>());
            }
            priceListByProductId.get(price.Product__c).add(price);
        }

        //4. filter productWrappers to minimize search processing time
        List<ProductWrapper> newProductWrapper = new List<ProductWrapper>();
        for(ProductWrapper originalWrapper:productWrappers){
            if(priceListByProductId.containsKey(originalWrapper.productId)){
                // Adding productWrapper Which has Product same as PriceList
                newProductWrapper.add(originalWrapper);
            }
        }
        //5. Finally creating Discounted Product 
        for( ProductWrapper originalWrapper:newProductWrapper){
        List<Price_List__c> prices = priceListByProductId.get(originalWrapper.productId);
            if(prices.size()>0){
                for(Price_List__c price:prices){
                    ProductWrapper discountWrapper = new ProductWrapper();

                    discountWrapper.pricebookEntry = originalWrapper.pricebookEntry;
                    discountWrapper.productId = originalWrapper.productId;
                    discountWrapper.productOfTheMonth = originalWrapper.productOfTheMonth;
                    discountWrapper.trendingSKU = originalWrapper.trendingSKU;
                    discountWrapper.lockingSKU = originalWrapper.lockingSKU;
                    discountWrapper.cappingSKU = originalWrapper.cappingSKU;
                    discountWrapper.maximum_Order_Quantity = originalWrapper.maximum_Order_Quantity;
                    discountWrapper.quantity = originalWrapper.quantity;
                    discountWrapper.lineItemSubTotal = originalWrapper.lineItemSubTotal;
                    discountWrapper.GSTPercentage = originalWrapper.GSTPercentage;

                    discountWrapper.discountPercentage = price.Discount_Price__c;// TODO: Change Discount Price to Discount Percentage
                    discountWrapper.discountType = price.Discount_Type__c;
                    discountWrapper.priceList = price;
                    discountWrapper.minimum_Order_Quantity = price.Minimum_Quantity__c;
                    discountWrapper.combinationKey = price.Product__r.Product_Code__c + price.Variant__r.Variant_Code__c + price.Minimum_Quantity__c;
                    discountProductWrappers.add(discountWrapper);
                }
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
        PriceListSelector priceListSelector = (PriceListSelector)Application.selector.newInstance(Price_List__c.SObjectType);
        List<Price_List__c> priceList = priceListSelector.selectPriceListByCustomer(accountId);
        return priceList;
    }

    private static List<Price_List__c> getPriceListByCustomerGroup(List<String> customerGroups){
        PriceListSelector priceListSelector = (PriceListSelector)Application.selector.newInstance(Price_List__c.SObjectType);
        List<Price_List__c> priceList = priceListSelector.selectPriceListByCustomerGroup(customerGroups);
        return priceList;
    }

    private static List<Price_List__c> getCommonPriceList(){
        PriceListSelector priceListSelector = (PriceListSelector)Application.selector.newInstance(Price_List__c.SObjectType);
        List<Price_List__c> priceList = priceListSelector.selectCommonPriceList();
        return priceList;
    }
}