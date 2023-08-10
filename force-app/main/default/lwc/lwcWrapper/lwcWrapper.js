import { LightningElement } from 'lwc';

export default class LwcWrapper extends LightningElement {
    config = {
        header: 'test',
        headerColor: '',
        description: 'abc',
        subheaderColor: '',
        editButtonLabel: 'edit',
        saveButtonLabel: 'save',
        cancelButtonLabel: 'cancel',
        requiredFieldMessage: 'required',
        successMessage: 'success'
    };
}