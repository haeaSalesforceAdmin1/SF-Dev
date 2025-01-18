/**
 * [DynamicLinkHelper Description]
 * 
 * ----- Change Log -----
 * @Author : JonghoonKim   / Date :  24-08-20
 * @Ticket Number : DPM-5640
 * @Change Description : Created DynamicLinkHelper
 */

 /**
     * [Method Description] 
     * get DynamicLink
     * Created by [Jonghoon Kim] on [24-08-20] for [Ticket DPM-5640]
     * Edited by [Author] on [Date] for [Ticket #]
*/
public class DynamicLinkHelper {
    @InvocableMethod
    public static List<String> generateDynamicLink() {
        List<String> links = new List<String>();
        
        try {
            String baseUrl = URL.getOrgDomainUrl().toExternalForm();
            links.add(baseUrl);
        } catch (Exception e) {
            links.add('Error retrieving URL: ' + e.getMessage());
        }
        
        return links;
    }
}