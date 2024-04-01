/**
 * @description       : This Class is used to create All layer like service,selector,domain and unit of work.                                          
 * @author            : Saurabh.pandey@skinternational.com
 * @last modified on  : 03-07-2024
 * @last modified by  : saurabh.pandey@skinternational.com
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
              YIN_Price_List__c.sObjectType,                 //Prashant Kumbhar
              Pricebook2.sObjectType,                        //Prashant Kumbhar
              PricebookEntry.sObjectType,                    //Prashant Kumbhar   
              YIN_Monitor_Log__c.sObjectType,                //Prashant Kumbhar
              Attachment.sObjectType,                        //Prashant Kumbhar
             //* YIN_Account_Document__c.sObjectType,        //Satish Tiware
              ContentVersion.sObjectType,                    //change by kalpesh
              ContentDocumentLink.sObjectType,               //change by kalpesh
             //* YIN_Account_KYC_Document__mdt.SObjectType,    //Prashant Kumbhar
              YIN_PriceBook_Entry__mdt.sObjectType,          //Prashant Kumbhar
              YIN_Security_Deposit__c.sObjectType,           //Prashant Kumbhar
              YIN_Payment__c.sObjectType,                    //Prashant Kumbhar    
              YIN_PJP__c.SObjectType,                        //Saurabh Pandey
              Event.SObjectType,                             //Saurabh Pandey
              // PJP_Detail__c.SObjectType,                  //Saurabh Pandey
              YIN_Balance_Confirmation__c.SObjectType,       //Saurabh Pandey
              YIN_Account_product_Mapping__c.SObjectType,    //Saurabh Pandey
             //* YIN_Atttandance__c.SObjectType,                //Saurabh Pandey
              ContentDocument.sObjectType,                   //Saurabh Pandey
              Document.sObjectType,                          //Saurabh Pandey
              YIN_Community_Configuration__c.SObjectType,    //Saurabh Pandey
              YIN_Target__c.SObjectType,                     //Nikhil Dhoke
              YIN_Target_Distributor__c.SObjectType,         //Nikhil Dhoke
              //  Target_Schedule__c.SObjectType,            //Nikhil Dhoke 
              YIN_Channel_Code__c.SObjectType,               //Kalpesh Chande  
              YIN_Country__c.SObjectType,                    //Kalpesh Chande
              YIN_State__c.SObjectType,                      //Kalpesh Chande
              YIN_Zone__c.SObjectType,                       //Kalpesh Chande
              YIN_District__c.SObjectType,                   //Kalpesh Chande
              YIN_Sub_District__c.SObjectType,               //Kalpesh Chande
              YIN_City__c.SObjectType,                       //Kalpesh Chande
              YIN_Territory__c.SObjectType,                  //Kalpesh Chande
              YIN_Pincode__c.SObjectType,                    //Kalpesh Chande
              YIN_Location__c.SObjectType,                   //Kalpesh Chande
              YIN_Change_Request__c.SObjectType,             //Amol Patil
              EmailTemplate.SObjectType,                     //Amol Patil
              YIN_Ledger__c.SObjectType,                     //Sandeep Vishwakarma
              Order.SObjectType,                             //Sandeep Vishwakarma
              OrderItem.SObjectType,                         //Sandeep Vishwakarma
              User.SObjectType, 
              Contract.SObjectType,                          // Nikhil Dhoke ...
              YIN_Vehicle_Detail__c.SObjectType,             // Nikhil Dhoke ...
              Asset.SObjectType,                             // Nikhil Dhoke ...
              YIN_Discount_Coupons__c.SObjectType,           // Nikhil Dhoke ...
              YIN_Claim__c.SObjectType,                      // Nikhil Dhoke ...
              Period.SObjectType,                            // Nikhil Dhoke ...
              Product2.SObjectType,                          // Nikhil Dhoke ...
              Profile.SObjectType,                           // Nikhil Dhoke ...
              YIN_Invoice__c.SObjectType,                      //Kalpesh Chande  
              YIN_Invoice_Item__c.SObjectType,                //Kalpesh Chande  
              YIN_Inventory__c.SObjectType,                  // vinayak godhade
              YIN_Customer_Group__c.SObjectType,              //Kalpesh chande
              YIN_Ledger__c.SObjectType                       //Satish Tiware
             //* Promotional_Budget_Used__c.SObjectType
         }    
      ); 
       
       
       
   /**
   * @description:Service Layer is Used to perform Actual Logic.
   */
   public static final LibApplication.ServiceFactory SERVICE =
      new LibApplication.ServiceFactory(
         new Map<Type, Type> {
         

            YINIPriceBookService.class =>YINIPriceBookServiceImp.class,                    //Prashant Kumbhar
            YINIPriceBookCreator.class =>YINCreatePriceBookByCustomerCommon.class,         //Prashant Kumbhar
            YINIPriceBookCreator.class =>YINCreatePriceBookByCustomer.class,               //Prashant Kumbhar
            YINIPriceBookCreator.class =>YINCreatePriceBookByCustomerGroup.class,          //Prashant Kumbhar
            YINIMonitor.class => YINMonitorImp.class,                                      //Prashant Kumbhar
            YINISecurityDeposit.class => YINSecurityDepositImpl.class,               //Prashant Kumbhar
            // TrgITargetAssignment.class=>TrgTargetAssignmentImpl.class,                   // Nikhil Dhoke
            // TrgITargetDistribution.class=>TrgTargetDistributionImpl.class,               // Nikhil Dhoke
            // TrgITargetSchedules.class=>TrgTargetSchedulesImpl.class,                     // Nikhil Dhoke
             YINIContentVersionCreator.Class=>YINContentVersionCreatorImp.Class,            //Kalpesh Chande
           //* YINICustomerOnBoarding.class =>YINCustomerOnBoardingImpl.class,                 //Satish Tiware
            // IDocumentDataTable.class => DocumentDataTableImp.class,                      //Satish Tiware
           /*-- YINIExternalApiServices.Class =>YINChannelCodeService.Class,                  ////Kalpesh Chande
            YINIExternalApiServices.Class =>YINCountryService.Class,                        //Kalpesh Chande
            YINIExternalApiServices.Class =>YINStateService.Class,                          //Kalpesh Chande
            YINIExternalApiServices.Class =>YINDistrictService.Class,                       //Kalpesh Chande
            YINIExternalApiServices.Class =>YINSubDistrictService.Class,                    //Kalpesh Chande
            YINIExternalApiServices.Class =>YINCityService.Class,                           //Kalpesh Chande
            YINIExternalApiServices.Class =>YINTerritoryService.Class,                      //Kalpesh Chande
            YINIExternalApiServices.Class =>YINPincodeService.Class,                        //Kalpesh Chande
            YINIExternalApiServices.Class =>YINLocationService.Class,                       //Kalpesh Chande
            YINIExternalApiServices.Class =>YINDealerService.Class,                         //Kalpesh Chande*/
           //-- YINIiconUtils.Class =>YINIconUtilsImp.Class,                                    //Kalpesh Chande
            //YINIPicklistColumnUtils.Class =>YINPicklistColumnUtilsImp.Class,                //Kalpesh Chande
            //YINIRelatedList.Class =>YINRelatedListImp.Class,                                //Kalpesh Chande
            YINIChangeRequest.Class =>YINChangeRequestImpl.Class,                           //Amol Patil 
            // IPjpService.class => PJPServiceImpl.class,                                   //Saurabh Pandey
            YINIBalanceConfirmation.class => YINBalanceConfirmationImpl.class,              //Saurabh Pandey
            YINILockingProductFileUpload.class => YINLockingProductFileUploadImpl.class,    //Saurabh Pandey
           //* YINIAttendanceModule.class => YINAttandanceModuleServiceImpl.class,             //Saurabh Pandey
            YINICommunityConfiguration.class => YINCommnityConfigurationImpl.class,         //Saurabh Pandey
            YINIPromotionalActivity.class => YINPromotionalActivityImpl.class,               //Saurabh Pandey
            YINIOrderManagement.class => YINOrderManagementImpl.class,                      // Sandeep Vishwakarma
            YINIWarranty.class => YINWarrantyImpl.class,                                    // Nikhil Dhoke ...
            YINIClaim.class => YINClaimImpl.class,                                          // Nikhil Dhoke ...
            YINIBarCode.class => YINBarCodeImpl.class,                                      // Nikhil Dhoke ...
            YINIExternalApiService.class => YINExternalApiServiceImpl.class,                //Kalpesh Chande
            YINIDocumentDataTable.class => YINDocumentDataTableImpl.class ,                 //Satish Tiware
            YINICustomDealerNotification.class => YINCustomDealerNotificationsImpl.class,   //vinayak Godhade
            YINIFrequentlyBroughtItem.class => YINFrequentlyBroughtItemImpl.class,           //Kalpesh Chande
            YINILedgerDataTable.class => YINLedgerDataTableImpl.class                        //Satish Tiware
         }
      );
   
   /**
   * @description:Selector Layer is Used to perform SOQL Query.
   */   
   public static final LibApplication.SelectorFactory SELECTOR =
      new LibApplication.SelectorFactory(
         new Map<SObjectType, Type> {       
                Pricebook2.sObjectType => YINPriceBookSelector.class,                            //Prashant Kumbhar
                YIN_Price_List__c.sObjectType  =>YINPriceListSelector.class,                     //Prashant Kumbhar
                YIN_Monitor_Log__c.sObjectType =>YINMonitorSelector.class,                       //Prashant Kumbhar
               //* YIN_Account_Document__c.sObjectType => YINAccountDocumentSelector.class,         //Satish Tiware
                ContentDocumentLink.sObjectType=>YINContentDocumentLinkSelector.class,           //Kalpesh Chande 
                ContentDocument.sObjectType=>YINContentDocumentSelector.class,                   //Kalpesh Chande 
                ContentVersion.sObjectType =>YINContentVersionSelector.class,                    //Kalpesh Chande 
               //* YIN_Account_KYC_Document__mdt.sObjectType => YINAccountKycDOcumentSelector.class,          //Satish Tiware
                YIN_Security_Deposit__c.sObjectType=>YINSecurityDepositSelector.class,           //Prashant Kumbhar
                YIN_PriceBook_Entry__mdt.sObjectType =>YINPriceBookEngineSelector.class,         //Prashant Kumbhar
                PricebookEntry.sObjectType =>YINPriceBookEntrySelector.class,                    //Prashant Kumbhar
                Account.SObjectType => YINAccountSelector.class,                                 // Nikhil Dhoke
               // Target__c.SObjectType => TargetSelector.class,                                 // Nikhil Dhoke
               // Target_Distributor__c.SObjectType => TargetDistributorSelector.class,          // Nikhil Dhoke
               // Target_Schedule__c.SObjectType => TargetScheduleSelector.class,                // Nikhil Dhoke
                Product2.SObjectType => YINProductSelector.class,                                // Nikhil Dhoke
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
              //* YIN_Atttandance__c.SObjectType => YINAttandanceSelector.class,                    //Saurabh Pandey
               YIN_Community_Configuration__c.SObjectType => YINCommunityConfigurationSelector.class, //Saurabh Pandey
              // RecordType.Schema.SObjectType=>RecordTypeSelector.class,                        //Kalpesh Chande 
               //RecordType.getSObjectType()=>YINRecordTypeSelector.class,                       //  //Kalpesh Chande 
               CollaborationGroup.SObjectType=>YINCollaborationGroupSelector.Class,              //Kalpesh Chande
               YIN_Change_Request__c.SObjectType=>YINChangeRequestSelector.Class,                //Amol Patil
               YIN_Pincode__c.SObjectType=>YINPincodeSelector.Class,                             //Amol Patil
               EmailTemplate.SObjectType=>YINEmailTempSelector.Class,                            //Amol Patil
             // Start Adding by Sandeep Vishwakarma
               User.sObjectType => YINUserSelector.class,
               Contact.sObjectType => YINContactSelector.class,
               YIN_Account_product_Mapping__c.sObjectType => YINAccountProductMappingSelector.class,
               Order.sObjectType => YINOrderSelector.class,
               OrderItem.sObjectType => YINOrderItemSelector.class,
               YIN_Ledger__c.sObjectType => YINLedgerSelector.class,
               YIN_Variant__c.sObjectType => YINVariantSelector.class,
               // End Adding by Sandeep Vishwakarma  
               ContentDocumentLink.sObjectType =>YINContentDocumentLinkSelector.class,
               Contract.sObjectType => YINContractSelector.class,                               // Nikhil Dhoke ...   
               YIN_Vehicle_Detail__c.sObjectType => YINVehicleDetailSelector.class,             // Nikhil Dhoke ...
               Asset.sObjectType => YINAssetSelector.class,                                     // Nikhil Dhoke ...
               YIN_Channel_Code__c.sObjectType => YINChannelCodeSelector.class,                 // Nikhil Dhoke ...
               YIN_Discount_Coupons__c.sObjectType => YINDiscountCouponsSelector.class,         // Nikhil Dhoke ...
               YIN_Claim__c.sObjectType => YINClaimSelector.class,                              // Nikhil Dhoke ...
               Period.sObjectType => YINPeriodSelector.class,                                   // Nikhil Dhoke ... 
               Profile.SObjectType => YINProfileSelector.class,                                 // Nikhil Dhoke ... 
               YIN_Invoice__c.sObjectType =>YINInvoiceSelector.class,                            //Kalpesh Chande
               YIN_Location__c.sObjectType =>YINLocationSelector.class,                            //Kalpesh Chande
               YIN_Inventory__c.SObjectType =>YINInventorySelector.class,                         // vinayak godhade
               YIN_Invoice_Item__c.SObjectType =>YINInvoiceItemSelector.class,              //kalpesh chande
               YIN_Customer_Group__c.SObjectType => YINCustomerGroupSelector.class,          //kalpesh chande
               YIN_Payment__c.SObjectType => YINPaymentSelector.class,          //kalpesh chande 
               Network.SObjectType => YINNetworkSelector.class         //Kalpesh chande 
            }
      );
   
   /**
   * @description:Domain Layer is Used to perform Trigger Operation.
   */   
  
   public static final LibApplication.DomainFactory DOMAIN =
      new LibApplication.DomainFactory(
         YINApplication.Selector,
         new Map<SObjectType, Type> {

           
            YIN_Price_List__c.sObjectType => YINPriceListDomain.class,              //Prashant Kumbhar
             YIN_Monitor_Log__c.sObjectType=>YINMonitorDomain.class,                 //Prashant Kumbhar
			   Case.sObjectType=>YINAutoCasehandler.class                           //Satish Tiware
            // YIN_Change_Request__c.sObjectType=>YINChangeRequestERPHandler.class     //Amol Patil

         }
      );
   }