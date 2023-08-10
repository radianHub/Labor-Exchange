// HEADER COMMENT
public with sharing class LEXHomeController {
	@AuraEnabled(cacheable=true)
	public static Labor_Exchange_Community_Setup__c laborExchangeCommunitySetup() {
		return Labor_Exchange_Community_Setup__c.getOrgDefaults();
	}

	// @AuraEnabled
	// public static Boolean checkForClientSkills(){
	//     try {
	//         /*CRUD/FLS Security check */
	//         if(!SobjectHelper.canQueryObj('User')){
	//             throw SObjectHelperException.queryPermissionException('User');
	//         }
	//         List<User> currentUser = [SELECT Id, ContactId, CreatedDate FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];

	//         Participant_Community_Setup__c jscs = Participant_Community_Setup__c.getOrgDefaults();

	//         if(currentUser.size() > 0) {
	//             /*CRUD/FLS Security check */
	//             if(!SobjectHelper.canQueryObj('Client_Skill__c')){
	//                 throw SObjectHelperException.queryPermissionException('Client_Skill__c');
	//             }
	//             List<Client_Skill__c> cSkills = [SELECT Id FROM Client_Skill__c
	//                                                      WHERE Client__c = :currentUser[0].ContactId
	//                                                       WITH SECURITY_ENFORCED];
	//             Integer noOfDays = currentUser[0].CreatedDate.date().daysBetween(System.Today());

	//             if(noOfDays <= jscs.of_Days_Skills_Popup_Post_Register__c && cSkills.isEmpty()) {return true;}
	//         }
	//         return false;
	//     } catch (Exception e) {throw new AuraHandledException(e.getMessage()); }
	// }

	// @AuraEnabled(cacheable=true)
	// public static Map<String, List<Skill>> getSkillsByCategory(){
	//     try {
	//         /*CRUD/FLS Security check */
	//         if(!SobjectHelper.canQueryObj('User')){
	//             throw SObjectHelperException.queryPermissionException('User');
	//         }
	//         List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
	//         Set<Id> skillIds = new Set<Id>();
	//         /*CRUD/FLS Security check */
	//         if(!SobjectHelper.canQueryObj('Client_Skill__c')){
	//             throw SObjectHelperException.queryPermissionException('Client_Skill__c');
	//         }
	//         for(Client_Skill__c s : [SELECT Id, Skill1__c FROM Client_Skill__c
	//                         WHERE Client__c = :currentUser[0].ContactId
	//                          WITH SECURITY_ENFORCED]) {
	//             skillIds.add(s.Skill1__c);
	//         }

	//         Map<String, List<Skill>> skillsMap = new Map<String, List<Skill>>();
	//         /*CRUD/FLS Security check */
	//         if(!SobjectHelper.canQueryObj('Skill1__c')){
	//             throw SObjectHelperException.queryPermissionException('Skill1__c');
	//         }
	//         for(Skill1__c skillObj : [SELECT Id, Name, Category__c
	//                                                FROM Skill1__c WHERE Id NOT IN :skillIds and Active__c = 'Yes'
	//                                                WITH SECURITY_ENFORCED
	//                                            ORDER BY Category__c, Name ASC]) {
	//             if(String.isBlank(skillObj.Category__c))
	//                 skillObj.Category__c='Miscellaneous';

	//             if(!skillsMap.containsKey(skillObj.Category__c)) {
	//                 skillsMap.put(skillObj.Category__c, new List<Skill>());
	//             }
	//             skillsMap.get(skillObj.Category__c).add(new Skill(skillObj.Name, skillObj.Id));
	//         }
	//         return skillsMap;
	//     } catch (Exception e) {throw new AuraHandledException(e.getMessage()); }
	// }

	// @AuraEnabled
	// public static Boolean saveSkills(String skills, String errorMessage){
	//     /*CRUD/FLS Security check */
	//     if(!SobjectHelper.canQueryObj('User')){
	//         throw SObjectHelperException.queryPermissionException('User');
	//     }
	//     List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
	//     /*CRUD/FLS Security check */
	//     if(!SobjectHelper.canQueryObj('Client_Skill__c')){
	//         throw SObjectHelperException.queryPermissionException('Client_Skill__c');
	//     }
	//     Set<Id> skillIds = new Set<Id>();
	//     List<Client_Skill__c> existingClientSkills = [SELECT Id, Skill1__c FROM Client_Skill__c WHERE Client__c = :currentUser[0].ContactId WITH SECURITY_ENFORCED];

	//     for(Client_Skill__c cs: existingClientSkills) {
	//         skillIds.add(cs.Skill1__c);
	//     }

	//     Participant_Community_Setup__c jscs = Participant_Community_Setup__c.getOrgDefaults();

	//     Boolean throwErrorForMinSkills = true;

	//     try {
	//         List<Skill> selectedSkills = (List<Skill>)JSON.deserialize(skills, List<Skill>.class);
	//         List<Client_Skill__c> clientSkills = new List<Client_Skill__c>();
	// 		Set<Id> selectedSkillIds = new Set<Id>();

	//         for(Skill s : selectedSkills) {
	//             selectedSkillIds.add(s.value);
	//             if(!skillIds.contains(s.value)) {
	//                 clientSkills.add(
	//                     new Client_Skill__c(
	//                         Skill1__c = s.value,
	//                         Client__c = currentUser[0].ContactId
	//                     )
	//                 );
	//             }
	//         }

	//         List<Client_Skill__c> clientSkillsToDelete = new List<Client_Skill__c>();
	//         for(Client_Skill__c cs: existingClientSkills) {
	//             if(!selectedSkillIds.contains(cs.Skill1__c)) {
	//             	clientSkillsToDelete.add(cs);
	//             }
	//         }

	//         Integer totalSkills = selectedSkillIds.size();
	//         system.debug('the skill'+totalSkills) ;
	//         system.debug('the skill2'+jscs.of_Required_Skills__c) ;

	//         if( totalSkills >= Integer.valueOf(jscs.of_Required_Skills__c) ) {
	//             if(!clientSkillsToDelete.isEmpty()) {
	//                 SObjectHelper.deleteObj(clientSkillsToDelete);
	//             }

	//             if(!clientSkills.isEmpty()) {
	//             	SObjectHelper.insertObj(clientSkills);
	//             }

	//             throwErrorForMinSkills = false;
	//         }
	//     } catch (Exception e) {throw new AuraHandledException(e.getMessage()); }

	//     if(throwErrorForMinSkills)
	//         throw new AuraHandledException(
	//             String.format(
	//                 errorMessage,
	//                 new List<String>{String.valueOf(Integer.valueOf(jscs.of_required_skills__c))}
	//             )
	//         );

	//     return true;
	// }

	// @AuraEnabled(cacheable=true)
	// public static List<Skill> getClientSkills(){
	//     try {
	//         /*CRUD/FLS Security check */
	//         if(!SobjectHelper.canQueryObj('User')){
	//             throw SObjectHelperException.queryPermissionException('User');
	//         }
	//         List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];

	//         /*CRUD/FLS Security check */
	//         if(!SobjectHelper.canQueryObj('Client_Skill__c')){
	//             throw SObjectHelperException.queryPermissionException('Client_Skill__c');
	//         }
	//         List<Skill> skills = new List<Skill>();
	//         for(Client_Skill__c s : [SELECT Id, Skill1__c, Skill1__r.Name
	//                          FROM Client_Skill__c
	//                         WHERE Client__c = :currentUser[0].ContactId
	//                          WITH SECURITY_ENFORCED
	//                      ORDER BY Skill1__r.Name ASC]) {
	//             skills.add(
	//                 new Skill(
	//                     s.Skill1__r.Name,
	//                     s.Skill1__c
	//                 )
	//             );
	//         }

	//         return skills;
	//     } catch (Exception e) {throw new AuraHandledException(e.getMessage()); }
	// }

	// @AuraEnabled
	// public static Boolean removeClientSkill(String skillId){
	//     try {
	//         /*CRUD/FLS Security check */
	//         if(!SobjectHelper.canQueryObj('User')){
	//             throw SObjectHelperException.queryPermissionException('User');
	//         }
	//         List<User> currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];

	//         /*CRUD/FLS Security check */
	//         if(!SobjectHelper.canQueryObj('Client_Skill__c')){
	//             throw SObjectHelperException.queryPermissionException('Client_Skill__c');
	//         }
	//         List<Client_Skill__c> clientSkills = [SELECT Id, Skill1__c
	//                                                            FROM Client_Skill__c
	//                                                           WHERE Client__c = :currentUser[0].ContactId AND
	//                                                                 Skill1__c = : skillId
	//                                                            WITH SECURITY_ENFORCED];
	//         if(clientSkills.size() > 0) {
	//             SObjectHelper.deleteObj(clientSkills); return true;
	//         } else {
	//             return false;
	//         }
	//     } catch (Exception e) {
	//         throw new AuraHandledException(e.getMessage());
	//     }
	// }

	// public class Skill {
	//     @AuraEnabled public String label;
	//     @AuraEnabled public String value;

	//     public Skill(String label, String value) {
	//         this.label = label;
	//         this.value = value;
	//     }
	// }
}