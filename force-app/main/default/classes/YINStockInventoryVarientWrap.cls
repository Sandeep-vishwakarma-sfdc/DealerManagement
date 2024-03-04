public with sharing class YINStockInventoryVarientWrap {
    // request Properites
    public YINRequestbody[] requestbody;
	public class YINRequestbody {
		public String itemCode;	//FG-R1249
		public String locationCode;	//IN-DL-DEL
		public String variant;	//2021
	}

    // response Properties
    public YINData[] data;
	public String error;
	public class YINData {
		public String responseCode;	//200
		public String itemCode;	//FG-R1249
		public String locationCode;	//IN-DL-DEL
		public String variant;	//2021
		public String quantity;	//100
		public String transitQuantity;	//75
		public String error;
	}

}