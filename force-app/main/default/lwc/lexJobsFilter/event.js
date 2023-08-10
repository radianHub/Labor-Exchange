export const SEARCH = 'search';

export class SearchJob extends CustomEvent {
    constructor(detail) {
        super(SEARCH, {
            detail,
            cancelable: true,
            bubbles: true,
            composed: true
        });
    }
}