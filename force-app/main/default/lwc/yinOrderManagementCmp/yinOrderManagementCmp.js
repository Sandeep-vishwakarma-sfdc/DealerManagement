import { LightningElement,wire,api,track } from 'lwc';
import getCurrentUser from '@salesforce/apex/YINOrderManagementController.getCurrentUser';
import getExperienceUserProfiles from '@salesforce/apex/YINOrderManagementController.getExperienceUserProfiles';
import getExperienceUserAccount from '@salesforce/apex/YINOrderManagementController.getExperienceUserAccount';
import getProducts from '@salesforce/apex/YINOrderManagementController.getProducts';
import getAccount from '@salesforce/apex/YINOrderManagementController.getAccount';
import addToCart from '@salesforce/apex/YINOrderManagementController.addToCart';
import getCartDetails from '@salesforce/apex/YINOrderManagementController.getCartDetails';
import deleteCartItem from '@salesforce/apex/YINOrderManagementController.deleteCartItem';
import getShippingAccounts from '@salesforce/apex/YINOrderManagementController.getShippingAccounts';
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
export default class YinOrderManagementCmp extends LightningElement {
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
    discountedProductsVirtual = []; // Copy of Discounted Product : use to get Cart Product Discount
    menuFilterLabel = 'Product Name';
    selectedMenu = 'name'; 
    isLoading = false;
    isHomePage = true; // use to display Landing Page on load
    @track cartDetails = [];// Cart Details
    CartDetailLength = 0;
    accountDetails = {}
    shippingAddress = '';
    billingAddress = '';
    totalGSTAmount = 0;
    finalPrice = 0;
    counter = 0; // Scroller Counter: use to load more products when scroll counter increments

    shippingAccounts = [];
    shippingAccountValue = '';
    selectedShippingAccount = {name:'',accountCode:'',phone:'',email:'',address:''};
    shippingAddressOption = [];
        
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
        this.cartCalculation();

        this.billingAddress = `${this.accountDetails.BillingStreet}  ,${this.accountDetails.BillingCity}  ,${this.accountDetails.BillingState}  ${this.accountDetails.BillingPostalCode}  ${this.accountDetails.BillingCountry}`;
        
        // Copy Discount Product
        this.discountedProductsVirtual = await getProducts({accountId:this.accountId,orderType:'Discount'});

        // Fetch Shipping Accounts
        this.shippingAccounts = await getShippingAccounts({accountId:this.accountId})
        let addresses = this.shippingAccounts.map(ele=>{
            return ({label:ele.Name,value:ele.SFDC_Customer_Code__c})
        });
        let none = {label:'none',value:''};
        addresses.unshift(none);
        this.shippingAddressOption = addresses;
        
        this.isLoading = false;
    }

    handleChangeShippingAddress(event){
        let value = event.detail.value;
        let index = this.shippingAccounts.findIndex(ele=>ele.SFDC_Customer_Code__c==value);
        if(index !=-1){
            this.selectedShippingAccount = this.shippingAccounts[index];
            console.log(this.selectedShippingAccount);
            this.shippingAddress = `${this.selectedShippingAccount.ShippingStreet}  ,${this.selectedShippingAccount.ShippingCity} ,${this.selectedShippingAccount.ShippingState} ${this.selectedShippingAccount.ShippingPostalCode}  ${this.selectedShippingAccount.ShippingCountry}`; 
        }
        
    }

    cartCalculation(){
        let totalGSTAmount = 0;
        let finalPrice = 0;
        this.cartDetails.forEach(item=>{
            totalGSTAmount = totalGSTAmount+item.gstAmount;
        });
        this.totalGSTAmount = isNaN(totalGSTAmount)?0:Number(totalGSTAmount).toFixed(2);
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
        this.counter = 0;
        const products = await getProducts({accountId:this.accountId,orderType:OrderType});
        // let tempArray = [];
        // for (let i = 0; i < 10000; i++) {
        //     for (let item in products){ 
        //         tempArray.push(products[item]); 
        //     }
        // }
        // this.productswrapperVirtual = tempArray;
        this.productswrapperVirtual = products;
        this.productswrapper = await this.getNextItems();
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
        uniqueArray.unshift({ label: 'None', value: '' });
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
        let productWrap = this.productswrapper[index];
        let cartIndex = undefined;
        if(this.selectedOrderType.all){ // Form Normal Product , No Need to check Variants
            cartIndex = this.cartDetails.findIndex(ele=>ele.productId==productWrap.productId);
        }else{ // Form Discount Product , Need to check Variants
            cartIndex = this.cartDetails.findIndex(ele=>ele.productId==productWrap.productId && ele.variantId==productWrap.priceList.Variant__c);
        }
        if(cartIndex==-1){
            // Adding sub-total for cart line-item
            console.log('Account ',this.accountDetails);
            let productWrap = this.productswrapper[index];
            if(this.accountDetails.Is_Locking_Enable__c){
                if(productWrap.lockingSKUAccount){
                    this.showToast('Warning ',`Product ${productWrap.productName} is locked for the customer.`,'warning','dismissable'); 
                    return;
                }
                if(productWrap.lockingSKULocation){
                    this.showToast('Warning ',`Product ${productWrap.productName} is locked for cutsomer location.`,'warning','dismissable'); 
                    return;
                }
            }else{
                this.showToast('Warning ','Locking is disabled for customer','warning','dismissable');   
                return; 
            }
            if(this.accountDetails.Is_Capping_Enable__c){
                if(productWrap.maximumCappingQuantity < productWrap.quantity){
                    this.showToast('Warning ',`You can add only ${productWrap.maximumCappingQuantity} quantity for Product ${productWrap.productName}.`,'warning','dismissable'); 
                    return;
                }
            }else{
                this.showToast('Warning ','Capping is disabled for customer','warning','dismissable');  
                return;
            }
            productWrap.netPrice = productWrap.pricebookEntry.UnitPrice * productWrap.quantity;
            this.cartDetails.push(productWrap);
            let isAddedToCart = await addToCart({productWrapper:JSON.stringify(productWrap),accountId:this.accountId});
            //  Refresh Carts
            this.cartDetails = await getCartDetails({accountId:this.accountId});
            this.CartDetailLength = this.cartDetails.length;
            this.cartCalculation();
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
                this.CartDetailLength = this.cartDetails.length;
                this.cartCalculation();
                this.showToast('Success ','Removed from Cart','success','dismissable');
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
    async handleHideCart(){
        try {
            this.selectedOrderType = {all:true,discount:false};
            await this.loadProducts('All');
        } catch (error) {
            console.log('error ',error.message);
            console.log('error ',error);
        }
        
        
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

    async handleScroll(event){
        try {
            let containerscroll = event.target;
            console.log('scrollHeight ',containerscroll.scrollHeight,' scrollTop ',containerscroll.scrollTop,' clientHeight ',containerscroll.clientHeight);
            console.log('Scroll ',containerscroll.scrollHeight - containerscroll.scrollTop === containerscroll.clientHeight + 1);
            if (containerscroll.scrollHeight - containerscroll.scrollTop <= containerscroll.clientHeight + 1) {
                console.log('End .....');
                let nextItems = await this.getNextItems();
                console.log('next Items ',nextItems.length);
                let newProducts = this.productswrapper;
                for (let item in nextItems){ 
                    newProducts.push(nextItems[item]); 
                }
                if(newProducts.length>0){
                    this.productswrapper = newProducts;
                }
                console.log('4');
            }   
        } catch (error) {
            console.log('error ',error.message);
        }
    }

    async getNextItems() {
        try {
            // Initialize or retrieve the counter from a persistent storage (e.g., closure or state management)
        console.log('1');
    
        // Assuming you have an array of items
        const allItems = this.productswrapperVirtual; // Replace with your array of items
    
        // Calculate the start and end indices for the slice
        const start = this.counter * 5;
        const end = start + 5;
    
        // Increment the counter for the next call
        this.counter++;
    
        // Save the updated counter to persistent storage
        console.log('3');
        // Return the requested items
        let nextItems = allItems.slice(start, end);
        return nextItems;
        } catch (error) {
            console.log('error Next Items ',error.message);
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

    async changeCartQuantity(event){
        let index = event.currentTarget.dataset.index;
        let quantity = event.target.value;
        let item = this.cartDetails[index];

        // Get Price List from Discount Products
        let discountIndex = this.discountedProductsVirtual.findIndex(ele=>(ele.productId==item.productId && ele.priceList?.Variant__c == item.variantId));
        if(discountIndex!=-1){
            item.priceList = this.discountedProductsVirtual[discountIndex].priceList;
            item.discountTable = this.discountedProductsVirtual[discountIndex].discountTable;
        }

        item.quantity = quantity;
        console.log('cart ',item);
        if(quantity==0){
            this.showToast('Error ','Quantity must be greater then "0" ','warning','dismissable'); 
            return;
        }

        if(this.accountDetails.Is_Capping_Enable__c){
            if(item.maximumCappingQuantity < item.quantity){
                this.showToast('Warning ',`You can add only ${item.maximumCappingQuantity} quantity for Product ${item.pricebookEntry.Product2.Name}.`,'warning','dismissable'); 
                return;
            }
        }else{
            this.showToast('Warning ','Capping is disabled for customer','warning','dismissable');  
            return;
        }

        let isAddedToCart = await addToCart({productWrapper:JSON.stringify(item),accountId:this.accountId});
        this.cartDetails = await getCartDetails({accountId:this.accountId});
        this.CartDetailLength = this.cartDetails.length;
        this.cartCalculation();

    }

    changeQuantity(event){
        let type = event.currentTarget.dataset.type;
        let index = event.currentTarget.dataset.index;
        let value = event.target.value;
        if(type=='minus' && this.productswrapper[index].quantity > 1){
            this.productswrapper[index].quantity = this.productswrapper[index].quantity - 1;
        }
        if(type=='plus'){
            this.productswrapper[index].quantity = this.productswrapper[index].quantity + 1
        }
        if(type=='change'){
            this.productswrapper[index].quantity = isNaN(value)?0:Number(value);
        }
        console.log(' this.productswrapper[index].quantity '+this.productswrapper[index].quantity);

        //this.productswrapperVirtual = this.productswrapper;
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