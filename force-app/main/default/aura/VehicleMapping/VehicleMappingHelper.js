/**
 * Created by dw.lee on 2023-09-06.
 */

({
    getInit : function(component, event, helper){
        component.set('v.showSpinner', true);
        var action = component.get('c.getFieldLabelInfo');

        action.setCallback(this, function(response){
            var state = response.getState();

            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                var listFieldLabelInfo = [];
                var selectedValue;
                var selectedLabel;

                if(!$A.util.isEmpty(result)){
                    listFieldLabelInfo = result;
                }
                if(listFieldLabelInfo.length > 0){
                    listFieldLabelInfo.forEach(e=>{
                        if(e.value === 'VehicleModel__c'){
                            selectedValue = e.value;
                            selectedLabel = e.label;
                            component.set('v.selectFieldValue', selectedValue);
                            component.set('v.selectFieldLabel', selectedLabel);
                            this.getListHMCDataPageInit(component, event, helper, selectedValue, null, false);
                        }
                    });
                }
                component.set('v.listFieldLabelInfo', listFieldLabelInfo);

            }else if (state === 'ERROR'){
                var errors = response.getError();
                if(!$A.util.isEmpty(errors)){
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast('error', 'Unknown Error');
                }
            }
                component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);

    },

    getListHMCDataPageInit : function(component, event, helper, selectedValue, keyword, Type){
        component.set('v.showSpinner', true);
        var action = component.get('c.getListHMCMappingInfo');

        action.setParams({
            selectedValue : selectedValue,
            keyword : keyword,
            Type : Type
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                var listPages = [];
                var listHMCData = [];
                var PagePerCount = component.get('v.PagePerCount');
                var listHMCDataNow = [];

                if(!$A.util.isEmpty(result)){
                    listHMCData = result;
                }
                if(!$A.util.isEmpty(listHMCData)){
                    for(var i = 0; i< (listHMCData.length > PagePerCount ? PagePerCount : listHMCData.length); i++){
                        if(listHMCData[i] != null){
                            listHMCDataNow.push(listHMCData[i]);
                        }
                    }
                    for(var i = 0; i < (listHMCData.length / PagePerCount) ; i++){
                        listPages.push(i+1);
                    }
                }

                component.set('v.listPages', listPages);
                component.set('v.NowPage', 1);
                component.set('v.listHMCData', listHMCData);
                component.set('v.listHMCDataNow ', listHMCDataNow);


            } else if (state === 'ERROR'){
                var errors = response.getError();
                if(!$A.util.isEmpty(errors)){
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast('error', 'Unknown Error');
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },

    getListHMCDataPage : function(component, listHMCData, NowPage){
        var PagePerCount = component.get('v.PagePerCount');
        var listPages = [];
        var listHMCDataNow = [];

        if(!$A.util.isEmpty(listHMCData)){
            for(var i = (NowPage-1)*PagePerCount; i< (listHMCData.length > PagePerCount ? (NowPage-1)*PagePerCount + PagePerCount : listHMCData.length); i++){
                if(listHMCData[i] != null){
                    listHMCDataNow.push(listHMCData[i]);
                }
            }
            for(var i = 0; i < (listHMCData.length / PagePerCount) ; i++){
                listPages.push(i+1);
            }
        }

        component.set('v.listPages', listPages);
        component.set('v.NowPage', NowPage);
        component.set('v.listHMCData', listHMCData);
        component.set('v.listHMCDataNow', listHMCDataNow);
    },

    getListHMCMappingInfo : function (component, event, helper, selectedValue, keyword, Type){
        component.set('v.showSpinner', true);
        var action = component.get('c.getListHMCMappingInfo');

        action.setParams({
            selectedValue : selectedValue,
            keyword : keyword,
            Type : Type
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            var listHMCData = [];
            var nowPage = component.get('v.NowPage');

            if(state === 'SUCCESS'){
                var result = response.getReturnValue();

                if(!$A.util.isEmpty(result)){
                    listHMCData = result;
                }
                this.getListHMCDataPage(component, listHMCData, nowPage);
            } else if (state === 'ERROR'){
                var errors = response.getError();
                if(!$A.util.isEmpty(errors)){
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast('error', 'Unknown Error');
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },

    updateMappingData : function(component, listChangeHMCData, selectedFieldValue){
        component.set('v.showSpinner', true);
        var action = component.get('c.updateMappingData');

        action.setParams({
            "listChangeHMCData" : JSON.stringify(listChangeHMCData),
            "selectedFieldValue" : selectedFieldValue
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result === 'SUCCESS'){
                    this.showToast('success','Update SUCCESS');
                    $A.get('e.force:refreshView').fire();
                }else{
                    this.showToast('info', result);
                }

            } else if (state === 'ERROR'){
                var errors = response.getError();
                if(!$A.util.isEmpty(errors)){
                    if(errors[0] && errors[0].message) {
                        this.showToast("error", errors[0].message);
                    }
                } else {
                    this.showToast('error', 'Unknown Error');
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);

    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
        key     : "info_alt",
        type    : type,
        message : message
        });
        evt.fire();
    }

});