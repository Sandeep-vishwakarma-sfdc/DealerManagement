@isTest
public with sharing class YINOrderManagementDataFactoryTest {
    private static Account accountRecord = null;
    private static Contact contactRecord = null;
    private static List<Product2> productsList = null;
    private static PriceBook2 priceBookCustome = null;
    private static List<PricebookEntry> priceBookEntriesRecords = null;
    private static List<YIN_Price_List__c> testPriceListRecords = null;
    private static Order orderRecord = null;
    private static List<OrderItem> orderItemRecords = null;
    private static List<YIN_Variant__c> variantsRecord = null;
    
    private static List<YIN_Ledger__c> ledgerRecord = null;
    private static YIN_Payment__c paymentRecord = null;
    // Creating Standrad Object Records
    public static Account testAccount(){
        Account acc = new Account();
        acc.Id = LibIDGenerator.generate(Account.SObjectType);
        acc.Name = 'Mahesh Tyres Pvt Ltd';
        acc.SFDC_Customer_Code__c = '1245678';
        acc.BillingCity = 'Mumbai';
        acc.BillingStreet = 'Balwant Phadke marg'; 
        acc.BillingState = 'maharashtra'; 
        acc.BillingPostalCode = '400001'; 
        acc.BillingCountry = 'India';
        acc.ShippingStreet = 'Balwant Phadke marg';
        acc.ShippingCity = 'Mumbai';
        acc.ShippingState = 'maharashtra'; 
        acc.ShippingPostalCode = '400001'; 
        acc.ShippingCountry = 'India';
        acc.Phone = '123456780'; 
        acc.PAN_Status__c = 'Valid';
        acc.Is_Capping_Enable__c = true;
        acc.Is_Locking_Enable__c = true;
        acc.X1H_TCS__c = true;
        // acc.ParentId = '';
        acc.Contact_Name__c = 'Mahesh Tyres';
        acc.Contact_Person_Email__c = 'mahesh@gmail.com';
        acc.Contact_Person_Phone__c = '1245678';
        acc.Primary_Contact_Number__c = '1245678';
        acc.Customer_Group__c = null;
        //acc.Total_Credit_Limit__c = 500000;
        acc.Orginal_Credit_Limit__c = 500000;
        acc.Additional_Credit_Limit__c = 2000;
        acc.Fixed_Additional_Credit_Amount__c = 0;
        acc.ERP_Ship_To_Code__c = '1245678';
        acc.ERP_Customer_Code__c = '1245678';
        //acc.Outstanding_Amount__c = 2000;
        if(accountRecord==null){
            accountRecord = acc;
        }
        return accountRecord;

    }
    
    public static List<YIN_Ledger__c> testLedgers(){
        List<YIN_Ledger__c> ledgers = new List<YIN_Ledger__c>();
        YIN_Ledger__c ledgerLedger = new YIN_Ledger__c();
        ledgerLedger.Id = LibIDGenerator.generate(YIN_Ledger__c.SObjectType);
        ledgerLedger.Dealer_Code__r = testAccount();
        ledgerLedger.RecordTypeId = Schema.SObjectType.YIN_Ledger__c.getRecordTypeInfosByName().get('Ledger').getRecordTypeId();
        ledgerLedger.Posting_Date__c = Date.today() - 1;
        ledgerLedger.Cheque_Clearance_Date__c = Date.today() - 10;
        ledgerLedger.Amount__c = 5000;
        ledgerLedger.Cheque_Date__c = Date.today() - 10;
        ledgerLedger.Cheque_Number__c = '12345678';
        ledgerLedger.Applies_To_Type__c = 'to Type';
        ledgerLedger.Applies_To_Document__c = 'Apply';
        ledgerLedger.Another_Bank_Account_Number__c = 'BANK4321';
        ledgerLedger.AmountLCY__c= 50;
        ledgerLedger.Debit_LCY__c = 50;
        ledgerLedger.Document_Date__c = Date.today() - 10;
        ledgerLedger.Document_Number__c = '123456';
        ledgerLedger.Document_Type__c = 'Invoice';
        ledgerLedger.Credit_LCY__c = 50;
        ledgerLedger.Credit_Amount__c = 50;
        ledgerLedger.Debit_Amount__c = 20;
        ledgerLedger.External_Document_Number__c = 'T1234';
        ledgerLedger.Due_Date__c = Date.today() + 1;
        ledgerLedger.Closed_Entry_No__c = 'C123';
        ledgerLedger.Payment_Method__c = 'UPI';
        ledgerLedger.Bank_Account_Number__c = 'BANK1234';
		ledgerLedger.Transaction_Number__c = 'T1234';
        ledgerLedger.Remaining_Amount__c = 1000;
        ledgerLedger.Remaining_Amount_LCY__c = 10000;
        ledgerLedger.Reversed__c = true;
        ledgerLedger.Open__c = true;
        ledgerLedger.Entry_Number__c = 'E123';
        ledgerLedger.Ledger_Type__c = 'Invoice';
        ledgerLedger.Closed_Amount__c = 45;
        ledgerLedger.Location__c = null;
        ledgerLedger.Payment__r = testPayment();
        ledgerLedger.GST_Jurisdiction_Type__c = 'GST123';
        ledgerLedger.Closed_Date__c = Date.today() + 1;
        
        
        YIN_Ledger__c ledgersSecurityDeposit = new YIN_Ledger__c();
        ledgersSecurityDeposit.Id = LibIDGenerator.generate(YIN_Ledger__c.SObjectType);
        ledgersSecurityDeposit.Dealer_Code__r = testAccount();
        ledgersSecurityDeposit.RecordTypeId = Schema.SObjectType.YIN_Ledger__c.getRecordTypeInfosByName().get('Security Deposit').getRecordTypeId();
        ledgersSecurityDeposit.Posting_Date__c = Date.today() - 1;
        ledgersSecurityDeposit.Document_Number__c = '1234';
        ledgersSecurityDeposit.Credit_Amount__c = 5000;
        ledgersSecurityDeposit.Amount__c = 5000;
        ledgersSecurityDeposit.Cheque_Number__c = '12345';
        ledgersSecurityDeposit.Cheque_Date__c = Date.today() - 10;
        
        
        YIN_Ledger__c ledgersTCSLedger = new YIN_Ledger__c();
        ledgersTCSLedger.Id = LibIDGenerator.generate(YIN_Ledger__c.SObjectType);
        ledgersTCSLedger.Dealer_Code__r = testAccount();
        ledgersTCSLedger.RecordTypeId = Schema.SObjectType.YIN_Ledger__c.getRecordTypeInfosByName().get('TCS Ledger').getRecordTypeId();
        ledgersTCSLedger.Posting_Date__c = Date.today() - 1;
        ledgersTCSLedger.Assessee_Code__c = 'E123';
        ledgersTCSLedger.TCS_Nature_of_Collection__c = 'TCS123';
        ledgersTCSLedger.TCS_Percent__c = 111;
        ledgersTCSLedger.TCS_Amount__c = 111;
        ledgersTCSLedger.TCS_Base_Amount__c = 123;
        ledgersTCSLedger.Custome_PAN__c = 'PAN12345';
        ledgersTCSLedger.ERP_Code__c = 'TCS12323';
        ledgersTCSLedger.Year__c = '2024';
        ledgersTCSLedger.Quarter__c = 'Q1';
        
        
        
        YIN_Ledger__c ledgersPromotionalBudget = new YIN_Ledger__c();
        ledgersPromotionalBudget.Id = LibIDGenerator.generate(YIN_Ledger__c.SObjectType);
        ledgersPromotionalBudget.Dealer_Code__r = testAccount();
        ledgersPromotionalBudget.RecordTypeId = Schema.SObjectType.YIN_Ledger__c.getRecordTypeInfosByName().get('Promotional_Budget').getRecordTypeId();
        ledgersPromotionalBudget.Posting_Date__c = Date.today() - 1;
        
        ledgers.add(ledgerLedger);
        ledgers.add(ledgersSecurityDeposit);
        ledgers.add(ledgersTCSLedger);
        ledgers.add(ledgersPromotionalBudget);
        if(ledgerRecord==null){
            ledgerRecord = ledgers;
        }
        return ledgerRecord;
    }
    
    public static YIN_Payment__c testPayment(){
        YIN_Payment__c payment = new YIN_Payment__c();
        payment.Amount__c = 100;
        payment.Customer_Number__r = testAccount();
        if(paymentRecord==null){
            paymentRecord = payment;
        }
        return paymentRecord;
    }
    
    public static Contact testContact(){
        Account acc = testAccount();
        Contact con = new Contact();
        con.Id = LibIDGenerator.generate(Contact.SObjectType);
        con.FirstName = 'Mahesh Contact';
        con.LastName = 'Mahesh Contact';
        con.AccountId = acc.Id;
        con.Account = acc;
        if(contactRecord==null){
            contactRecord = con;
        }
        return contactRecord;
    }
   
    private static PriceBook2 testPriceBook2Standard(){
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        return standardPricebook;
    }

    public static PriceBook2 testPriceBook2Custom(){
        Id pricebookId = LibIDGenerator.generate(PriceBook2.SObjectType);
        Pricebook2 customePricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true,
            Customer__c = testAccount().Id,
            Customer__r = testAccount(),
            Type__c = 'All Customer'
        );
        if(priceBookCustome==null){
            priceBookCustome = customePricebook;
        }
        return priceBookCustome;
    }

    public static List<Product2> testProduct2(){
        List<Product2> products = new List<Product2>();
        for(Integer i=1;i<=10;i++){
            Product2 p = new Product2();
            p.Id =  LibIDGenerator.generate(Product2.SObjectType);
            p.Name = 'Test Product '+1;
            p.Description='Test Product Entry For Product';
            p.productCode = 'PC-00'+i;
            p.product_Code__c = 'PC-00'+i;
            p.isActive = true;
            p.Tire_Size__c = '165/80R14 85T';
            p.Tread_Pattern__c = 'patter '+i;
			p.Item_Category_Code__c = 'TIRE_I';
            products.add(p);
        }
        if(productsList==null){
            productsList = products;
        }
        return productsList;
    }

    public static List<PricebookEntry> testPriceBookEntries(){
        PriceBook2 customePricebook = testPriceBook2Custom();
        List<Product2> products = testProduct2();
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for(Product2 p:products){
            PricebookEntry pbe1 = new PricebookEntry(
                Pricebook2Id = customePricebook.Id,
                Product2Id = p.Id,
                Pricebook2 = customePricebook,
                Product2 = p,
                UnitPrice = 5999,
                IsActive = true,
                Start_Date__c = System.today()-1,
                End_Date__c = System.today()+10
            );
            pbEntries.add(pbe1);
        }
        if(priceBookEntriesRecords==null){
            priceBookEntriesRecords = pbEntries;
        }
        return priceBookEntriesRecords;
    }

    public static List<YIN_Price_List__c> testPriceListData(){

        List<YIN_Price_List__c> priceLists = new List<YIN_Price_List__c>();
        List<Product2> products = testProduct2();
        for(Integer i=0;i<=3;i++){
            YIN_Price_List__c pl = new YIN_Price_List__c();
            pl.Name = 'pl '+i;
            pl.Start_Date__c = System.today()-1;
            pl.End_Date__c = System.today()+10;
            pl.Unit_Price__c = 4000;
            pl.UOM__c = 'PCS';
            pl.Sales_type__c = 'Customer';
            pl.Minimum_Quantity__c = 1;
            pl.Customer__c = testAccount().Id;
            pl.Customer__r = testAccount();
            pl.product__c = products[i].Id;
            pl.product__r = products[i];
            pl.Discount_type__c = 'Product Discount';
            pl.Discount_Percentage__c = 1000;
            pl.recordTypeId = Schema.SObjectType.YIN_Price_List__c.getRecordTypeInfosByName().get('Discount').getRecordTypeId();
            priceLists.add(pl);
        }

        if(testPriceListRecords==null){
            testPriceListRecords = priceLists;
        }
        return testPriceListRecords;
    }

    public static User testUser(){
        Contact con = testContact();
        Profile profile = [SELECT Id,Name FROM Profile WHERE Name='Dealer Partner User'];
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(
            Alias = uid, 
            Email= uid + '@yokohama.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = profile.Id, 
            TimeZoneSidKey='America/New_York', 
            UserName= uid + '@myorg.com',
            ContactId = con.Id,
            Contact = con,
            Id=LibIDGenerator.generate(User.SObjectType)
            );
        return u;
    }

    public static List<YINProductWrapper> getProductWrapperTestData(){
        List<PricebookEntry> entries = testPriceBookEntries();
        List<OrderItem> orderItems = getOrderItemTest();
        List<YINProductWrapper> productsWrapper= new List<YINProductWrapper>();
        Integer i = 0;
        for(PricebookEntry priceBookEntry:entries){
            YINProductWrapper productWrapper = new YINProductWrapper();
            productWrapper.pricebookEntry = priceBookEntry;
            
            productWrapper.productId = priceBookEntry.Product2Id;
            productWrapper.maximumOrderQuantity = 24;
            productWrapper.minimumOrderQuantity = 1;
            productWrapper.quantity = 1; // Default Quantity value when Order page loads
            productWrapper.discountPercentage = 0;
            productWrapper.frequentlyBoughtProduct = true;
            productWrapper.lockingSKUAccount = false;
            productWrapper.lockingSKULocation = false;
            productWrapper.trendingSKU = true;
            productWrapper.productOfTheMonth = true;
            productWrapper.unitPrice = priceBookEntry.UnitPrice;
            productWrapper.netPrice = (1 * priceBookEntry.UnitPrice);
            productWrapper.productName = priceBookEntry.Product2.Name;
            productWrapper.productSize = priceBookEntry.Product2.Size__c;
            productWrapper.productPattern = priceBookEntry.Product2.Tread_Pattern__c;
            productWrapper.combinationKey = priceBookEntry.Product2.ProductCode;
            productWrapper.maximumCappingQuantity = 24;
            productWrapper.GSTPercentage = 28;
            productWrapper.tdsPercentage = 1;
            productWrapper.tcsPercentage = 0;
            productWrapper.discountPercentage = 10;
            productWrapper.applyTCS = false;
            //productWrapper.variantCode = '2021';
            
            productWrapper.locationCode = '00LC';
            if(i<1){
            productWrapper.orderItemId = orderItems[i].Id;
            productWrapper.priceList = testPriceListData()[i];
            }
            // Adding productWrapper to List
            productsWrapper.add(productWrapper);
            i++;
        }
        return productsWrapper;
    }
    
    public static List<YINProductWrapper> getProductWrapperDiscountTestData(){
        List<PricebookEntry> entries = testPriceBookEntries();
        List<OrderItem> orderItems = getOrderItemTest();
        List<YINProductWrapper> productsWrapper= new List<YINProductWrapper>();
        Integer i = 0;
        for(PricebookEntry priceBookEntry:entries){
            YINProductWrapper productWrapper = new YINProductWrapper();
            productWrapper.pricebookEntry = priceBookEntry;
            if(i==0){
            	productWrapper.priceList = testPriceListData()[0];
            }
            productWrapper.productId = priceBookEntry.Product2Id;
            productWrapper.maximumOrderQuantity = 24;
            productWrapper.minimumOrderQuantity = 1;
            productWrapper.quantity = 1; // Default Quantity value when Order page loads
            productWrapper.discountPercentage = 0;
            productWrapper.frequentlyBoughtProduct = true;
            productWrapper.lockingSKUAccount = false;
            productWrapper.lockingSKULocation = false;
            productWrapper.trendingSKU = true;
            productWrapper.productOfTheMonth = true;
            productWrapper.unitPrice = priceBookEntry.UnitPrice;
            productWrapper.netPrice = (1 * priceBookEntry.UnitPrice);
            productWrapper.productName = priceBookEntry.Product2.Name;
            productWrapper.productSize = priceBookEntry.Product2.Size__c;
            productWrapper.productPattern = priceBookEntry.Product2.Tread_Pattern__c;
            productWrapper.combinationKey = priceBookEntry.Product2.ProductCode;
            productWrapper.maximumCappingQuantity = 24;
            productWrapper.GSTPercentage = 28;
            productWrapper.tdsPercentage = 1;
            productWrapper.tcsPercentage = 0;
            productWrapper.applyTCS = false;
            productWrapper.variantCode = '2021';
            productWrapper.locationCode = '00LC';
            if(i<1){
            productWrapper.orderItemId = orderItems[i].Id;
            }
            // Adding productWrapper to List
            productsWrapper.add(productWrapper);
            i++;
        }
        return productsWrapper;
    }
    
    // Creating Custome Object Records
    public static List<YIN_Account_product_Mapping__c> testAccountproductMapping(){

        List<YIN_Account_product_Mapping__c> mappings = new List<YIN_Account_product_Mapping__c>();

        List<Product2> products = testProduct2();
        Account acc = testAccount();
        YIN_Account_product_Mapping__c lockingAccountProduct = new YIN_Account_product_Mapping__c();
        lockingAccountProduct.Id = LibIDGenerator.generate(YIN_Account_product_Mapping__c.SObjectType);
        lockingAccountProduct.Type__c = 'Locking Account Product';
        lockingAccountProduct.Product__c =  products[0].Id;
        lockingAccountProduct.Product__r =  products[0];
        lockingAccountProduct.Maximum_Order_Quantity__c =  24;
        lockingAccountProduct.Minimum_Order_Quantity__c =  1;
        lockingAccountProduct.Status__c =  true;
        lockingAccountProduct.Start_Date__c = System.TODAY()-1;
        lockingAccountProduct.End_Date__c = System.TODAY()+10;
        lockingAccountProduct.Account__c = acc.Id;
        lockingAccountProduct.Account__r = acc;


        YIN_Account_product_Mapping__c lockingLocationProduct = new YIN_Account_product_Mapping__c();
        lockingLocationProduct.Id = LibIDGenerator.generate(YIN_Account_product_Mapping__c.SObjectType);
        lockingLocationProduct.Type__c = 'Locking Location Product';
        lockingLocationProduct.Product__c =  products[1].Id;
        lockingLocationProduct.Product__r =  products[1];
        lockingLocationProduct.Maximum_Order_Quantity__c =  24;
        lockingLocationProduct.Minimum_Order_Quantity__c =  1;
        lockingLocationProduct.Status__c =  true;
        lockingLocationProduct.Start_Date__c = System.TODAY()-1;
        lockingLocationProduct.End_Date__c = System.TODAY()+10;
        lockingLocationProduct.Account__c = acc.Id;
        lockingLocationProduct.Account__r = acc;

        YIN_Account_product_Mapping__c trendingProducts = new YIN_Account_product_Mapping__c();
        trendingProducts.Id = LibIDGenerator.generate(YIN_Account_product_Mapping__c.SObjectType);
        trendingProducts.Type__c = 'Trending Products';
        trendingProducts.Product__c =  products[2].Id;
        trendingProducts.Product__r =  products[2];
        trendingProducts.Maximum_Order_Quantity__c =  24;
        trendingProducts.Minimum_Order_Quantity__c =  1;
        trendingProducts.Status__c =  true;
        trendingProducts.Start_Date__c = System.TODAY()-1;
        trendingProducts.End_Date__c = System.TODAY()+10;
        trendingProducts.Account__c = acc.Id;
        trendingProducts.Account__r = acc;

        YIN_Account_product_Mapping__c productoftheMonth = new YIN_Account_product_Mapping__c();
        productoftheMonth.Id = LibIDGenerator.generate(YIN_Account_product_Mapping__c.SObjectType);
        productoftheMonth.Type__c = 'Product of the Month';
        productoftheMonth.Product__c =  products[3].Id;
        productoftheMonth.Product__r =  products[3];
        productoftheMonth.Maximum_Order_Quantity__c =  24;
        productoftheMonth.Minimum_Order_Quantity__c =  1;
        productoftheMonth.Status__c =  true;
        productoftheMonth.Start_Date__c = System.TODAY()-1;
        productoftheMonth.End_Date__c = System.TODAY()+10;
        productoftheMonth.Account__c = acc.Id;
        productoftheMonth.Account__r = acc;

        YIN_Account_product_Mapping__c frequentlyBoughtProduct = new YIN_Account_product_Mapping__c();
        frequentlyBoughtProduct.Id = LibIDGenerator.generate(YIN_Account_product_Mapping__c.SObjectType);
        frequentlyBoughtProduct.Type__c = 'Frequently Bought Product';
        frequentlyBoughtProduct.Product__c =  products[4].Id;
        frequentlyBoughtProduct.Product__r =  products[4];
        frequentlyBoughtProduct.Maximum_Order_Quantity__c =  24;
        frequentlyBoughtProduct.Minimum_Order_Quantity__c =  1;
        frequentlyBoughtProduct.Status__c =  true;
        frequentlyBoughtProduct.Start_Date__c = System.TODAY()-1;
        frequentlyBoughtProduct.End_Date__c = System.TODAY()+10;
        frequentlyBoughtProduct.Account__c = acc.Id;
        frequentlyBoughtProduct.Account__r = acc;

        mappings.add(lockingAccountProduct);
        mappings.add(lockingLocationProduct);
        mappings.add(trendingProducts);
        mappings.add(productoftheMonth);
        mappings.add(frequentlyBoughtProduct);



        return mappings;
    }
    private static List<YIN_Ledger__c> testLedger(){
        return new List<YIN_Ledger__c>();
    }
    
    

    public static List<Order> getOrderTest(){
        Order o = new Order();
        o.Id = LibIDGenerator.generate(Order.SObjectType);
        o.AccountId = testAccount().Id;
        o.Account = testAccount();
        o.EffectiveDate = System.today();
        o.Ship_To_Party__c = testAccount().Id;
        o.Status = 'Open';
        if(orderRecord==null){
            orderRecord = o;
        }
        return new List<Order>{orderRecord};
    }

    public static List<OrderItem> getOrderItemTest(){
        List<Product2> products = testProduct2();
        List<Order> orders = getOrderTest();
        List<OrderItem> items = new List<OrderItem>();
        for(Integer i=0;i<2;i++){
            OrderItem item = new OrderItem();
            
            item.OrderId = orders[0].Id;
            item.Variant__c = testVariants()[0].Id;
            item.Order = orders[0];
            item.PricebookEntry = testPriceBookEntries()[i];
            item.PricebookEntryId = testPriceBookEntries()[i].Id;
            item.Product2Id = products[i].Id;
            item.Product2 = products[i];
            item.ListPrice = 3000;
            item.UnitPrice = 4000;
            item.Quantity = 2;
            item.GST__c = 28;
            item.GST_Amount__c = 1680;
            item.Discounted_Amount__c = 0;
            item.Discount_Percent__c = 0;
            item.TDS__c = 0;
            item.TDS_Amount__c = 0;
            item.TCS__c = 0;
            item.TCS_Amount__c = 0;
            item.Total_Amount__c = 0;
            item.id = LibIDGenerator.generate(OrderItem.SObjectType);
            items.add(item);
        }
        if(orderItemRecords==null){
            orderItemRecords = items;
        }
        return orderItemRecords;
    }
    
    public static List<YIN_Variant__c> testVariants(){
        List<YIN_Variant__c> variants = new List<YIN_Variant__c>();
        YIN_Variant__c variant = new YIN_Variant__c();
        variant.Name = '2021';
        variant.Variant_code__c = '2021';
        variant.Id = LibIDGenerator.generate(YIN_Variant__c.SObjectType);
        variants.add(variant);
        if(variantsRecord==null){
            variantsRecord = variants;
        }
        
        return variantsRecord;
    }
    
    public static List<YIN_Ledger__c> testLeadger(){
        List<YIN_Ledger__c> ledgers = new List<YIN_Ledger__c>();
        YIN_Ledger__c ledger = new YIN_Ledger__c();
        ledger.Id=LibIDGenerator.generate(YIN_Ledger__c.SObjectType);
        ledger.Dealer_Code__r = testAccount();
        ledger.Dealer_Code__c = testAccount().Id;
        
        return ledgers;
    }
}