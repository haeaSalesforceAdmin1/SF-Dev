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
    fnInit : function(component, event, helper){
        helper.getListKASOVinPageInit(component, event, helper);
    },

    fnKeyUp : function(component, event, helper){
        var keyword = component.get('v.keyword');
        var isNull = component.get('v.isNull');

        if(event.keyCode === 13){
            helper.getListKASOVinPageInit(component, event, helper, keyword, isNull);
        }
    },

    fnSearchKey : function(component, event, helper){
        var keyword = component.get('v.keyword');
        var isNull = component.get('v.isNull');
        helper.getListKASOVinPageInit(component, event, helper, keyword, isNull);
    },

    fnNullListBtn : function(component, event, helper){
        var isNull = component.get('v.isNull');
        var keyword = component.get('v.keyword');

        helper.getListKASOVinPageInit(component, event, helper, keyword, !isNull);
        component.set('v.isNull', !isNull);
    },

    fnPageChange : function(component, event, helper){
        var isNull = component.get('v.isNull');
        var keyword = component.get('v.keyword');
        var NowPage = event.getSource().get('v.label');

        component.set('v.NowPage', NowPage);
        component.set('v.listChangeKASOVinData', []);
        helper.getListKASOVinPage(component, event, helper, keyword, isNull);
    },
//
//    fnPageChangeClick : function (component,event, helper){
//        var clickedButton = event.getSource();
//        var buttonId = clickedButton.getLocalId();
//        var NowPage = component.get('v.NowPage');
//        var PageNumPerList = component.get('v.PageNumPerList');
//        var listPageNum = [];
//
//        if(buttonId ==='Previous'){
//            console.log("Previous button clicked");
//            console.log('NowPage :: ' + NowPage);
//
//            for(i=0; i<(NowPage/PageNumPerList)*PageNumPerList; i++){
//                listPageNum.push(i+1);
//            }
//
//
//        } else if(buttonId === 'Next'){
//            console.log("Next button clicked");
//            console.log('NowPage :: ' + NowPage);
//
//            var PageNumPerList = component.get('v.PageNumPerList');
//
//            console.log('NowPage/PageNumPerList ::: ' + NowPage/PageNumPerList);
//            console.log('(NowPage/PageNumPerList)*PageNumPerList ::: ' + (NowPage/PageNumPerList)*PageNumPerList);
//
//            for(i=0; i<(NowPage+PageNumPerList)*PageNumPerList; i++){
//                listPageNum.push(i+1);
//            }
//
//            component.set('v.NowPage', (NowPage/PageNumPerList)*PageNumPerList);
//        }
//
//        component.set('v.listPageNum',listPageNum);
//    },

    fnValueChange : function(component, event, helper){
        var idx = event.getSource().get("v.name");
        var listChangeKASOVinData = component.get('v.listChangeKASOVinData');
        var listKASOVinNow = component.get('v.listKASOVinNow');
        var InputData = listKASOVinNow[idx];
        var listChangeKASOVinTmp = [];

        if(InputData.fuelType != null && InputData.fuelType != '') {
            listChangeKASOVinTmp.push(InputData);
            component.set('v.listChangeKASOVinData', listChangeKASOVinData.concat(listChangeKASOVinTmp));
        }
    },

    fnAllChangeBtn : function(component, event, helper){
        var listChangeKASOVinData = component.get('v.listChangeKASOVinData');
        if(!$A.util.isEmpty(listChangeKASOVinData)){
            helper.saveKASOVinData(component, event, helper, listChangeKASOVinData);
        }
    }


});