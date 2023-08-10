public with sharing class JobSkillsService {

    public static void createJobSkills(Set<String> jobIds, Set<String> skillIds) {
		createJobSkills(jobIds, skillIds, null);
	}

	public static void createJobSkills(Set<String> jobIds, Set<String> skillIds, String type) {
		try {
			List<Launchpad__JobSkill__c> jobSkillsToInsert = new List<Launchpad__JobSkill__c>();

			for (String jobId : jobIds) {
				for (String skillId : skillIds) {
					Launchpad__JobSkill__c skill = new Launchpad__JobSkill__c(Launchpad__Job__c = jobId, Launchpad__Skill1__c = skillId);
					jobSkillsToInsert.add(skill);
				}
			}

			SObjectHelper.insertObj(jobSkillsToInsert);
		} catch (Exception e) {
			throw new SObjectHelperException(e.getMessage());
		}
	}

    public static void deleteJobSkills(Set<String> jobIds, Set<String> skillIds) {
		try {
			if (!SobjectHelper.canQueryObj('Launchpad__JobSkill__c')) {
				throw new SObjectHelperException.queryPermissionException('Launchpad__JobSkill__c');
			}
	
			List<Launchpad__JobSkill__c> jobSkillsToDelete = [
				SELECT Id
				FROM Launchpad__JobSkill__c
				WHERE Launchpad__Job__c IN :jobIds AND Launchpad__Skill1__c IN :skillIds
				WITH SECURITY_ENFORCED
			];
	
			if (jobSkillsToDelete.size() > 0) {
				SObjectHelper.deleteObj(jobSkillsToDelete);
			}
		}
		catch (Exception e) {
			throw new SObjectHelperException(e.getMessage());
		}
	}
}