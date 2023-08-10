public virtual class TriggerHandler {
	// static map of handlername, times run() was invoked
	private static Map<String, LoopCount> loopCountMap;
	private static Set<String> bypassedHandlers;

	// the current context of the trigger, overridable in tests
	@TestVisible
	private TriggerContext context;

	// the current context of the trigger, overridable in tests
	@TestVisible
	private Boolean isTriggerExecuting;

	@TestVisible
	private SObjectType sObjectTriggerType;

	@TestVisible
	private Map<String, Boolean> sObjectTrigger = new Map<String, Boolean>{
		'Active' => true,
		'beforeInsert' => true,
		'beforeUpdate' => true,
		'beforeDelete' => true,
		'afterInsert' => true,
		'afterUpdate' => true,
		'afterDelete' => true,
		'afterUndelete' => true
	};

	@TestVisible
	private List<sObject_Trigger__mdt> sObjectTriggerMetadata = new List<sObject_Trigger__mdt>{
		new sObject_Trigger__mdt(
			DeveloperName = 'sObject',
			Active__c = true,
			beforeInsert__c = true,
			beforeUpdate__c = true,
			beforeDelete__c = true,
			afterInsert__c = true,
			afterUpdate__c = true,
			afterDelete__c = true,
			afterUndelete__c = true
		)
	};

	// static initialization
	static {
		loopCountMap = new Map<String, LoopCount>();
		bypassedHandlers = new Set<String>();
	}

	// constructor
	public TriggerHandler() {
		this.setTriggerContext();
		this.setTriggerActivity();
	}

	@TestVisible
	private void setTriggerActivity() {
		if (!Test.isRunningTest()) {
			String sObjectApiName = (Trigger.isDelete ? Trigger.old.getSObjectType() : Trigger.new.getSObjectType()).getDescribe().getName();
			this.sObjectTriggerMetadata = [
				SELECT Id, Active__c, beforeInsert__c, beforeUpdate__c, beforeDelete__c, afterInsert__c, afterUpdate__c, afterDelete__c, afterUndelete__c
				FROM sObject_Trigger__mdt
				WHERE sObject_API_Name__c = :sObjectApiName
				LIMIT 1
			];
		}

		if (sObjectTriggerMetadata.size() != 0) {
			this.sObjectTrigger.put('Active', sObjectTriggerMetadata[0].Active__c);
			this.sObjectTrigger.put('beforeInsert', sObjectTriggerMetadata[0].beforeInsert__c);
			this.sObjectTrigger.put('beforeUpdate', sObjectTriggerMetadata[0].beforeUpdate__c);
			this.sObjectTrigger.put('beforeDelete', sObjectTriggerMetadata[0].beforeDelete__c);
			this.sObjectTrigger.put('afterInsert', sObjectTriggerMetadata[0].afterInsert__c);
			this.sObjectTrigger.put('afterUpdate', sObjectTriggerMetadata[0].afterUpdate__c);
			this.sObjectTrigger.put('afterDelete', sObjectTriggerMetadata[0].afterDelete__c);
			this.sObjectTrigger.put('afterUndelete', sObjectTriggerMetadata[0].afterUndelete__c);
		}
	}

	/***************************************
	 * public instance methods
	 ***************************************/

	// main method that will be called during execution
	public void run() {
		if (!validateRun() || !this.sObjectTrigger.get('Active')) {
			return;
		}

		addToLoopCount();

		// dispatch to the correct handler method
		switch on this.context {
			when BEFORE_INSERT {
				if (this.sObjectTrigger.get('beforeInsert')) {
					this.beforeInsert();
				}
			}
			when BEFORE_UPDATE {
				if (this.sObjectTrigger.get('beforeUpdate')) {
					this.beforeUpdate();
				}
			}
			when BEFORE_DELETE {
				if (this.sObjectTrigger.get('beforeDelete')) {
					this.beforeDelete();
				}
			}
			when AFTER_INSERT {
				if (this.sObjectTrigger.get('afterInsert')) {
					this.afterInsert();
				}
			}
			when AFTER_UPDATE {
				if (this.sObjectTrigger.get('afterUpdate')) {
					this.afterUpdate();
				}
			}
			when AFTER_DELETE {
				if (this.sObjectTrigger.get('afterDelete')) {
					this.afterDelete();
				}
			}
			when AFTER_UNDELETE {
				if (this.sObjectTrigger.get('afterUndelete')) {
					this.afterUndelete();
				}
			}
		}
	}

	public void setMaxLoopCount(Integer max) {
		String handlerName = getHandlerName();
		if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
			TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
		} else {
			TriggerHandler.loopCountMap.get(handlerName).setMax(max);
		}
	}

	public void clearMaxLoopCount() {
		this.setMaxLoopCount(-1);
	}

	/***************************************
	 * public static methods
	 ***************************************/

	public static void bypass(String handlerName) {
		TriggerHandler.bypassedHandlers.add(handlerName);
	}

	public static void clearBypass(String handlerName) {
		TriggerHandler.bypassedHandlers.remove(handlerName);
	}

	public static Boolean isBypassed(String handlerName) {
		return TriggerHandler.bypassedHandlers.contains(handlerName);
	}

	public static void clearAllBypasses() {
		TriggerHandler.bypassedHandlers.clear();
	}

	/***************************************
	 * private instancemethods
	 ***************************************/

	@TestVisible
	private void setTriggerContext() {
		this.setTriggerContext(null, false);
	}

	@TestVisible
	private void setTriggerContext(String ctx, Boolean testMode) {
		if (!Trigger.isExecuting && !testMode) {
			this.isTriggerExecuting = false;
			return;
		} else {
			this.isTriggerExecuting = true;
		}

		if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) || (ctx != null && ctx == 'before insert')) {
			this.context = TriggerContext.BEFORE_INSERT;
		} else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) || (ctx != null && ctx == 'before update')) {
			this.context = TriggerContext.BEFORE_UPDATE;
		} else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) || (ctx != null && ctx == 'before delete')) {
			this.context = TriggerContext.BEFORE_DELETE;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) || (ctx != null && ctx == 'after insert')) {
			this.context = TriggerContext.AFTER_INSERT;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) || (ctx != null && ctx == 'after update')) {
			this.context = TriggerContext.AFTER_UPDATE;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) || (ctx != null && ctx == 'after delete')) {
			this.context = TriggerContext.AFTER_DELETE;
		} else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) || (ctx != null && ctx == 'after undelete')) {
			this.context = TriggerContext.AFTER_UNDELETE;
		}
	}

	// increment the loop count
	@TestVisible
	private void addToLoopCount() {
		String handlerName = getHandlerName();
		if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
			Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
			if (exceeded) {
				Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
				throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
			}
		}
	}

	// make sure this trigger should continue to run
	@TestVisible
	private Boolean validateRun() {
		if (!this.isTriggerExecuting || this.context == null) {
			throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
		}
		return !TriggerHandler.bypassedHandlers.contains(getHandlerName());
	}

	@TestVisible
	private String getHandlerName() {
		return this.toString().substringBefore(':');
	}

	/***************************************
	 * context methods
	 ***************************************/

	// context-specific methods for override
	@TestVisible
	protected virtual void beforeInsert() {
	}
	@TestVisible
	protected virtual void beforeUpdate() {
	}
	@TestVisible
	protected virtual void beforeDelete() {
	}
	@TestVisible
	protected virtual void afterInsert() {
	}
	@TestVisible
	protected virtual void afterUpdate() {
	}
	@TestVisible
	protected virtual void afterDelete() {
	}
	@TestVisible
	protected virtual void afterUndelete() {
	}

	/***************************************
	 * inner classes
	 ***************************************/

	// inner class for managing the loop count per handler
	@TestVisible
	private class LoopCount {
		private Integer max;
		private Integer count;

		public LoopCount() {
			this.max = 5;
			this.count = 0;
		}

		public LoopCount(Integer max) {
			this.max = max;
			this.count = 0;
		}

		public Boolean increment() {
			this.count++;
			return this.exceeded();
		}

		public Boolean exceeded() {
			return this.max >= 0 && this.count > this.max;
		}

		public Integer getMax() {
			return this.max;
		}

		public Integer getCount() {
			return this.count;
		}

		public void setMax(Integer max) {
			this.max = max;
		}
	}

	// possible trigger contexts
	@TestVisible
	private enum TriggerContext {
		BEFORE_INSERT,
		BEFORE_UPDATE,
		BEFORE_DELETE,
		AFTER_INSERT,
		AFTER_UPDATE,
		AFTER_DELETE,
		AFTER_UNDELETE
	}

	// exception class
	public class TriggerHandlerException extends Exception {
	}
}