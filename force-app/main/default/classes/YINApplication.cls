/**
 * @description       : This Class is used to create All layer like service,selector,domain and unit of work.                                          
 * @author            : Saurabh.pandey@skinternational.com
 * @last modified on  : 19-01-2024
 * @last modified by  : Amol Patil/amol.patil@skinternational.com
**/

public class YINApplication {

   /**
   * @description:This method Objects which will used in DML Operations.
   */   
   public static final LibApplication.UnitOfWorkFactory UNITOFWORK =
      new LibApplication.UnitOfWorkFactory(
         new List<SObjectType> {
         

              Account.sObjectType,
             // YIN_Credit_Limit__c.sObjectType,             //Prashant Kumbhar
              YIN_Price_List__c.sObjectType,                //Prashant Kumbhar
              Pricebook2.sObjectType,                     //Prashant Kumbhar
              PricebookEntry.sObjectType,                 //Prashant Kumbhar   
              YIN_Monitor_Log__c.sObjectType,             //Prashant Kumbhar
              Attachment.sObjectType,                     //Prashant Kumbhar
              // Distributor_Document__c.sObjectType,   //Satish Tiware
              ContentVersion.sObjectType,   //change by kalpesh
              ContentDocumentLink.sObjectType,    //change by kalpesh
              //  KYC_Doc_Configuration__mdt.SObjectType,
              YIN_PriceBook_Entry__mdt.sObjectType,                       //Prashant Kumbhar
              YIN_Security_Deposit__c.sObjectType,                       //Prashant Kumbhar
              YIN_Payment__c.sObjectType,                       //Prashant Kumbhar    
              YIN_PJP__c.SObjectType,                              //Saurabh Pandey
              Event.SObjectType,                          //Saurabh Pandey
              // PJP_Detail__c.SObjectType,               //Saurabh Pandey
              YIN_Balance_Confirmation__c.SObjectType,    //Saurabh Pandey
              YIN_Account_product_Mapping__c.SObjectType, //Saurabh Pandey
              YIN_Atttandance__c.SObjectType,             //Saurabh Pandey
              ContentDocument.sObjectType,                //Saurabh Pandey
              Document.sObjectType,                       //Saurabh Pandey
              YIN_Target__c.SObjectType,             // Nikhil Dhoke
              YIN_Target_Distributor__c.SObjectType, // Nikhil Dhoke
              //  Target_Schedule__c.SObjectType,   // Nikhil Dhoke 
              YIN_Channel_Code__c.SObjectType,    //Kalpesh Chande  
              YIN_Country__c.SObjectType,         //Kalpesh Chande
              YIN_State__c.SObjectType,           //Kalpesh Chande
              YIN_Zone__c.SObjectType,            //Kalpesh Chande
              YIN_District__c.SObjectType,        //Kalpesh Chande
              YIN_Sub_District__c.SObjectType,    //Kalpesh Chande
              YIN_City__c.SObjectType,            //Kalpesh Chande
              YIN_Territory__c.SObjectType,       //Kalpesh Chande
              YIN_Pincode__c.SObjectType,         //Kalpesh Chande
              YIN_Location__c.SObjectType,         //Kalpesh Chande
              YIN_Change_Request__c.SObjectType,   //Amol Patil
              EmailTemplate.SObjectType,         //Amol Patil
              YIN_Ledger__c.SObjectType,         //Sandeep Vishwakarma
              Order.SObjectType,                  //Sandeep Vishwakarma
              OrderItem.SObjectType          //Sandeep Vishwakarma
         }
      ); 
       
       
       
   /**
   * @description:Service Layer is Used to perform Actual Logic.
   */
   public static final LibApplication.ServiceFactory SERVICE =
      new LibApplication.ServiceFactory(
         new Map<Type, Type> {
         

             YINIPriceBookService.class =>YINIPriceBookServiceImp.class,               //Prashant Kumbhar
             YINIPriceBookCreator.class =>YINCreatePriceBookByCustomerCommon.class,    //Prashant Kumbhar
             YINIPriceBookCreator.class =>YINCreatePriceBookByCustomer.class,          //Prashant Kumbhar
             YINIPriceBookCreator.class =>YINCreatePriceBookByCustomerGroup.class,         //Prashant Kumbhar
             YINIMonitor.class => YINMonitorImp.class,                                 //Prashant Kumbhar
             YINISecurityDeposit.class => YINSecurityDepositIncService.class,          //Prashant Kumbhar
            // TrgITargetAssignment.class=>TrgTargetAssignmentImpl.class,       // Nikhil Dhoke
            // TrgITargetDistribution.class=>TrgTargetDistributionImpl.class,   // Nikhil Dhoke
            // TrgITargetSchedules.class=>TrgTargetSchedulesImpl.class,        // Nikhil Dhoke
             YINIContentVersionCreator.Class=>YINContentVersionCreatorImp.Class,    //Kalpesh Chande
            // ICustomerOnboardingApplication.class =>ICustomerOnboardingService.class,   //Satish Tiware
            // IDocumentDataTable.class => DocumentDataTableImp.class,     //Satish Tiware
            YINIExternalApiServices.Class =>YINChannelCodeService.Class,      //Kalpesh Chande
            YINIExternalApiServices.Class =>YINCountryService.Class,          //Kalpesh Chande
            YINIExternalApiServices.Class =>YINStateService.Class,            //Kalpesh Chande
            YINIExternalApiServices.Class =>YINDistrictService.Class,         //Kalpesh Chande
            YINIExternalApiServices.Class =>YINSubDistrictService.Class,      //Kalpesh Chande
            YINIExternalApiServices.Class =>YINCityService.Class,             //Kalpesh Chande
            YINIExternalApiServices.Class =>YINTerritoryService.Class,        //Kalpesh Chande
            YINIExternalApiServices.Class =>YINPincodeService.Class,          //Kalpesh Chande
            YINIExternalApiServices.Class =>YINLocationService.Class,         //Kalpesh Chande
            YINIExternalApiServices.Class =>YINDealerService.Class,           //Kalpesh Chande
            YINIiconUtils.Class =>YINIconUtilsImp.Class,                      //Kalpesh Chande
            YINIPicklistColumnUtils.Class =>YINPicklistColumnUtilsImp.Class,  //Kalpesh Chande
            YINIRelatedList.Class =>YINRelatedListImp.Class,                  //Kalpesh Chande
            YINIChangeRequest.Class =>YINChangeRequestImpl.Class,             //Amol Patil 
            // IPjpService.class => PJPServiceImpl.class,                               //Saurabh Pandey
            YINIBalanceConfirmation.class => YINBalanceConfirmationImpl.class,          //Saurabh Pandey
            YINILockingProductFileUpload.class => YINLockingProductFileUploadImpl.class,//Saurabh Pandey
            YINIAttendanceModule.class => YINAttandanceModuleServiceImpl.class,         //Saurabh Pandey
            YINIOrderManagement.class => YINOrderManagementImpl.class // Sandeep Vishwakarma

         }
      );
   
   /**
   * @description:Selector Layer is Used to perform SOQL Query.
   */   
   public static final LibApplication.SelectorFactory SELECTOR =
      new LibApplication.SelectorFactory(
         new Map<SObjectType, Type> {

         

                Pricebook2.sObjectType => YINPriceBookSelector.class,                        //Prashant Kumbhar
                YIN_Price_List__c.sObjectType  =>YINPriceListSelector.class,                 //Prashant Kumbhar
                YIN_Monitor_Log__c.sObjectType =>YINMonitorSelector.class,                    //Prashant Kumbhar
               // Distributor_Document__c.sObjectType => DistributorDocumentSelector.class,  //Satish Tiware
                ContentDocumentLink.sObjectType=>YINContentDocumentLinkSelector.class,       //Kalpesh Chande Chande
                ContentDocument.sObjectType=>YINContentDocumentSelector.class,               //Kalpesh Chande Chande
                ContentVersion.sObjectType =>YINContentVersionSelector.class,                //Kalpesh Chande Chande
               // KYC_Doc_Configuration__mdt.sObjectType => KycDocConfigSelector.class,      //Satish Tiware
               // User.sObjectType =>UserSelector.class,                                     //Saurabh Pandey
                YIN_Security_Deposit__c.sObjectType=>YINSecurityDepositSelector.class,    //Prashant Kumbhar
                YIN_PriceBook_Entry__mdt.sObjectType =>YINPriceBookEngineSelector.class,   //Prashant Kumbhar
                PricebookEntry.sObjectType =>YINPriceBookEntrySelector.class,              //Prashant Kumbhar
                Account.SObjectType => YINAccountSelector.class,                                  // Nikhil Dhoke
               // Target__c.SObjectType => TargetSelector.class,                                 // Nikhil Dhoke
               // Target_Distributor__c.SObjectType => TargetDistributorSelector.class,          // Nikhil Dhoke
               // Target_Schedule__c.SObjectType => TargetScheduleSelector.class,                // Nikhil Dhoke
               // Product2.SObjectType => Product2Selector.class,                                 // Nikhil Dhoke
               // Profile.SObjectType => ProfileSelector.class,                                  //Saurabh Pandey
               // ProcessInstanceWorkitem.SObjectType => ProcessInstanceWorkitemSelector.class,  //Saurabh Pandey
               // Zone__c.SObjectType => ZoneSelector.class,                                     //Saurabh Pandey
               // Sub_Zone__c.SObjectType => SubZoneSelector.class,                              //Saurabh Pandey
               // City__c.SObjectType => CitySelector.class,                                     //Saurabh Pandey
               // Area__c.SObjectType => AreaSelector.class,                                     //Saurabh Pandey 
               // PJP__c.SObjectType => PJPSelector.class,                                       //Saurabh Pandey 
               // PJP_Detail__c.SObjectType => PjpDetailsSelector.class,                         //Saurabh Pandey
               ContentVersion.sObjectType =>YINContentVersionSelector.class,                     //Saurabh Pandey
               CustomNotificationType.SObjectType => YINCustomNotificationSelector.class,        //Saurabh Pandey
               Document.SObjectType => YINDocumentSelector.class,                                //Saurabh Pandey
               YIN_Balance_Confirmation__c.SObjectType => YINBalanceConfirmationSelector.class,  //Saurabh Pandey
               YIN_Atttandance__c.SObjectType => YINAttandanceSelector.class,                    //Saurabh Pandey
               //RecordType.Schema.SObjectType=>RecordTypeSelector.class,                        //Kalpesh Chande Chande
               RecordType.getSObjectType()=>YINRecordTypeSelector.class,                          //Kalpesh Chande 
               CollaborationGroup.SObjectType=>YINCollaborationGroupSelector.Class,               //Kalpesh Chande*/
               YIN_Change_Request__c.SObjectType=>YINChangeRequestSelector.Class,                      //Amol Patil
               YIN_Pincode__c.SObjectType=>YINPincodeSelector.Class,                                    //Amol Patil
               EmailTemplate.SObjectType=>YINEmailTempSelector.Class,                                   //Amol Patil
               // Start Adding by Sandeep Vishwakarma
               User.sObjectType => YINUserSelector.class,
               Contact.sObjectType => YINContactSelector.class,
               YIN_Account_product_Mapping__c.sObjectType => YINAccountProductMappingSelector.class,
               Order.sObjectType => YINOrderSelector.class,
               OrderItem.sObjectType => YINOrderItemSelector.class,
               YIN_Ledger__c.sObjectType => YINLedgerSelector.class,
               YIN_Variant__c.sObjectType => YINVariantSelector.class
               // End Adding by Sandeep Vishwakarma  */    
               
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
             YIN_Monitor_Log__c.sObjectType=>YINMonitorDomain.class,   
			    Case.sObjectType=>YINAutoCasehandler.class			 
         }
      );
   }