/**
 * @description       : This class Show all Query from Price List Object.                                          
 * @author            : prashant.kumbhar@skinternational.com
 * @last modified on  : 10-11-2023
 * @last modified by  :  prashant.kumbhar@skinternational.com
**/

public without Sharing class YINPriceListSelector extends LIBSObjectSelector{
    public Schema.SObjectType getSObjectType(){
        return YIN_Price_List__c.SObjectType;
    }
    
    /**
    * @description:This method is used to define all the fields of Object
    * @return List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            YIN_Price_List__c.Id,
                YIN_Price_List__c.Name,
                YIN_Price_List__c.Customer__c,
                YIN_Price_List__c.Customer_Group__c,
                YIN_Price_List__c.Customer_Group__r.Name,
                YIN_Price_List__c.Product__c,    
                YIN_Price_List__c.Price__c,
                YIN_Price_List__c.Start_Date__c,
                YIN_Price_List__c.End_Date__c,
                YIN_Price_List__c.Combination_Key__c,
                YIN_Price_List__c.Latest_Update_Status__c,
                YIN_Price_List__c.Customer__r.Name,
                YIN_Price_List__c.Discount_Price__c,
                YIN_Price_List__c.OnDemand__c,
                YIN_Price_List__c.CreatedDate,
                YIN_Price_List__c.Unit_Price__c, 
                YIN_Price_List__c.Variant__c,
                YIN_Price_List__c.Discount_Type__c,
                YIN_Price_List__c.Minimum_Quantity__c
              
                };
            }
    
    /**
    * @description:This method is used to get Price List whose Status is Open
    * @return Database.QueryLocator
    */
        
    public Database.QueryLocator allPriceList(){
        String status='Open';
        string query;
        query = 'SELECT Id, Name, Customer__c,Customer__r.Name,Customer__r.Account_Code__c,Customer_Group__c,Customer_Group__r.Name,Customer_Group__r.Group_Code__c, Product__c,Product__r.ProductCode,Price__c, Start_Date__c, End_Date__c, Combination_Key__c, Latest_Update_Status__c,Discount_Price__c,CreatedDate  FROM YIN_Price_List__c Where Latest_Update_Status__c=';
        query=query+ '\''+status+'\'' +' '+'order by CreatedDate Asc';
        System.debug('Query is'+query);       
        return Database.getQueryLocator(query);
    }
    
    /**
    * @description:This method is used to get Price List whose Status is Open and On demand checkbox is true
    * @return Database.QueryLocator
    */    
    public Database.QueryLocator allPriceListonDemand(){
        boolean strParameter=true;
        String status='Open';
        string query;
        query = 'SELECT Id, Name, Customer__c,Customer__r.Name,Customer__r.Account_Code__c, Customer_Group__c,Customer_Group__r.Name,Customer_Group__r.Group_Code__c, Product__c,Product__r.ProductCode,Price__c, Start_Date__c, End_Date__c, Combination_Key__c, Latest_Update_Status__c,Discount_Price__c,CreatedDate  FROM YIN_Price_List__c Where Latest_Update_Status__c=';
        query=query+ '\''+status+'\''+' AND OnDemand__c='+strParameter +' '+'order by CreatedDate Asc';
        System.debug('Query Seond is'+query);       
        return Database.getQueryLocator(query);
    }
        
    /**
    * @description:This method is used to get Price List whose Status is in progress.
    * @return List<YIN_Price_List__c>
    */    
        
    public List<YIN_Price_List__c> selectInprogressPriceList(){
        String status='In progress';    
        LIBQueryFactory aQF = newQueryFactory();
            aQF.setCondition('Latest_Update_Status__c=\''+status+'\'');
            aQF.setLimit(9000); 
        System.debug('PriceList Query in Application'+aQF.toSOQL());    
        return Database.query( aQF.toSOQL());
    }
    
    /**
    * @description:This method is used to get Price List based on RecordId.
    * @return YIN_Price_List__c
    */    
    public YIN_Price_List__c selectById(Id recordIds){
        LIBQueryFactory query = newQueryFactory();
        query.setCondition('Id =:recordIds');
        System.debug('Query is'+query.toSOQL());
        return Database.query( query.toSOQL());    
    }
    
    /**
    * @description:This method is used to get Price List Based on Trigger.
    * @return List<YIN_Price_List__c>
    */   
        public List<YIN_Price_List__c> selectByTriggerAll1(){
        boolean strParameter=false;
        String status='Open';
        string query;
        query = 'SELECT Id, Name, Customer__c,Customer__r.Name,Customer__r.Account_Code__c,Customer_Group__c,Customer_Group__r.Name,Customer_Group__r.Group_Code__c, Product__c,Product__r.ProductCode, Price__c, Start_Date__c, End_Date__c, Combination_Key__c, Latest_Update_Status__c,Discount_Price__c,CreatedDate  FROM YIN_Price_List__c Where Latest_Update_Status__c=';
        query=query+ '\''+status+'\''+' AND OnDemand__c='+strParameter +' '+'order by CreatedDate Asc';
        System.debug('Query Seond is'+query);       
        return Database.query(query);
    }
        
        
     public Database.QueryLocator allPriceList1(){
        String status='In progress';
        string query;
        query = 'SELECT Id, Name, Customer__c,Customer__r.Name,Customer__r.Account_Code__c,Customer_Group__c,Customer_Group__r.Name,Customer_Group__r.Group_Code__c, Product__c,Product__r.ProductCode,Price__c, Start_Date__c, End_Date__c, Combination_Key__c, Latest_Update_Status__c,Discount_Price__c,CreatedDate  FROM YIN_Price_List__c Where Latest_Update_Status__c=';
        query=query+ '\''+status+'\'' +' '+'order by CreatedDate Asc';
        System.debug('Query is'+query);       
        return Database.getQueryLocator(query);
    }
    
    public List<YIN_Price_List__c> selectPriceListByCustomer(String accountId){
        String status = 'Approved';
        String query =  newQueryFactory()
        .selectField('Variant__r.Variant_Code__c')
        .selectField('Product__r.Product_Code__c')
        .setCondition('Customer__c=:accountId and Start_Date__c <= TODAY and End_Date__c>=TODAY and Discount_Type__c !=null and Status__c=:status')
        .setOrdering('Minimum_Quantity__c',LIBQueryFactory.SortOrder.ASCENDING, false)
        .toSOQL();  
        return Database.query(query);
    }
       
    public List<YIN_Price_List__c> selectPriceListByCustomerGroup(List<String> customerGroups){
        String status = 'Approved';
        String query =  newQueryFactory()
        .selectField('Variant__r.Variant_Code__c')
        .selectField('Product__r.Product_Code__c')
        .setCondition('Customer_Group__c IN:customerGroups and Start_Date__c <= TODAY and End_Date__c>= TODAY and Discount_Type__c !=null and Status__c=:status')
        .setOrdering('Minimum_Quantity__c',LIBQueryFactory.SortOrder.ASCENDING, false)
        .toSOQL();  
        return Database.query(query);
    }
    
    public List<YIN_Price_List__c> selectCommonPriceList(){
        String status = 'Approved';
        String query =  newQueryFactory()
        .selectField('Variant__r.Variant_Code__c')
        .selectField('Product__r.Product_Code__c')
        .setCondition('Customer_Group__c=null and Customer__c=null and Start_Date__c <= TODAY and End_Date__c>= TODAY and Discount_Type__c !=null and Status__c=:status')
        .setOrdering('Minimum_Quantity__c',LIBQueryFactory.SortOrder.ASCENDING, false)
        .toSOQL();  
        return Database.query(query);
    }
        
        
    
    }