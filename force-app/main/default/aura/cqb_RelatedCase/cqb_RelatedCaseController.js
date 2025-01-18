({
    // Pagination: https://www.mstsolutions.com/technical/pagination-using-lightning-components/

    doInit : function(component, event, helper) {
        var limitResults = component.get('v.limitResults');
        
        let action = component.get('c.getRelatedCasesEnhanced');

        action.setParams({
            recordId: component.get('v.recordId')
        });
        
        action.setCallback(this, function(response){
            let state = response.getState();
            console.log(state);
            if(state === "SUCCESS"){
                console.log(response.getReturnValue());
                component.set('v.relatedCases', response.getReturnValue());

                component.set('v.totalSize', component.get('v.relatedCases').length);
                component.set('v.start', 0);
                component.set('v.end', limitResults - 1);

                let pageList = [];
                for(let i = 0; i< limitResults; i++){
                    pageList.push(response.getReturnValue()[i]);
                }

                component.set('v.pageList', pageList);
            } else {
                let errMsg;
                let errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message){
                        errMsg = errors[0].message;
                    } else {
                        errMsg = "Unknown error"
                    }
                }
                console.log(errMsg);
                let msg = component.find('noResultsMessage');
                $A.util.removeClass(msg, 'slds-hide');
            }
            let spinner = component.find('loadSpinner');
            $A.util.addClass(spinner, 'slds-hide');
            
        });
        
        $A.enqueueAction(action);
    },
    
    onCheck : function(component, event, helper) {
        console.log('onCheck Start');

        let checkboxes = component.find('checkbox'); 
        let checkedIds = [];
        let checked = checkboxes.filter(box => box.get('v.value') == true);
        checked.forEach(function(check){
            checkedIds.push(check.get('v.label'));
        });
        component.set('v.selectedCases', checkedIds);
        console.log(component.get('v.selectedCases'));

        console.log('onCheck End');
    },
    
    selectAll : function(component, event, helper){
        console.log('selectAll Start');

        let checkboxes = component.find('checkbox'); 
        let checked = checkboxes.filter(box => box.get('v.value') == true);
        if(checkboxes.length == checked.length){
            checkboxes.forEach(function(check){
                if(check.get('v.disabled') == false){
                    check.set('v.value', false);
                }
            });  
        } else {
            checkboxes.forEach(function(check){
                check.set('v.value', true);
            }); 
        }

        let onCheckAction = component.get('c.onCheck');
        $A.enqueueAction(onCheckAction);
        console.log('selectAll End');

    },
    
    handleLinkCases : function(component, event, helper){
        let action = component.get('c.linkCases');
        
        action.setParams({
            parentId : component.get('v.recordId'),
            selectedCases : component.get('v.selectedCases')
        });

        console.log('Parent Case Id: ' + component.get('v.recordId'));
        console.log('Selected Cases: ' + component.get('v.selectedCases'));
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log(state);
            if(state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'SUCCESS',
                    message: 'Cases successfully linked',
                    duration:' 5000',
                    type: 'success'
                });
                toastEvent.fire();
                $A.enqueueAction(component.get('c.doInit'));
                //$A.get('e.force:refreshView').fire();
                //window.location.reload();
            } else if (state === "ERROR"){
                let errMsg;
                let errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message){
                        errMsg = errors[0].message;
                    } else {
                        errMsg = "Unknown error"
                    }
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'ERROR',
                    message: errMsg,
                    duration:' 5000',
                    type: 'error'
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);
    },
    
    navigateToRecord : function(component, event, helper){
        let cId = event.getSource().get("v.title")
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cId
        });
        navEvt.fire();
    },

    handleNextBtn : function(component, event, helper){
        let relatedCases = component.get('v.relatedCases');
        let start = component.get('v.start');
        let end = component.get('v.end');
        let limitResults = component.get('v.limitResults');

        let pageList = [];
        for(let i = end; i < end + limitResults; i++){
            pageList.push(relatedCases[i]);
        }

        start += pageList.length;
        end += pageList.length;

        component.set('v.start', start);
        component.set('v.end', end);
        component.set('v.pageList', pageList);
    },

    handlePreviousBtn : function(component, event, helper){
        let relatedCases = component.get('v.relatedCases');
        let start = component.get('v.start');
        let end = component.get('v.end');
        let limitResults = component.get('v.limitResults');

        let pageList = [];
        for(let i = start - limitResults; i < start; i++){
            if(i >= 0){
                pageList.push(relatedCases[i]);
            } else{
                start ++;
            }
        }

        start -= pageList.length;
        end -= pageList.length;

        component.set('v.start', start);
        component.set('v.end', end);
        component.set('v.pageList', pageList);
    }
})