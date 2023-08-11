export const CHANGE_FILTERS = 'changefilters';
export const SEARCH = 'search';
export const CLEAR_FILTERS = 'clearfilters';

export class ChangeFiltersEvent extends CustomEvent {
    constructor(detail) {
        super(CHANGE_FILTERS, {
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

export class SearchCandidate extends CustomEvent {
    constructor(detail) {
        super(SEARCH, {
            detail,
            cancelable: true,
            bubbles: true,
            composed: true
        });
    }
}