@isTest
public class YINMakePaymentControllerTest {

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
        String accountId = YINOrderManagementImpl.getExperienceUserAccount();
        YINMakePaymentController.getExperienceUserAccount();
        Test.stopTest();
        // Then
        System.assert(accountId!=null,'getOrderDetailsTest Working');
    }
    
    @IsTest
    static void testgetOpenInvoice() {
        LIBApexMocks mocks = new LIBApexMocks();
        List<YIN_Ledger__c> ledgers = YINOrderManagementDataFactoryTest.testLedgers();
        Account acc = YINOrderManagementDataFactoryTest.testAccount();
        YIN_Payment__c payment = YINOrderManagementDataFactoryTest.testPayment();
        Id securityDepositRecordType = Schema.SObjectType.YIN_Ledger__c.getRecordTypeInfosByName().get('Security Deposit').getRecordTypeId();
        YINLedgerSelector selectorMock = (YINLedgerSelector)mocks.mock(YINLedgerSelector.class);
        YINAccountSelector accountSelectorMock = (YINAccountSelector)mocks.mock(YINAccountSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.selectOpenInvoice(new List<Id>{acc.Id})).thenReturn(ledgers);
        mocks.when(accountSelectorMock.getAccounts(new List<String>{acc.Id})).thenReturn(new List<Account>{acc});
        mocks.stopStubbing();
        YINApplication.selector.setMock((YINLedgerSelector)mocks.mock(YINLedgerSelector.class));
        Test.startTest();
        List<YIN_Ledger__c> result = YINMakePaymentController.getOpenInvoice(acc.Id);
        YINMakePaymentController.getAccount(acc.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(0, result.size(), 'No records should be returned');
        mocks.verify(selectorMock);
    }
    
    @IsTest
    static void testCreatePaymentLinkAndPaymentRecord() {
        LIBApexMocks mocks = new LIBApexMocks();
        
         
        
        Account acc = YINOrderManagementDataFactoryTest.testAccount();
        
        String payBodyWithamount = '{"amount": 50000,"currency": "INR"}';
        String params = '{"accountId": "' + acc.Id + '","recordId": "","paymentRecordTypeName": "Invoice"}';
        
        YINAccountSelector accountSelectorMock = (YINAccountSelector)mocks.mock(YINAccountSelector.class);
        
        LibISObjectUnitOfWork mockUnitOfWork = (LibISObjectUnitOfWork)mocks.mock(LibISObjectUnitOfWork.class);
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.getAccounts(new List<String>{acc.Id})).thenReturn(new List<Account>{acc});
        mocks.when(YINApplication.unitOfWork.newInstance()).thenReturn(mockUnitOfWork);
        mocks.stopStubbing();
        
        YINApplication.selector.setMock(accountSelectorMock);
        YINApplication.unitOfWork.setMock(mockUnitOfWork);
        
        Test.startTest();
        YINMakePaymentController.createPaymentRecordAndRazorPayLink(payBodyWithamount,params);
        Test.stopTest();
    }
    
    @IsTest
    static void testCreatePaymentLinkAndPaymentRecordRest() {
        LIBApexMocks mocks = new LIBApexMocks();
        
         
        
        Account acc = YINOrderManagementDataFactoryTest.testAccount();
        
        String payBodyWithamount = '{"amount": 50000,"currency": "INR"}';
        String params = '{"accountId": "' + acc.Id + '","recordId": "","paymentRecordTypeName": "Invoice"}';
        
        YINAccountSelector accountSelectorMock = (YINAccountSelector)mocks.mock(YINAccountSelector.class);
        
        LibISObjectUnitOfWork mockUnitOfWork = (LibISObjectUnitOfWork)mocks.mock(LibISObjectUnitOfWork.class);
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.getAccounts(new List<String>{acc.Id})).thenReturn(new List<Account>{acc});
        mocks.when(YINApplication.unitOfWork.newInstance()).thenReturn(mockUnitOfWork);
        mocks.stopStubbing();
        
        YINApplication.selector.setMock(accountSelectorMock);
        YINApplication.unitOfWork.setMock(mockUnitOfWork);
        
        Test.startTest();
        YINMakePaymentRestService.createPaymentLinkAndPaymentRecord(payBodyWithamount,params);
        YINRazorPayOrderApi.makeRazorPayCallout(payBodyWithamount,'/test',params);
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateLedgerOpenInvoice() {
        LIBApexMocks mocks = new LIBApexMocks();
        
        Account acc = YINOrderManagementDataFactoryTest.testAccount();
        List<YIN_Ledger__c> ledgers = YINOrderManagementDataFactoryTest.testLedgers();
        List<String> ledgerIds =  new List<String>();
        for(YIN_Ledger__c ledger:ledgers){
            ledgerIds.add(ledger.Id);
        }
        String ids = JSON.serialize(ledgerIds);
        YIN_Payment__c payment = YINOrderManagementDataFactoryTest.testPayment();
        
        LibISObjectUnitOfWork mockUnitOfWork = (LibISObjectUnitOfWork)mocks.mock(LibISObjectUnitOfWork.class);
        mocks.startStubbing();
        //mocks.when(YINApplication.unitOfWork.newInstance()).thenReturn(mockUnitOfWork);
        mocks.stopStubbing();
        
        YINApplication.unitOfWork.setMock(mockUnitOfWork);
        
        Test.startTest();
        YINMakePaymentController.updateLedgerOpenInvoice(ids,payment.Id);
        YINOpenInvoiceUpdateLedger.updateLedgerOpenInvoice(ids,payment.Id);
        try{
            new YINException('Test');
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        Test.stopTest();
    }
    
    
    
}