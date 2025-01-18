public without sharing class GeneratePDFScheduler implements Schedulable {

    private String pdfType;
    private List<String> recordIds;
    
    public GeneratePDFScheduler(List<String> recordIds, String pdfType) {
        this.recordIds = recordIds;
        this.pdfType = pdfType;
    }

    public void execute(SchedulableContext context) {
        System.enqueueJob(new GeneratePDFQueueable(recordIds, pdfType, 0, 0));

        System.abortJob(context.getTriggerId());
    }
}