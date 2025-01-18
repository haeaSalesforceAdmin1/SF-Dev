public with sharing class HMADealerObjectAccessWrapper {
    public String dealerCode {get; set;}
    public String objectAccessType {get; set;}

    public HMADealerObjectAccessWrapper(String dealerCode, String objectAccessType) {
        this.dealerCode = dealerCode;
        this.objectAccessType = objectAccessType;
    }
}