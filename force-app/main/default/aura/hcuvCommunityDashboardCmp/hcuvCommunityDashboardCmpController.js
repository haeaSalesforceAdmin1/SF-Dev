({    
    init : function(component, event, helper) {
        var programType;
        var COMMUNITY_BASE_PATH=window.location.href;
        if (sessionStorage.getItem('ProgramType')) {
            programType = sessionStorage.getItem('ProgramType');
        }else if (COMMUNITY_BASE_PATH.includes('HMA') || COMMUNITY_BASE_PATH.includes('hyundai')) {
        programType = 'CUV';
    	}else if (COMMUNITY_BASE_PATH.includes('GMA') || COMMUNITY_BASE_PATH.includes('genesis')) {
        programType = 'CPO';
    	}
        var dashboardType=component.get("v.dashboardType");
        if(dashboardType){
            component.set("v.dHeight", "150");
            component.set("v.showSharing", "false"); //Hide Filter, Sharing tool bar for Home Page.
        }        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var act = component.get('c.getDashboardInfo');
        act.setParams({ "programType" : programType,"dashboardType" : dashboardType});
        act.setCallback(this, function(response) {                
            var state = response.getState();
            var result= response.getReturnValue();
            if(state === 'SUCCESS') {
                var accountId = result.accId;
                if (accountId != undefined && accountId != null) {
                    var filter ='{ "datasets":{"CUV_Inventory_Hyundai":[{"fields":["DealerContactInventory.Dealer__c"],"filter":{"operator":"in","values":["'+  accountId  +'"]},"locked":true},{"fields":["DealerContactInventory.Inspection_Type__c"],"filter":{"operator":"in","values":["'+  programType  +'"]},"locked":true}],"CUV_Inventory_Genesis":[{"fields":["DealerContactInventory.DealerAccount.Id"],"filter":{"operator":"in","values":["'+  accountId  +'"]},"locked":true},{"fields":["DealerContactInventory.Inspection_Type__c"],"filter":{"operator":"in","values":["'+  programType  +'"]},"locked":true}], "CUV_Sales_Hyundai":[{"fields":["DealerSales.Id"],"filter":{"operator":"in","values":["'+  accountId  +'"]},"locked":true},{"fields":["Inspection_Type__c"],"filter":{"operator":"in","values":["'+  programType  +'"]},"locked":true}],"CUV_Sales_Genesis":[{"fields":["DealerSales.Id"],"filter":{"operator":"in","values":["'+  accountId  +'"]},"locked":true},{"fields":["Inspection_Type__c"],"filter":{"operator":"in","values":["'+  programType  +'"]},"locked":true}], "CUV_Sales_Full_Hyundai":[{"fields":["Inspection_Type__c"],"filter":{"operator":"in","values":["'+  programType  +'"]},"locked":true}]}}';
                    component.set("v.account", accountId);
                    component.set("v.filter", filter);
                    component.set("v.hyundaiDealerDashboardId", result.dashboardId);
                    component.set("v.showComponent", "TRUE");  
                } else {
                    console.error('Something Went Wrong!');
                }
            }
            else {
                console.error(JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(act); 
    }
})