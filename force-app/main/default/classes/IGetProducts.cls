/*
Apex Interface Name    : IGetProducts
Created Date       : Nov 16, 2023
@description       : This interface is used for creating dynamically  instance of implementing child class.
@author            : Sandeep Vishwakarma <sandeep.vishwakarma@skinternational.com>
*/
public interface IGetProducts {
    List<ProductWrapper> getProducts(String accountId);
}