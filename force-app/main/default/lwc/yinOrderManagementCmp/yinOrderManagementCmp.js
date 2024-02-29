import { LightningElement,wire,api,track } from 'lwc';
import getCurrentUser from '@salesforce/apex/YINOrderManagementController.getCurrentUser';
import getExperienceUserProfiles from '@salesforce/apex/YINOrderManagementController.getExperienceUserProfiles';
import getExperienceUserAccount from '@salesforce/apex/YINOrderManagementController.getExperienceUserAccount';
import getProducts from '@salesforce/apex/YINOrderManagementController.getProducts';
import getAccount from '@salesforce/apex/YINOrderManagementController.getAccount';
import addToCart from '@salesforce/apex/YINOrderManagementController.addToCart';
import getCartDetails from '@salesforce/apex/YINOrderManagementController.getCartDetails';
import deleteCartItem from '@salesforce/apex/YINOrderManagementController.deleteCartItem';
import getObjectApiName from '@salesforce/apex/YINOrderManagementController.getObjectApiName';
import getOrderDetails from '@salesforce/apex/YINOrderManagementController.getOrderDetails';
import getShippingAccounts from '@salesforce/apex/YINOrderManagementController.getShippingAccounts';
import createOrder from '@salesforce/apex/YINOrderManagementController.createOrder';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import customcss from '@salesforce/resourceUrl/resourceOrderMangmt';
import LightningAlert from 'lightning/alert';

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
    openOrderId = '';
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
    netOrderValue = 0;
    totalTDS = 0;
    totalTCS = 0;
    totalOrderQuantity = 0;
    gstPercentage = 0;
    tdsPercentage = 0;
    tcsPercentage = 0;
    grandTotal = 0;

    isGridView = true;
        
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

    isModalOpen = false;
    orderPreview = [];
    isModalOrder = false;
    orderModuleType = 'Normal';

    get isDisableBtn(){
        return this.isLoading;
    }
    
    get options() {
        return [
            { label: 'All Products', value: 'All' },
            { label: 'Discounted Products', value: 'Discount' },
        ];
    }
    displayToggle = false;

    

    async connectedCallback(){
        try {
        this.isLoading = true;

        // check whether current user is Sales Representative OR Digital Experience User
        this.experienceUserProfiles = await getExperienceUserProfiles();
        this.user = await getCurrentUser();
        console.log(' USer ',JSON.stringify(this.user));
        this.isSalesRepUser = !this.experienceUserProfiles?.includes(this.user?.Profile?.Name);

        
        if(!this.isSalesRepUser){// For Experience User
            let urlString = location.href;
            let url = new URL(urlString);
            if(url.searchParams.get('orderId')){
                this.openOrderId = url.searchParams.get('orderId');
            }
            this.accountId = await getExperienceUserAccount();
            
        }else{// For Salesforce User
            let objectApiName = await getObjectApiName({recordId:this.recordId});
            if(objectApiName=='Account'){
                this.accountId = this.recordId;
            }else{
                let orderDetails = await getOrderDetails({recordId:this.recordId});
                console.log('JSON Order ',JSON.stringify(orderDetails[0]));
                this.openOrderId = orderDetails[0].Id;
                this.accountId = orderDetails[0].AccountId;
            }
            // this.accountId = '0010T00000fYTVBQA4';
        }
        console.log('Account Id ',this.accountId);
        
        // Loading All Products from Normal price book
        this.loadProducts('All');// by default load all product, TODO : Edit All string from metadata configuration
        
        // Loading Account Details of current account Id
        this.accountDetails = await getAccount({accountId:this.accountId});

        // Loading existing cart order details
        this.cartDetails = await getCartDetails({accountId:this.accountId,openOrderId:this.openOrderId});
        console.log('Cart Detail ',this.cartDetails);
        console.log('Cart Detail str',JSON.stringify(this.cartDetails));
        this.CartDetailLength = this.cartDetails.length;
        this.cartCalculation();

        this.billingAddress = `${this.accountDetails.Address__c?this.accountDetails.Address__c:''}  ,${this.accountDetails.Address2__c?this.accountDetails.Address2__c:''}`;

        // this.billingAddress = `${this.accountDetails.BillingStreet?this.accountDetails.BillingStreet:''}  ,${this.accountDetails.BillingCity?this.accountDetails.BillingCity:''}  ,${this.accountDetails.BillingState?this.accountDetails.BillingState:''}  ${this.accountDetails.BillingPostalCode?this.accountDetails.BillingPostalCode:''}  ${this.accountDetails.BillingCountry?this.accountDetails.BillingCountry:''}`;
        
        // Copy Discount Product
        this.discountedProductsVirtual = await getProducts({accountId:this.accountId,orderType:'Discount',orderModuleType:this.orderModuleType});

        // Fetch Shipping Accounts
        this.shippingAccounts = await getShippingAccounts({accountId:this.accountId})
        let addresses = this.shippingAccounts.map(ele=>{
            return ({label:ele?.Address__c+''+ele?.Address2__c,value:ele.ERP_Ship_To_Code__c})
        });
        let none = {label:'Select Shipping Address',value:''};
        addresses.unshift(none);
        this.shippingAddressOption = addresses;
        
        this.isLoading = false;
        } catch (error) {
           this.showAlert(error.body.message,'error','Error');
           this.isLoading = false;
        }

    }

    handleChangeShippingAddress(event){
        let value = event.detail.value;
        this.shippingAccountValue = value;
        console.log('shipping value ',value);
        let index = this.shippingAccounts.findIndex(ele=>ele.ERP_Ship_To_Code__c==value);
        if(index !=-1){
            this.selectedShippingAccount = this.shippingAccounts[index];
            console.log(this.selectedShippingAccount);

            this.shippingAddress = `${this.selectedShippingAccount?.Address__c?this.selectedShippingAccount?.Address__c:''}  ,${this.selectedShippingAccount.Address2__c?this.selectedShippingAccount.Address2__c:''}`;

            // this.shippingAddress = `${this.selectedShippingAccount.ShippingStreet?this.selectedShippingAccount.ShippingStreet:''}  ,${this.selectedShippingAccount.ShippingCity?this.selectedShippingAccount.ShippingCity:''} ,${this.selectedShippingAccount.ShippingState?this.selectedShippingAccount.ShippingState:''} ${this.selectedShippingAccount.ShippingPostalCode?this.selectedShippingAccount.ShippingPostalCode:''}  ${this.selectedShippingAccount.ShippingCountry?this.selectedShippingAccount.ShippingCountry:''}`; 
        }else{
            this.selectedShippingAccount = {Contact_Person_Email__c:'',Contact_Person_Phone__c:''};
            this.shippingAddress = ``;
            this.shippingAccountValue = '';
        }
        
    }

    cartCalculation(){
        let totalGSTAmount = 0;
        let subTotal = 0;
        let totalDiscount = 0;
        let totalTDS = 0;
        let totalTCS = 0;
        let netValue = 0;
        this.totalOrderQuantity = 0;
        
        this.cartDetails.forEach(item=>{
            let listPrice = isNaN(item.pricebookEntry?.UnitPrice * item.quantity)?0:item.pricebookEntry?.UnitPrice * item.quantity;
            let discount = (listPrice * item.discountPercentage)/100;
            item.netPrice = listPrice;
            item.totalAmount = item.netPrice - discount + item.gstAmount;
            console.log('netPrice '+item.netPrice);
            console.log('discount '+discount);
            console.log('item.gstAmount '+item.gstAmount);
            totalGSTAmount = totalGSTAmount+item.gstAmount;
            subTotal = subTotal + item.totalAmount;
            netValue = netValue + item.netPrice - (item.netPrice * item.discountPercentage/100);
            totalTDS = totalTDS + ((item.netPrice - discount)  * item.tdsPercentage/100);
            totalTCS = totalTCS + ((item.netPrice + item.gstAmount  - discount) * item.tcsPercentage/100);
            this.totalOrderQuantity = this.totalOrderQuantity + item.quantity;

            item.totalAmount = isNaN(item.totalAmount)?0:Number(item.totalAmount).toFixed(2);// Added to Fix decimal Issue
            // item.valueWithoutGST = netValue;
            totalDiscount = totalDiscount + discount;
            item.discountAmount = discount;
        });
        if(this.cartDetails.length > 0){
        this.netOrderValue = isNaN(netValue)?0:Number(netValue).toFixed(2);   
        this.totalGSTAmount = isNaN(totalGSTAmount)?0:Number(totalGSTAmount).toFixed(2);
        this.totalTDS = isNaN(totalTDS)?0:Number(totalTDS).toFixed(2);
        this.totalTCS = isNaN(totalTCS)?0:Number(totalTCS).toFixed(2);
        this.gstPercentage = this.cartDetails[0].gstPercentage;
        this.tdsPercentage = this.cartDetails[0].tdsPercentage;
        this.tcsPercentage = this.cartDetails[0].tcsPercentage;
        this.grandTotal = subTotal - Number(this.totalTDS) + Number(this.totalTCS);
        // this.grandTotal = subTotal + Number(this.totalGSTAmount) + Number(this.totalTDS) - Number(this.totalTCS);
        this.grandTotal = isNaN(this.grandTotal)?0:Number(this.grandTotal).toFixed(2);
        }else{
            this.totalGSTAmount = 0;
            this.totalTDS = 0;
            this.totalTCS = 0;
            this.grandTotal = 0;
            this.netOrderValue = 0;
        }
    }

    async handleOrderTypeChange(event){
        let orderType = event.target.value;
        this.isLoading = true;
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
        this.refs.searchinput.value = '';
        // reset filters
        if(this.displayToggle){
            this.refs.trendingSKU.checked = false;
            this.refs.productOfTheMonth.checked = false;
        }
        this.isLoading = false;
        // setTimeout(() => {// TODO: Remove setTimout once working on real time Data
        //     this.isLoading = false;
        // }, 200);
    }

    async handleChangeToggle(event){
        let trendingSKU = this.refs.trendingSKU.checked;
        let productOfTheMonth = this.refs.productOfTheMonth.checked;

        if(trendingSKU && !productOfTheMonth){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>ele['trendingSKU']==true);
        }else if(!trendingSKU && productOfTheMonth){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>ele['productOfTheMonth']==true);
        }else if(trendingSKU && productOfTheMonth){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>ele['productOfTheMonth']==true && ele['trendingSKU']==true);
        }else if(!trendingSKU && !productOfTheMonth){// reset products
            // this.productswrapper = this.productswrapperVirtual;
            this.counter = 0;
            this.productswrapper = await this.getNextItems();
        }
        this.refs.searchinput.value = '';
        this.isLoading = true;
        setTimeout(() => {// TODO: Remove setTimout once working on real time Data
            this.isLoading = false;
        }, 200);
    }

    async loadProducts(OrderType){// This will load Products based on orderType (i.e All, Discount)
        this.counter = 0;
        const products = await getProducts({accountId:this.accountId,orderType:OrderType,orderModuleType:this.orderModuleType});
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
            if(item?.priceList?.Variant__r){
                const { Variant_Code__c, Id } = item?.priceList?.Variant__r;
                if (!uniqueValuesSet.has(Id)) {
                    uniqueValuesSet.add(Id);
                    uniqueArray.push({ label: Variant_Code__c, value: Id });
                }
            }
        });
        uniqueArray.sort((a, b) => parseInt(b.label) - parseInt(a.label));
        uniqueArray.unshift({ label: 'Select Variant', value: '' });

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
        try {
        this.isLoading = true;
        let index = event.currentTarget.dataset.index;
        // console.log('Add to Cart index',index);
        let productWrap = this.productswrapper[index];
        if(productWrap.quantity<=0){
            this.showAlert('Quantity must be greater than 0','warning','Warning'); 
            productWrap.quantity = this.oldQty;
            return;
        }
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
                    this.showAlert(`Product ${productWrap.productName} is locked for the customer.`,'warning','Warning'); 
                    this.isLoading = false;
                    return;
                }
                if(productWrap.lockingSKULocation){
                    this.showAlert(`Product ${productWrap.productName} is locked for customer location.`,'warning','Warning'); 
                    this.isLoading = false;
                    return;
                }
            }else{
                // this.showAlert('Locking is disabled for customer','warning','Warning');   
                // this.isLoading = false;
                // return; 
            }
            if(this.accountDetails.Is_Capping_Enable__c){
                if(productWrap.maximumCappingQuantity < productWrap.quantity){
                    productWrap.quantity = 1;
                    this.showAlert(`You can add only ${productWrap.maximumCappingQuantity} quantity for Product ${productWrap.productName}.`,'warning','Warning'); 
                    this.isLoading = false;
                    return;
                }
            }else{
                // this.showAlert('Capping is disabled for customer','warning','Warning');  
                // this.isLoading = false;
                // return;
            }
            productWrap.netPrice = productWrap.pricebookEntry.Sales_Price__c * productWrap.quantity;
            
            console.log('Cart productWrap ',JSON.stringify(productWrap));
            let isAddedToCart = await addToCart({productWrapper:JSON.stringify(productWrap),accountId:this.accountId,openOrderId:this.openOrderId});
            this.cartDetails.push(productWrap);
            //  Refresh Carts
            this.cartDetails = await getCartDetails({accountId:this.accountId,openOrderId:this.openOrderId});
            this.CartDetailLength = this.cartDetails.length;
            this.cartCalculation();
            this.showToast('Success ','Product Added To Cart','success','dismissable');
        }else{
            this.showAlert('Product Already Added To Cart','warning','Warning'); 
            productWrap.quantity = this.oldQty;
        }
        this.isLoading = false;
           
        } catch (error) {
            console.log(error);
            this.isLoading = false;
            this.showAlert(error.body.message,'error','Error');
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
            let response = await deleteCartItem({productWrapper:JSON.stringify(productWrap),accountId:this.accountId,openOrderId:this.openOrderId});
            console.log('resp ',response);
            if(response=='success'){
                console.log('this.cartDetails ',this.cartDetails.length);
                this.cartDetails.splice(cartIndex,1);
                console.log('this.cartDetails ',this.cartDetails.length);
                this.cartDetails = this.cartDetails;
                this.CartDetailLength = this.cartDetails.length;
                this.cartCalculation();
                this.showToast('Success ','Product Removed From Cart','success','dismissable');
            }
        }else{
            this.showAlert('Unable to find selected Item','warning','Warning'); 
        }
        this.isLoading = false;
    }

    async handleChangeVarient(event){
        let selectedVarient = event.detail.value;
        if(selectedVarient){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>ele?.priceList?.Variant__c==selectedVarient)
        }else{
            // this.productswrapper = this.productswrapperVirtual;
            this.counter = 0;
            this.productswrapper = await this.getNextItems();
        }
    }

    // switch to cart page
    handleShowCart(){
        this.isHomePage = false;
    }
    async handleHideCart(){
        try {
            this.selectedOrderType = {all:true,discount:false};
            this.selectedMenu = 'name';
            this.menuFilterLabel = 'Product Name';
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
            
            if (containerscroll.scrollHeight - containerscroll.scrollTop <= containerscroll.clientHeight + 1) {
                console.log('End .....');
                let nextItems = await this.getNextItems();
                console.log('next Items ',nextItems.length);
                let newProducts = this.productswrapper;
                if(newProducts.length <= this.productswrapperVirtual.length){
                    for (let item in nextItems){ 
                        newProducts.push(nextItems[item]); 
                    }
                    if(newProducts.length>0){
                        this.productswrapper = newProducts;
                    }
                    console.log('4');
                }
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
        const start = this.counter * 10;
        const end = start + 10;
    
        // Increment the counter for the next call
        this.counter++;
    
        // Save the updated counter to persistent storage
        console.log('3');
        // Return the requested items
        let nextItems = allItems.slice(start, end);
        console.log('Next Items  ',JSON.parse(JSON.stringify(nextItems)));
        return nextItems;
        } catch (error) {
            console.log('error Next Items ',error.message);
        }
        
    }

    // search bar button action
    async handleSearch(event){
        console.log('search ',this.refs.searchinput.value);
        let searchValue = this.refs.searchinput.value;
        let fieldName ='';
        switch (this.selectedMenu) {
            case 'size':
                fieldName = 'productSize';
                break; 
            case 'pattern':
                fieldName = 'productPattern';
                break;       
            default:
                fieldName = 'productName';
                break;
        }
        console.log('field Name ',fieldName);
        if(searchValue){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>(ele['productSize']?.toLowerCase().includes(searchValue.toLowerCase())) || (ele['productPattern']?.toLowerCase().includes(searchValue.toLowerCase())) || (ele['productName']?.toLowerCase().includes(searchValue.toLowerCase())));
            if(this.displayToggle){
                this.refs.trendingSKU.checked = false;
                this.refs.productOfTheMonth.checked = false;
            }
        }else{
            // this.productswrapper = this.productswrapperVirtual;
            this.counter = 0;
            this.productswrapper = await this.getNextItems();
        }
    }

    // Switch to Grid View
    handleGridView(event){
        this.productCSSClass = 'green';
        this.isGridView = true;
        
    }
 
    // Switch to List View
    handleListView(event){
        this.productCSSClass = 'blue';
        this.isGridView = false;
    }

    async handleCheckout(event){
        this.isLoading = true;
        let commitCheckOut = event.target.dataset.confirm;
        commitCheckOut = commitCheckOut=='true';
        console.log('commit ',commitCheckOut);
        // Check for valid Shipping Address
        if(this.shippingAddress && this.shippingAccountValue){
            try {
                let param = {doCommit:commitCheckOut,grandTotal:Number(this.grandTotal),accountId:this.accountId,shippingAccountCode:this.shippingAccountValue};
                let response = await createOrder({productWrapper:JSON.stringify(this.cartDetails),wrapCommit:JSON.stringify(param)});
                console.log('response str',response);
                response = JSON.parse(response);
                let resSubmitted = JSON.parse(response.Submitted);
                let resOpen = JSON.parse(response.Open);
                let resOrder = JSON.parse(response.Orders);
                let tempId = 0;
                let submitted = resSubmitted.map(item=>{
                    tempId++;
                    return {tempId:tempId,VariantCode: item?.Variant_Code__c,status:'Submitted',...item}
                });
                tempId = 0;
                let open = resOpen.map(item=>{
                    tempId++;
                    return {tempId:tempId,VariantCode: item?.Variant_Code__c,status:'Open',...item}
                });
                
                this.orderPreview = {Submitted:submitted,Open:open,Orders:resOrder};
                
                console.log('Boolean(commitCheckOut)==false ',commitCheckOut);
                console.log('resOrder ',JSON.stringify(resOrder));
                if(commitCheckOut==false){
                    this.isModalOpen = true;
                    this.isModalOrder = false;
                }else{
                    this.isModalOpen = false;
                    this.isModalOrder = true;
                    this.showToast('SUCCESS','Order Submitted Succesfully','success');
                }
            } catch (error) {
                console.log('error ',error);
                this.showAlert(error.body.message,'error','Error');
                console.log('error ',error.message);
            }
            
        }else{
            this.showAlert('Please Select Shipping Address','error','Error');
        }
        this.isLoading = false;
    }

    oldQty = 1;
    copyOldQuanity(event){
        console.log('on Focus');
        this.oldQty = event.target.value;
    }

    async changeCartQuantity(event){
        try {
        
        this.isLoading = true;
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
            this.showAlert('Quantity must be greater then "0" ','warning','Warning'); 
            this.isLoading = false;
            return;
        }

        if(this.accountDetails.Is_Capping_Enable__c){
            if(item.maximumCappingQuantity < item.quantity){
                item.quantity = this.oldQty;
                this.showAlert(`You can add only ${item.maximumCappingQuantity} quantity for Product ${item.pricebookEntry.Product2.Name}.`,'warning','Warning '); 
                this.isLoading = false;
                return;
            }
        }else{
            // this.showAlert('Capping is disabled for customer','warning','Warning ');  
            // this.isLoading = false;
            // return;
        }

        let isAddedToCart = await addToCart({productWrapper:JSON.stringify(item),accountId:this.accountId,openOrderId:this.openOrderId});
        this.cartDetails = await getCartDetails({accountId:this.accountId,openOrderId:this.openOrderId});
        this.CartDetailLength = this.cartDetails.length;
        this.cartCalculation();
        this.isLoading = false;
            
        } catch (error) {
            this.isLoading = false;
            this.showAlert(error.body.message,'error','Error');
        }
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
 
    async showToast(title,message,variant,mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    async showAlert(message,theme,label){
        await LightningAlert.open({
            message: message,
            theme: theme, 
            label: label, 
        });
    }

    closeModalCheckout(){
        this.isModalOpen = false;
        this.isModalOrder = false;
    }
    async handleCheckoutRedirect(){
        
        this.isModalOpen = false;
        this.isModalOrder = false;
        this.handleHideCart();
        this.cartDetails = await getCartDetails({accountId:this.accountId,openOrderId:this.openOrderId});
        this.CartDetailLength = this.cartDetails.length;
        this.cartCalculation();
        this.selectedShippingAccount = {name:'',accountCode:'',phone:'',email:'',address:''};
        
    }
    async handleReset(){
        if(this.displayToggle){
            this.refs.trendingSKU.checked = false;
            this.refs.productOfTheMonth.checked = false;
        }
        this.refs.searchinput.value = '';
        this.counter = 0;
        this.productswrapper = await this.getNextItems();
    }
}