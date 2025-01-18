/**
* @date 09/28/2020
* @description This class pulls from the appropriate Trigger_Settings__c record for use in the trigger framework
*/
public class Trigger_SettingsSupport {
	private static Trigger_Settings__c testconfig = null;
	public static Boolean testKillSwitch = false;
	public static Boolean testEmailDebugInfoLog = false;
	public static String testDebugInfoRecipientEmails;
	public static Integer testDebugInfoMaxNum;
	public static Integer testDebugInfoMaxAge;

	/**
	* @date 09/28/2020
	* @description Called to get (or set and then return if currently null) config options for the execution context via the AppConfig custom setting.
	*				Caches result for future calls if within testing context.
	*/
	private static Trigger_Settings__c getConfiguration(){
		if(Test.isRunningTest() && testconfig!=null) return testconfig;

		Trigger_Settings__c theobject = Trigger_Settings__c.getInstance();
		if(theobject==null || Test.isRunningTest())
		{
			theobject = new Trigger_Settings__c();
			theobject.EnableDiagnostics__c = (Test.isRunningTest())? false: false;
			theobject.KillSwitch__c = (Test.isRunningTest() && testKillSwitch)? true: false;
			theobject.EmailDebugInfoLog__c = (Test.isRunningTest() && testEmailDebugInfoLog)? true: false;
			theobject.DebugInfoRecipientEmails__c = (Test.isRunningTest() && testDebugInfoRecipientEmails!=null)? testDebugInfoRecipientEmails: null;
			theobject.MaxDebugInfoRecords__c = (Test.isRunningTest() && testDebugInfoMaxNum!=null)? testDebugInfoMaxNum: null;
            theobject.MaxDebugInfoAge__c = (Test.isRunningTest() && testDebugInfoMaxAge!=null)? testDebugInfoMaxAge: null;

			if(!Test.isRunningTest()) Database.Insert(theobject);
			else testconfig = theobject;
		}
		return theobject;
	}

	public static Boolean DiagnosticsEnabled{
		get{
			return getConfiguration().EnableDiagnostics__c;
		}
	}

	public static Boolean ThrowExceptions{
		get{
			return getConfiguration().ThrowExceptions__c;
		}
	}

	public static Boolean KillSwitchEnabled{
		get{
			return getConfiguration().KillSwitch__c;
		}
	}

	public static String KillList{
		get{
			return getConfiguration().KillList__c + '\n'  + getConfiguration().KillList2__c;
		}
    }
    
    public static String MethodKillList{
		get{
			return getConfiguration().MethodKillList1__c + '\n'  + getConfiguration().MethodKillList2__c;
		}
	}

	public static Boolean EmailDebugInfoEnabled{
		get{
			return getConfiguration().EmailDebugInfoLog__c;
		}
	}

	public static String DebugInfoEmailRecipients{
		get{
			return getConfiguration().DebugInfoRecipientEmails__c;
		}
	}

	public static Integer DebugInfoMaxNum{
		get{
			return (Integer)getConfiguration().MaxDebugInfoRecords__c;
		}
	}

	public static Integer DebugInfoMaxAge{
		get{
			return (Integer)getConfiguration().MaxDebugInfoAge__c;
		}
    }
    
    public static Boolean isMethodDisabled(String className, String methodName) {
        
        if(MethodKillList.contains(className + '.' + methodName)){
            return true;
        }
        return false;
    }

}