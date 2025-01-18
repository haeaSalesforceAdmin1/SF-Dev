({

    getUploadedFiles : function(component) {

        var action = component.get("c.getFiles");  

        action.setParams({  

            "recordId":component.get("v.recordId")  

        });      

        action.setCallback(this,function(response){  

            var state = response.getState();  

            if(state=='SUCCESS'){  

                var result = response.getReturnValue();          

                component.set("v.files",result);  
            }
			 

        });  

        $A.enqueueAction(action);  

    },

   

    delUploadedfiles : function(component,documentId) {  

        var action = component.get("c.deleteFiles");          
		action.setParams({

            "docId":documentId            

        });  

        action.setCallback(this,function(response){  
			console.log('*********response='+JSON.stringify(response));
            var state = response.getState();  
			console.log('*********state='+JSON.stringify(state));
            if(state=='SUCCESS'){
				var result = response.getReturnValue();
                console.log('*********result='+result);
                /*
                this.getUploadedFiles(component);

                $A.get('e.force:refreshView').fire();

                component.set("v.Spinner", false);
				component.set("v.showConfirmation", false); 
                */
                //DNA-1073-Start
                // Handle the return value (e.g., 'SUCCESS' or 'ERROR: <message>')
                if (result == 'SUCCESS') {
                    console.log('*********SUCCESS='+result);
                    this.getUploadedFiles(component);
                    $A.get('e.force:refreshView').fire();
                    component.set("v.Spinner", false);
                    component.set("v.showConfirmation", false);
                } else {
                    // Handle failure case
                    console.log('*********ERROR='+result);
                    component.set("v.errorMessage", result);
                    component.set("v.showErrorScreen", true);
                    component.set("v.Spinner", false);
                }
				//DNA-1073-End
            }  

        });
        
        $A.enqueueAction(action);  

    }

})