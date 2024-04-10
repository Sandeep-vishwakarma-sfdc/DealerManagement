@SuppressWarnings('PMD.CognitiveComplexity')
/**
 * YINOrderManagementController - A controller class for handling order-related functionalities in a Salesforce Lightning component.
 *
 * Description: This class exposes methods that interact with the YINIOrderManagement service to provide order-related
 * functionalities to the Salesforce Lightning components. It includes methods for retrieving user profiles, object API names,
 * order details, current user, experience user account, accounts, products, adding to the cart, retrieving cart details,
 * deleting cart items, getting shipping accounts, and creating orders.
 *
 * Access: This class is declared as "public without sharing" to ensure that the methods can access data without enforcing
 * sharing rules, making it suitable for scenarios where the sharing model is not applicable.
 * @author            : Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
 */
public without sharing class YINOrderManagementController {

    /**
     * YINIOrderManagement instance for handling order-related operations.
     */
    private static YINIOrderManagement orderService;

    /**
     * Static initialization block to instantiate the YINIOrderManagement service.
     */
    static {
        orderService = (YINIOrderManagement) YINApplication.Service.newInstance(YINIOrderManagement.class);
    }
    
    /**
     * Retrieves the profiles of experience users from the YINIOrderManagement service.
     *
     * @return List<String> - List of profile names for experience users.
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getExperienceUserProfiles() {
        return orderService.getExperienceUserProfiles();
    }

    /**
     * Retrieves the object API name based on the provided record Id.
     *
     * @param recordId - Id of the record for which the object API name is retrieved.
     * @return String - Object API name.
     */
    @AuraEnabled
    public static String getObjectApiName(String recordId) {
        return orderService.getObjectApiName(recordId);
    }

    /**
     * Retrieves the details of an order based on the provided record Id.
     *
     * @param recordId - Id of the record for which order details are retrieved.
     * @return List<Order> - List of Order objects representing the order details.
     */
    @AuraEnabled
    public static List<Order> getOrderDetails(String recordId) {
        return orderService.getOrderDetails(recordId);
    }

    /**
     * Retrieves the current user from the YINIOrderManagement service.
     *
     * @return User - Current User object.
     */
    @AuraEnabled(cacheable=true)
    public static User getCurrentUser() {
        return orderService.getCurrentUser();
    }

    /**
     * Retrieves the account Id of the experience user from the YINIOrderManagement service.
     *
     * @return String - Account Id of the experience user.
     */
    @AuraEnabled
    public static String getExperienceUserAccount() {
        return orderService.getExperienceUserAccount();
    }

    /**
     * Retrieves the account information based on the provided account Id.
     *
     * @param accountId - Id of the account for which account details are retrieved.
     * @return Account - Account object representing the account information.
     */
    @AuraEnabled
    public static Account getAccount(String accountId) {
        return orderService.getAccount(accountId);
    }

    /**
     * Retrieves a list of products based on the provided account Id, order type, and order module type.
     *
     * @param accountId - Id of the account for which products are retrieved.
     * @param orderType - Type of order (e.g., Discount, Promotional).
     * @param orderModuleType - Type of order module.
     * @return List<YINProductWrapper> - List of YINProductWrapper objects representing the products.
     */
    @AuraEnabled
    public static List<YINProductWrapper> getProducts(String accountId, String orderType, String orderModuleType) {
        return orderService.getProducts(accountId, orderType, orderModuleType);
    }

    /**
     * Adds a product to the cart based on the provided product wrapper, account Id, and open order Id.
     *
     * @param productWrapper - JSON string representing the product details.
     * @param accountId - Id of the account for which the product is added to the cart.
     * @param openOrderId - Id of the open order where the product is added.
     * @return Boolean - True if the addition to the cart is successful, false otherwise.
     */
    @AuraEnabled
    public static boolean addToCart(String productWrapper, String accountId, String openOrderId) {
        return orderService.addToCart(productWrapper, accountId, openOrderId);
    }

    /**
     * Retrieves the details of items in the cart based on the provided account Id and open order Id.
     *
     * @param accountId - Id of the account for which cart details are retrieved.
     * @param openOrderId - Id of the open order for which cart details are retrieved.
     * @return List<YINProductWrapper> - List of YINProductWrapper objects representing the cart details.
     */
    @AuraEnabled
    public static List<YINProductWrapper> getCartDetails(String accountId, String openOrderId,String orderModuleType) {
        return orderService.getCartDetails(accountId, openOrderId,orderModuleType);
    }

    /**
     * Deletes a cart item based on the provided product wrapper, account Id, and open order Id.
     *
     * @param productWrapper - JSON string representing the product details to be deleted.
     * @param accountId - Id of the account for which the cart item is deleted.
     * @param openOrderId - Id of the open order from which the cart item is deleted.
     * @return String - Result message indicating the success or failure of the deletion.
     */
    @AuraEnabled
    public static String deleteCartItem(String productWrapper, String accountId, String openOrderId) {
        return orderService.deleteCartItem(productWrapper, accountId, openOrderId);
    }

    /**
     * Retrieves a list of shipping accounts associated with the provided account Id.
     *
     * @param accountId - Id of the account for which shipping accounts are retrieved.
     * @return List<Account> - List of shipping accounts.
     */
    @AuraEnabled
    public static List<Account> getShippingAccounts(String accountId) {
        return orderService.getShippingAccounts(accountId);
    }

    /**
     * Creates an order based on the provided product wrapper and wrap commit information.
     *
     * @param productWrapper - JSON string representing the product details for the order.
     * @param wrapCommit - JSON string representing the wrap commit information.
     * @return String - Result message indicating the success or failure of the order creation.
     */
    @AuraEnabled
    public static String createOrder(String productWrapper, String wrapCommit) {
        return orderService.createOrder(productWrapper, wrapCommit);
    }

    @AuraEnabled
    public static YINPromotionalOrderUtils.LedgerBudgetInfo getCurrentYearQuaterledger(String accountId,String recordType) {
        return orderService.getCurrentYearQuaterledger(accountId,recordType);
    }

    

    @AuraEnabled
    public static string promotionalOrderSendForApproval(String productWrapper,String shipToCode){
        try {
            return YINOrderManagementImpl.promotionalOrderSendForApproval(productWrapper,shipToCode);
             
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
}