global with sharing class EinsteinCalloutMock implements HttpCalloutMock {

    static final String CLASSNAME = 'EinsteinCalloutMock';

   global HTTPResponse respond(HTTPRequest request) {
       HttpResponse response = new HttpResponse();
       response.setHeader('Content-Type', 'application/json');
       response.setBody('{"datasets":[ {"id":"0056g000005766pAAA","name":"TestKPI","currentVersionId":"0Fc3I000000MWKRSA4","label":"TestKPI" } ]}');
       response.setStatusCode(200);
       return response;
   }
}