public with sharing class UserTriggerHandler extends TriggerHandler {
	List<User> newUsers;
	Map<Id, User> newUsersMap;
	List<User> oldUsers;
	Map<Id, User> oldUsersMap;

	public UserTriggerHandler() {
		this.newUsers = (List<User>) Trigger.new;
		this.newUsersMap = (Map<Id, User>) Trigger.newMap;
		this.oldUsers = (List<User>) Trigger.old;
		this.oldUsersMap = (Map<Id, User>) Trigger.oldMap;
	}

	public override void afterInsert() {
		// Assign permission sets
		UserService.assignPermissionSets(newUsers);
	}
}