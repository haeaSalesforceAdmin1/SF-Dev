({
       
    myAction : function(component, event, helper) {

    },

    handleApprovalComplete : function(component, event, helper) {
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
        
        component.set("v.showSpinner", false);
    },

    handleCancel : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
    },

    /**
     * [Method Description] If Original_Partner_User_Id is inactive, get the error from ErrorMessageController class 
     * Created by [MinheeKim] on [2024-05-01] for [DPM-5400]
    */
    handleSubmitSendBack : function(component, event, helper) {
        
        var action = component.get("c.getEventData"); // Apex 메소드 호출
        var recordId = component.get("v.recordId");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var eventData = response.getReturnValue(); // 이벤트 데이터
                if(eventData=="" || eventData=="undifined" || eventData==null){
                            component.set("v.showSpinner", true);
                            component.find('actionPlanApproval').approveActionPlan();
                            console.log('message: '+message);
                }else{
                    alert(eventData);
                    helper.handleCancel();
                }
            } else {
                console.error("에러 발생: ", response.getError());
            }
        });
        $A.enqueueAction(action);
    

    }
    
    // handleEvent: function(component, event, helper) {
    //     var channel = '/event/Techdicer_Event__e';
    //     var message = event.getParam("message");
    //     console.debug('handleEvant: '+message);
    //     component.set("v.errorMessage", message); 
    //     // 에러 메시지를 사용자에게 알림으로 표시
    //     alert(message);
        
    // }


        
    
})