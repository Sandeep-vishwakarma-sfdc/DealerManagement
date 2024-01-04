public with sharing class YINGetDiscountProductImpl implements YINIGetProducts {
    public List<YINProductWrapper> getProducts(String accountId){
        
        
        Map<String,List<YINProductWrapper.DiscountTable>> discountProductWrappersByKey = new Map<String,List<YINProductWrapper.DiscountTable>>();

        //1. Bring all Normal Products in a wrapper (let's say productWrappers)
        List<YINProductWrapper> productWrappers = new YINGetAllProductImpl().getProducts(accountId);

        //2. Bring all Discounted Product in a wrapper (let's say discountedpriceList)
        List<YIN_Price_List__c> discountedPriceList = getDiscountedPriceList(accountId);

        //3. Store Product and its related prices in a Map
        Map<String,List<YIN_Price_List__c>> priceListByProductId = new Map<String,List<YIN_Price_List__c>>();
        for(YIN_Price_List__c price :discountedPriceList){
            if(!priceListByProductId.containsKey(price.Product__c)){
                priceListByProductId.put(price.Product__c,new List<YIN_Price_List__c>());
            }
            priceListByProductId.get(price.Product__c).add(price);
        }

        //4. filter productWrappers to minimize search processing time
        List<YINProductWrapper> newProductWrapper = new List<YINProductWrapper>();
        for(YINProductWrapper originalWrapper:productWrappers){
            if(priceListByProductId.containsKey(originalWrapper.productId)){
                // Adding productWrapper Which has Product same as PriceList
                newProductWrapper.add(originalWrapper);
            }
        }
        //5. Finally creating Discounted Product 
        List<YINProductWrapper> discountProductWrappersWithDiscounts = getDiscountedItems(newProductWrapper,priceListByProductId,discountProductWrappersByKey);

        return discountProductWrappersWithDiscounts;
    }

    private static List<YINProductWrapper> getDiscountedItems(List<YINProductWrapper> newProductWrapper,Map<String,List<YIN_Price_List__c>> priceListByProductId,Map<String,List<YINProductWrapper.DiscountTable>> discountProductWrappersByKey){
        List<YINProductWrapper> discountProductWrappers = new List<YINProductWrapper>();
        for( YINProductWrapper originalWrapper:newProductWrapper){
            List<YIN_Price_List__c> prices = priceListByProductId.get(originalWrapper.productId);
                if(prices.size()>0){
                    for(YIN_Price_List__c price:prices){
                        YINProductWrapper discountWrapper = new YINProductWrapper();
    
                        discountWrapper.pricebookEntry = originalWrapper.pricebookEntry;
                        discountWrapper.productId = originalWrapper.productId;
                        discountWrapper.productOfTheMonth = originalWrapper.productOfTheMonth;
                        discountWrapper.trendingSKU = originalWrapper.trendingSKU;
                        discountWrapper.lockingSKUAccount = originalWrapper.lockingSKUAccount;
                        discountWrapper.lockingSKULocation = originalWrapper.lockingSKULocation;
                        discountWrapper.maximumOrderQuantity = originalWrapper.maximumOrderQuantity;
                        discountWrapper.quantity = originalWrapper.quantity;
                        discountWrapper.unitPrice = originalWrapper.unitPrice;
                        
                
                        discountWrapper.discountPercentage = price.Discount_Price__c;// TODO: Change Discount Price to Discount Percentage
                        discountWrapper.discountType = price.Discount_Type__c;
                        discountWrapper.priceList = price;
                        discountWrapper.productName = originalWrapper.productName;
                        discountWrapper.productSize = originalWrapper.productSize;
                        discountWrapper.productPattern = originalWrapper.productPattern;
                        discountWrapper.minimumOrderQuantity = price.Minimum_Quantity__c;
                        discountWrapper.combinationKey = price.Product__r.Product_Code__c + price.Variant__r.Variant_Code__c;
                        discountWrapper.maximumCappingQuantity = originalWrapper.maximumCappingQuantity;

                        discountWrapper.GSTPercentage = originalWrapper.GSTPercentage;
                        discountWrapper.tdsPercentage = originalWrapper.tdsPercentage;
                        discountWrapper.tcsPercentage = originalWrapper.tcsPercentage;

                        discountWrapper.applyTCS = originalWrapper.applyTCS;

                        discountProductWrappers.add(discountWrapper);
    
                        if(!discountProductWrappersByKey.containsKey(price.Product__r.Product_Code__c + price.Variant__r.Variant_Code__c)){
                            discountProductWrappersByKey.put(price.Product__r.Product_Code__c + price.Variant__r.Variant_Code__c,new List<YINProductWrapper.DiscountTable>());
                        }
                        
                        YINProductWrapper.DiscountTable table = new YINProductWrapper.DiscountTable();
                        table.minimumOrderQuantity = price.Minimum_Quantity__c;
                        table.discountPercentage = price.Discount_Price__c;// TODO: Change Discount Price to Discount Percentage
                        discountProductWrappersByKey.get(price.Product__r.Product_Code__c + price.Variant__r.Variant_Code__c).add(table);
    
                    }
                }
            }
    
            List<YINProductWrapper> discountProductWrappersWithDiscounts = new List<YINProductWrapper>();
            Set<String> checkDuplicates = new Set<String>();
            for (YINProductWrapper discountWrapper : discountProductWrappers) {
                if(checkDuplicates.add(discountWrapper.combinationKey)){
                    discountWrapper.discountTable = discountProductWrappersByKey.get(discountWrapper.combinationKey);
                    discountProductWrappersWithDiscounts.add(discountWrapper);
                }
            }
            return discountProductWrappersWithDiscounts;
    }

    private List<YIN_Price_List__c> getDiscountedPriceList(String accountId){
        List<YIN_Price_List__c> priceList = new List<YIN_Price_List__c>();
        
        //1. check for customer price List
        priceList = getPriceListByCustomer(accountId);
        if(priceList.size()>0){
            return priceList;
        }

        //2. check for customer Group price List
        List<String> customeGroups = YINGetAllProductImpl.getCustomerGroupByCustomer(accountId);
        priceList = getPriceListByCustomerGroup(customeGroups);
        if(priceList.size()>0){
            return priceList;
        }

        //3. check for common price List
        priceList = getCommonPriceList();
        return priceList;
    }

    private static List<YIN_Price_List__c> getPriceListByCustomer(String accountId){
        YINPriceListSelector priceListSelector = (YINPriceListSelector)YINApplication.selector.newInstance(YIN_Price_List__c.SObjectType);
        List<YIN_Price_List__c> priceList = priceListSelector.selectPriceListByCustomer(accountId);
        return priceList;
    }

    private static List<YIN_Price_List__c> getPriceListByCustomerGroup(List<String> customerGroups){
        YINPriceListSelector priceListSelector = (YINPriceListSelector)YINApplication.selector.newInstance(YIN_Price_List__c.SObjectType);
        List<YIN_Price_List__c> priceList = priceListSelector.selectPriceListByCustomerGroup(customerGroups);
        return priceList;
    }

    private static List<YIN_Price_List__c> getCommonPriceList(){
        YINPriceListSelector priceListSelector = (YINPriceListSelector)YINApplication.selector.newInstance(YIN_Price_List__c.SObjectType);
        List<YIN_Price_List__c> priceList = priceListSelector.selectCommonPriceList();
        return priceList;
    }
}