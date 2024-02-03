({
    init : function(component, event, helper) {
        if(component.get("v.pageReference")){
            component.set("v.recordId", component.get("v.pageReference").state.c__recordId);
        }
        },
    onPageReferenceChanged : function(component, event, helper) {
        if(component.get("v.pageReference")){
        component.set("v.recordId", component.get("v.pageReference").state.c__recordId);
        $A.get('e.force:refreshView').fire();
        }
    }
})