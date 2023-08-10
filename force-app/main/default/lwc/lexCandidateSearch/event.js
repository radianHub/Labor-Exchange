export const VIEW = 'view';
export const CLEAR_FILTERS = 'clearfilters';

export class ViewEvent extends CustomEvent {
    constructor(detail) {
        super(VIEW, {
            detail,
            cancelable: true,
            bubbles: true,
            composed: true
        });
    }
}

export class ClearFiltersEvent extends CustomEvent {
    constructor() {
        super(CLEAR_FILTERS, {
            cancelable: true,
            bubbles: true,
            composed: true
        });
    }
}