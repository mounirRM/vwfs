import { LightningElement, api, wire, track } from "lwc";
import clearOptOutField from "@salesforce/apex/SM001_ContactServices.clearOptOutField";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class LWC001_SurveyOptout extends LightningElement {
  connectedCallback() {
    const a = new URL(window.location.href).searchParams.get("a");
    clearOptOutField({ v: a }).then((result)=> {
    if(result==true){
      const event = new ShowToastEvent({
        title: "Vous demande a bien été prise en compte",
        message: "",
        variant: "success"
      });
      this.dispatchEvent(event);
    }else if(result==false){
      const event = new ShowToastEvent({
        title: "Une erreur est survenue lors du traitement de votre demande",
        message: "",
        variant: "Error"
      });
      this.dispatchEvent(event);

    }});    
  }
}