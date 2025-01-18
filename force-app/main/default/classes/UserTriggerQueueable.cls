/**
 * [Class Description]
 * When user gets updated for inactive, process deleting contact after the trigger for user is done.
 * ----- Change Log -----
 * @Author : Minheekim@haeaus.com / Date : 12/05/2023
 * @Ticket Number :  DPM-5192
 * @Change Description : 
 */
public without sharing class UserTriggerQueueable implements Queueable{
    public List<Id> listContactToDelete;

    /* Constructor */
    public UserTriggerQueueable(List<Id> listContactToDelete) {
        this.listContactToDelete = listContactToDelete;
    }


    public void execute(QueueableContext context) {
        
        List<Contact> contacts = new List<Contact>();
        for(Id contactId : listContactToDelete){
            contacts.add(new Contact(Id=contactId));
        }
        delete contacts;
            
    }
  
}