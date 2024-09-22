/**
 * @description       : Test Class for CurrencyAPIConnector
 * @author            : gredrianc
 * @last modified on  : 2024-09-22
 * @last modified by  : gredrianc
**/
@isTest
public class CurrencyAPIConnectorTest {
    
    @isTest
    static void testCheckConnection() {
        // Mock the HTTP response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status":"success"}');
        response.setStatusCode(200);
        
        System.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));
        
        // Call the method
        System.Test.startTest();
        String result = CurrencyAPIConnector.checkConnection();
        System.Test.stopTest();
        
        // Verify the result
        System.assertEquals('{"status":"success"}', result);
    }
    
    @isTest
    static void testGetExchangeRate() {
        // Mock the HTTP response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"rate":"1.2345"}');
        response.setStatusCode(200);
        
        System.Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));
        
        // Prepare parameters
        Map<String, String> urlParams = new Map<String, String>();
        urlParams.put('date', '2024-01-01');
        urlParams.put('base_currency', 'USD');
        urlParams.put('currencies', 'EUR');
        
        // Call the method
        System.Test.startTest();
        String result = CurrencyAPIConnector.getExchangeRate('historical', urlParams);
        System.Test.stopTest();
        
        // Verify the result
        System.assertEquals('{"rate":"1.2345"}', result);
    }
    
    // Mock HTTP response generator class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }
        
        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
}
