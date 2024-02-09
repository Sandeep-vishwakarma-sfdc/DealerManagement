/**
 * @description       : This Class is used to create Price book for Common.                                          
 * @author            : prashant.kumbhar@skinternational.com
 * @last modified on  : 10-11-2023
 * @last modified by  :  prashant.kumbhar@skinternational.com
**/

public class YINCreatePriceBookByCustomerCommon implements YINIPriceBookCreator {
    
    /**
    * @description:This method is Used Create Price Book For Common..
    * @param  mapOfCustomerCommon: get the Comman Map of Price List Object.
    * @param  priceBookbyCommon: get the value of Comman records from Price Book Object.
    * @param  priceList: Valueof Price List Object.
    * @param  ontrigger: to Check wheather called from trigger or Not.
    * @param  jsPriceBook: Field mapping of Price Book from Custom Meta Data.
    * @param  jsPriceBookEntry: Field mapping of Price Book Entry from Custom Meta Data
    * @param  discount: to Check either discount or not.
    * @return void
    */   
        
        public static void createPricebook(Map<String,YIN_Price_List__c> mapOfCustomerCommon, Map<String,Pricebook2> priceBookbyCommon,List<YIN_Price_List__c> priceList,String ontrigger,String jsPriceBook,String jsPriceBookEntry,boolean discount){
            Pricebook2 pricebook=new Pricebook2();
            YINMonitorService x=new  YINMonitorService();
            String  userId=userInfo.getUserId();   
            List<PricebookEntry> operationInsert=new List<PricebookEntry>();
            List<Pricebook2>  pricebookInsert=new List<Pricebook2>();
            String combinationKey='';
            try{  
                LIBISObjectUnitOfWork uow=YINApplication.unitOfWork.newInstance();
                for(YIN_Price_List__c priceListObj: mapOfCustomerCommon.values()){
                    
                    System.debug('Calling Price Book for Comman Customer');
                    System.debug('Discount is'+priceListObj.Discount_Price__c);
                    System.debug('Price is'+priceListObj.Price__c);
                                
                    if(priceListObj.Customer__c==null && priceListObj.Customer_Group__c==null){ 
                        
                        System.debug('Common Map is'+priceBookbyCommon.get('Common'));
                        if(priceBookbyCommon.get('Common') ==null){  
                            
                            Map<String, Object> jsonObj = (Map<String, Object>) JSON.deserializeUntyped(jsPriceBook);
                            JSONGenerator gen = JSON.createGenerator(true);
                            gen.writeStartObject();
                            for(String key:jsonObj.keySet()){
                             String key1=String.valueof(jsonObj.get(key));
                                
                                
                                if(key=='Name' && priceListObj.Discount_Price__c==null){
                                gen.writeObjectField(key,'PriceBook-Common');
                                    
                                }
                                
                                else if(key=='Name' && priceListObj.Price__c==null){
                                gen.writeObjectField(key,'PriceBookDiscount-Common');
                                       
                                }
                                
                                else if(key=='Type__c'){
                                gen.writeObjectField(key,key1);
                                    
                                }
                                else{
                                gen.writeObjectField(key,priceListObj.get(key1));    
                                }
                                
                            }
                            gen.writeEndObject();
                            
                            String jsonS = gen.getAsString(); 
                            System.debug('MAp String is'+jsonS);
                            Map<String, Object> jsonObj1 = (Map<String, Object>) JSON.deserializeUntyped(jsonS);
                            jsonObj1.put('IsActive','true'); 
                            if(discount==true){
                            combinationKey='Common'+'PriceBookDiscount'; 
                            jsonObj1.put('IsDiscount__c','true');
                            jsonObj1.put('Combination_Key__c',combinationKey);    
                                
                            }
                            else{
                            jsonObj1.put('IsDiscount__c','false');    
                            combinationKey='Common'+'PriceBookPrice'; 
                            jsonObj1.put('Combination_Key__c',combinationKey);    
                                
                            }
                            String jsonStri = JSON.serialize(jsonObj1);
                            System.debug('Final String is'+jsonStri);
                            
                            LIBISObjectSelector selector= YINApplication.selector.newInstance(Pricebook2.sObjectType);
                            YINPriceBookSelector selectorObj=(YINPriceBookSelector)selector;
                            Pricebook2 standardPB=new Pricebook2();
                            if(Test.isRunningTest()==false){
                            standardPB=selectorObj.getStandardPriceBook(); 
                            }
                            
                            LIBISObjectSelector selector1= YINApplication.selector.newInstance(PricebookEntry.sObjectType);
                            YINPriceBookEntrySelector selectorObj1=(YINPriceBookEntrySelector)selector1;
                            
                            List<PricebookEntry> standardPBE=selectorObj1.getStandardPriceBookEntry(standardPB.Id,priceListObj.Product__c); 
                            
                            
                            System.debug('Standard Price Book Present or not'+standardPBE);
                            System.debug('Standard Price Book Size'+standardPBE.size());
                            
                            if(standardPBE.Size() ==0){
                                PricebookEntry stand=new PricebookEntry();
                                stand.Pricebook2Id=standardPB.id;
                                stand.Product2Id=priceListObj.Product__c;
                                
                                if(priceListObj.Price__c !=null){
                                    stand.UnitPrice=priceListObj.Price__c;    
                                }
                                else if(priceListObj.Discount_Price__c !=null){
                                    stand.UnitPrice=priceListObj.Discount_Price__c;       
                                }
                                stand.IsActive=true;
                                //operationInsert.add(stand);
                                System.debug('Standard Price Book is Common'+stand);
                                uow.registerNew(stand);
                               
                            }
                           
                            
                            pricebook=(Pricebook2)JSON.deserialize(jsonStri, Pricebook2.class);
                            uow.registerNew(pricebook);
                           // pricebookInsert.add(pricebook);
                            //uow.registerNew(pricebookInsert);
                            System.debug('Insert Object is'+pricebook);
                        }
                    }
                }
                
                uow.commitWork();
                if(pricebook.id !=null){
                    YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
                    exceptionLog.apexClass = 'CreatePriceBookByCustomerCommon';
                    exceptionLog.recordId = pricebook.id;
                    exceptionLog.module = 'PriceBookEngine';
                    exceptionLog.userId = userId;
                    x.log(exceptionLog);
                }
           //   CreatePriceBookByCustomerCommon.createPbEntryByCommon(priceList,ontrigger,jsPriceBookEntry,discount);
            }
            Catch(Exception e)
            {
                System.debug('Message'+E.getMessage());
                System.debug('Line Cause is'+E.getCause());
                System.debug('Line Number'+e.getLineNumber()); 
                
                YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
                exceptionLog.exObj = e;
                exceptionLog.apexClass = 'CreatePriceBookByCustomerCommon';
                exceptionLog.module = 'PriceBookEngine';
                
                x.exceptionHandler(exceptionLog);
            }
            
            finally{
              //  CreatePriceBookByCustomer.updateStatus(priceList,ontrigger,jsPriceBookEntry,discount);
                YINCreatePriceBookByCustomerCommon.createPbEntryByCommon(priceList,ontrigger,jsPriceBookEntry,discount);
                }
        }
        
        /*
        
        public static void updateStatus(List<YIN_Price_List__c> priceList,String ontrigger,String jsPriceBookEntry,boolean discount){
            LIBISObjectUnitOfWork uow=YINApplication.unitOfWork.newInstance();
            for(YIN_Price_List__c priceListObj1: priceList){ 
                    if(priceListObj1.Customer__c ==null && priceListObj1.Customer_Group__c==null){
                        
                        if(ontrigger !='ontrigger'){
                                 priceListObj1.Latest_Update_Status__c='In progress'; 
                                 uow.registerUpsert(priceListObj1);  
                            
                            }
                    }
            }
            System.debug('In Progress New Method');
             uow.commitWork();
        }
        
        */
        
        
     /**
    * @description:This method is Used Create Price Book Entry For Common.
    * @param  priceList: List of Price List.
    * @param  ontrigger: to Check for Updating the status
    * @param  jsPriceBookEntry: Mapping of Price Book Entry from Custom Meta data.
    * @return void.
    */   
    public static void createPbEntryByCommon(List<YIN_Price_List__c> priceList,String ontrigger,String jsPriceBookEntry,boolean discount){
            
            System.debug('priceList size is'+priceList.size());
            System.debug('Discount value is'+discount);
            String   userId=userInfo.getUserId();
            YINMonitorService x=new  YINMonitorService();
            PricebookEntry priceEntry=new PricebookEntry(); 
            List<PricebookEntry> operationInsert=new List<PricebookEntry>();
    
            try{
                LIBISObjectUnitOfWork uow1 =YINApplication.unitOfWork.newInstance();
                
                LIBISObjectSelector selector= YINApplication.selector.newInstance(Pricebook2.sObjectType);
                YINPriceBookSelector selectorObj=(YINPriceBookSelector)selector;
                List<Pricebook2> queryPriceBook =new List<Pricebook2>();
                
                if(discount ==false){
                 queryPriceBook=selectorObj.selectByActivePriceBook1();    
                }
                else
                {
                 queryPriceBook=selectorObj.selectByActivePriceBookwithDiscount1();
                }
                
                LIBISObjectSelector selector1= YINApplication.selector.newInstance(PricebookEntry.sObjectType);
                YINPriceBookEntrySelector selectorObj1=(YINPriceBookEntrySelector)selector1;
    
                
                Map<String,Pricebook2> priceBookForEntries=new Map<String,Pricebook2>();
                for(Pricebook2 price:queryPriceBook){
                    priceBookForEntries.put('Common',price);
                }
                
                for(YIN_Price_List__c priceListObj1: priceList){     
                    Pricebook2 matchingPricebook =new  Pricebook2();
                    
                    if(priceListObj1.Customer__c ==null && priceListObj1.Customer_Group__c==null){
                        System.debug('lll---'+priceBookForEntries.containsKey('Common'));
                        if(priceBookForEntries.containsKey('Common')){   
                            matchingPricebook = priceBookForEntries.get('Common');
                            System.debug('Matching price book in Customer Comman'+matchingPricebook);
                            if(ontrigger =='ontrigger'){
                                if(Test.isRunningTest()==false){
                                YINPriceBookService.createStatusProcess(priceListObj1.id) ;
                                }
                            }
                            else{
                                priceListObj1.Latest_Update_Status__c='In progress'; 
                                uow1.registerUpsert(priceListObj1);   
                               }
                            system.debug('matchingPricebook>>'+matchingPricebook);
                               
                            Map<String, Object> jsonObj = (Map<String, Object>) JSON.deserializeUntyped(jsPriceBookEntry);
                            JSONGenerator gen = JSON.createGenerator(true);
                            gen.writeStartObject();
                            for(String key:jsonObj.keySet()){
                                String key1=String.valueof(jsonObj.get(key));
                                
                                String pr=String.valueof(priceListObj1.get(key1));
                                System.debug('key1 is One By one1'+pr);
                                if(pr !=null){
                                gen.writeObjectField(key,priceListObj1.get(key1));
                                }
                                    
                            }
                            gen.writeEndObject();
                            
                            String Combinationkey=matchingPricebook.Combination_Key__c+priceListObj1.Product__r.ProductCode;
                            System.debug('Combination key in Entry is'+Combinationkey);
                           
                            
                            String jsonS = gen.getAsString(); 
                            System.debug('MAp String is11'+jsonS);
                            Map<String, Object> jsonObj1 = (Map<String, Object>) JSON.deserializeUntyped(jsonS);
                            jsonObj1.put('Pricebook2Id',matchingPricebook.Id);
                            jsonObj1.put('UseStandardPrice','false');
                            jsonObj1.put('Combination_Key__c',Combinationkey);
                            jsonObj1.put('IsActive','true');
                            
                            String jsonStri = JSON.serialize(jsonObj1);
                            System.debug('Final String is11'+jsonStri);
                            
                            priceEntry=(PricebookEntry)JSON.deserialize(jsonStri, PricebookEntry.class); 
                            operationInsert.add(priceEntry);
                            
                          //  Schema.SObjectField combination=PricebookEntry.Fields.Combination_Key__c;
                          //  Database.UpsertResult srList = Database.upsert(priceEntry,combination,false);
                           // if(srList.isSuccess()){
                             //CreatePriceBookByCustomer.updateStatusProcess(priceListObj1);
                               /* priceListObj1.Latest_Update_Status__c='Processed'; 
                                uow1.registerDirty(priceListObj1);  */  
                            //}
                            
                
                          /*  PricebookEntry priceBookEntryforUpdate=selectorObj1.getPriceBookEntryforUpdate(matchingPricebook.Id,priceEntry.Product2Id); 
    
                            if(priceBookEntryforUpdate.id !=null){
                                System.debug('In Update Statment');
                                priceEntry.id=priceBookEntryforUpdate.id;
                                uow1.registerDirty(priceEntry);
                            }
                            
                            else{
                                uow1.registerNew(priceEntry);
                                System.debug('In Insert Statment');    
                            }
                            */ 
                           
                        }   
                    }    
                }
                 Schema.SObjectField combination=PricebookEntry.Fields.Combination_Key__c;
                 Database.UpsertResult[] srList = Database.upsert(operationInsert,combination,false);
                
                for (Database.UpsertResult saveResult : srList) {
                    if (saveResult.isSuccess()) {
                        YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
                        exceptionLog.apexClass = 'CreatePriceBookByCustomerCommon';
                        exceptionLog.module = 'PriceBookEngine';
                        exceptionLog.userId = userId;
                        x.log(exceptionLog);
                    }
                 }
                uow1.commitWork();
            }
            Catch(Exception e) {
                System.debug('In common'+e.getMessage());
                System.debug('Line Number is'+e.getLineNumber());
                System.debug('Cause is'+e.getCause());
                YINMonitorLogWrap exceptionLog = new YINMonitorLogWrap();
                exceptionLog.exObj = e;
                exceptionLog.recordId = priceEntry.id;
                exceptionLog.apexClass = 'CreatePriceBookByCustomerCommon';
                exceptionLog.module = 'PriceBookEngine';
                x.exceptionHandler(exceptionLog);
            }
        }
        
         
    }