/**
 * @description       : This Class is used to create All layer like service,selector,domain and unit of work.                                          
 * @author            : Saurabh.pandey@skinternational.com
 * @last modified on  : 18-12-2023
 * @last modified by  : Amol Patil/amol.patil@skinternational.com
**/

public class Application {

/**
* @description:This method Objects which will used in DML Operations.
*/   
public static final LibApplication.UnitOfWorkFactory unitOfWork =
   new LibApplication.UnitOfWorkFactory(
      new List<SObjectType> {
            Account.sObjectType,
            Credit_Limit__c.sObjectType,
            Price_List__c.sObjectType,
            Pricebook2.sObjectType,
            PricebookEntry.sObjectType,   
            Monitor_Log__c.sObjectType,
            Attachment.sObjectType,
          //  Distributor_Document__c.sObjectType,   //Satish Tiware
            ContentVersion.sObjectType,   //change by kalpesh
            ContentDocumentLink.sObjectType,    //change by kalpesh
          //  KYC_Doc_Configuration__mdt.SObjectType,
           PriceBookEntry__mdt.sObjectType,
            Security_Deposit__c.sObjectType,
            Payment__c.sObjectType,    
            PJP__c.SObjectType,                //Saurabh
            Event.SObjectType,                 //Saurabh
         //   PJP_Detail__c.SObjectType,          //Saurabh
           Balance_Confirmation__c.SObjectType,    //Saurabh
            Target__c.SObjectType,             // Nik...
            Target_Distributor__c.SObjectType, // Nik...
          //  Target_Schedule__c.SObjectType,   // Nik...   
            // RecordType.SObjectType 
            Channel_Code__c.SObjectType,    //Kalpesh  
            Country__c.SObjectType,         //kalpesh
            State__c.SObjectType,           //kalpesh
            Zone__c.SObjectType,            //Kalpesh
            District__c.SObjectType,        //kalpesh
            Sub_District__c.SObjectType,    //kalpesh
            City__c.SObjectType,            //kalpesh
            Territory__c.SObjectType,       //kalpesh
            Pincode__c.SObjectType,         //kalpesh
            Location__c.SObjectType,         //kalpesh
            Change_Request__c.SObjectType,   //Amol Patil
            
            Order.SObjectType,
            OrderItem.SObjectType
      }
   ); 
    
    
    
/**
* @description:Service Layer is Used to perform Actual Logic.
*/
public static final LibApplication.ServiceFactory service =
   new LibApplication.ServiceFactory(
      new Map<Type, Type> {
          IPriceBookService.class =>IPriceBookServiceImp.class, 
          IPriceBookCreator.class =>CreatePriceBookByCustomerCommon.class,
          IPriceBookCreator.class =>CreatePriceBookByCustomer.class,
          IPriceBookCreator.class =>CreatePriceBookByCustomerGroup.class,         
          IMonitor.class => MonitorImp.class,
          ISecurityDeposit.class => SecurityDepositIncService.class,    
         // IPjpService.class => PJPServiceImpl.class,                        //Saurabh
         // TrgITargetAssignment.class=>TrgTargetAssignmentImpl.class,       // Nik...
         // TrgITargetDistribution.class=>TrgTargetDistributionImpl.class,   // Nik...
         // TrgITargetSchedules.class=>TrgTargetSchedulesImpl.class,        // Nik...
         // IContentVersionCreator.Class=>ContentVersionCreatorImp.Class,    //kalpesh
         // ICustomerOnboardingApplication.class =>ICustomerOnboardingService.class,   //Satish Tiware
         // IDocumentDataTable.class => DocumentDataTableImp.class,     //Satish Tiware
         IExternalApiServices.Class =>ChannelCodeService.Class,      //Kalpesh
         IExternalApiServices.Class =>CountryService.Class,          //Kalpesh
         IExternalApiServices.Class =>StateService.Class,            //Kalpesh
         IExternalApiServices.Class =>DistrictService.Class,         //Kalpesh
         IExternalApiServices.Class =>SubDistrictService.Class,      //Kalpesh
         IExternalApiServices.Class =>CityService.Class,             //Kalpesh
         IExternalApiServices.Class =>TerritoryService.Class,        //Kalpesh
         IExternalApiServices.Class =>PincodeService.Class,          //Kalpesh
         IExternalApiServices.Class =>LocationService.Class,         //Kalpesh
         IiconUtils.Class =>IconUtilsImp.Class,                      //kalpesh
         IPicklistColumnUtils.Class =>PicklistColumnUtilsImp.Class,  //kalpesh
         IRelatedList.Class =>RelatedListImp.Class,                  //kalpesh
         CrIChangeRequest.Class =>CrChangeRequestImpl.Class,          //Amol Patil 
         IBalanceConfirmation.class => BalanceConfirmationImpl.class //Saurabh
      }
   );

/**
* @description:Selector Layer is Used to perform SOQL Query.
*/   
public static final LibApplication.SelectorFactory selector =
   new LibApplication.SelectorFactory(
      new Map<SObjectType, Type> {
             Pricebook2.sObjectType => PriceBookSelector.class,
             Price_List__c.sObjectType  =>PriceListSelector.class,
             Monitor_Log__c.sObjectType =>MonitorSelector.class,
            // Distributor_Document__c.sObjectType => DistributorDocumentSelector.class,  //Satish Tiware
             ContentDocumentLink.sObjectType=>ContentDocumentLinkSelector.class,
             ContentVersion.sObjectType =>ContentVersionSelector.class,
            // KYC_Doc_Configuration__mdt.sObjectType => KycDocConfigSelector.class,      //Satish Tiware
            // User.sObjectType =>UserSelector.class,
             Security_Deposit__c.sObjectType=>SecurityDepositSelector.class,    
            // Profile.SObjectType => ProfileSelector.class,                                  //Saurabh
             PriceBookEntry__mdt.sObjectType =>PriceBookEngineSelector.class,
             PricebookEntry.sObjectType =>PriceBookEntrySelector.class,
             Account.SObjectType => AccountSelector.class,                                  // Nik ...
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
            // RecordType.getSObjectType()=>RecordTypeSelector.class,                          //kalpesh 
            // CollaborationGroup.SObjectType=>CollaborationGroupSelector.Class                //kalpesh
            Change_Request__c.SObjectType=>CrChangeRequestSelector.Class,                      //Amol Patil
            Pincode__c.SObjectType=>PincodeSelector.Class,                                      //Amol Patil
            Balance_Confirmation__c.SObjectType => BalanceConfirmationSelector.class,           //Saurabh

            // Start Adding by Sandeep Vishwakarma
            User.sObjectType => UserSelector.class,
            Contact.sObjectType => ContactSelector.class,
            Account_product_Mapping__c.sObjectType => AccountProductMappingSelector.class,
            Order.sObjectType => OrderSelector.class,
            OrderItem.sObjectType => OrderItemSelector.class
            // End Adding by Sandeep Vishwakarma
            
      }
   );

/**
* @description:Domain Layer is Used to perform Trigger Operation.
*/   
public static final LibApplication.DomainFactory domain =
   new LibApplication.DomainFactory(
      Application.Selector,
      new Map<SObjectType, Type> {
          Price_List__c.sObjectType => PriceListDomain.class,
          Monitor_Log__c.sObjectType=>MonitorDomain.class    
      }
   );
}