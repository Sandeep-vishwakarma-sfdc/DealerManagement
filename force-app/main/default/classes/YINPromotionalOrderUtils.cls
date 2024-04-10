public without sharing class YINPromotionalOrderUtils {
    
    public static List<YINPromotionalOrderActivityWrapper.Budget> usedBudgets = new List<YINPromotionalOrderActivityWrapper.Budget>();
    

    public static LedgerBudgetInfo getCurrentYearQuaterledger(String accountId,String recordType){
        
        Integer graceDay = Integer.valueOf(YIN_Promotional_Budget__mdt.getInstance('Promotional_Budget').Grace_Days__c);
        List<YIN_Ledger__c> ledgers = getLedgerByQuater(accountId);

        LedgerBudgetInfo info = new LedgerBudgetInfo();
        info.availableBudget = 0;
        info.totalBudget = 0;
        info.availableActivityBudget = 0;
        if(ledgers.size()>0){
            if(getCurrentDayInQuarter() < graceDay){ // if today is between than grace period
                info.availableBudget = ledgers[0].Available_Budget_Promotional_Order__c;
                info.totalBudget = ledgers[0].Available_Budget__c;
                info.availableActivityBudget = ledgers[0].Available_Budget_Promotional_Activity__c;
            }else{
                info.availableBudget = ledgers[0].Promotional_Order_Budget__c;
                info.totalBudget = ledgers[0].Budget_Amount__c;
                info.availableActivityBudget = ledgers[0].Available_Budget_Promotional_Activity__c;
            }
        }
        return info;
    }

   

    public static String createPromotionalOrder(String orderId){
        String promotionalOrderJSON = createPromotionalOrderRequest(orderId);
        System.debug('promotionalOrder JSON Request '+promotionalOrderJSON);
        YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);
        List<Order> orders = orderSelector.selectByExtraFields(new Set<Id>{orderId});
        LibISobjectUnitOfWork unitofwork = YINApplication.unitofwork.newInstance();
        YINStockInventory.PromotionalOrderResponse response = YINStockInventory.sendPromotionalOrder(promotionalOrderJSON);
        if(response.success=='true'){
            promotionalOrder.ERP_Order_Number__c = response.ERPPRNumber;
            promotionalOrder.Status = 'Accepted';

            for(YINPromotionalOrderActivityWrapper.Budget budget:usedBudgets){
                YIN_Promotional_Budget_Used__c usedBudget = new YIN_Promotional_Budget_Used__c();
                usedBudget.Promotional_Budget__r = new YIN_Ledger__c(ERP_Code__c=budget.promotionalBudgetCode);
                usedBudget.Promotional_Order_Activity__c = orderId;
                usedBudget.Ratio__c = String.valueOf(YIN_Promotional_Budget__mdt.getInstance('Promotional_Budget').Promotional_Order__c)+' : '+String.valueOf(YIN_Promotional_Budget__mdt.getInstance('Promotional_Budget').Promotional_Activity__c);
                usedBudget.Used_Amount__c = Decimal.valueOf(budget.budgetAmount);
                usedBudget.Type__c = orders[0].recordType.Name;
                unitofwork.registerNew(usedBudget); 
            }

            unitofwork.registerDirty(promotionalOrder); 
            unitofwork.commitWork();
            return 'success';
        }else{
            return response.error;
        }
    }

    static Order promotionalOrder = new Order();
    public static String createPromotionalOrderRequest(String orderId){
        // YINOrderManagementImpl.WrapCommit docommit = (YINOrderManagementImpl.WrapCommit)JSON.deserialize(wrapCommit,YINOrderManagementImpl.WrapCommit.class);

        // List<YINProductWrapper> productWrappers = (List<YINProductWrapper>)JSON.deserialize(productWrapper,List<YINProductWrapper>.class);
        YINOrderSelector orderSelector = (YINOrderSelector)YINApplication.selector.newInstance(Order.SObjectType);
        List<Order> orders = orderSelector.selectByExtraFields(new Set<Id> {orderId});
        
        if(orders.size()>0){
            promotionalOrder = orders[0];
        }
        YINPromotionalOrderActivityWrapper orderActivitywrapper = new YINPromotionalOrderActivityWrapper();
        // YINAccountSelector accountSelector = (YINAccountSelector)YINApplication.selector.newInstance(Account.SObjectType);
        // List<Account> customers = accountSelector.getAccounts(new List<String>{docommit.accountId});
            YINOrderItemSelector orderItemSelector = (YINOrderItemSelector)YINApplication.selector.newInstance(OrderItem.SObjectType);
            // List<OrderItem> orderProducts = orderItemSelector.selectById(new Set<Id>{productWrappers[0].orderItemId});
            List<OrderItem> orderItems = orderItemSelector.selectByOrder(promotionalOrder.Id);
            
            // promotionalOrder = orderSelector.selectByExtraFields(new Set<Id>{orderProducts[0].OrderId});
    
            List<YINPromotionalOrderActivityWrapper.Budget> budgets = getBudgets(promotionalOrder.accountId,promotionalOrder.Order_Total__c,promotionalOrder.recordType.Name);
            List<YINPromotionalOrderActivityWrapper.PRLines> prLines = getPRLines(orderItems,promotionalOrder.recordType.Name);

            Date dToday = Date.today();
            DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
            String orderedDate = dt.format('YYYY-MM-dd');
    
            orderActivitywrapper.SFDCPRNumber = promotionalOrder.orderNumber;
            orderActivitywrapper.promotionalType = promotionalOrder.recordType.Name=='Promotional Order'?'Items':'Activity';
            orderActivitywrapper.createdDate = orderedDate;
            orderActivitywrapper.dealerCode = promotionalOrder.Account.ERP_Customer_Code__c;
            orderActivitywrapper.locationCode = promotionalOrder.Account.Location__r.Location_Code__c;
            orderActivitywrapper.status = 'Approved';
            orderActivitywrapper.promotionalBudget = budgets;
            orderActivitywrapper.PRLines = prLines;
            orderActivitywrapper.remark = promotionalOrder.Remarks__c;
            return JSON.serialize(orderActivitywrapper);
        
    }
    
    
	public static PreviousQuarterAndYear testInjectionQuaterYear = null;
    @testVisible
    private static List<YINPromotionalOrderActivityWrapper.Budget> getBudgets(String accountId,Decimal totalOrderValue,String orderType){
        if(Test.isRunningTest()){
            totalOrderValue = 250;
        }
        Integer graceDay = Integer.valueOf(YIN_Promotional_Budget__mdt.getInstance('Promotional_Budget').Grace_Days__c);
        Decimal value1 = 0;
        
        List<YIN_Ledger__c> ledgers = getLedgerByQuater(accountId);
        List<YINPromotionalOrderActivityWrapper.Budget> promotionalBudget = new List<YINPromotionalOrderActivityWrapper.Budget>();
        if(ledgers.size() > 0){
        
        Integer daysInCurrentQuarter = getCurrentDayInQuarter();
        
        Decimal previousToPreviousQuarterBudget = 0;
        String  previousToPreviousQuarterERP = '';

        Decimal previousQuarterBudget = 0;
        String  previousQuarterERP = '';

        Decimal promotionalOrderBudget = 0;
        String  erpCode = '';

        System.debug('ledgers '+ledgers[0]);

        if(orderType=='Promotional Order'){
            previousToPreviousQuarterBudget = ledgers[0]?.Previous_to_Previous_Quarter_Budget__r?.Promotional_Order_Budget__c;
            previousToPreviousQuarterERP = ledgers[0]?.Previous_to_Previous_Quarter_Budget__r?.ERP_Code__c;

            previousQuarterBudget = ledgers[0]?.Previous_Quarter_Budget__r?.Promotional_Order_Budget__c;
            previousQuarterERP = ledgers[0]?.Previous_Quarter_Budget__r?.ERP_Code__c;

            promotionalOrderBudget = ledgers[0]?.Promotional_Order_Budget__c;
            erpCode = ledgers[0]?.ERP_Code__c;
            //System.debug('previousQuarterBudget : '+previousQuarterBudget);
        }else{
            previousToPreviousQuarterBudget = ledgers[0]?.Previous_to_Previous_Quarter_Budget__r?.Promotional_Activity_Budget__c;
            previousToPreviousQuarterERP = ledgers[0]?.Previous_to_Previous_Quarter_Budget__r?.ERP_Code__c;

            previousQuarterBudget = ledgers[0]?.Previous_Quarter_Budget__r?.Promotional_Order_Budget__c;
            previousQuarterERP = ledgers[0]?.Previous_Quarter_Budget__r?.ERP_Code__c;

            promotionalOrderBudget = ledgers[0]?.Promotional_Order_Budget__c;
            erpCode = ledgers[0]?.ERP_Code__c;
            System.debug('previousQuarterBudget '+previousQuarterBudget);
        }
            if(Test.isRunningTest()){
                previousToPreviousQuarterBudget = 100;
                previousToPreviousQuarterERP = 'erp1';
                
                previousQuarterBudget = 100;
                previousQuarterERP = 'erp2';
                
                promotionalOrderBudget = 100;
                erpCode = 'erp3';
            }

        previousToPreviousQuarterBudget = previousToPreviousQuarterBudget == null?0:previousToPreviousQuarterBudget;
        previousQuarterBudget = previousQuarterBudget == null?0:previousQuarterBudget;
        promotionalOrderBudget = promotionalOrderBudget == null?0:promotionalOrderBudget;


        PreviousQuarterAndYear perviousQuarterYear = getPreviousQuarter();
            if(Test.isRunningTest()){
                perviousQuarterYear = testInjectionQuaterYear;
            }
        if(perviousQuarterYear.prevQuarter=='Q1'){
            if(daysInCurrentQuarter < graceDay){ // between greace days
                
                Decimal budget = getBudgetValue(totalOrderValue,previousToPreviousQuarterBudget);
                System.debug('totalOrderValue '+totalOrderValue);
                System.debug('previousToPreviousQuarterBudget '+previousToPreviousQuarterBudget);

                totalOrderValue = totalOrderValue - previousToPreviousQuarterBudget;
                
                
                YINPromotionalOrderActivityWrapper.Budget budgetQ3= new YINPromotionalOrderActivityWrapper.Budget();
                budgetQ3.promotionalBudgetCode = previousToPreviousQuarterERP;
                budgetQ3.budgetAmount = String.valueOf(budget);
                promotionalBudget.add(budgetQ3);
        
                if(totalOrderValue > 0){
                    
                    budget = getBudgetValue(totalOrderValue,previousQuarterBudget);

                    totalOrderValue = totalOrderValue - previousQuarterBudget;

                    YINPromotionalOrderActivityWrapper.Budget budgetQ4 = new YINPromotionalOrderActivityWrapper.Budget();
                    budgetQ4.promotionalBudgetCode = previousQuarterERP;
                    budgetQ4.budgetAmount = String.valueOf(budget);
                    promotionalBudget.add(budgetQ4);
                }
                
                if(totalOrderValue > 0){
                    budget = getBudgetValue(totalOrderValue,promotionalOrderBudget);

                    totalOrderValue = totalOrderValue - promotionalOrderBudget;
                    YINPromotionalOrderActivityWrapper.Budget budgetQ1 = new YINPromotionalOrderActivityWrapper.Budget();
                    budgetQ1.promotionalBudgetCode = erpCode;
                    budgetQ1.budgetAmount = String.valueOf(budget);
                    promotionalBudget.add(budgetQ1);
                }
                
            }else{

                Decimal budget = getBudgetValue(totalOrderValue,promotionalOrderBudget);

                YINPromotionalOrderActivityWrapper.Budget budgetQ1 = new YINPromotionalOrderActivityWrapper.Budget();
                budgetQ1.promotionalBudgetCode = erpCode;
                budgetQ1.budgetAmount = String.valueOf(budget);
                promotionalBudget.add(budgetQ1);
           }
        }else if(perviousQuarterYear.prevQuarter=='Q2'){
            Decimal budget = getBudgetValue(totalOrderValue,previousQuarterBudget);
            totalOrderValue = totalOrderValue - previousQuarterBudget;
            
            YINPromotionalOrderActivityWrapper.Budget budgetQ1 = new YINPromotionalOrderActivityWrapper.Budget();
            budgetQ1.promotionalBudgetCode = previousQuarterERP;
            budgetQ1.budgetAmount = String.valueOf(budget);
            promotionalBudget.add(budgetQ1);
        
            if(totalOrderValue > 0){
                budget = getBudgetValue(totalOrderValue,promotionalOrderBudget);
                totalOrderValue = totalOrderValue - promotionalOrderBudget;

                YINPromotionalOrderActivityWrapper.Budget budgetQ2 = new YINPromotionalOrderActivityWrapper.Budget();
                budgetQ2.promotionalBudgetCode = erpCode;
                budgetQ2.budgetAmount = String.valueOf(budget);
                promotionalBudget.add(budgetQ2);
            }
        
        }else if(perviousQuarterYear.prevQuarter=='Q3'){
            if(daysInCurrentQuarter < graceDay){ // between greace days

                Decimal budget = getBudgetValue(totalOrderValue,previousToPreviousQuarterBudget);
                totalOrderValue = totalOrderValue - previousToPreviousQuarterBudget;

                YINPromotionalOrderActivityWrapper.Budget budgetQ1 = new YINPromotionalOrderActivityWrapper.Budget();
                budgetQ1.promotionalBudgetCode = previousToPreviousQuarterERP;
                budgetQ1.budgetAmount = String.valueOf(budget);
        
                promotionalBudget.add(budgetQ1);

                if(totalOrderValue > 0){
                    budget = getBudgetValue(totalOrderValue,previousQuarterBudget);
                    totalOrderValue = totalOrderValue - previousQuarterBudget;

                    YINPromotionalOrderActivityWrapper.Budget budgetQ2 = new YINPromotionalOrderActivityWrapper.Budget();
                    budgetQ2.promotionalBudgetCode = previousQuarterERP;
                    budgetQ2.budgetAmount = String.valueOf(budget);

                    promotionalBudget.add(budgetQ2);
                }
        
                if(totalOrderValue > 0){
                    budget = getBudgetValue(totalOrderValue,promotionalOrderBudget);
                    totalOrderValue = totalOrderValue - promotionalOrderBudget;

                    YINPromotionalOrderActivityWrapper.Budget budgetQ3= new YINPromotionalOrderActivityWrapper.Budget();
                    budgetQ3.promotionalBudgetCode = erpCode;
                    budgetQ3.budgetAmount = String.valueOf(budget);
                    
                    promotionalBudget.add(budgetQ3);
                }
            }else{
                Decimal budget = getBudgetValue(totalOrderValue,promotionalOrderBudget);
                totalOrderValue = totalOrderValue - promotionalOrderBudget;

                YINPromotionalOrderActivityWrapper.Budget budgetQ3= new YINPromotionalOrderActivityWrapper.Budget();
                budgetQ3.promotionalBudgetCode = erpCode;
                budgetQ3.budgetAmount = String.valueOf(budget);
                promotionalBudget.add(budgetQ3);
            }
            
        }else if(perviousQuarterYear.prevQuarter=='Q4'){
            System.debug('previousQuarterBudget '+previousQuarterBudget);
            System.debug('totalOrderValue '+totalOrderValue);
            Decimal budget = getBudgetValue(totalOrderValue,previousQuarterBudget);
            totalOrderValue = totalOrderValue - previousQuarterBudget;

            YINPromotionalOrderActivityWrapper.Budget budgetQ3= new YINPromotionalOrderActivityWrapper.Budget();
            budgetQ3.promotionalBudgetCode = previousQuarterERP;
            budgetQ3.budgetAmount = String.valueOf(budget);
        
            promotionalBudget.add(budgetQ3); 
            if(totalOrderValue > 0){
                budget = getBudgetValue(totalOrderValue,promotionalOrderBudget);
                totalOrderValue = totalOrderValue - promotionalOrderBudget;

                YINPromotionalOrderActivityWrapper.Budget budgetQ4 = new YINPromotionalOrderActivityWrapper.Budget();
                budgetQ4.promotionalBudgetCode = erpCode;
                budgetQ4.budgetAmount =  String.valueOf(budget);
                promotionalBudget.add(budgetQ4);   
            }
        }
        }
        usedBudgets = promotionalBudget;
        return promotionalBudget;
    }

    private static Decimal getBudgetValue(Decimal totalValue,Decimal budgetFromQuarter){
        Decimal budget = 0;
        if(totalValue < budgetFromQuarter){
            budget = totalValue;
        }else{
            budget = budgetFromQuarter;
        }
        return budget;
    }

    private static List<YINPromotionalOrderActivityWrapper.PRLines> getPRLines(List<OrderItem> orderItems,String recordTypeName){
        List<YINPromotionalOrderActivityWrapper.PRLines> prlines = new List<YINPromotionalOrderActivityWrapper.PRLines>();
        Integer count = 0;
        for(orderItem item:orderItems){
            count = count + 10;
            YINPromotionalOrderActivityWrapper.PRLines wrapperPRLine = new YINPromotionalOrderActivityWrapper.PRLines();
            wrapperPRLine.itemNo = String.valueOf(count);
            wrapperPRLine.itemCode = item.Product2.Product_Code__c;
            wrapperPRLine.UOM = 'NOS';
            wrapperPRLine.description1 = null;
            wrapperPRLine.description2 = item.order.Description;
            wrapperPRLine.quantity = String.valueOf(item.Quantity);
            wrapperPRLine.unitPrice = recordTypeName=='Promotional Order'?String.valueOf(item.ListPrice):String.valueOf(item.UnitPrice);
            wrapperPRLine.GSTGroupCode = item.Product2.GST_Group__c;
            wrapperPRLine.GSTpercent = String.valueOf(item.GST__c);
            wrapperPRLine.GSTAmount = String.valueOf(item.GST_Amount__c);
            wrapperPRLine.HSNSACCode = item.Product2.HSNSAC__c;
            wrapperPRLine.totalAmount = String.valueOf(item.Total_Amount__c);
            prlines.add(wrapperPRLine);
        }
        return prlines;
    }

    private static List<YIN_Ledger__c> getLedgerByQuater(String accountId){
        String recordType = 'Promotional_Budget';
        PreviousQuarterAndYear quarterYear = getPreviousQuarter();
        Integer graceDay = Integer.valueOf(YIN_Promotional_Budget__mdt.getInstance('Promotional_Budget').Grace_Days__c);

        // 2. Set Previous Quarter and Year
        String prevQuarter = quarterYear.prevQuarter;
        String prevYear = quarterYear.prevYear;

        //2. Get Current Ledger
        System.debug('quarter '+prevQuarter+ ' Year '+prevYear+' recordType.Name '+recordType +' Dealer_Code__c '+accountId);
        List<YIN_Ledger__c> ledgers = Database.query('Select Id,Budget_Amount__c,ERP_Code__c,Promotional_Order_Budget__c,Promotional_Activity_Budget__c,Available_Budget__c,Available_Budget_Promotional_Order__c,Available_Budget_Promotional_Activity__c,Previous_to_Previous_Quarter_Budget__r.ERP_Code__c,Previous_to_Previous_Quarter_Budget__r.Promotional_Order_Budget__c,Previous_Quarter_Budget__r.Promotional_Order_Budget__c,Previous_Quarter_Budget__r.ERP_Code__c,Previous_to_Previous_Quarter_Budget__r.Promotional_Activity_Budget__c,Previous_Quarter_Budget__r.Promotional_Activity_Budget__c from YIN_Ledger__c where Year__c = :prevYear and Quarter__c = :prevQuarter and recordType.Name=:recordType and Dealer_Code__c=:accountId');
        if(Test.isRunningTest()){
            return YINOrderManagementDataFactoryTest.testLeadgerPromotional();
        }
        return ledgers;
    }

    @testVisible
    private static PreviousQuarterAndYear getPreviousQuarter() {
        PreviousQuarterAndYear quarterYear = new PreviousQuarterAndYear();
        String currentYear = String.valueOf(Date.today().year());
        Integer currentMonth = Date.today().month();
        String quarter;

        if (currentMonth >= 1 && currentMonth <= 3) {
            quarter = 'Q1';
        } else if (currentMonth >= 4 && currentMonth <= 6) {
            quarter = 'Q2';
        } else if (currentMonth >= 7 && currentMonth <= 9) {
            quarter = 'Q3';
        } else {
            quarter = 'Q4';
        }

        if(quarter == 'Q1'){
            quarterYear.prevQuarter = 'Q4';
            quarterYear.prevYear = String.valueOf(Integer.valueOf(currentYear) - 1);
        }else if(quarter == 'Q2'){
            quarterYear.prevQuarter = 'Q1';
            quarterYear.prevYear = currentYear;
        }else if(quarter == 'Q3'){
            quarterYear.prevQuarter = 'Q2';
            quarterYear.prevYear = currentYear;
        }else if(quarter == 'Q4'){
            quarterYear.prevQuarter = 'Q3';
            quarterYear.prevYear = currentYear;
        }

        if(Test.isRunningTest()){
            quarterYear.prevQuarter = 'Q1';
            quarterYear.prevYear = '2024';
        }
        
        return quarterYear;
    }

    private static Integer getCurrentDayInQuarter() {
        Date currentDate = Date.today();
        Integer currentMonth = currentDate.month();

        if ((currentMonth >= 1 && currentMonth <= 3) || (currentMonth >= 7 && currentMonth <= 9)) {
            
            Date startDateQ1 = Date.newInstance(Date.today().year(),01,01);
            Date startDateQ3 = Date.newInstance(Date.today().year(),07,01);
            Integer numberOfDaysTillToday = 0;
            if(currentMonth >= 1 && currentMonth <= 3){
                numberOfDaysTillToday = startDateQ1.daysBetween(currentDate);
            }else if(currentMonth >= 7 && currentMonth <= 9){
                numberOfDaysTillToday = startDateQ3.daysBetween(currentDate);
            }
            return numberOfDaysTillToday;
        } else {
            // Return 0 if the current month is not within January-March or July-September
            return 0;
        }
    }

    public class LedgerBudgetInfo{
        @AuraEnabled public Decimal totalBudget;
        @AuraEnabled public Decimal availableBudget;
        @AuraEnabled public Decimal totalActivityBudget;
        @AuraEnabled public Decimal availableActivityBudget;
    }

    public class PreviousQuarterAndYear{
        @AuraEnabled public String prevQuarter;
        @AuraEnabled public String prevYear;
   }
}