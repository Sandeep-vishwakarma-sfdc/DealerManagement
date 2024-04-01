public class YINPromotionalOrderActivityWrapper {

	public String SFDCPRNumber;
	public String promotionalType;
	public String createdDate;
	public String dealerCode;
	public String locationCode;
	public String status;
	public String remark;
	public List<Budget> promotionalBudget;
	public List<PRLines> PRLines;

	public class Budget {
		public String promotionalBudgetCode;
		public String budgetAmount;
	}

	public class PRLines {
		public String itemNo;
		public String itemCode;
		public String UOM;
		public String description1;
		public String description2;
		public String quantity;
		public String unitPrice;
		public String GSTGroupCode;
		public String GSTpercent;
		public String GSTAmount;
		public String HSNSACCode;
		public String totalAmount;
	}

	
}