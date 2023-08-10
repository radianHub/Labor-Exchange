import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { SelectionEvent, LoadedSkills } from './event.js';

import getSkillsByCategory from '@salesforce/apex/MultiSkillSelectionController.getSkillsByCategory';
import getSkills from '@salesforce/apex/MultiSkillSelectionController.getSkills';

export default class MultiSkillSelection extends LightningElement {
	@api title;
	@api recordId;

	@track categories = [];
	skillsHidden = true;
	@track activeSkills = [];
	@track deactivatedSkills = [];

	loading = true;
	saving = false;

	// * GETS RELATED SKILLS AND SKILL CATEGORIES ON COMPONENT LOAD
	connectedCallback() {
		if (this.recordId) {
			this.getSkills();
		} else {
			this.getSkillsByCategory();
		}
	}

	// # APEX

	// * GETS SKILLS AND SKILL CATEGORIES. MATCHES SKILLS WITH RELATED SKILLS AND MARKS THEM AS ACTIVE.
	getSkillsByCategory() {
		getSkillsByCategory()
			.then((result) => {
				this.categories = result;
				if (this.activeSkills == null || this.activeSkills.length > 0) {
					this.categories.forEach((cat) => {
						cat.skills.forEach((skill) => {
							const found = this.activeSkills.find((aSkill) => aSkill === skill.id);
							if (found) {
								skill.isSelected = true;
							}
						});
					});
				}
			})
			.catch((err) => {
				console.log('ERROR', err);
				this.showToast('Error', err.body.message, 'error');
			})
			.finally(() => {
				this.loading = false;
			});
	}

	// * GETS RELATED SKILLS BY RECORD ID.
	getSkills() {
		getSkills({ recordId: this.recordId })
			.then((result) => {
				this.activeSkills = result;
				this.activeSkills = this.activeSkills.map((skill) => {
					let { Id, ...rest } = skill;
					return Object.values(rest)[0];
				});
				this.dispatchEvent(new LoadedSkills(this.activeSkills));
				this.getSkillsByCategory();
			})
			.catch((err) => {
				console.log('ERROR', err);
				this.showToast('Error', err.body.message, 'error');
				this.loading = false;
			});
	}

	// # PRIVATE METHODS

	// * SHOW TOAST NOTIFICATION
	showToast(title, message, variant, mode = 'dismissable') {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode,
		});
		this.dispatchEvent(event);
	}

	// # HANDLERS

	// * SHOW/HIDE SKILLS WITHIN A CATEGORY
	toggleSkillCategoryButton(event) {
		const name = event.currentTarget.name;
		const selector = 'div[data-name=' + name + ']';
		const div = this.template.querySelector(selector);
		if (div.hidden) {
			this.template.querySelector('button[name=' + name + ']').className = 'slds-button slds-button_brand skills category';
		} else {
			this.template.querySelector('button[name=' + name + ']').className = 'slds-button slds-button_outline-brand skills collapsed category';
		}
		div.hidden = !div.hidden;
	}

	// * MARKS SKILLS ACTIVATED OR DEACTIVATED. BUILDS ARRAYS OF EACH.
	checkSkillCheckBox(event) {
		const isChecked = event.target.checked;

		this.activeSkills = JSON.parse(JSON.stringify(this.activeSkills));
		if (isChecked && !this.activeSkills.includes(event.target.name)) {
			this.activeSkills.push(event.target.name);
		} else if (!isChecked && this.activeSkills.includes(event.target.name)) {
			this.activeSkills = this.activeSkills.filter((v) => v !== event.target.name);
			this.deactivatedSkills.push(event.target.name);
		}
		if (isChecked && this.deactivatedSkills.includes(event.target.name)) {
			this.deactivatedSkills = this.deactivatedSkills.filter((v) => v !== event.target.name);
		}

		this.dispatchEvent(
			new SelectionEvent({
				selected: this.activeSkills,
				unselected: this.deactivatedSkills,
			})
		);
	}

	// # GETTERS/SETTERS

	// * DISPLAYS SPINNER
	get isLoading() {
		if (this.loading || this.saving) {
			return true;
		}
		return false;
	}

	// * RETURNS TRUE IF A TITLE IS PROVIDED
	get hasTitle() {
		if (this.title !== undefined) {
			return true;
		}
		return false;
	}
}