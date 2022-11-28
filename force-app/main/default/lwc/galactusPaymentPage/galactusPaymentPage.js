import { LightningElement } from 'lwc';

export default class GalactusPaymentPage extends LightningElement {
    cardNum;
    expireDate;
    cvv;
    details;
    showDetails = false;
    handleNum(event){
        this.cardNum = event.target.value;
    }
    handleDate(event){
        this.expireDate = event.target.value;
    }
    handleCVV(event){
        this.cvv = event.target.value;
    }
    handleSubmit(){
        this.details = 'Your details are:\nCard Number: ' + this.cardNum + '\nExpire Date: ' + this.expireDate + '\nCVV: ' + this.cvv;
        this.showDetails = true;
    }
}