public interface YINIOrderManagement {
    // Order methods
    List<YINProductWrapper> getProducts(String accountId,String OrderType);
    boolean addToCart(String productWrapper,String accountId);
    string deleteCartItem(String productWrapper,String accountId);
    List<YINProductWrapper> getCartDetails(String accountId);
    string getCreditLimits(String accountId);
    string createOrder(String productWrapper,String accountId);

    // some user information methods
    List<String> getExperienceUserProfiles();
    User getCurrentUser();
    string getExperienceUserAccount();
    Account getAccount(String accountId);
}