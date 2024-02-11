public with sharing class YINSalesOrderWrap {
    // Request Properties
    public YINHeader header;
	public YINLines[] lines;
	public class YINHeader {
		public String sfdcOrderNumber;	//SF0000342
		public String erpOrderNumber;	//
		public String erpCustomerCode;	//C000000234
		public String orderDate;	//25-01-2024
		public String externalDocumentNumber;	//
		public String status;	//Closed
		public String erpShipToCode;	//C000343
		public String remark;	//
	}
	public class YINLines {
		public String itemNumber;	//10
		public String itemCode;	//FG-R1249
		public String variant;	//2023
		public String quantity;	//4
		public String discount;	//4
		public String discountAmount;	//
		public String unitPrice;	//1000
		public String tdstcsPercent;	//1
		public String tdstcsBaseAmount;	//
		public String tdstcsAmount;	//
		public String type;	//Normal Order
		public String docketNo;	//
		public String discountType;	//Aged Discount
		public String discountRemark;	//
		public String gstPercent;	//28
		public String gstAmount;	//
		public String totalAmount;	//
    }

    // response properties
    public String responseCode;	//200
	public String message;	//Order created successfully
	public String erpCustomrCode;	//C000000234
	public String sfdcOrderNumber;	//SF0000342
	public String erpOrderNumber;	//SF00122
	public String orderStatus;	//Invoice
	public String status;	//Success
}