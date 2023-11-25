import { LightningElement,wire,api } from 'lwc';
import getCurrentUser from '@salesforce/apex/OrderManagementController.getCurrentUser';
import getExperienceUserProfiles from '@salesforce/apex/OrderManagementController.getExperienceUserProfiles';
import getExperienceUserAccount from '@salesforce/apex/OrderManagementController.getExperienceUserAccount';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/resource';
import customcss from '@salesforce/resourceUrl/resource';
import allcss from '@salesforce/resourceUrl/resource';
import custom from '@salesforce/resourceUrl/resource';
import jquerymin from '@salesforce/resourceUrl/resource';
import images from '@salesforce/resourceUrl/resource';
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
    value = 'All Products'; // what filter applied e.g All Product || Discounted Product
    productCSSClass ='green'; // use to switch views e.g green = Grid View and blue = List view
    productswrapper = [];
    productswrapperVirtual = []; // Copy of productswrapper to minimize apex request
    menuFilterLabel = 'Product Name';
    selectedMenu = 'name'; 
    isLoading = false;
    cartDetails = [];// Cart Details
    CartDetailLength = 0;

     /* Add Design code */
    geolander = images + '/resource/images/geolander.jpg';
    geolander1 = images + '/resource/images/geolander1.jpg';
    geolander2 = images + '/resource/images/geolander2.jpg';
    geolander3 = images + '/resource/images/geolander3.jpg';
 
     /* End */

    // When LoggedIn User is Sales representative , record Id will store Account Id
    @api recordId; 
    
    get options() {
        return [
            { label: 'All Products', value: 'All Products' },
            { label: 'Discounted Products', value: 'Discounted Products' },
        ];
    }

    

    async connectedCallback(){

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
        this.loadProducts('All');// by default load all product, TODO : Edit All string from metadata configuration
        this.isLoading = false;
    }

    async handleOrderTypeChange(event){
        let orderType = event.target.value;
        console.log('order type ',orderType);
        await this.loadProducts(orderType);
        this.isLoading = true;
        // reset filters
        this.refs.trendingSKU.checked = false;
        this.refs.weekOfTheSKU.checked = false;
        setTimeout(() => {// TODO: Remove setTimout once working on real time Data
            this.isLoading = false;
        }, 200);
    }

    handleChangeToggle(event){
        let trendingSKU = this.refs.trendingSKU.checked;
        let weekOfTheSKU = this.refs.weekOfTheSKU.checked;

        if(trendingSKU && !weekOfTheSKU){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>ele['trendingSKU']==true);
        }else if(!trendingSKU && weekOfTheSKU){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>ele['weekOfTheSKU']==true);
        }else if(trendingSKU && weekOfTheSKU){
            this.productswrapper = this.productswrapperVirtual.filter(ele=>ele['weekOfTheSKU']==true && ele['trendingSKU']==true);
        }else if(!trendingSKU && !weekOfTheSKU){// reset products
            this.productswrapper = this.productswrapperVirtual;
        }
        this.isLoading = true;
        setTimeout(() => {// TODO: Remove setTimout once working on real time Data
            this.isLoading = false;
        }, 200);
    }

    async loadProducts(OrderType){// This will load Products based on orderType (i.e All, Discount)
        const products = await this.prepareData(this.accountId,OrderType);
        this.productswrapper = products;
        this.productswrapperVirtual = products;
        console.log('Product ',products);
    }

    renderedCallback(){
        // Ensure CSS loads only one time
        if(!this.hasRendered){
            this.loadStyling();
            this.hasRendered = true;
        }
    }

    async loadStyling(){
        Promise.all([
            loadStyle(this, allcss + '/resource/Fontawesome/css/all.css'),
            loadStyle(this, bootstrap + '/resource/bootstrap.css'),
            loadStyle(this, customcss + '/resource/customcss.css'),
            loadScript(this, custom + '/resource/js/custom.js'),         
            loadScript(this, jquerymin + '/resource/js/jquerymin.js'),   
        ]).then(() => { /* callback */ });
    }

    // Add to Cart
    handleCartAdd(event){
        let index = event.currentTarget.dataset.index;
        // console.log('Add to Cart index',index);
        // if(this.cartDetails.findIndex())
        this.cartDetails.push(this.productswrapper[index]);
        console.log('cart Detais ',this.cartDetails);
        this.CartDetailLength = this.cartDetails.length;
        this.showToast('Success ','Added to Cart','success','dismissable');
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
 
    /* Preparing Dummy Data To Test UI */
    async prepareData(accountId,OrderType){
        let data = [];
        for(let i=1;i<=50;i++){
            let val = Math.floor(1000 + Math.random() * 9000);
            let obj = {
                pricebookEntry:{Id:'01u',Name:'pbe1',UnitPrice:val,Product2Id:{Id:'01t'+i,Name:'pName'},Pricebook2Id:{Id:'01s',Type__c:i%2==0?'Customer':'Customer Group',IsDiscount__c:i%2==0,IsActive:true}},
                productId:'01t'+i,
                weekOfTheSKU:i%2==0,
                trendingSKU:i%3==0 || i%4==0,
                lockingSKU:false,
                cappingSKU:false,
                quantity:0
            }
        data.push(obj);
        }
        return data;
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