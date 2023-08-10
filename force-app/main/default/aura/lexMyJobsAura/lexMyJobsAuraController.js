({
    doInit : function(component, event, helper) {

        const config = {
            // * MY JOBS CONFIG
            header: component.get('v.header'),
            headerColor: component.get('v.headerColor'),
            description: component.get('v.description'),
            newJobBtnLabel: component.get('v.newJobBtnLabel'),
            showNewJobBtn: component.get('v.showNewJobBtn'),

            // * SEARCH JOBS CONFIG
            filterHeader: component.get('v.filterHeader'),
            filterDescription: component.get('v.filterDescription'),
            filterField: component.get('v.filterField'),
            filterInputLabel: component.get('v.filterInputLabel'),
            clearFiltersBtnLabel: component.get('v.clearFiltersBtnLabel'),
            searchBtnLabel: component.get('v.searchBtnLabel'),
            searchInputLabel: component.get('v.searchInputLabel'),

            // * FOUND JOBS CONFIG
            jobsHeader: component.get('v.jobsHeader'),
            jobsSubHeader: component.get('v.jobsSubHeader'),
            jobTileHeaderColor: component.get('v.jobTileHeaderColor'),
            jobTileFooterColor: component.get('v.jobTileFooterColor'),
            viewDetailsBtnLabel: component.get('v.viewDetailsBtnLabel'),
            editJobBtnLabel: component.get('v.editJobBtnLabel'),
            noResultMessage: component.get('v.noResultMessage'),

            // * VIEW DETAILS CONFIG
            detailsHeader: component.get('v.detailsHeader'),
            skillPillColor: component.get('v.skillPillColor'),
            editJobDetailBtnLabel: component.get('v.editJobDetailBtnLabel'),
            backBtnLabel: component.get('v.backBtnLabel'),
            archiveBtnLabel: component.get('v.archiveBtnLabel'),

            // * CREATE/EDIT JOB CONFIG
            editJobHeader: component.get('v.editJobHeader'),
            createJobHeader: component.get('v.createJobHeader'),
            editJobObjName: component.get('v.editJobObjName'),
            saveBtnLabel: component.get('v.saveBtnLabel'),
            cancelBtnLabel: component.get('v.cancelBtnLabel'),
            createSaveMsg: component.get('v.createSaveMsg'),
            editSaveMsg: component.get('v.editSaveMsg')
        };

        component.set('v.config', config);
    },
    refreshData: function(cmp, evt, hlp) {
        $A.get('e.force:refreshView').fire();
    }
})