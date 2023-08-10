import { LightningElement, api } from 'lwc';

import { ApplyFilterEvent } from './event.js';

export default class lexSelectFilterValues extends LightningElement {
    @api filter;
    @api buttonLabel;

    renderedCallback() {
        [...this.template.querySelectorAll('lightning-input')].forEach(input => {
            input.checked = this.filter.selectedValues.find(value => value === input.name);
        });
    }

    handleApplyFilters() {
        const inputs = [...this.template.querySelectorAll('lightning-input')].filter(input => input.checked);
        const selectedValues = [];
        inputs.forEach(element => {
            selectedValues.push(element.name)
        });

        this.dispatchEvent(
            new ApplyFilterEvent({
                selectedValues,
                fieldName: this.filter.fieldName
            })
        );
    }
}