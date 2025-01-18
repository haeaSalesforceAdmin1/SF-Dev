({
    getHyundailDealerDashboard : function(component, event, helper) {
        
        var action = component.get("c.getDashboardIdByType");
		action.setParams({ dashboardType: 'HyundaiDealerDashboard'});
		action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                component.set("v.hyundaiDealerDashboardId", response.getReturnValue());
                helper.getGenesisDealerDashboard(component, event, helper);
            }
            else {
                helper.handleError(component, "Error getting dashboard", null, response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    getGenesisDealerDashboard : function(component, event, helper) {
        var action = component.get("c.getDashboardIdByType");
		action.setParams({ dashboardType: 'GenesisDealerDashboard'});
		action.setCallback(this, function(response) {
            if(response.getState() == "SUCCESS") {
                component.set("v.genesisDealerDashboardId", response.getReturnValue());
            }
            else {
                helper.handleError(component, "Error getting dashboard", null, response.getError());
            }
        });
        $A.enqueueAction(action);
    },


    handleError : function(component, title, customErrorMessage, errors) {
        component.set("v.showSpinner", false);
		var message = "";
		if(customErrorMessage === null) {
			if(errors[0]) {
                if(errors[0].message != undefined && errors[0].message != null) {
                    message = errors[0].message + "\n\n" + errors[0].stackTrace;
                }
                else {
                    var pageErrors = errors[0].pageErrors;
                    if(pageErrors[0]) {
                        message = pageErrors[0].message;
                    }
                }
			}
			else {
				message = 'Uknown Error';
			}
		}
		else {
			message = customErrorMessage;
		}

		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			"duration" : 10000,
			"title": title,
			"message": message,
			"mode": 'dismissible',
			"type": 'error'
		});
		toastEvent.fire();
    },
})