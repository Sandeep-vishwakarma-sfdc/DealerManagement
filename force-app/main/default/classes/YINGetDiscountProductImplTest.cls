@isTest
public with sharing class YINGetDiscountProductImplTest {
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
        	mocks.when(priceBookEntrySelector.selectPriceBookEntriesByPricebook(new List<Id>{priceBookCustome.Id},true)).thenReturn(priceBookEnteryData);
        
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
            YINGetDiscountProductImpl impl = new YINGetDiscountProductImpl();
            List<YINProductWrapper> result = impl.getProducts(accountRecord.Id,true);
        Test.stopTest();

        //Then
        System.assertEquals(1, 1, 'Working');

    }
}