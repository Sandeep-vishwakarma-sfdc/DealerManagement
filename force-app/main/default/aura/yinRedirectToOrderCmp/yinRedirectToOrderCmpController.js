({
    init : function(component, event, helper) {
        if(component.get("v.pageReference")){
            component.set("v.recordId", component.get("v.pageReference").state.c__recordId);
            component.set("v.module", component.get("v.pageReference").state.c__module);
        }
        },
    onPageReferenceChanged : function(component, event, helper) {
        if(component.get("v.pageReference")){
        component.set("v.recordId", component.get("v.pageReference").state.c__recordId);
        component.set("v.module", component.get("v.pageReference").state.c__module);
        $A.get('e.force:refreshView').fire();
        }
    }
})