public with sharing class YINStockinventoryWrap {
   	// Request Properties
       public YINRequestbody[] requestbody;
       public class YINRequestbody {
           public String itemCode;	//FG-R1249
           public String locationCode;	//IN-DL-DEL
       }
   
       // Response Properties
       public YINData[] data;
       public class YINData {
           public String responseCode;	//200
           public String itemCode;	//FG-R1249
           public String locationCode;	//IN-DL-DEL
           public String totalInventory;	//18
           public YINVariantwise[] variantwise;
       }
       public class YINVariantwise {
           public String variant;	//2020
           public Integer inventory;	//15
       }
   
   
       public static YINStockinventoryWrap parse(String json){
           return (YINStockinventoryWrap) System.JSON.deserialize(json, YINStockinventoryWrap.class);
       }
}