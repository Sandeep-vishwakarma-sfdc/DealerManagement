import { LightningElement,wire,api,track } from 'lwc';
import getCurrentUser from '@salesforce/apex/OrderManagementController.getCurrentUser';
import getExperienceUserProfiles from '@salesforce/apex/OrderManagementController.getExperienceUserProfiles';
import getExperienceUserAccount from '@salesforce/apex/OrderManagementController.getExperienceUserAccount';
import getProducts from '@salesforce/apex/OrderManagementController.getProducts';
import getAccount from '@salesforce/apex/OrderManagementController.getAccount';
import addToCart from '@salesforce/apex/OrderManagementController.addToCart';
import getCartDetails from '@salesforce/apex/OrderManagementController.getCartDetails';
import deleteCartItem from '@salesforce/apex/OrderManagementController.deleteCartItem';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import customcss from '@salesforce/resourceUrl/resourceOrderMangmt';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/**
 * Order Management LWC Components.
 * @alias OrderManagement
 * @extends LightningElement
 * @hideconstructor
 *
 * @example
 * <c-order-management></c-order-management>
 */
export default class OrderManagement extends LightningElement {

   /**
   * TRUE when loggedIn user profile is Sales Representatives profile;
   * @type {Boolean}
   * @default 'false'
   */
    isSalesRepUser = false;
    user = {};
    error = {};
    accountId = {};
    experienceUserProfiles = [];
    hasRendered = false;
    value = 'All'; // what filter applied e.g All Product || Discounted Product
    productCSSClass ='green'; // use to switch views e.g green = Grid View and blue = List view
    @track productswrapper = [];
    productswrapperVirtual = []; // Copy of productswrapper to minimize apex request
    menuFilterLabel = 'Product Name';
    selectedMenu = 'name'; 
    isLoading = false;
    isHomePage = true; // use to display Landing Page on load
    @track cartDetails = [];// Cart Details
    CartDetailLength = 0;
    accountDetails = {}
    shippingAddress = '';
    billingAddress = '';
    TotalGST = 0;

    selectedOrderType ={
        all:true,
        discount:false
    }

    varientOptions = {}
    varientValue = '';


     /* Add Design code */
    geolander = customcss + '/resource/images/geolander.jpg';
    geolander1 = customcss + '/resource/images/geolander1.jpg';
    geolander2 = customcss + '/resource/images/geolander2.jpg';
    geolander3 = customcss + '/resource/images/geolander3.jpg';
 
     /* End */

    // When LoggedIn User is Sales representative , record Id will store Account Id
    @api recordId; 
    
    get options() {
        return [
            { label: 'All Products', value: 'All' },
            { label: 'Discounted Products', value: 'Discount' },
        ];
    }

    

    async connectedCallback(){
        this.isLoading = true;
        // check whether current user is Sales Representative OR Digital Experience User
        this.experienceUserProfiles = await getExperienceUserProfiles();
        this.user = await getCurrentUser();
        this.isSalesRepUser = !this.experienceUserProfiles?.includes(this.user?.Profile?.Name);

        // If Logged In User is Expericence User then Bring Account Id
        if(!this.isSalesRepUser){
            this.accountId = await getExperienceUserAccount();
        }else{
            this.accountId = this.recordId;
        }
        console.log('Account Id ',this.accountId);
        
        // Loading All Products from Normal price book
        this.loadProducts('All');// by default load all product, TODO : Edit All string from metadata configuration
        
        // Loading Account Details of current account Id
        this.accountDetails = await getAccount({accountId:this.accountId});

        // Loading existing cart order details
        this.cartDetails = await getCartDetails({accountId:this.accountId});
        this.CartDetailLength = this.cartDetails.length;

        this.billingAddress = `${this.accountDetails.BillingStreet}  ,${this.accountDetails.BillingCity}  ,${this.accountDetails.BillingState}  ${this.accountDetails.BillingPostalCode}  ${this.accountDetails.BillingCountry}`;

        this.shippingAddress = `${this.accountDetails.ShippingStreet}  ,${this.accountDetails.ShippingCity}  ,${this.accountDetails.ShippingState} ${this.accountDetails.ShippingPostalCode}  ${this.accountDetails.ShippingCountry}`;                              
        this.isLoading = false;
    }

    cartCalculation(){
        let GSTAmount = 0;
        /*this.cartDetails.forEach(item=>{
            let discountDecimal = isNaN((item.discountPercentage / 100))?0:(item.discountPercentage / 100);
            let price = item.pricebookEntry.UnitPrice * (item.pricebookEntry.UnitPrice * discountDecimal);

        })*/
    }

    async handleOrderTypeChange(event){
        let orderType = event.target.value;
        console.log('order type ',orderType);
        if(orderType=='All'){
            this.selectedOrderType = {
                all:true,
                discount:false
            }
        }else{
            this.selectedOrderType = {
                all:false,
                discount:true
            }
        }
        await this.loadProducts(orderType);
        this.isLoading = true;
        // reset filters
        this.refs.trendingSKU.checked = false;
        this.refs.productOfTheMonth.checked = false;
        setTimeout(() => {// TODO: Remove setTimout once working on real time Data
            this.isLoading = false;
        }, 200);
    }

    handleChangeToggle(event){
        let trendingSKU = this.refs.trendingSKU.checked;
        let productOfTheMonth = this.refs.productOfTheMonth.checked;

        if(trendingSKU && !productOfTheMonth){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>ele['trendingSKU']==true);
        }else if(!trendingSKU && productOfTheMonth){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>ele['productOfTheMonth']==true);
        }else if(trendingSKU && productOfTheMonth){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>ele['productOfTheMonth']==true && ele['trendingSKU']==true);
        }else if(!trendingSKU && !productOfTheMonth){// reset products
            this.productswrapper = this.productswrapperVirtual;
        }
        this.isLoading = true;
        setTimeout(() => {// TODO: Remove setTimout once working on real time Data
            this.isLoading = false;
        }, 200);
    }

    async loadProducts(OrderType){// This will load Products based on orderType (i.e All, Discount)
        const products = await getProducts({accountId:this.accountId,OrderType:OrderType});
        this.productswrapper = products;
        this.productswrapperVirtual = products;
        console.log('Product ',products);
        
        // Creating Options of varients
        this.createVariantOption();
        
    }

    renderedCallback(){
        // Ensure CSS loads only one time
        if(!this.hasRendered){
            this.loadStyling();
            this.hasRendered = true;
        }
    }

    createVariantOption(){
        const uniqueArray = [];
        const uniqueValuesSet = new Set();
        this.productswrapperVirtual.forEach(item => {
            if(item?.priceList){
                const { Variant_Code__c, Id } = item?.priceList?.Variant__r;
                if (!uniqueValuesSet.has(Id)) {
                    uniqueValuesSet.add(Id);
                    uniqueArray.push({ label: Variant_Code__c, value: Id });
                }
            }
        });
        uniqueArray.push({ label: 'None', value: '' });
        this.varientOptions = uniqueArray;
    }

    async loadStyling(){
        console.log('css resource ',customcss);
        Promise.all([
            loadStyle(this, customcss + '/resource/Fontawesome/css/all.css'),
            loadStyle(this, customcss + '/resource/Fontawesome/css/regular.css'),
            loadStyle(this, customcss + '/resource/bootstrap.css'),
            loadStyle(this, customcss + '/resource/cartcss.css'),
            loadStyle(this, customcss + '/resource/customcss.css'),
            loadScript(this, customcss + '/resource/js/custom.js'),         
            loadScript(this, customcss + '/resource/js/jquerymin.js'), 
            loadStyle(this, customcss + '/resource/Fontawesome/css/regular.css')
        ]).then(() => { /* callback */ });
    }

    // Add to Cart
    async handleCartAdd(event){
        let index = event.currentTarget.dataset.index;
        // console.log('Add to Cart index',index);
        if(this.cartDetails.findIndex(ele=>ele.productId==this.productswrapper[index].productId)==-1){
            // Adding sub-total for cart line-item
            let productWrap = this.productswrapper[index];
            productWrap.lineItemSubTotal = productWrap.pricebookEntry.UnitPrice * productWrap.quantity;
            this.cartDetails.push(productWrap);
            let isAddedToCart = await addToCart({productWrapper:JSON.stringify(productWrap),accountId:this.accountId});
            this.CartDetailLength = this.cartDetails.length;
            this.showToast('Success ','Added to Cart','success','dismissable');
        }else{
            this.showToast('Warning ','Already added to cart','warning','dismissable');    
        }
    }

    async handleCartDelete(event){
        this.isLoading = true;
        let index = event.currentTarget.dataset.index;
        console.log('Delete index',index);
        let cartIndex = this.cartDetails.findIndex(ele=>ele.productId==this.cartDetails[index].productId);
        if(cartIndex!=-1){
            let productWrap = this.cartDetails[cartIndex];
            console.log(' productWrap ',JSON.stringify(productWrap));
            let response = await deleteCartItem({productWrapper:JSON.stringify(productWrap),accountId:this.accountId});
            console.log('resp ',response);
            if(response=='success'){
                console.log('this.cartDetails ',this.cartDetails.length);
                this.cartDetails.splice(cartIndex,1);
                console.log('this.cartDetails ',this.cartDetails.length);
                this.cartDetails = this.cartDetails;
            }
        }else{
            this.showToast('Error ','Unable to find selected Item','warning','dismissable'); 
        }
        this.isLoading = false;
    }

    handleChangeVarient(event){
        let selectedVarient = event.detail.value;
        if(selectedVarient){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>ele?.priceList?.Variant__c==selectedVarient)
        }else{
            this.productswrapper = this.productswrapperVirtual;
        }
    }

    // switch to cart page
    handleShowCart(){
        this.isHomePage = false;
    }
    handleHideCart(){
        this.isHomePage = true;
    }

    // Search Bar Menu Action
    handleActionsMenuSelect(event){
        console.log('value ',event.detail.value);
        this.selectedMenu = event.detail.value;
        switch (this.selectedMenu) {
            case 'name':
                this.menuFilterLabel = 'Product Name'
                break;
            case 'size':
                this.menuFilterLabel = 'Size'
                break;
            case 'pattern':
                this.menuFilterLabel = 'Pattern'
                break;
            default:
                break;
        }
    }

    // search bar button action
    handleSearch(event){
        console.log('search ',this.refs.searchinput.value);
    }

    // Switch to Grid View
    handleGridView(event){
        this.productCSSClass = 'green';
        
    }
 
    // Switch to List View
    handleListView(event){
        this.productCSSClass = 'blue';
    }

    handleCheckout(event){

    }

    changeQuantity(event){
        let type = event.currentTarget.dataset.type;
        let index = event.currentTarget.dataset.index;
        if(type=='minus' && this.productswrapper[index].quantity > 1){
            this.productswrapper[index].quantity = this.productswrapper[index].quantity - 1;
        }
        if(type=='plus'){
            this.productswrapper[index].quantity = this.productswrapper[index].quantity + 1
        }
        console.log(' this.productswrapper[index].quantity '+this.productswrapper[index].quantity);

        this.productswrapperVirtual = this.productswrapper;
    }
 
    showToast(title,message,variant,mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
    
}