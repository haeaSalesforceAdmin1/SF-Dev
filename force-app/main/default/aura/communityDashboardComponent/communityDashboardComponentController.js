({
    
    init : function(component, event, helper) { 
        
        if (component.get("v.recordId") == undefined || component.get("v.recordId") == null) {
            
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            console.log('userId :: '+userId);
            
            var act = component.get('c.getAccountId');
            act.setParams({"userId": userId});
            act.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    var usr = response.getReturnValue();
                    console.log('usr '+JSON.stringify(usr));
                    if (usr != undefined && usr != null) {
                        component.set("v.recordId",usr.Contact.AccountId);
                        component.set("v.isDealerTerminated",usr.Contact.Account.IsTerminated__c);
                        
                        console.log("is terminated "+component.get("v.isDealerTerminated"));
                        
                        var action = component.get('c.getAccountDetails');                       
                        
                        action.setParams({"accountId": component.get("v.recordId")});
                        action.setCallback(this, function(response) {
                            
                            var state = response.getState();
                            if(state === 'SUCCESS') {
                                
                                var account = response.getReturnValue();
                                var filter = ''; 
                                
                                if(account.RecordTypeId != null && account.RecordTypeId != undefined && account.RecordTypeId != '' && account.RecordType.Name == 'Hyundai Dealer') {
                                    //filter = '{"datasets":{"SalesKPI":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":[' + '"$DealerCode__c"' + ']},"locked":true,"hidden":null}]}}';
                                    // Commented below line by Kusuma on 16th Sep 2021
                                    // filter = '{"datasets":{"SalesKPI":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["' +  account.DealerCode__c  + '"]},"locked":true,"hidden":null}]}}';
                                    // {"datasets":{"SalesKPI":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["$DealerCode__c"]},"locked":true,"hidden":null}]}}
                                    // Added below line by Kusuma on 16th Sep 2021
                                    // filter = '{"datasets":{"SalesKPI":[{"fields":["dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}],"ServiceKPI":[{"fields":["dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}]}}';
                                    // (David) Added new line below, as part of DPM-3487
                                    filter = '{"datasets":{"Vehicle_Sales_Sec":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}],"Repair_Order_Sec":[{"fields":["dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}]}}';
                                }
                                else if(account.RecordTypeId != null && account.RecordTypeId != undefined && account.RecordTypeId != '' && account.RecordType.Name != 'Hyundai Dealer') {
                                    // filter = '{"datasets":{"SalesKPI_Genesis":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["' + account.DealerCode__c + '"]},"locked":true,"hidden":null}]}}';
                                    // (David) Added new line below, as part of DPM-3487
                                    filter = '{"datasets":{"Vehicle_Sales_Genesis_Sec":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}],"Repair_Order_Genesis_Sec":[{"fields":["dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}]}}';
                                }
                                //{"datasets":{"SalesKPI":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["$DealerCode__c"]},"locked":true,"hidden":null}]}}
                                
                                component.set("v.account", account);
                                component.set("v.filter", filter);
                                // DPM-4797 : 23.07.21 Edit by Semy Lee
                                helper.getHyundailDealerDashboard(component, event, helper);
                                
                            }
                            else {
                                console.error(JSON.stringify(response.getError()));
                            }
                        });
                        $A.enqueueAction(action);
                    } else {
                        console.error('Something Went Wrong!');
                    }
                }
                else {
                    console.error(JSON.stringify(response.getError()));
                }
            });
            $A.enqueueAction(act);
            
        } else if (component.get("v.recordId") != undefined && component.get("v.recordId") != null) {
            
            var action = component.get('c.getAccountDetails');            
            
            action.setParams({"accountId": component.get("v.recordId")});
            action.setCallback(this, function(response) {
               
                var state = response.getState();
                if(state === 'SUCCESS') {
                    var account = response.getReturnValue();
                    var filter = ''; 
                    component.set("v.isDealerTerminated",account.IsTerminated__c);
                    
                    if(account.RecordTypeId != null && account.RecordTypeId != undefined && account.RecordTypeId != '' && account.RecordType.Name == 'Hyundai Dealer') {
                        //filter = '{"datasets":{"SalesKPI":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":[' + '"$DealerCode__c"' + ']},"locked":true,"hidden":null}]}}';
                        // Commented below line by Kusuma on 16th Sep 2021
                        // filter = '{"datasets":{"SalesKPI":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["' +  account.DealerCode__c  + '"]},"locked":true,"hidden":null}]}}';
                        // {"datasets":{"SalesKPI":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["$DealerCode__c"]},"locked":true,"hidden":null}]}}
                        // Added below line by Kusuma on 16th Sep 2021
                        // filter = '{"datasets":{"SalesKPI":[{"fields":["dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}],"ServiceKPI":[{"fields":["dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}]}}';
                        // (David) Added new line below, as part of DPM-3487, hot-fix for deployment issue. Reconcile with Stage.
                        filter = '{"datasets":{"Vehicle_Sales_Sec":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}],"Repair_Order_Sec":[{"fields":["dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}]}}';
                    }
                    else if(account.RecordTypeId != null && account.RecordTypeId != undefined && account.RecordTypeId != '' && account.RecordType.Name != 'Hyundai Dealer') {
                        // filter = '{"datasets":{"SalesKPI_Genesis":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["' + account.DealerCode__c + '"]},"locked":true,"hidden":null}]}}';
                        // (David) Added new line below, as part of DPM-3487, hot-fix for deployment issue. Reconcile with Stage.
                        filter = '{"datasets":{"Vehicle_Sales_Genesis_Sec":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}],"Repair_Order_Genesis_Sec":[{"fields":["dealer_cd"],"filter":{"operator":"in","values":["'+  account.DealerCode__c  +'"]},"locked":true,"hidden":null}]}}';
                    }
                    //{"datasets":{"SalesKPI":[{"fields":["inventory_dealer_cd"],"filter":{"operator":"in","values":["$DealerCode__c"]},"locked":true,"hidden":null}]}}
                    
                    component.set("v.account", account);
                    component.set("v.filter", filter);
                    // DPM-4797 : 23.07.21 Edit by Semy Lee
            		helper.getHyundailDealerDashboard(component, event, helper);
                    
                }
                else {
                    console.error(JSON.stringify(response.getError()));
                }
            });
            $A.enqueueAction(action);
        }
        
        
    }
})