@isTest
private class TestPackageElementBothTrigger { 
    private static testMethod void Test_PackageElementBothTrigger () { 
        try{
            PackageElement__c fw = new PackageElement__c(); 
            insert fw; 
            System.assertNotEquals(null, fw.id); 
            update fw; 
            delete fw;
        } catch(Exception e){
            FSTR.COTestFactory.FillAllFields=true;
            PackageElement__c fw = (PackageElement__c)FSTR.COTestFactory.createSObject('PackageElement__c',true); 
            insert fw; 
            System.assertNotEquals(null, fw.id); 
            update fw; 
            delete fw;
        }
    } 
}