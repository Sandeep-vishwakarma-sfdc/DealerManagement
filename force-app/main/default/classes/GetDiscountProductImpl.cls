public with sharing class GetDiscountProductImpl implements IGetProducts {
    public List<ProductWrapper> getProducts(String accountId){
        //1. Bring all Normal Products in a wrapper (let's say productsWrapper)
        //2. Bring all Discounted Product in a wrapper (let's say DiscountedProductsWrapper)
        //3. create a Map<ProductId,DiscountedProductsWrapper> where {key='productId',value='Discounted Product Wrapper'}
        //4. create a new instance of List<ProductsWrapper> add only those product which exist in discount product wrapper
        //5. return
    }
}