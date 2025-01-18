public class HCUV_CarFaxVehicleHistoryWrapper {
    public DataClass data {get;set;}
    public class DataClass{
        public ICRClass icr{get;set;}
    }
    public class ICRClass{
        public CarFaxLinkClass carfaxLink {get;set;}
        public OwnerHistoryClass ownerHistory {get;set;} 
    }
    public class CarFaxLinkClass{
        public String url {get;set;}
        public String iconUrl {get;set;}
        public String valueBadgeAltText {get;set;}
        public ExpiresAtClass expiresAt{get;set;}
    }
    public class ExpiresAtClass{
        public String rfc {get;set;}
    }             
    public class OwnerHistoryClass{
        public Boolean oneOwner {get;set;}
    }
}