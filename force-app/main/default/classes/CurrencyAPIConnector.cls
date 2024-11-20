/**
 * @description       : Class bundles methods making calls to https://app.currencyapi.com/
 * @author            : gredrianc
 * @last modified on  : 2024-11-20
 * @last modified by  : gredrianc
**/
public with sharing class CurrencyAPIConnector {
    /**
    * @description Method to get the available currencies at https://app.currencyapi.com/
    * @author gredrianc | 2024-09-22 
    * @return String value of currencies available
    **/
    @AuraEnabled(cacheable=true)
    public static String checkConnection(){
        try {
            return httpRequestHelper('currencies?type=fiat');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

	/**
	* @description Method to get the latest or historical exchange rates at https://app.currencyapi.com/
	* @author gredrianc | 2024-09-22 
	* @param requestType String value of type of request - historical or latest
	* @param urlParam Map<String, String> values to add attributes into the callout url
	* @return String value of exchange rate
	**/
    @AuraEnabled(cacheable=true)
	public static String getExchangeRate(String requestType, Map<String, String> urlParam) {
        try {
			PageReference pr = new PageReference(requestType);
			pr.getParameters().putAll(urlParam);
            return httpRequestHelper(pr.getUrl());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

	}

	public static String httpRequestHelper(String requestType) {
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');
		request.setEndpoint('callout:CurrencyApi' + '/' + requestType);
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		request.setTimeout(120000);
		HttpResponse response = new Http().send(request);
		switch on String.valueOf(response.getStatusCode()) {
			when '200' {
				return response.getBody();
			}
			when else {
				throw new CalloutException(response.getBody());
			}
		}
	}	

}
