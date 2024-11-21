/*
 * @author            : gredrianc
 * @last modified on  : 2024-11-21
 * @last modified by  : gredrianc
 */
import { LightningElement, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import checkConnection from '@salesforce/apex/CurrencyAPIConnector.checkConnection';
import getExchangeRate from '@salesforce/apex/CurrencyAPIConnector.getExchangeRate';


export default class CurrencyApp extends LightningElement {

    isProcessing = true;
    isProcessed;
    
    isConverted;
    isHistorical =false;

    options = [];
    amount;
    fromCurrency;
    toCurrency;

    convertedAmount;
    currencyCode;

    formattedDate = new Date().toLocaleDateString('en-CA');
    @track historicalDate;
    

    connectedCallback() {
        checkConnection()
            .then(results=>{
                const result = JSON.parse(results);
                this.options = Object.entries(result.data) 
                    .filter(([currencyCode, data]) => data.code && data.name) 
                    .map(([currencyCode, data]) => ({ 
                        label: `${data.code} - ${data.name}`, 
                        value: data.code 
                    }));
                this.isProcessing = false;
            })
            .catch(() => {
                if(!import.meta.env.SSR) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Connection Failed',
                            message: 'Error with retreiving currencies.',
                            variant: 'error'
                        })
                    );
                }
            })
            .finally(() => {
                this.isProcessed = true;
            });
    }


    handleAmount(event) {
        this.amount = event.detail.value;
        this.isConverted = false;
    }

    handleFromChange(event) {
        this.fromCurrency = event.detail.value;
    }

    handleToChange(event) {
        this.toCurrency = event.detail.value;
        this.currencyCode = event.detail.value;
    }

    get disableButton() {
        return !(this.amount && this.fromCurrency && this.toCurrency);
    }

    handleClick() {
        [this.fromCurrency, this.toCurrency] =  [this.toCurrency, this.fromCurrency];
        this.currencyCode = this.toCurrency;
        this.convertedAmount ='';
        this.isConverted = false;
    }

    handleEditDate() {
        this.isHistorical = true;
        this.historicalDate = this.formattedDate;
    }

    handleDateChange(event){
        this.historicalDate = event.detail.value;
    }

    handleConversion() {
        const isLatest = this.isHistorical === false || new Date(this.historicalDate) >= new Date(this.formattedDate);
        const params = {
            ...(isLatest ? {} : { date: this.historicalDate }),
            base_currency: this.fromCurrency,
            currencies: this.toCurrency,
        };
        const type = isLatest ? "latest" : "historical";    
        
        this.getExchangeRateAndConvert(type, params);
        this.isConverted = false;
        this.isProcessing = true;
        this.isProcessed = false;
    }

    getExchangeRateAndConvert(requestType,urlParam) {
        getExchangeRate({requestType, urlParam})
            .then(results => {
                const result = JSON.parse(results);
                this.convertedAmount = this.amount * result.data[this.toCurrency].value;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isProcessing = false;
                this.isProcessed = true;
                this.isConverted = true;
            });

    }


}