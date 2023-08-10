export const SELECTION_EVENT = 'selection';
export const LOADED_SKILLS = 'loadedskills'

export class SelectionEvent extends CustomEvent {
    constructor(detail) {
        super(SELECTION_EVENT, {
            detail,
            cancelable: true,
            bubbles: true,
            composed: true
        });
    }
}

export class LoadedSkills extends CustomEvent {
    constructor(detail) {
        super(LOADED_SKILLS, {
            detail,
            cancelable: true,
            bubbles: true,
            composed: true
        });
    }
}