@isTest
public class YINOrderRestServiceTest {
    @isTest
    public static void getCartDetailsTest( ){ 
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
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String openId= '';
        req.requestURI = '/services/apexrest/order/carts/?accountId='+accounts.Id; 
        req.httpMethod = 'Get';
        RestContext.request = req;
        try{
        	YINOrderRestCarts.getCartDetails();
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        Test.stopTest();
        // Then
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
        YINOrderRestCarts.addToCart(JSON.serialize(productWrappers[0]),orderDataTest[0].AccountId,'');
        Test.stopTest();
        
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
        String mesg = YINOrderRestCreate.createOrder(JSON.serialize(productWrappers),JSON.serialize(commitWrap));
        
        Test.stopTest();
        // Then
        System.assert(!String.isEmpty(mesg),'Working');
        
        String mesg1 = YINOrderRestCreate.createOrder('','');
        
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
        String mesg = YINOrderRestDelete.deleteCartItem(JSON.serialize(productWrappers[0]),acc.Id,'');
        Test.stopTest();
        // Then
        System.assertEquals(mesg,'"success"','Working');
        String mesg1 = YINOrderRestDelete.deleteCartItem('','','');
        
    }
    
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
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String type1= 'All';
        String moduleType = 'Normal';
        req.requestURI = '/services/apexrest/order/products/?accountId='+accountRecord.Id+'&orderType='+type1+'&moduleType='+moduleType; 
        req.httpMethod = 'Get';
        RestContext.request = req;
        try{
             String resultSuccess = YINOrderRestProducts.getProducts();
        }Catch(Exception e){
            System.debug('Exception '+e);
        }
           
        	
        Test.stopTest();
        

    }
}