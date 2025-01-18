/**
 * Created by baltamimi on 2022-02-15.
 */

({
    invoke : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})