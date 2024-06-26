public interface YINIOrderManagement {
    // Order methods
    // orderType: All,Discount & searchType : Normal,Personal
    List<YINProductWrapper> getProducts(String accountId,String orderType,String orderModuleType);
    Boolean addToCart(String productWrapper,String accountId,String openOrderId);
    String deleteCartItem(String productWrapper,String accountId,String openOrderId);
    List<YINProductWrapper> getCartDetails(String accountId,String openOrderId,String orderModuleType);
    String createOrder(String productWrapper,String wrapCommit);
    List<Order> getOrderDetails(String recordId);

    // for Promotional Order
    YINPromotionalOrderUtils.LedgerBudgetInfo getCurrentYearQuaterledger(String accountId,String recordType);
    void createPromotionalOrder(List<String> orderId);
    String promotionalOrderSendForApproval(String productWrapper,String shipToCode);
    
    // some user information methods
    List<String> getExperienceUserProfiles();
    User getCurrentUser();
    string getExperienceUserAccount();
    Account getAccount(String accountId);
    string getObjectApiName(String recordId);
    List<Account> getShippingAccounts(String accountId);
}