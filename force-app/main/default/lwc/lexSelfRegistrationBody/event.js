export const AGREEMENT_EVENT_NAME = 'agreement';

export class AgreementEvent extends CustomEvent {
    constructor() {
        super(AGREEMENT_EVENT_NAME, {});
    }
}