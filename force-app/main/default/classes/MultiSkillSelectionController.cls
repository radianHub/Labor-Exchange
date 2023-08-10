public with sharing class MultiSkillSelectionController {
    @AuraEnabled
    public static List<CategoryWrapper> getSkillsByCategory() {
        try {
            Map<String, List<SkillWrapper>> mapCategoryToLstSkillWrappers = new Map<String, List<SkillWrapper>>();
            List<CategoryWrapper> categories = new List<CategoryWrapper>();

            if (!SObjectHelper.canQueryObj('Launchpad__Skill1__c')) {
                throw SObjectHelperException.queryPermissionException('Launchpad__Skill1__c');
            }
            for (Launchpad__Skill1__c skill : [
                SELECT Id, Name, Launchpad__Category__c
                FROM Launchpad__Skill1__c
                WHERE Launchpad__Active__c = 'Yes'
                WITH SECURITY_ENFORCED
                ORDER BY Launchpad__Category__c, Name ASC
                LIMIT 50000
            ]) {
                if (String.isBlank(skill.Launchpad__Category__c)) {
                    skill.Launchpad__Category__c = 'Uncategorized';
                }
                if (mapCategoryToLstSkillWrappers.containsKey(skill.Launchpad__Category__c)) {
                    List<SkillWrapper> skills = mapCategoryToLstSkillWrappers.get(skill.Launchpad__Category__c);
                    skills.add(new SkillWrapper(false, skill.Name, skill.Id));
                    mapCategoryToLstSkillWrappers.put(skill.Launchpad__Category__c, skills);
                } else {
                    mapCategoryToLstSkillWrappers.put(skill.Launchpad__Category__c, new List<SkillWrapper>{new SkillWrapper(false, skill.Name, skill.Id)});
                }

            }

            Integer i = 1;
            for (String category : mapCategoryToLstSkillWrappers.keySet()) {
                categories.add(new CategoryWrapper(category, mapCategoryToLstSkillWrappers.get(category), 'Category'+i));
                i++;
            }

            return categories;
        } catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<SObject> getSkills(String recordId) {
        if (recordId == null) {
            throw new CustomException('No record Id available.');
        }

        String sObjectType = Id.valueOf(recordId).getSobjectType().getDescribe().getName();
        List<String> allowedObjectsList = new List<String>{
            'Launchpad__Job__c'
        };
        Set<String> allowedObjects = new Set<String>(allowedObjectsList);

        if (!allowedObjects.contains(sObjectType)) {
            return new List<SObject>();
        }

        try {
            if (!SObjectHelper.canQueryObj(sObjectType)) {
                throw SObjectHelperException.queryPermissionException(sObjectType);
            }
            String initialQuery = 'SELECT Id, {0} FROM {1} WHERE {2} WITH SECURITY_ENFORCED';
            Set<String> queryFields = new Set<String>();
            String queryObject;
            String queryWhere;

            if (sObjectType == allowedObjectsList[0]) {
                queryFields = new Set<String>{ 'Launchpad__Skill1__c' };
                queryObject = 'Launchpad__JobSkill__c';
                queryWhere = 'Launchpad__Job__c = :recordId';
            }

            String query = String.format(initialQuery, new List<String>{ 
                String.join(new List<String>(queryFields), ','),
                queryObject,
                queryWhere
            });

            return Database.query(query);

        } catch (SObjectHelperException e) {
            throw new CustomException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateSkills(String recordId, List<String> skillsToCreate, List<String> skillsToDelete) {
        if (recordId == null) {
			throw new CustomException('No record Id available.');
		}

		String sObjType = Id.valueOf(recordId).getSobjectType().getDescribe().getName();
        List<String> allowedObjectsList = new List<String>{ 
            'Launchpad__Job__c'
		};

        try {
			if (sObjType == allowedObjectsList[0]) {
				if (!SObjectHelper.canQueryObj('Launchpad__JobSkill__c')) {
					throw SObjectHelperException.queryPermissionException('Launchpad__JobSkill__c');
				}
				if (skillsToCreate.size() > 0) {
					JobSkillsService.createJobSkills(new Set<String>{ recordId }, new Set<String>(skillsToCreate));
				}
				if (skillsToDelete.size() > 0) {
					JobSkillsService.deleteJobSkills(new Set<String>{ recordId }, new Set<String>(skillsToDelete));
				}
			}
        } catch (SObjectHelperException e) {
            throw new CustomException(e.getMessage());
        }
    }

    public class CustomException extends Exception {}

    public class CategoryWrapper {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String selector;
        @AuraEnabled
        public List<SkillWrapper> skills;
        @AuraEnabled
        public Integer skillsCount;
        
        public CategoryWrapper(String name, List<SkillWrapper> skills, String selector) {
            this.name = name;
            this.selector = selector;
            this.skills = new List<SkillWrapper>();
            this.skills.addAll(skills);
            this.skillsCount = skills.size();
        }
    }

    public class SkillWrapper {
        @AuraEnabled
        public Boolean isSelected;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String id;

        public SkillWrapper(Boolean isSelected, String name, String id) {
            this.isSelected = isSelected;
            this.name = name;
            this.id = id;
        }
    }
}