/**
 * Created by dw.lee on 2023-09-06.
 */

({
    fnInit : function(component, event, helper){
        helper.getInit(component, event, helper);
    },

    // Field Select
    fnGetFieldInfo : function(component, event, helper){
        var selectedValue = component.get("v.selectFieldValue");
        var options = component.get("v.listFieldLabelInfo");
        var keyword = component.get('v.keyword');
        var selectedLabel;


        for (var i = 0; i < options.length; i++) {
            if (options[i].value === selectedValue) {
                selectedLabel = options[i].label;
                break;
            }
        }

        if(!$A.util.isEmpty(selectedLabel) && !$A.util.isEmpty(selectedValue)){
            component.set('v.selectFieldLabel', selectedLabel);
            helper.getListHMCDataPageInit(component,event, helper, selectedValue, null, false);
            component.set('v.isNull', false);
            component.set('v.keyword', '');
            component.set('v.listChangeHMCData', []);
        }
    },

    fnNullListBtn : function(component, event, helper){
        var selectedValue = component.get('v.selectFieldValue');
        var isNull = component.get('v.isNull');
        var Keyword = component.get('v.keyword');

        if(!$A.util.isEmpty(selectedValue)){
            helper.getListHMCDataPageInit(component, event, helper, selectedValue, Keyword, !isNull);
            component.set('v.isNull', !isNull);
            component.set('v.listChangeHMCData', []);
        }
    },

    fnSearchKey : function(component,event, helper){
        var selectFieldValue = component.get("v.selectFieldValue");
        var keyword = component.get('v.keyword');
        var isNull = component.get('v.isNull');

        if(!$A.util.isEmpty(selectFieldValue)){
            helper.getListHMCDataPageInit(component, event, helper, selectFieldValue, keyword, isNull);
        }

    },

    fnKeyUp : function(component, event, helper){
        var selectFieldValue = component.get("v.selectFieldValue");
        var isNull = component.get('v.isNull');
        var keyword = component.get('v.keyword');
        if(event.keyCode === 13 && !$A.util.isEmpty(selectFieldValue)){
            helper.getListHMCDataPageInit(component, event, helper, selectFieldValue, keyword, isNull);
        }

    },

    fnValueChange : function(component, event, helper){
        var idx = event.getSource().get("v.name");
        var listHMCDataNow = component.get('v.listHMCDataNow');
        var selectedData = listHMCDataNow[idx];

        var listChangeHMCData = component.get('v.listChangeHMCData');
        var listChangeHMCDataTmp = [];

        if( selectedData.changeValue != null && selectedData.changeValue != '') {
            listChangeHMCDataTmp.push(selectedData);
            component.set('v.listChangeHMCData', listChangeHMCData.concat(listChangeHMCDataTmp));
        }
    },

    fnPageChange : function(component, event, helper){
        var selectedFieldValue = component.get("v.selectFieldValue");
        var isNull = component.get('v.isNull');
        var keyword = component.get('v.keyword');

        if(!$A.util.isEmpty(selectedFieldValue)){
            var NowPage = event.getSource().get('v.label');
            component.set('v.NowPage', NowPage);
            component.set('v.listChangeHMCData', []);
            helper.getListHMCMappingInfo(component, event, helper, selectedFieldValue, keyword, isNull);
        }
    },

    fnAllChangeBtn : function(component, event, helper){
        var listChangeHMCData = component.get('v.listChangeHMCData');
        var selectedFieldValue = component.get('v.selectFieldValue');
        helper.updateMappingData(component, listChangeHMCData, selectedFieldValue);
    }
});