export const APPLY_FILTER = 'applyfilter';

export class ApplyFilterEvent extends CustomEvent {
    constructor(detail) {
        super(APPLY_FILTER, {
            detail,
            cancelable: true,
            bubbles: true,
            composed: true
        });
    }
}