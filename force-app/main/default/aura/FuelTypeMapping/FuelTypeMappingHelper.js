/**
 * @description       :
 *
 * @author            : jiae.tak@daeunextier.com
 * @group             :
 * @last modified on  : 2023-11-07
 * @last modified by  : jiae.tak@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2023-11-07   jiae.tak@daeunextier.com   Initial Version
 */
({

    getListKASOVinPageInit : function(component, event, helper, keyword, Type){
        component.set('v.showSpinner', true);
        var action = component.get('c.getKASOVinMappingData');

        action.setParams({
            keyword : keyword,
            Type : Type
        });

        action.setCallback(this, function(response){
            var state = response.getState();

            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                var listPages = [];
                var listKASOVin = [];
                var PagePerCount = component.get('v.PagePerCount');
                var listKASOVinNow = [];

                if(!$A.util.isEmpty(result)){
                    listKASOVin = result;
                }

                if(!$A.util.isEmpty(listKASOVin)){
                    for(var i = 0; i< (listKASOVin.length > PagePerCount ? PagePerCount : listKASOVin.length); i++){
                        if(listKASOVin[i] != null){
                            listKASOVinNow.push(listKASOVin[i]);
                        }
                    }
                    for(var i = 0; i < (listKASOVin.length / PagePerCount) ; i++){
                        listPages.push(i+1);
                    }
                }

                component.set('v.listPages', listPages);
                component.set('v.NowPage', 1);
                component.set('v.listKASOVin', listKASOVin);
                component.set('v.listKASOVinNow ', listKASOVinNow);

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

    getListKASOVinPage : function (component, event, helper, keyword, Type, buttonId) {
        component.set('v.showSpinner', true);
        var action = component.get('c.getKASOVinMappingData');

        action.setParams({
            keyword : keyword,
            Type : Type
        });

        action.setCallback(this, function(response){
            var state = response.getState();

            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                var listPages = [];
                var listKASOVin = [];
                var listKASOVinNow = [];
                var PagePerCount = component.get('v.PagePerCount');
                var NowPage = component.get('v.NowPage');

                if(!$A.util.isEmpty(result)){
                    listKASOVin = result;
                }

                if(!$A.util.isEmpty(listKASOVin)){
                    for(var i = (NowPage-1)*PagePerCount; i< (listKASOVin.length > PagePerCount ? (NowPage-1)*PagePerCount + PagePerCount : listKASOVin.length); i++){
                        if(listKASOVin[i] != null){
                            listKASOVinNow.push(listKASOVin[i]);
                        }
                    }
                    for(var i = 0; i < (listKASOVin.length / PagePerCount) ; i++){
                        listPages.push(i+1);
                    }
                }

                component.set('v.listPages', listPages);
                component.set('v.NowPage', NowPage);
                component.set('v.listKASOVin', listKASOVin);
                component.set('v.listKASOVinNow ', listKASOVinNow);

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

    saveKASOVinData : function (component, event, helper, listChangeKASOVinData){
        component.set('v.showSpinner', true);
        var action = component.get('c.saveKASOVinMappingData');
        action.setParams({
            listChangeKASOVinData : JSON.stringify(listChangeKASOVinData)
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