({
    initialize : function(component, event, helper) {
        let showMenuNames = (sessionStorage.getItem('showMenuNames') != undefined 
                             ? (sessionStorage.getItem('showMenuNames') == 'false' ? false : true)
                             : true);
        component.set("v.showMenuNames", showMenuNames);
        
        let showBlueTheme = (sessionStorage.getItem('ShowBlueTheme') != undefined 
                             ? (sessionStorage.getItem('ShowBlueTheme') == 'false' ? false : true)
                             : true);
        component.set("v.showBlueTheme", showBlueTheme);  
        component.set("v.leftNavItems",sessionStorage.getItem('NavItems'));
        component.set("v.showTopNav",false);
        component.set("v.showLeftNav",false);
        component.set("v.showVINSearch",false);
        component.set("v.dealerName",sessionStorage.getItem( 'DealerName'));
        var device = $A.get("$Browser.formFactor");
        //component.set("v.device",device);  
        //console.log("Device::"+component.get("v.leftNavItems"));
        
        let path = window.location.pathname;

        if(path.includes("GMA") || path.includes("genesis")){
            component.set("v.siteName", 'GMA');
        }
        else {
            component.set("v.siteName", 'HMA');
        }
    },
    
	handleLeftNavBar : function(component, event, helper) {
		//var showMenu = component.get("v.showMenuNames");
        var device = $A.get("$Browser.formFactor");
        console.log(device);
        if(device == 'PHONE'){
            component.set("v.showTopNav",false);
            component.set("v.showLeftNav",false);
        }
        else{
            component.set("v.showMenuNames",event.getParam('showMenu'));
            console.log('show Menu AUra::'+component.get("v.showMenuNames"));
        }
	},
    handleThemeChange : function(component, event, helper) {
		//var isBlueTheme = component.get("v.showBlueTheme");
        component.set("v.showBlueTheme",event.getParam('showTheme'));
        console.log('show Blue Theme on click::'+component.get("v.showBlueTheme")); 
	},
    handleSearchVIN:function(component, event, helper) {
		//var isBlueTheme = component.get("v.showBlueTheme");
        component.set("v.showVINSearch",event.getParam('showVINSearch'));
         console.log('show showVINSearch on click::'+component.get("v.showVINSearch")); 
	},
    handleSearchOut:function(component, event, helper) {
		//var isBlueTheme = component.get("v.showBlueTheme");
        component.set("v.showTopNav",false);
        component.set("v.showLeftNav",false);
        component.set("v.showVINSearch",false);
	},
    handleEnter:function(component, event, helper) {
        if (event.keyCode === 13) {
        let searchValue = event.target.value;
            console.log('Search:::' + searchValue);
            window.open('/HMACPO/s/global-search/' + searchValue, '_self');
        }
    },
    navigateToPage: function(component, event, helper) {
        
		var id= event.getParam("menuItemId");
        if(id)
            component.getSuper().navigate(id);
	},
    handleClearSession: function(component,event,helper) {
        sessionStorage.clear();
        /*sessionStorage.setItem("NavItems",event.getParam('leftNavItems'));
        component.set("v.leftNavItems",null);
        console.log('Local storage Set LeftNavItems::'+sessionStorage.getItem('NavItems'));*/
    },
    
    showTopNavMobile: function(component,event,helper){
    	component.set("v.showTopNav",!component.get("v.showTopNav"));
        console.log("showTopNav:::"+component.get("v.showTopNav"));
        component.set("v.showLeftNav",false);
        component.set("v.showVINSearch",false);
	},
    showLeftNavMobile:function(component,event,helper){
    	component.set("v.showLeftNav",!component.get("v.showLeftNav"));
        console.log("showLwftNav:::"+component.get("v.showLeftNav"));
        component.set("v.showTopNav",false);
	},
})