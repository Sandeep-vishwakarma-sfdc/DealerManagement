@isTest
public with sharing class YINOrderManagementImplTest {
   
  	@isTest
    static void getProductsTest(){
        //1. setup
        
        List<YINProductWrapper> productWrappers = YINOrderManagementDataFactoryTest.getProductWrapperTestData();
        PriceBook2 priceBookCustome = YINOrderManagementDataFactoryTest.testPriceBook2Custom();
        List<PriceBook2> priceBooksCustomes = new List<PriceBook2>{priceBookCustome};
        List<YIN_Account_product_Mapping__c> accountProductMappings = YINOrderManagementDataFactoryTest.testAccountproductMapping();
        Account accountRecord = YINOrderManagementDataFactoryTest.testAccount();
        List<PricebookEntry> priceBookEnteryData = YINOrderManagementDataFactoryTest.testPriceBookEntries();
		
        List<YIN_Price_List__c> priceListData = YINOrderManagementDataFactoryTest.testPriceListData();
        
        //Create Mock
        LibApexMocks mocks = new LibApexMocks();
        YINAccountProductMappingSelector accountProductMappingSelectorMock = (YINAccountProductMappingSelector)mocks.mock(YINAccountProductMappingSelector.class);

        YINAccountSelector accountSelector = (YINAccountSelector)mocks.mock(YINAccountSelector.class);
        
        YINPriceBookSelector priceBookSelector = (YINPriceBookSelector)mocks.mock(YINPriceBookSelector.class);
        
        YINPriceBookEntrySelector priceBookEntrySelector = (YINPriceBookEntrySelector)mocks.mock(YINPriceBookEntrySelector.class);
        
        YINPriceListSelector priceListSelector = (YINPriceListSelector)mocks.mock(YINPriceListSelector.class);

        // Stubbing the behavior of the selector
        mocks.startStubbing();
            mocks.when(accountProductMappingSelectorMock.sObjectType()).thenReturn(YIN_Account_product_Mapping__c.SObjectType);
            mocks.when(accountProductMappingSelectorMock.selectAll()).thenReturn(accountProductMappings);
            
            mocks.when(accountSelector.sObjectType()).thenReturn(Account.SObjectType);
            mocks.when(accountSelector.getAccounts(new List<String>{accountRecord.Id})).thenReturn(new List<Account>{accountRecord});
        
        	mocks.when(priceBookSelector.sObjectType()).thenReturn(PriceBook2.SObjectType);
            mocks.when(priceBookSelector.selectPriceBookByCustomer(accountRecord.Id)).thenReturn(new List<PriceBook2>());
        	mocks.when(priceBookSelector.selectPriceBookByCustomerGroup(new List<String>{null})).thenReturn(new List<PriceBook2>());
            mocks.when(priceBookSelector.priceBookbyCustomerComman()).thenReturn(priceBooksCustomes);
        
        	mocks.when(priceBookEntrySelector.sObjectType()).thenReturn(PricebookEntry.SObjectType);
        	mocks.when(priceBookEntrySelector.selectPriceBookEntriesByPricebook(new List<Id>{priceBookCustome.Id},false)).thenReturn(priceBookEnteryData);
        
        	mocks.when(priceListSelector.sObjectType()).thenReturn(YIN_Price_List__c.SObjectType);
        	mocks.when(priceListSelector.selectPriceListByCustomer(accountRecord.Id)).thenReturn(new List<YIN_Price_List__c>());
        	mocks.when(priceListSelector.selectPriceListByCustomerGroup(new List<String>{null})).thenReturn(new List<YIN_Price_List__c>());
        	mocks.when(priceListSelector.selectCommonPriceList()).thenReturn(priceListData);
        mocks.stopStubbing();

        // Set the mock selector
        YINApplication.selector.setMock(accountProductMappingSelectorMock);
        YINApplication.selector.setMock(accountSelector);
        YINApplication.selector.setMock(priceBookSelector);
        YINApplication.selector.setMock(priceBookEntrySelector);
        YINApplication.selector.setMock(priceListSelector);

        // When
        Test.startTest();
            List<YINProductWrapper> resultSuccess = YINOrderManagementImpl.getProducts(accountRecord.Id,'All','Normal');
        	try{
                YINOrderManagementController.getProducts(accountRecord.Id,'All','Normal');
        		List<YINProductWrapper> resultError = YINOrderManagementImpl.getProducts(accountRecord.Id,'error','Normal');
            }catch(Exception e){
                System.debug('error '+e);
            }
        Test.stopTest();

        //Then
        System.assert(resultSuccess.size()>0,'getProductsTest Working');

    }

    @isTest static void getObjectApiNameTest(){
        Id accountId = LibIDGenerator.generate(Account.SObjectType);
        Test.startTest();
        String objectName = YINOrderManagementImpl.getObjectApiName(accountId);
        List<String> profiles = YINOrderManagementImpl.getExperienceUserProfiles();
        YINOrderManagementController.getExperienceUserProfiles();
        Test.stopTest();
        System.assertEquals('Account',objectName,'getObjectApiNameTest working');
        YINOrderManagementController.getObjectApiName(accountId);
        try{
            objectName = YINOrderManagementImpl.getObjectApiName('0');
        }catch(Exception e){
            System.debug('error checked');
        }
    }
    
    @isTest static void getOrderDetailsTest(){
        //1. setup
        List<Order> orderDataTest = YINOrderManagementDataFactoryTest.getOrderTest();
        //Create Mock
        LibApexMocks mocks = new LibApexMocks();
        YINOrderSelector orderSelector = (YINOrderSelector)mocks.mock(YINOrderSelector.class);
        
        // Stubbing the behavior of the selector
        mocks.startStubbing();
        	mocks.when(orderSelector.sObjectType()).thenReturn(Order.SObjectType);
        	mocks.when(orderSelector.selectById(new Set<Id>{orderDataTest[0].Id})).thenReturn(orderDataTest);
        mocks.stopStubbing();
        
        // Set the mock selector
        YINApplication.selector.setMock(orderSelector);
        
        // When
        Test.startTest();
        List<Order> orders = YINOrderManagementImpl.getOrderDetails(orderDataTest[0].Id);
        YINOrderManagementController.getOrderDetails(orderDataTest[0].Id);
        Test.stopTest();
        // Then
        System.assert(orders.size()>0,'getOrderDetailsTest Working');
        
    }
   
    @isTest static void addToCartInsertTest(){
        //1. setup
        List<Order> orderDataTest = YINOrderManagementDataFactoryTest.getOrderTest();
        List<YINProductWrapper> productWrappers = YINOrderManagementDataFactoryTest.getProductWrapperTestData();
        //Create Mock
        LibApexMocks mocks = new LibApexMocks();
        YINOrderSelector orderSelector = (YINOrderSelector)mocks.mock(YINOrderSelector.class);
        LibISObjectUnitOfWork mockUnitOfWork = (LibISObjectUnitOfWork)mocks.mock(LibISObjectUnitOfWork.class);
        
        // Stubbing the behavior of the selector
        mocks.startStubbing();
        	mocks.when(orderSelector.sObjectType()).thenReturn(Order.SObjectType);
        	mocks.when(orderSelector.selectRecentOrderOfAccountByStatus(orderDataTest[0].AccountId,'Cart','Cart')).thenReturn(orderDataTest);
        	mocks.when(YINApplication.unitOfWork.newInstance()).thenReturn(mockUnitOfWork);
        mocks.stopStubbing();
        
        // Set the mock selector
        YINApplication.selector.setMock(orderSelector);
        YINApplication.unitOfWork.setMock(mockUnitOfWork);
        
        // When
        Test.startTest(); 
        boolean isCreated = YINOrderManagementImpl.addToCart(JSON.serialize(productWrappers[0]),orderDataTest[0].AccountId,'');
        Test.stopTest();
        // Then
        System.assert(isCreated,'getOrderDetailsTest Working');
        try{
            YINOrderManagementController.addToCart(JSON.serialize(productWrappers[0]),orderDataTest[0].AccountId,'');
            YINOrderRestCarts.addToCart(JSON.serialize(productWrappers[0]),orderDataTest[0].AccountId,'');
           isCreated = YINOrderManagementImpl.addToCart(JSON.serialize(productWrappers[0]),orderDataTest[0].AccountId,orderDataTest[0].Id);
        }catch(Exception e){
            System.debug('error checked '+e.getMessage());
        }
    }
    
    @isTest static void addToCartUpdateTest(){
        //1. setup
        Account accounts = YINOrderManagementDataFactoryTest.testAccount();
        List<YINProductWrapper> productWrappers = YINOrderManagementDataFactoryTest.getProductWrapperTestData();
        //Create Mock
        LibApexMocks mocks = new LibApexMocks();
        YINOrderSelector orderSelector = (YINOrderSelector)mocks.mock(YINOrderSelector.class);
        LibISObjectUnitOfWork mockUnitOfWork = (LibISObjectUnitOfWork)mocks.mock(LibISObjectUnitOfWork.class);
        
        // Stubbing the behavior of the selector
        mocks.startStubbing();
        	mocks.when(orderSelector.sObjectType()).thenReturn(Order.SObjectType);
        	mocks.when(orderSelector.selectRecentOrderOfAccountByStatus(accounts.Id,'Cart','Cart')).thenReturn(new List<Order>());
        	mocks.when(YINApplication.unitOfWork.newInstance()).thenReturn(mockUnitOfWork);
        mocks.stopStubbing();
        
        // Set the mock selector
        YINApplication.selector.setMock(orderSelector);
        YINApplication.unitOfWork.setMock(mockUnitOfWork);
        
        // When
        Test.startTest();
        boolean isCreated = YINOrderManagementImpl.addToCart(JSON.serialize(productWrappers[0]),accounts.Id,'');
        Test.stopTest();
        // Then
        System.assert(isCreated,'getOrderDetailsTest Working');
    }
    
    @isTest static void getCartDetailsTest(){ 
        //1. setup
        Account accounts = YINOrderManagementDataFactoryTest.testAccount();
        List<OrderItem> orderItemsData = YINOrderManagementDataFactoryTest.getOrderItemTest();
        List<Order> orderData = YINOrderManagementDataFactoryTest.getOrderTest();
        List<YINProductWrapper> productWrappers = YINOrderManagementDataFactoryTest.getProductWrapperTestData();
        
        PriceBook2 priceBookCustome = YINOrderManagementDataFactoryTest.testPriceBook2Custom();
        List<YIN_Price_List__c> priceListData = YINOrderManagementDataFactoryTest.testPriceListData();
        List<PriceBook2> priceBooksCustomes = new List<PriceBook2>{priceBookCustome};
        List<YIN_Account_product_Mapping__c> accountProductMappings = YINOrderManagementDataFactoryTest.testAccountproductMapping();
        Account accountRecord = YINOrderManagementDataFactoryTest.testAccount();
        List<PricebookEntry> priceBookEnteryData = YINOrderManagementDataFactoryTest.testPriceBookEntries();
        //Create Mock
        LibApexMocks mocks = new LibApexMocks();
        YINOrderSelector orderSelector = (YINOrderSelector)mocks.mock(YINOrderSelector.class);
        YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)mocks.mock(YINOrderItemSelector.class);
        YINAccountProductMappingSelector accountProductMappingSelectorMock = (YINAccountProductMappingSelector)mocks.mock(YINAccountProductMappingSelector.class);

        YINAccountSelector accountSelector = (YINAccountSelector)mocks.mock(YINAccountSelector.class);
        
        YINPriceBookSelector priceBookSelector = (YINPriceBookSelector)mocks.mock(YINPriceBookSelector.class);
        
        YINPriceBookEntrySelector priceBookEntrySelector = (YINPriceBookEntrySelector)mocks.mock(YINPriceBookEntrySelector.class);
        
        YINPriceListSelector priceListSelector = (YINPriceListSelector)mocks.mock(YINPriceListSelector.class);
        
        
        
        // Stubbing the behavior of the selector
        mocks.startStubbing();
        	mocks.when(orderSelector.sObjectType()).thenReturn(Order.SObjectType);
        	mocks.when(orderSelector.selectRecentOrderOfAccountByStatus(accounts.Id,'Cart','Cart')).thenReturn(orderData);
        	
        	mocks.when(orderItemSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        	mocks.when(orderItemSelector.selectByOrder(orderData[0].Id)).thenReturn(orderItemsData);
        
        	mocks.when(accountProductMappingSelectorMock.sObjectType()).thenReturn(YIN_Account_product_Mapping__c.SObjectType);
            mocks.when(accountProductMappingSelectorMock.selectAll()).thenReturn(accountProductMappings);
        	mocks.when(accountProductMappingSelectorMock.selectByAccount(accounts.Id)).thenReturn(accountProductMappings);
            
            mocks.when(accountSelector.sObjectType()).thenReturn(Account.SObjectType);
            mocks.when(accountSelector.getAccounts(new List<String>{accountRecord.Id})).thenReturn(new List<Account>{accountRecord});
        
        	mocks.when(priceBookSelector.sObjectType()).thenReturn(PriceBook2.SObjectType);
            mocks.when(priceBookSelector.selectPriceBookByCustomer(accountRecord.Id)).thenReturn(new List<PriceBook2>());
        	mocks.when(priceBookSelector.selectPriceBookByCustomerGroup(new List<String>{null})).thenReturn(new List<PriceBook2>());
            mocks.when(priceBookSelector.priceBookbyCustomerComman()).thenReturn(priceBooksCustomes);
        
        	mocks.when(priceBookEntrySelector.sObjectType()).thenReturn(PricebookEntry.SObjectType);
        	mocks.when(priceBookEntrySelector.selectPriceBookEntriesByPricebook(new List<Id>{priceBookCustome.Id},false)).thenReturn(priceBookEnteryData);
        
        	mocks.when(priceListSelector.sObjectType()).thenReturn(YIN_Price_List__c.SObjectType);
        	mocks.when(priceListSelector.selectPriceListByCustomer(accountRecord.Id)).thenReturn(new List<YIN_Price_List__c>());
        	mocks.when(priceListSelector.selectPriceListByCustomerGroup(new List<String>{null})).thenReturn(new List<YIN_Price_List__c>());
        	mocks.when(priceListSelector.selectCommonPriceList()).thenReturn(priceListData);
        	
        mocks.stopStubbing();
        
        // Set the mock selector
        YINApplication.selector.setMock(orderSelector);
        YINApplication.selector.setMock(orderItemSelector);
        YINApplication.selector.setMock(accountProductMappingSelectorMock);
        YINApplication.selector.setMock(accountSelector);
        YINApplication.selector.setMock(priceBookSelector);
        YINApplication.selector.setMock(priceBookEntrySelector);
        YINApplication.selector.setMock(priceListSelector);
        
        // When
        Test.startTest();
        List<YINProductWrapper> wrapper = YINOrderManagementImpl.getCartDetails(accounts.Id,'','Normal');
        YINOrderManagementController.getCartDetails(accounts.Id,'','Normal');
        
        YINOrderManagementController.getAccount(accounts.Id);
        Test.stopTest();
        // Then
        System.assert(wrapper.size()>0,'getOrderDetailsTest Working');
    }
    
    @isTest static void deleteCartItemTest(){
        //1. setup
        Account acc = YINOrderManagementDataFactoryTest.testAccount();
        List<Order> orderDataTest = YINOrderManagementDataFactoryTest.getOrderTest();
        List<YINProductWrapper> productWrappers = YINOrderManagementDataFactoryTest.getProductWrapperTestData();
        List<OrderItem> orderItemsData = YINOrderManagementDataFactoryTest.getOrderItemTest();
        
        
        //Create Mock
        LibApexMocks mocks = new LibApexMocks();
        YINOrderSelector orderSelector = (YINOrderSelector)mocks.mock(YINOrderSelector.class);
        YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)mocks.mock(YINOrderItemSelector.class);
        LibISObjectUnitOfWork mockUnitOfWork = (LibISObjectUnitOfWork)mocks.mock(LibISObjectUnitOfWork.class);
        
        // Stubbing the behavior of the selector
        mocks.startStubbing();
        	mocks.when(orderSelector.sObjectType()).thenReturn(Order.SObjectType);
        	mocks.when(orderSelector.selectRecentOrderOfAccountByStatus(acc.Id,'Cart','Cart')).thenReturn(orderDataTest);
        	mocks.when(orderItemSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        	mocks.when(orderItemSelector.selectByOrderAndProduct(orderDataTest[0].Id,productWrappers[0].orderItemId)).thenReturn(orderItemsData);
        	mocks.when(YINApplication.unitOfWork.newInstance()).thenReturn(mockUnitOfWork);
        mocks.stopStubbing();
        
        // Set the mock selector
        YINApplication.selector.setMock(orderSelector);
        YINApplication.unitOfWork.setMock(mockUnitOfWork);
        
        // When
        Test.startTest();
        String mesg = YINOrderManagementImpl.deleteCartItem(JSON.serialize(productWrappers[0]),acc.Id,'');
        Test.stopTest();
        // Then
        System.assertEquals(mesg,'success','Working');
        try{
            YINOrderManagementController.deleteCartItem(JSON.serialize(productWrappers[0]),acc.Id,'');
           YINOrderManagementImpl.deleteCartItem(JSON.serialize(''),acc.Id,'');
        }catch(Exception e){
            System.debug('Exception test in delete Cart Item '+e.getMessage());
        }
    }
    
    @isTest static void createOrderTestWhenCommitFalse(){
        //1. setup
        Account acc = YINOrderManagementDataFactoryTest.testAccount();
        List<YIN_Variant__c> variants = YINOrderManagementDataFactoryTest.testVariants();
        List<Order> orderDataTest = YINOrderManagementDataFactoryTest.getOrderTest();
        
        List<YINProductWrapper> productWrappers = YINOrderManagementDataFactoryTest.getProductWrapperTestData();
        List<OrderItem> orderItemsData = YINOrderManagementDataFactoryTest.getOrderItemTest();
        YINOrderManagementImpl.wrapCommit commitWrap = new YINOrderManagementImpl.wrapCommit();
        commitWrap.doCommit = false;
        commitWrap.grandTotal = 500;
        commitWrap.accountId = acc.Id;
        commitWrap.shippingAccountCode = '1245678';
        
        //Create Mock
        LibApexMocks mocks = new LibApexMocks();
        YINOrderSelector orderSelector = (YINOrderSelector)mocks.mock(YINOrderSelector.class);
        YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)mocks.mock(YINOrderItemSelector.class);
        LibISObjectUnitOfWork mockUnitOfWork = (LibISObjectUnitOfWork)mocks.mock(LibISObjectUnitOfWork.class);
        YINAccountSelector accountSelector = (YINAccountSelector)mocks.mock(YINAccountSelector.class);
        YINVariantSelector variantSelector = (YINVariantSelector)mocks.mock(YINVariantSelector.class);
        
        // Stubbing the behavior of the selector
        mocks.startStubbing();
        	mocks.when(orderSelector.sObjectType()).thenReturn(Order.SObjectType);
        	mocks.when(orderSelector.selectRecentOrderOfAccountByStatus(acc.Id,'Cart','Cart')).thenReturn(orderDataTest);
        	mocks.when(orderSelector.selectById(new Set<Id>{orderItemsData[0].OrderId})).thenReturn(orderDataTest);
        	
        	mocks.when(orderItemSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        	System.debug('D orderDataTest[0].Id :::: '+orderDataTest[0].Id);
            System.debug('D productWrappers[0].orderItemId :::: '+productWrappers[0].orderItemId);
            System.debug('D orderItemsData :::: '+orderItemsData);
        	mocks.when(orderItemSelector.selectByOrderAndProduct(orderDataTest[0].Id,productWrappers[0].orderItemId)).thenReturn(orderItemsData);
        	mocks.when(orderItemSelector.selectById(new Set<Id>{orderItemsData[0].Id})).thenReturn(orderItemsData);
        	mocks.when(orderItemSelector.selectByOrder(orderItemsData[0].OrderId)).thenReturn(orderItemsData);
        	
        	mocks.when(YINApplication.unitOfWork.newInstance()).thenReturn(mockUnitOfWork);
        
        	mocks.when(accountSelector.sObjectType()).thenReturn(Account.SObjectType);
            mocks.when(accountSelector.getDealerIdList(new List<String>{'1245678'})).thenReturn(new List<Account>{acc});
         	mocks.when(accountSelector.getAccounts(new List<String>{acc.Id})).thenReturn(new List<Account>{acc});
        	mocks.when(accountSelector.selectShippingAccounts(acc.Id)).thenReturn(new List<Account>{acc});
        mocks.when(accountSelector.selectByERPShipToAndSoldToPartyCode(new List<String>{'1245678'})).thenReturn(new List<Account>{acc});
        	
        	mocks.when(variantSelector.sObjectType()).thenReturn(YIN_Variant__c.SObjectType);
            mocks.when(variantSelector.selectAll()).thenReturn(variants);
        mocks.stopStubbing();
        
        // Set the mock selector
        YINApplication.selector.setMock(orderSelector);
        YINApplication.unitOfWork.setMock(mockUnitOfWork);
        YINApplication.selector.setMock(accountSelector);
        YINApplication.selector.setMock(orderItemSelector);
        YINApplication.selector.setMock(variantSelector);
        
        // When
        Test.startTest();
        String mesg = YINOrderManagementImpl.createOrder(JSON.serialize(productWrappers),JSON.serialize(commitWrap));
        
        Test.stopTest();
        // Then
        System.assert(!String.isEmpty(mesg),'Working');
        try{
            YINOrderManagementController.createOrder(JSON.serialize(productWrappers),JSON.serialize(commitWrap));
        }catch(Exception e){
            System.debug('Exception '+e);
        }
    }
   
    @isTest static void createOrderTestWhenCommitDiscountFalse(){
        //1. setup
        Account acc = YINOrderManagementDataFactoryTest.testAccount();
        List<YIN_Variant__c> variants = YINOrderManagementDataFactoryTest.testVariants();
        List<Order> orderDataTest = YINOrderManagementDataFactoryTest.getOrderTest();
        
        List<YINProductWrapper> productWrappers = YINOrderManagementDataFactoryTest.getProductWrapperDiscountTestData();
        List<OrderItem> orderItemsData = YINOrderManagementDataFactoryTest.getOrderItemTest();
        YINOrderManagementImpl.wrapCommit commitWrap = new YINOrderManagementImpl.wrapCommit();
        commitWrap.doCommit = true;
        commitWrap.grandTotal = 500;
        commitWrap.accountId = acc.Id;
        commitWrap.shippingAccountCode = '1245678';
        
        //Create Mock
        LibApexMocks mocks = new LibApexMocks();
        YINOrderSelector orderSelector = (YINOrderSelector)mocks.mock(YINOrderSelector.class);
        YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)mocks.mock(YINOrderItemSelector.class);
        LibISObjectUnitOfWork mockUnitOfWork = (LibISObjectUnitOfWork)mocks.mock(LibISObjectUnitOfWork.class);
        YINAccountSelector accountSelector = (YINAccountSelector)mocks.mock(YINAccountSelector.class);
        YINVariantSelector variantSelector = (YINVariantSelector)mocks.mock(YINVariantSelector.class);
        
        // Stubbing the behavior of the selector
        mocks.startStubbing();
        	mocks.when(orderSelector.sObjectType()).thenReturn(Order.SObjectType);
        	mocks.when(orderSelector.selectRecentOrderOfAccountByStatus(acc.Id,'Cart','Cart')).thenReturn(orderDataTest);
        	mocks.when(orderSelector.selectById(new Set<Id>{orderItemsData[0].OrderId})).thenReturn(orderDataTest);
        	
        	mocks.when(orderItemSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        	System.debug('D orderDataTest[0].Id :::: '+orderDataTest[0].Id);
            System.debug('D productWrappers[0].orderItemId :::: '+productWrappers[0].orderItemId);
            System.debug('D orderItemsData :::: '+orderItemsData);
        	mocks.when(orderItemSelector.selectByOrderAndProduct(orderDataTest[0].Id,productWrappers[0].orderItemId)).thenReturn(orderItemsData);
        	mocks.when(orderItemSelector.selectById(new Set<Id>{orderItemsData[0].Id})).thenReturn(orderItemsData);
        	mocks.when(orderItemSelector.selectByOrder(orderItemsData[0].OrderId)).thenReturn(orderItemsData);
        	
        	mocks.when(YINApplication.unitOfWork.newInstance()).thenReturn(mockUnitOfWork);
        
        	mocks.when(accountSelector.sObjectType()).thenReturn(Account.SObjectType);
            mocks.when(accountSelector.getDealerIdList(new List<String>{'1245678'})).thenReturn(new List<Account>{acc});
         	mocks.when(accountSelector.getAccounts(new List<String>{acc.Id})).thenReturn(new List<Account>{acc});
        	mocks.when(accountSelector.selectShippingAccounts(acc.Id)).thenReturn(new List<Account>{acc});
        mocks.when(accountSelector.selectByERPShipToAndSoldToPartyCode(new List<String>{'1245678'})).thenReturn(new List<Account>{acc});
        	
        	mocks.when(variantSelector.sObjectType()).thenReturn(YIN_Variant__c.SObjectType);
            mocks.when(variantSelector.selectAll()).thenReturn(variants);
        mocks.stopStubbing();
        
        // Set the mock selector
        YINApplication.selector.setMock(orderSelector);
        YINApplication.unitOfWork.setMock(mockUnitOfWork);
        YINApplication.selector.setMock(accountSelector);
        YINApplication.selector.setMock(orderItemSelector);
        YINApplication.selector.setMock(variantSelector);
        
        // When
        Test.startTest();
        String mesg = YINOrderManagementImpl.createOrder(JSON.serialize(productWrappers),JSON.serialize(commitWrap));
        Test.stopTest();
        // Then
        System.assert(!String.isEmpty(mesg),'Working');
    }
    
   
    @isTest static void createOrderTestWhenCommitTrue(){
        //1. setup
        Account acc = YINOrderManagementDataFactoryTest.testAccount();
        List<Order> orderDataTest = YINOrderManagementDataFactoryTest.getOrderTest();
        List<YIN_Variant__c> variants = YINOrderManagementDataFactoryTest.testVariants();
        
        List<YINProductWrapper> productWrappers = YINOrderManagementDataFactoryTest.getProductWrapperTestData();
        List<OrderItem> orderItemsData = YINOrderManagementDataFactoryTest.getOrderItemTest();
        YINOrderManagementImpl.wrapCommit commitWrap = new YINOrderManagementImpl.wrapCommit();
        commitWrap.doCommit = true;
        commitWrap.grandTotal = 500;
        commitWrap.accountId = acc.Id;
        commitWrap.shippingAccountCode = '1245678';
        
        //Create Mock
        LibApexMocks mocks = new LibApexMocks();
        YINOrderSelector orderSelector = (YINOrderSelector)mocks.mock(YINOrderSelector.class);
        YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)mocks.mock(YINOrderItemSelector.class);
        LibISObjectUnitOfWork mockUnitOfWork = (LibISObjectUnitOfWork)mocks.mock(LibISObjectUnitOfWork.class);
        YINAccountSelector accountSelector = (YINAccountSelector)mocks.mock(YINAccountSelector.class);
        YINVariantSelector variantSelector = (YINVariantSelector)mocks.mock(YINVariantSelector.class);
        // Stubbing the behavior of the selector
        mocks.startStubbing();
        	mocks.when(orderSelector.sObjectType()).thenReturn(Order.SObjectType);
        	mocks.when(orderSelector.selectRecentOrderOfAccountByStatus(acc.Id,'Cart','Cart')).thenReturn(orderDataTest);
        	mocks.when(orderSelector.selectById(new Set<Id>{orderItemsData[0].OrderId})).thenReturn(orderDataTest);
        	
        	mocks.when(orderItemSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        	System.debug('D orderDataTest[0].Id :::: '+orderDataTest[0].Id);
            System.debug('D productWrappers[0].orderItemId :::: '+productWrappers[0].orderItemId);
            System.debug('D orderItemsData :::: '+orderItemsData);
        	mocks.when(orderItemSelector.selectByOrderAndProduct(orderDataTest[0].Id,productWrappers[0].orderItemId)).thenReturn(orderItemsData);
        	mocks.when(orderItemSelector.selectById(new Set<Id>{orderItemsData[0].Id})).thenReturn(orderItemsData);
        	mocks.when(orderItemSelector.selectByOrder(orderItemsData[0].OrderId)).thenReturn(orderItemsData);
        	
        	mocks.when(YINApplication.unitOfWork.newInstance()).thenReturn(mockUnitOfWork);
        
        	mocks.when(accountSelector.sObjectType()).thenReturn(Account.SObjectType);
            mocks.when(accountSelector.getDealerIdList(new List<String>{'1245678'})).thenReturn(new List<Account>{acc});
         	mocks.when(accountSelector.getAccounts(new List<String>{acc.Id})).thenReturn(new List<Account>{acc});
        	mocks.when(accountSelector.selectShippingAccounts(acc.Id)).thenReturn(new List<Account>{acc});
        mocks.when(accountSelector.selectByERPShipToAndSoldToPartyCode(new List<String>{'1245678'})).thenReturn(new List<Account>{acc});
        
        	mocks.when(variantSelector.sObjectType()).thenReturn(YIN_Variant__c.SObjectType);
            mocks.when(variantSelector.selectAll()).thenReturn(variants);
        	
        mocks.stopStubbing();
        
        // Set the mock selector
        YINApplication.selector.setMock(orderSelector);
        YINApplication.unitOfWork.setMock(mockUnitOfWork);
        YINApplication.selector.setMock(accountSelector);
        YINApplication.selector.setMock(orderItemSelector);
        YINApplication.selector.setMock(variantSelector);
        
        // When
        Test.startTest();
        String mesg = YINOrderManagementImpl.createOrder(JSON.serialize(productWrappers),JSON.serialize(commitWrap));
        Test.stopTest();
        // Then
        System.assert(!String.isEmpty(mesg),'Working');
    }
   
    @isTest static void getCurrentUserTest(){
        //1. setup
        User usr = YINOrderManagementDataFactoryTest.testUser();
        Contact contactRecord = YINOrderManagementDataFactoryTest.testContact();
        //Create Mock
        LibApexMocks mocks = new LibApexMocks();
        YINUserSelector userSelector = (YINUserSelector)mocks.mock(YINUserSelector.class);
        YINContactSelector contactSelector = (YINContactSelector)mocks.mock(YINContactSelector.class);
        
        // Stubbing the behavior of the selector
        mocks.startStubbing();
        	mocks.when(userSelector.sObjectType()).thenReturn(User.SObjectType);
        mocks.when(userSelector.getUserbyId(UserInfo.getUserId())).thenReturn(new List<User>{usr});
        
        mocks.when(contactSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactSelector.selectById(new Set<Id>{contactRecord.Id})).thenReturn(new List<Contact>{contactRecord});
        mocks.stopStubbing();
        
        // Set the mock selector
        YINApplication.selector.setMock(userSelector);
        YINApplication.selector.setMock(contactSelector);
        
        // When
        Test.startTest();
        User userRecord = YINOrderManagementImpl.getCurrentUser();
        YINOrderManagementController.getCurrentUser();
        String accountId = YINOrderManagementImpl.getExperienceUserAccount();
        YINOrderManagementController.getExperienceUserAccount();
        Test.stopTest();
        // Then
        System.assert(userRecord!=null,'getOrderDetailsTest Working');
        System.assert(accountId!=null,'getOrderDetailsTest Working');
    }
    
    @isTest static void promotionalOrderSendForApprovalTest(){
        //1. setup
        Account acc = YINOrderManagementDataFactoryTest.testAccount();
        List<Order> orderDataTest = YINOrderManagementDataFactoryTest.getOrderTest();
        //List<YIN_Variant__c> variants = YINOrderManagementDataFactoryTest.testVariants();
        
        List<YINProductWrapper> productWrappers = YINOrderManagementDataFactoryTest.getProductWrapperTestData();
        List<OrderItem> orderItemsData = YINOrderManagementDataFactoryTest.getOrderItemTest();
        YINOrderManagementImpl.wrapCommit commitWrap = new YINOrderManagementImpl.wrapCommit();
        commitWrap.doCommit = true;
        commitWrap.grandTotal = 500;
        commitWrap.accountId = acc.Id;
        commitWrap.shippingAccountCode = '1245678';
        
        //Create Mock
        LibApexMocks mocks = new LibApexMocks();
        YINOrderSelector orderSelector = (YINOrderSelector)mocks.mock(YINOrderSelector.class);
        YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)mocks.mock(YINOrderItemSelector.class);
        LibISObjectUnitOfWork mockUnitOfWork = (LibISObjectUnitOfWork)mocks.mock(LibISObjectUnitOfWork.class);
        YINAccountSelector accountSelector = (YINAccountSelector)mocks.mock(YINAccountSelector.class);
        YINVariantSelector variantSelector = (YINVariantSelector)mocks.mock(YINVariantSelector.class);
        // Stubbing the behavior of the selector
        mocks.startStubbing();
        	mocks.when(orderSelector.sObjectType()).thenReturn(Order.SObjectType);
        	//mocks.when(orderSelector.selectRecentOrderOfAccountByStatus(acc.Id,'Cart','Cart')).thenReturn(orderDataTest);
        	//mocks.when(orderSelector.selectById(new Set<Id>{orderItemsData[0].OrderId})).thenReturn(orderDataTest);
        	
        	mocks.when(orderItemSelector.sObjectType()).thenReturn(OrderItem.SObjectType);
        	//System.debug('D orderDataTest[0].Id :::: '+orderDataTest[0].Id);
            System.debug('D productWrappers[0].orderItemId :::: '+productWrappers[0].orderItemId);
            System.debug('D orderItemsData :::: '+orderItemsData);
        	//mocks.when(orderItemSelector.selectByOrderAndProduct(orderDataTest[0].Id,productWrappers[0].orderItemId)).thenReturn(orderItemsData);
        	mocks.when(orderItemSelector.selectById(new Set<Id>{orderItemsData[0].Id})).thenReturn(orderItemsData);
        	mocks.when(orderItemSelector.selectByOrder(orderItemsData[0].OrderId)).thenReturn(orderItemsData);
        mocks.when(orderItemSelector.selectByOrder(orderDataTest[0].Id)).thenReturn(orderItemsData);
        mocks.when(orderSelector.selectByExtraFields(new Set<Id>{orderDataTest[0].Id})).thenReturn(orderDataTest);
        mocks.when(orderSelector.selectByExtraFields(new Set<Id>{orderItemsData[0].OrderId})).thenReturn(orderDataTest);
        	
        	mocks.when(YINApplication.unitOfWork.newInstance()).thenReturn(mockUnitOfWork);
        
        	mocks.when(accountSelector.sObjectType()).thenReturn(Account.SObjectType);
            mocks.when(accountSelector.getDealerIdList(new List<String>{'1245678'})).thenReturn(new List<Account>{acc});
         	mocks.when(accountSelector.getAccounts(new List<String>{acc.Id})).thenReturn(new List<Account>{acc});
        	mocks.when(accountSelector.selectShippingAccounts(acc.Id)).thenReturn(new List<Account>{acc});
        mocks.when(accountSelector.selectByERPShipToAndSoldToPartyCode(new List<String>{'1245678'})).thenReturn(new List<Account>{acc});
        
        	mocks.when(variantSelector.sObjectType()).thenReturn(YIN_Variant__c.SObjectType);
            //mocks.when(variantSelector.selectAll()).thenReturn(variants);
        	
        mocks.stopStubbing();
        
        // Set the mock selector
        YINApplication.selector.setMock(orderSelector);
        YINApplication.unitOfWork.setMock(mockUnitOfWork);
        YINApplication.selector.setMock(accountSelector);
        YINApplication.selector.setMock(orderItemSelector);
        YINApplication.selector.setMock(variantSelector);
        
        // When
        YINPromotionalOrderUtils.PreviousQuarterAndYear qY = new YINPromotionalOrderUtils.PreviousQuarterAndYear();
        qy.prevQuarter = 'Q1';
        qy.prevYear = '2024';
        
        Test.startTest();
        YINPromotionalOrderUtils.testInjectionQuaterYear = qy;
        YINOrderManagementController.promotionalOrderSendForApproval(JSON.Serialize(productWrappers),'1245678');
        //YINPromotionalOrderUtils.LedgerBudgetInfo info = YINPromotionalOrderUtils.getCurrentYearQuaterledger(acc.Id,'Promotional_Budget');
        YINOrderManagementController.getCurrentYearQuaterledger(acc.Id,'Promotional_Budget');
        String pOrder = YINPromotionalOrderUtils.createPromotionalOrder(orderDataTest[0].Id);
        
        qy.prevQuarter = 'Q3';
        qy.prevYear = '2023';
        YINPromotionalOrderUtils.testInjectionQuaterYear = qy;
        YINPromotionalOrderUtils.getBudgets(acc.Id,250,'Promotional_Budget');
        
        qy.prevQuarter = 'Q2';
        qy.prevYear = '2023';
        YINPromotionalOrderUtils.testInjectionQuaterYear = qy;
        YINPromotionalOrderUtils.getBudgets(acc.Id,250,'Promotional_Budget');
        
        qy.prevQuarter = 'Q1';
        qy.prevYear = '2023';
        YINPromotionalOrderUtils.testInjectionQuaterYear = qy;
        YINPromotionalOrderUtils.getBudgets(acc.Id,250,'Promotional_Budget');
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String recType= 'Promotional_Budget';
        
        req.requestURI = '/services/apexrest/promotionalorder?accountId='+acc.Id+'&recordType='+recType; 
        req.httpMethod = 'Get';
        RestContext.request = req;
        try{
        	YINPromotionalOrderRestService.getLedgerInfo();
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        
        YINPromotionalOrderRestService.sendForApproval(JSON.Serialize(productWrappers),'1245678');
        
        Test.stopTest();
        // Then
    }

}