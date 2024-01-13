/**
 * @description       : This Class is used to create All layer like service,selector,domain and unit of work.                                          
 * @author            : Saurabh.pandey@skinternational.com
 * @last modified on  : 01-02-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public class YINApplication {

    /**
    * @description:This method Objects which will used in DML Operations.
    */   
    public static final LibApplication.UnitOfWorkFactory UNITOFWORK =
       new LibApplication.UnitOfWorkFactory(
          new List<SObjectType> {
          
 
               Account.sObjectType,
              // YIN_Credit_Limit__c.sObjectType,
               YIN_Price_List__c.sObjectType,
               Pricebook2.sObjectType,
               PricebookEntry.sObjectType,   
               YIN_Monitor_Log__c.sObjectType,
               Attachment.sObjectType,
               // Distributor_Document__c.sObjectType,   //Satish Tiware
               ContentVersion.sObjectType,   //change by kalpesh
               ContentDocumentLink.sObjectType,    //change by kalpesh
               ContentDocument.sObjectType,   //Saurabh
               Document.sObjectType,    //Saurabh
               //  KYC_Doc_Configuration__mdt.SObjectType,
               YIN_PriceBook_Entry__mdt.sObjectType,
               YIN_Security_Deposit__c.sObjectType,
               YIN_Payment__c.sObjectType,    
               YIN_PJP__c.SObjectType,                //Saurabh
               Event.SObjectType,                 //Saurabh
               //   PJP_Detail__c.SObjectType,          //Saurabh
               YIN_Balance_Confirmation__c.SObjectType,    //Saurabh
               YIN_Account_product_Mapping__c.sObjectType,  //Saurabh
               YIN_Target__c.SObjectType,             // Nik...
               YIN_Target_Distributor__c.SObjectType, // Nik...
               //  Target_Schedule__c.SObjectType,   // Nik...   
               // RecordType.SObjectType 
               YIN_Channel_Code__c.SObjectType,    //Kalpesh  
               YIN_Country__c.SObjectType,         //kalpesh
               YIN_State__c.SObjectType,           //kalpesh
               YIN_Zone__c.SObjectType,            //Kalpesh
               YIN_District__c.SObjectType,        //kalpesh
               YIN_Sub_District__c.SObjectType,    //kalpesh
               YIN_City__c.SObjectType,            //kalpesh
               YIN_Territory__c.SObjectType,       //kalpesh
               YIN_Pincode__c.SObjectType,         //kalpesh
               YIN_Location__c.SObjectType,         //kalpesh
               YIN_Change_Request__c.SObjectType,   //Amol Patil
               YIN_Ledger__c.SObjectType,
               Order.SObjectType,
               OrderItem.SObjectType       
          }
       ); 
        
        
        
    /**
    * @description:Service Layer is Used to perform Actual Logic.
    */
    public static final LibApplication.ServiceFactory SERVICE =
       new LibApplication.ServiceFactory(
          new Map<Type, Type> {
          
 
              YINIPriceBookService.class =>YINIPriceBookServiceImp.class, 
              YINIPriceBookCreator.class =>YINCreatePriceBookByCustomerCommon.class,
              YINIPriceBookCreator.class =>YINCreatePriceBookByCustomer.class,
              YINIPriceBookCreator.class =>YINCreatePriceBookByCustomerGroup.class,         
              YINIMonitor.class => YINMonitorImp.class,
              YINISecurityDeposit.class => YINSecurityDepositIncService.class,    
             // IPjpService.class => PJPServiceImpl.class,                        //Saurabh
             // TrgITargetAssignment.class=>TrgTargetAssignmentImpl.class,       // Nik...
             // TrgITargetDistribution.class=>TrgTargetDistributionImpl.class,   // Nik...
             // TrgITargetSchedules.class=>TrgTargetSchedulesImpl.class,        // Nik...
              YINIContentVersionCreator.Class=>YINContentVersionCreatorImp.Class,    //kalpesh
             // ICustomerOnboardingApplication.class =>ICustomerOnboardingService.class,   //Satish Tiware
             // IDocumentDataTable.class => DocumentDataTableImp.class,     //Satish Tiware
           
             YINIExternalApiServices.Class =>YINChannelCodeService.Class,      //Kalpesh
             YINIExternalApiServices.Class =>YINCountryService.Class,          //Kalpesh
             YINIExternalApiServices.Class =>YINStateService.Class,            //Kalpesh
             YINIExternalApiServices.Class =>YINDistrictService.Class,         //Kalpesh
             YINIExternalApiServices.Class =>YINSubDistrictService.Class,      //Kalpesh
             YINIExternalApiServices.Class =>YINCityService.Class,             //Kalpesh
             YINIExternalApiServices.Class =>YINTerritoryService.Class,        //Kalpesh
             YINIExternalApiServices.Class =>YINPincodeService.Class,          //Kalpesh
             YINIExternalApiServices.Class =>YINLocationService.Class,         //Kalpesh
             YINIExternalApiServices.Class =>YINDealerService.Class,           //Kalpesh
  			    YINIiconUtils.Class =>YINIconUtilsImp.Class,                      //kalpesh
             YINIPicklistColumnUtils.Class =>YINPicklistColumnUtilsImp.Class,  //kalpesh
             YINIRelatedList.Class =>YINRelatedListImp.Class,                  //kalpesh
             YINIChangeRequest.Class =>YINChangeRequestImpl.Class,             //Amol Patil 
             YINIBalanceConfirmation.class => YINBalanceConfirmationImpl.class, //Saurabh
             YINILockingProductFileUpload.class => YINLockingProductFileUploadImpl.class,//Saurabh
             YINIOrderManagement.class => YINOrderManagementImpl.class // Sandeep Vishwakarma
          }
       );
    
    /**
    * @description:Selector Layer is Used to perform SOQL Query.
    */   
    public static final LibApplication.SelectorFactory SELECTOR =
       new LibApplication.SelectorFactory(
          new Map<SObjectType, Type> {
 
          
 
                 Pricebook2.sObjectType => YINPriceBookSelector.class,
                 YIN_Price_List__c.sObjectType  =>YINPriceListSelector.class,
                 YIN_Monitor_Log__c.sObjectType =>YINMonitorSelector.class,
                // Distributor_Document__c.sObjectType => DistributorDocumentSelector.class,  //Satish Tiware
                 ContentDocumentLink.sObjectType=>YINContentDocumentLinkSelector.class,
                 ContentDocument.sObjectType=>YINContentDocumentSelector.class,
                 ContentVersion.sObjectType =>YINContentVersionSelector.class,
                // KYC_Doc_Configuration__mdt.sObjectType => KycDocConfigSelector.class,      //Satish Tiware
                // User.sObjectType =>UserSelector.class,
                 YIN_Security_Deposit__c.sObjectType=>YINSecurityDepositSelector.class,    
                // Profile.SObjectType => ProfileSelector.class,                                  //Saurabh
                 YIN_PriceBook_Entry__mdt.sObjectType =>YINPriceBookEngineSelector.class,
                 PricebookEntry.sObjectType =>YINPriceBookEntrySelector.class,
                 Account.SObjectType => YINAccountSelector.class,                                  // Nik ...
                // Target__c.SObjectType => TargetSelector.class,                                 // Nik ...
                // Target_Distributor__c.SObjectType => TargetDistributorSelector.class,          // Nik ...
                // Target_Schedule__c.SObjectType => TargetScheduleSelector.class,                // Nik ...
                // Product2.SObjectType => Product2Selector.class,                                 // Nik ...
                // ProcessInstanceWorkitem.SObjectType => ProcessInstanceWorkitemSelector.class,  //Saurabh
                // Zone__c.SObjectType => ZoneSelector.class,                                     //Saurabh
                // Sub_Zone__c.SObjectType => SubZoneSelector.class,                              //Saurabh
                // City__c.SObjectType => CitySelector.class,                                     //Saurabh
                // Area__c.SObjectType => AreaSelector.class,                                     //Saurabh 
                // PJP__c.SObjectType => PJPSelector.class,                                       //Saurabh 
                // PJP_Detail__c.SObjectType => PjpDetailsSelector.class,                          //Saurabh
                // //RecordType.Schema.SObjectType=>RecordTypeSelector.class,    
                RecordType.getSObjectType()=>YINRecordTypeSelector.class,                          //kalpesh 
                CollaborationGroup.SObjectType=>YINCollaborationGroupSelector.Class,               //kalpesh*/
                YIN_Change_Request__c.SObjectType=>YINChangeRequestSelector.Class,                      //Amol Patil
                YIN_Pincode__c.SObjectType=>YINPincodeSelector.Class,                                    //Amol Patil
                ContentVersion.sObjectType =>YINContentVersionSelector.class,           
                CustomNotificationType.SObjectType => YINCustomNotificationSelector.class,  //Saurabh
                Document.SObjectType => YINDocumentSelector.class,                               //Saurabh
                YIN_Balance_Confirmation__c.SObjectType => YINBalanceConfirmationSelector.class,           //Saurabh

                Account.SObjectType => YINAccountSelector.class,                                  // Nik ...
               
                // Start Adding by Sandeep Vishwakarma
                User.sObjectType => YINUserSelector.class,
                Contact.sObjectType => YINContactSelector.class,
                YIN_Account_product_Mapping__c.sObjectType => YINAccountProductMappingSelector.class,
                Order.sObjectType => YINOrderSelector.class,
                OrderItem.sObjectType => YINOrderItemSelector.class,
                YIN_Ledger__c.sObjectType => YINLedgerSelector.class,
                YIN_Variant__c.sObjectType => YINVariantSelector.class
                // End Adding by Sandeep Vishwakarma      
                
          }
       );
    
    /**
    * @description:Domain Layer is Used to perform Trigger Operation.
    */   
   
    public static final LibApplication.DomainFactory DOMAIN =
       new LibApplication.DomainFactory(
          YINApplication.Selector,
          new Map<SObjectType, Type> {
 
            
              YIN_Price_List__c.sObjectType => YINPriceListDomain.class,
              YIN_Monitor_Log__c.sObjectType=>YINMonitorDomain.class       
          }
       );
    }