/**
 * @description       : This class Show all Query from Price Book Object.                                          
 * @author            : prashant.kumbhar@skinternational.com
 * @last modified on  : 10-11-2023
 * @last modified by  :  prashant.kumbhar@skinternational.com
**/

public without Sharing class  YINPriceBookSelector extends LIBSObjectSelector{
    public Schema.SObjectType getSObjectType(){
        return Pricebook2.SObjectType;
    }
    
/**
* @description:This method is used to define all the fields of Object.
* @return List<Schema.SObjectField>
*/ 
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Pricebook2.Id,
                Pricebook2.Name,
                Pricebook2.Customer__c,
                Pricebook2.Customer_Group__c,
                Pricebook2.Customer_Group__r.Name,
                Pricebook2.Type__c,    
                Pricebook2.IsActive,
                Pricebook2.IsDiscount__c,
                Pricebook2.Combination_Key__c,
                PriceBook2.Is_Discount_Price_Book__c
                };
    }
        
/**
* @description:This method is used to get All Pricebook.
* @return List<Pricebook2>
*/
    public List<Pricebook2> selectByActivePriceBook(){
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('IsActive =true AND IsDiscount__c=false');          
        System.debug('PriceBook Query in Application'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }
    
/**
* @description:This method is used to get All Pricebook data by active checkbox and Discount.
* @return List<Pricebook2>
*/    
    public List<Pricebook2> selectByActivePriceBookwithDiscount(){
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('IsActive =true AND IsDiscount__c=true');          
        System.debug('PriceBook Query in Application'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }
    
/**
* @description:This method is used to get All Pricebook data by active checkbox and based on Customer
* @return List<Pricebook2>
*/    
    public List<Pricebook2> priceBookbyCustomer(){
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('IsActive =true and Customer__c !=null');          
        System.debug('PriceBook Query in Application Customer'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }
    
/**
* @description:This method is used to get All Pricebook data by active checkbox and based on Customer Price Group
* @return List<Pricebook2>
*/    

    public List<Pricebook2> priceBookbyCustomerGroup(){
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('IsActive =true and Customer_Group__c !=null');          
        System.debug('PriceBook Query in Application Group'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }
    
/**
* @description:This method is used to get All Pricebook data by active checkbox and based on Comman Customer
* @return List<Pricebook2>
*/    
     
    public List<Pricebook2> priceBookbyCustomerComman(){
        String type='All Customer';
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('IsActive =true and IsDiscount__c=false and Customer_Group__c =null and Customer__c =null'+ ' And' +' '+ 'Type__c=\''+type+'\'');          
        System.debug('PriceBook Query in Application Group Comman'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }
    
/**
* @description:This method is used to get Standard Price Book.
* @return Pricebook2
*/    

    public Pricebook2 getStandardPriceBook(){
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('isStandard=true');          
        System.debug('Query is'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }
       
/**
* @description:This method is used to get ALl active and All Customer type Price Book.
* @return List<Pricebook2>
*/    
    public List<Pricebook2> selectByActivePriceBook1(){
        String type='All Customer';
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('IsActive =true AND IsDiscount__c=false'+ ' And' +' '+ 'Type__c=\''+type+'\'');          
        System.debug('PriceBook Query in Application'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }
    
/**
* @description:This method is used to get ALl active and All Customer type Price Book with Discount.
* @return List<Pricebook2>
*/    
    public List<Pricebook2> selectByActivePriceBookwithDiscount1(){
        String type='All Customer';
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('IsActive =true AND IsDiscount__c=true'+ ' And' +' '+ 'Type__c=\''+type+'\'');          
        System.debug('PriceBook Query in Application'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }
    
    
    
    
    /**
* @description:This method is used to get ALl active and All Customer type Price Book.
* @return List<Pricebook2>
*/    
    public List<Pricebook2> selectByActivePriceBook2(){
        String type='Customer';
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('IsActive =true AND IsDiscount__c=false and Customer__c !=null '+ ' And' +' '+ 'Type__c=\''+type+'\'');          
        System.debug('PriceBook Query in Application'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }
    
/**
* @description:This method is used to get ALl active and All Customer type Price Book with Discount.
* @return List<Pricebook2>
*/    
    public List<Pricebook2> selectByActivePriceBookwithDiscount2(){
        String type='Customer';
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('IsActive =true AND IsDiscount__c=true and Customer__c !=null '+ ' And' +' '+ 'Type__c=\''+type+'\'');          
        System.debug('PriceBook Query in Application'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }

    
    /**
* @description:This method is used to get ALl active and All Customer type Price Book.
* @return List<Pricebook2>
*/    
    public List<Pricebook2> selectByActivePriceBook3(){
        String type='Customer Price Group';
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('IsActive =true AND IsDiscount__c=false and Customer_Group__c !=null '+ ' And' +' '+ 'Type__c=\''+type+'\'');          
        System.debug('PriceBook Query in Application'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }
    
/**
* @description:This method is used to get ALl active and All Customer type Price Book with Discount.
* @return List<Pricebook2>
*/    
    public List<Pricebook2> selectByActivePriceBookwithDiscount3(){
        String type='Customer Price Group';
        LIBQueryFactory aQF = newQueryFactory()
            .setCondition('IsActive =true AND IsDiscount__c=true and Customer_Group__c !=null '+ ' And' +' '+ 'Type__c=\''+type+'\'');          
        System.debug('PriceBook Query in Application'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    } 

    public List<PriceBook2> selectPriceBookByCustomer(String accountId){
        String type = 'Customer';
        Boolean isActive = true;
        String query = newQueryFactory()
        .setCondition('Customer__c=:accountId and Type__c=:type and IsActive=:isActive and IsDiscount__c=false')
        .toSOQL();
        return Database.query(query);
    }

    public List<PriceBook2> selectPriceBookByCustomerGroup(List<String> customerGroups){
        String type = 'Customer Price Group';
        Boolean isActive = true;
        String query = newQueryFactory()
        .setCondition('Customer_Group__c IN:customerGroups and Type__c=:type and IsActive=:isActive and IsDiscount__c=false')
        .toSOQL();
        return Database.query(query);
    }

    
}