public interface YINIOrderManagement {
    // Order methods
    // List<YINProductWrapper> getProducts(String accountId,String orderType,String searchType);
    List<YINProductWrapper> getProducts(String accountId,String orderType);
    boolean addToCart(String productWrapper,String accountId);
    string deleteCartItem(String productWrapper,String accountId);
    List<YINProductWrapper> getCartDetails(String accountId);
    string createOrder(String productWrapper,String wrapCommit);

    // some user information methods
    List<String> getExperienceUserProfiles();
    User getCurrentUser();
    string getExperienceUserAccount();
    Account getAccount(String accountId);
    List<Account> getShippingAccounts(String accountId);
}