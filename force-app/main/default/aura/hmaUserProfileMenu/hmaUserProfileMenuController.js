({
    doInit : function(component, event, helper) {

        helper.getUserProfile(component);
        helper.setCommunityURL(component);
        helper.setDropdownItems(component);
    },

    

    onClickUserProfile :function(component, event, helper) {
        var isDropdownOpen = component.get("v.isDropdownOpen");
        component.set("v.isDropdownOpen", !isDropdownOpen);
    }
})