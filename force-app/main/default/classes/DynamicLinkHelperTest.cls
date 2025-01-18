/**
 * [DynamicLinkHelperTest Description]
 * 
 * ----- Change Log -----
 * @Author : JonghoonKim   / Date :  24-08-20
 * @Ticket Number : DPM-5640
 * @Change Description : Created DynamicLinkHelperTest
 */
@isTest
private class DynamicLinkHelperTest {
    
    @isTest
    static void testGenerateDynamicLink() {
        
        List<String> result = DynamicLinkHelper.generateDynamicLink();
        System.assertEquals(1, result.size(), 'The result list should contain exactly one entry.');

        String expectedPrefix = 'https://';
        Boolean urlFound = result.get(0).startsWith(expectedPrefix);
        
        System.assert(urlFound, 'The result should contain a valid URL or an error message.');

    }
}