({
    setDropdownItems: function(component) {
        var accounts = [];
        var action = component.get("c.getAccountId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                for (const element of res) {
                    accounts.push({label: element.accountName, value: element.accountURL});
                }
                component.set("v.accounts", accounts);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    setCommunityURL: function(component) {
        var action = component.get("c.getDPMSiteURL");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set("v.homeUrl", res.homeURL);
                component.set("v.myProfileUrl", res.myProfileURL);
                component.set("v.myAccountUrl", res.myAccountUrl);
                component.set("v.logoutUrl", res.logoutURL);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);	        
    },

    getUserProfile : function(component){
        var action = component.get("c.fetchUserDetail");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set('v.oUser', res);
                console.log('v.oUser: '+component.get('v.oUser'));
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);	
    }

})