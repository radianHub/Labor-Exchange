import { LightningElement, api } from 'lwc';

import { PageChangeEvent } from './event.js';

export default class LEXTilesPagination extends LightningElement {
	@api pageSize = 6;
	@api totalRecords;
	@api currentPage = 1;

	renderedCallback() {
		var buttons = this.template.querySelectorAll('lightning-button');

		if (buttons != undefined && this.currentPage === 1 && buttons[0] !== undefined) {
			buttons[0].disabled = true;
		}
	}

	handlePageClick(event) {
		const page = event.target.name;
		[...this.template.querySelectorAll('lightning-button')].forEach((button) => {
			button.disabled = false;
		});
		event.target.disabled = true;
		this.dispatchEvent(new PageChangeEvent({ page: parseInt(page) }));
	}

	get totalPages() {
		return this.totalRecords % this.pageSize === 0 ? parseInt(this.totalRecords / this.pageSize) : parseInt(this.totalRecords / this.pageSize) + 1;
	}

	get pages() {
		var pages = [];
		for (var i = 0; i < this.totalPages; i++) {
			pages.push(i + 1);
		}
		return pages;
	}
}