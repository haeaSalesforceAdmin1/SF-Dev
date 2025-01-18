@IsTest
private class DNAMSHelpControllerTest{
    @IsTest
    static void testgetDNAMSLinks() {
        DNAMSHelpController.getDNAMLinks();
        DNAMSHelpController.getIntHMAPermissionLinks();
        DNAMSHelpcontroller.getIntHMAGuideLinks();
        DNAMSHelpcontroller.getIntGMAPermissionLinks();
        DNAMSHelpcontroller.getDealerHMAPermissionLinks();
        DNAMSHelpcontroller.getDealerHMAGuideLinks();
        DNAMSHelpcontroller.getDealerGMAPermissionLinks();
        DNAMSHelpcontroller.getDealerGMAGuideLinks();
        DNAMSHelpcontroller.getIntGMAGuideLinks();
        DNAMSHelpcontroller.getIntHMAGuidesPermissionLinks();//DNA-993
        DNAMSHelpcontroller.getIntGMAGuidesPermissionLinks();//DNA-993
    }
}