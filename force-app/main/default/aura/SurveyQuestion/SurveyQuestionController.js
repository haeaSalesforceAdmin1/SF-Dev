({
	doInit : function(component, event){
		var action = component.get("c.getSurveyQuestion");
        var surveyQuestionId = component.get("v.recordId");
        action.setParams({"surveyQuestionId": surveyQuestionId});
        action.setCallback(this, function(a) {
            component.set("v.surveyQuestion", a.getReturnValue());
            component.set("v.didInit", true);
        });
        $A.enqueueAction(action);
	},
    openModal: function(component, event, helper) {
      // Set isModalOpen attribute to true
      component.set("v.isModalOpen", true);
   },
  
   closeModal: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   },
    isRadioChanged: function(component, event) {
        component.set("v.radioValue", event.getParam("value"));
    },
})