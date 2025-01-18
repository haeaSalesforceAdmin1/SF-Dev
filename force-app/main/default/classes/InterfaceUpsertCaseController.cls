/**
 * @description       : Case 단건 Insert/Update 
 * @author            : honguniverse@hyundai-autoever.com
 * @group             : 
 * @last modified on  : 12-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@RestResource(urlMapping='/IF_SODAS_CMT_001/v1/*')
global with sharing class InterfaceUpsertCaseController {
    @HttpPost 
    global static Output doPost() {
        RestRequest restRequest = RestContext.request;
		Output output = null;

        RestRequest req = RestContext.request;
        //RestResponse res = RestContext.response;
  
        string jsonbody = req.requestBody.toString();
        System.assert(jsonbody!= null);
        //System.debug('Json :'+jsonbody);
     

		try {
			InterfaceUpsertCaseHandler bizInstance = InterfaceUpsertCaseHandler.getInstance();
	
			output = bizInstance.post(bizInstance.pre(req));

		} catch (Exception e) {
			System.debug('ERROR =====> ' + e.getMessage());
		}

		return output;
    }

    global class Output {
        public OutputBody payload;
        public Output() {
            payload = new OutputBody();
        }
    }

    global class OutputBody {
		public List<OutputItem> data;
        public String result;
        public String message;
        public String type;

		public OutputBody() {
			data = new List<OutputItem>();
		}
    }

	global class OutputItem {
		public String subject;
		public String caseNo;
		public String caseId;
		public String country;
        public String region;
        public String stage;
        public String status;
        public String caseOwner;
	}


    global class Input {
        public InputItem parameter;
        public Input() {
            parameter = new InputItem();
        }
    }

    // global class InputBody {
	// 	public List<InputItem> itemList;
	// 	public InputBody() {
	// 		itemList = new List<InputItem>();
	// 	}
    // }

	global class InputItem {
		public String caseNumber;
        public String alertId;
        public String alertAssignee; //Alert 담당자
        public String issueYn; //이전 보고 여부 
	}
}