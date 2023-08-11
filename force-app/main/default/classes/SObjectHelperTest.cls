@isTest
public with sharing class SObjectHelperTest {
	static final String NAMESPACE_PREFIX = SObjectHelper.getNamespace();

	@isTest
	static void canQueryObj() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();
			User oStandardUser = (User) new SObjectBuilder(User.sObjectType).create().getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				System.assertEquals(true, SObjectHelper.canQueryObj('Contact'), 'Does not have object access');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void canQueryObjNull() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Test.startTest();
			try {
				System.assertEquals(true, SObjectHelper.canQueryObj(null), 'No error thrown');
			} catch (SObjectHelperException mcEx) {
				System.assertEquals(string.format('No SObject provided.', new List<string>{ 'sSObject' }), mcEx.getMessage(), 'Incorrect error thrown');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void insertObj() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Contact oContact = new Contact();
			oContact.FirstName = 'TestFirstName';
			oContact.LastName = 'TestLastName';
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					Database.SaveResult[] lSaveResults = SObjectHelper.insertObj(oContact);
					for (Database.SaveResult oSaveResult : lSaveResults) {
						System.assertEquals(true, oSaveResult.isSuccess(), 'Record not inserted');
					}
				} catch (Exception oException) {
					System.assertEquals(null, oException.getMessage(), 'Error thrown');
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void insertObjects() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Contact oContact1 = new Contact();
			oContact1.FirstName = 'TestFirstName1';
			oContact1.LastName = 'TestLastName1';

			Contact oContact2 = new Contact();
			oContact2.FirstName = 'TestFirstName2';
			oContact2.LastName = 'TestLastName2';

			List<Contact> lstContacts = new List<Contact>();
			lstContacts.add(oContact1);
			lstContacts.add(oContact2);
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					Database.SaveResult[] lSaveResults = SObjectHelper.insertObj(lstContacts);
					for (Database.SaveResult oSaveResult : lSaveResults) {
						System.assertEquals(true, oSaveResult.isSuccess(), 'Records not inserted');
					}
				} catch (Exception oException) {
					System.assertEquals(null, oException.getMessage(), 'Error thrown');
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void insertObjPermissionError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Campaign oCampaign = new Campaign();
			oCampaign.Name = 'TestName';
			User oStandardUser = (User) new SObjectBuilder(User.sObjectType).create().getRecord();

			Test.startTest();
			System.runAs(oStandardUser) {
				try {
					Database.SaveResult[] lSaveResults = SObjectHelper.insertObj(oCampaign);
				} catch (SObjectHelperException.InsertPermissionException oException) {
					System.assertEquals('User does not have permission to insert Campaign Object', oException.getMessage(), 'Incorrect error thrown');
				} catch (Exception oException) {
					System.assertEquals(null, oException.getMessage(), 'Error thrown');
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void insertObjListIsEmptyError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			List<Contact> lContact = new List<Contact>();

			Test.startTest();
			try {
				Database.SaveResult[] lSaveResult = SObjectHelper.insertObj(lContact);
			} catch (SObjectHelperException.InvalidParameterException oException) {
				System.assertEquals(string.format('{0} cannot be null.', new List<string>{ 'oSObjects' }), oException.getMessage(), 'Incorrect error thrown');
			} catch (Exception oException) {
				System.assertEquals(null, oException.getMessage(), 'Error thrown');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void insertObjListIsNullError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			List<Contact> lContact;

			Test.startTest();
			try {
				Database.SaveResult[] lSaveResult = SObjectHelper.insertObj(lContact);
			} catch (SObjectHelperException.InvalidParameterException oException) {
				System.assertEquals(string.format('{0} cannot be null.', new List<string>{ 'oSObjects' }), oException.getMessage(), 'Incorrect error thrown');
			} catch (Exception oException) {
				System.assertEquals(null, oException.getMessage(), 'Error thrown');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void insertObjNullObjectError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			List<Contact> lContact;

			Test.startTest();
			try {
				Database.SaveResult[] lSaveResult = SObjectHelper.insertObj(lContact);
			} catch (SObjectHelperException.InvalidParameterException oException) {
				System.assertEquals(string.format('{0} cannot be null.', new List<string>{ 'oSObjects' }), oException.getMessage(), 'Incorrect error thrown');
			} catch (Exception oException) {
				System.assertEquals(null, oException.getMessage(), 'Error thrown');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void updateObj() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Contact oContact = (Contact) new SObjectBuilder(Contact.sObjectType).create().getRecord();
			oContact.FirstName = 'CHANGE';
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					Database.SaveResult[] lSaveResults = SObjectHelper.updateObj(oContact);
					for (Database.SaveResult oSaveResult : lSaveResults) {
						System.assertEquals(true, oSaveResult.isSuccess(), 'Record not updated');
					}
				} catch (Exception oException) {
					System.assertEquals(null, oException.getMessage(), 'Error thrown');
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void updateObjPermissionError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Campaign oCampaign = (Campaign) new SObjectBuilder(Campaign.sObjectType).create().getRecord();
			oCampaign.Description = 'CHANGE';
			User oStandardUser = (User) new SObjectBuilder(User.sObjectType).create().getRecord();

			Test.startTest();
			System.runAs(oStandardUser) {
				try {
					Database.SaveResult[] lSaveResults = SObjectHelper.updateObj(oCampaign);
				} catch (SObjectHelperException.UpdatePermissionException oException) {
					System.assertEquals('User does not have permission to update Campaign Object', oException.getMessage(), 'Incorrect error thrown');
				} catch (Exception oException) {
					System.assertEquals(null, oException.getMessage(), 'Error thrown');
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void updateObjListIsEmptyError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			List<Contact> lContact = new List<Contact>();

			Test.startTest();
			try {
				Database.SaveResult[] lSaveResult = SObjectHelper.updateObj(lContact);
			} catch (SObjectHelperException.InvalidParameterException oException) {
				System.assertEquals(string.format('{0} cannot be null.', new List<string>{ 'oSObjects' }), oException.getMessage(), 'Incorrect error thrown');
			} catch (Exception oException) {
				System.assertEquals(null, oException.getMessage(), 'Error thrown');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void updateObjListIsNullError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			List<Contact> lContact = new List<Contact>();

			Test.startTest();
			try {
				Database.SaveResult[] lSaveResult = SObjectHelper.updateObj(lContact);
			} catch (SObjectHelperException.InvalidParameterException oException) {
				System.assertEquals(string.format('{0} cannot be null.', new List<string>{ 'oSObjects' }), oException.getMessage(), 'Incorrect error thrown');
			} catch (Exception oException) {
				System.assertEquals(null, oException.getMessage(), 'Error thrown');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void updateObjNullObjectError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Contact oContact;

			Test.startTest();
			try {
				Database.SaveResult[] lSaveResult = SObjectHelper.updateObj(oContact);
			} catch (SObjectHelperException.InvalidParameterException oException) {
				System.assertEquals(string.format('{0} cannot be null.', new List<string>{ 'sSObject' }), oException.getMessage(), 'Incorrect error thrown');
			} catch (Exception oException) {
				System.assertEquals(null, oException.getMessage(), 'Error thrown');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void deleteObj() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Contact oContact = (Contact) new SObjectBuilder(Contact.sObjectType).create().getRecord();
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					Database.DeleteResult[] lDeleteResults = SObjectHelper.deleteObj(oContact);
					for (Database.DeleteResult oDeleteResult : lDeleteResults) {
						System.assertEquals(true, oDeleteResult.isSuccess(), 'Record not deleted');
					}
				} catch (Exception oException) {
					System.assertEquals(null, oException.getMessage(), 'Error thrown');
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void deleteObjPermissionError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Campaign oCampaign = (Campaign) new SObjectBuilder(Campaign.sObjectType).create().getRecord();
			User oStandardUser = (User) new SObjectBuilder(User.sObjectType).create().getRecord();

			Test.startTest();
			System.runAs(oStandardUser) {
				try {
					Database.DeleteResult[] lDeleteResults = SObjectHelper.deleteObj(oCampaign);
				} catch (SObjectHelperException.DeletePermissionException oException) {
					System.assertEquals('User does not have permission to delete Campaign Object', oException.getMessage(), 'Incorrect error thrown');
				} catch (Exception oException) {
					System.assertEquals(null, oException.getMessage(), 'Error thrown');
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void deleteObjListisEmptyError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			List<Contact> lContact = new List<Contact>();

			Test.startTest();
			try {
				Database.DeleteResult[] lDeleteResult = SObjectHelper.deleteObj(lContact);
			} catch (SObjectHelperException.InvalidParameterException oException) {
				System.assertEquals(string.format('{0} cannot be null.', new List<string>{ 'oSObjects' }), oException.getMessage(), 'Incorrect error thrown');
			} catch (Exception oException) {
				System.assertEquals(null, oException.getMessage(), 'Error thrown');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void deleteObjListIsNullError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			List<Contact> lContact;

			Test.startTest();
			try {
				Database.DeleteResult[] lDeleteResult = SObjectHelper.deleteObj(lContact);
			} catch (SObjectHelperException.InvalidParameterException oException) {
				System.assertEquals(string.format('{0} cannot be null.', new List<string>{ 'oSObjects' }), oException.getMessage(), 'Incorrect error thrown');
			} catch (Exception oException) {
				System.assertEquals(null, oException.getMessage(), 'Error thrown');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void deleteObjNullObjectError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Contact oContact;

			Test.startTest();
			try {
				Database.DeleteResult[] lDeleteResult = SObjectHelper.deleteObj(oContact);
			} catch (SObjectHelperException.InvalidParameterException oException) {
				System.assertEquals(string.format('{0} cannot be null.', new List<string>{ 'sSObject' }), oException.getMessage(), 'Incorrect error thrown');
			} catch (Exception oException) {
				System.assertEquals(null, oException.getMessage(), 'Error thrown');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void upsertObjContact() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Contact oContact = new Contact();
			oContact.LastName = 'Gates';
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					Database.UpsertResult[] oUpsertResult = SObjectHelper.upsertObj(oContact);
					System.assertEquals(true, oUpsertResult[0].isSuccess(), 'Incorrect error thrown');
				} catch (Exception oException) {
					System.assertEquals(null, oException.getMessage(), 'Error thrown');
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void upsertObjContactNull() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					Contact nullSObject = null;
					Database.UpsertResult[] oUpsertResult = SObjectHelper.upsertObj(nullSObject);
					System.assertEquals(true, oUpsertResult[0].isSuccess(), 'Record not upserted');
				} catch (Exception oException) {
					System.assertEquals(
						String.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'sSObject' }),
						oException.getMessage(),
						'Incorrect error thrown'
					);
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void upsertObjContactNullList() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					List<Contact> nullSObjects = null;
					Database.UpsertResult[] oUpsertResult = SObjectHelper.upsertObj(nullSObjects);
					System.assertEquals(true, oUpsertResult[0].isSuccess(), 'Record not upserted');
				} catch (Exception oException) {
					System.assertEquals(
						String.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'sSObject' }),
						oException.getMessage(),
						'Incorrect error thrown'
					);
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void upsertObjContactError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Contact oContact;
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					Database.UpsertResult[] oUpsertResult = SObjectHelper.upsertObj(oContact);
				} catch (Exception oException) {
					System.assertEquals(
						string.format('{0} cannot be null.', new List<string>{ 'sSObject' }),
						oException.getMessage(),
						'Incorrect error message'
					);
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void insertObjError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Contact oContact;
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					Database.SaveResult[] oUpsertResult = SObjectHelper.insertObj(oContact);
				} catch (Exception oException) {
					System.assertEquals(
						string.format('{0} cannot be null.', new List<string>{ 'sSObject' }),
						oException.getMessage(),
						'Incorrect error message'
					);
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void updateObjError() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Launchpad__Enrollment__c enroll;
			//oContact.LastName='Gates';
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					Database.UpsertResult[] oUpsertResult = SObjectHelper.upsertObj(enroll);
				} catch (Exception oException) {
					System.assertEquals(
						string.format('{0} cannot be null.', new List<string>{ 'sSObject' }),
						oException.getMessage(),
						'Incorrect error message'
					);
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void upsertObjPermissionErrorContact() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Contact oContact = new Contact();

			oContact.LastName = 'Gates';
			User oStandardUser = (User) new SObjectBuilder(User.sObjectType).create().getRecord();

			Test.startTest();
			System.runAs(oStandardUser) {
				try {
					Database.UpsertResult[] lUpsertResult = SObjectHelper.upsertObj(oContact);
				} catch (SObjectHelperException.UpsertPermissionException oException) {
					System.assertEquals('User does not have permission to upsert Contact Object', oException.getMessage(), 'Incorrect error message');
				} catch (Exception oException) {
					System.Debug(oException.getMessage());
					//System.assertEquals(null, oException.getMessage());
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void sObjectHelperExceptionMethods() {
		createNonSetupObjectRecords();

		Exception exception1;
		Exception exception2;
		Exception exception3;
		Exception exception4;
		Exception exception5;

		System.runAs(getAdminUser()) {
			Test.startTest();
			exception1 = SObjectHelperException.queryPermissionException('Contact');
			exception2 = SObjectHelperException.insertPermissionException('Contact');
			exception3 = SObjectHelperException.updatePermissionException('Contact');
			exception4 = SObjectHelperException.deletePermissionException('Contact');
			exception5 = SObjectHelperException.upsertPermissionException('Contact');
			Test.stopTest();
		}

		Assert.isNotNull(exception1, 'No exception returned');
		Assert.isNotNull(exception2, 'No exception returned');
		Assert.isNotNull(exception3, 'No exception returned');
		Assert.isNotNull(exception4, 'No exception returned');
		Assert.isNotNull(exception5, 'No exception returned');
	}

	@isTest
	static void upsertObjEnrollment() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Launchpad__Program__c prg = new Launchpad__Program__c(Name = 'prg1');
			insert prg;
			Contact c = new Contact(LastName = 'TestLastName');
			insert c;
			Launchpad__Enrollment__c e = new Launchpad__Enrollment__c(
				Launchpad__Client__c = c.id,
				Launchpad__Enrollment_Date__c = Date.today(),
				Launchpad__Program__c = prg.id
			);
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					Database.UpsertResult[] oUpsertResult = SObjectHelper.upsertObj(e);
					System.assertEquals(true, oUpsertResult[0].isSuccess(), 'Record not upserted');
				} catch (Exception oException) {
					System.assertEquals(null, oException.getMessage(), 'Error thrown');
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void upsertObjEnrollmentNull() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					Launchpad__Enrollment__c nullSObject = null;
					Database.UpsertResult[] oUpsertResult = SObjectHelper.upsertObj(nullSObject);
					System.assertEquals(true, oUpsertResult[0].isSuccess(), 'Record not upserted');
				} catch (Exception oException) {
					System.assertEquals(
						String.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'sSObject' }),
						oException.getMessage(),
						'Incorrect error thrown'
					);
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void upsertObjEnrollmentNullList() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			User oSystemAdministratorUser = (User) new SObjectBuilder(User.sObjectType)
				.put(User.ProfileId, SObjectFactory.provideAdminProfile())
				.create()
				.getRecord();

			Test.startTest();
			System.runAs(oSystemAdministratorUser) {
				try {
					List<Launchpad__Enrollment__c> nullSObjects = null;
					Database.UpsertResult[] oUpsertResult = SObjectHelper.upsertObj(nullSObjects);
					System.assertEquals(true, oUpsertResult[0].isSuccess(), 'Record not upserted');
				} catch (Exception oException) {
					System.assertEquals(
						String.format(SObjectHelperException.NULLPARAMETERERROR, new List<string>{ 'sSObject' }),
						oException.getMessage(),
						'Incorrect error thrown'
					);
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	static void upsertObjPermissionErrorEnrollment() {
		createNonSetupObjectRecords();

		System.runAs(getAdminUser()) {
			Launchpad__Program__c prg = new Launchpad__Program__c(Name = 'prg1');
			insert prg;
			Contact c = new Contact(LastName = 'TestLastName');
			insert c;
			Launchpad__Enrollment__c e = new Launchpad__Enrollment__c(
				Launchpad__Client__c = c.id,
				Launchpad__Enrollment_Date__c = Date.today(),
				Launchpad__Program__c = prg.id
			);

			User oStandardUser = (User) new SObjectBuilder(User.sObjectType).create().getRecord();

			Test.startTest();
			System.runAs(oStandardUser) {
				try {
					Database.UpsertResult[] lUpsertResult = SObjectHelper.upsertObj(e);
				} catch (SObjectHelperException.UpsertPermissionException oException) {
					String actualMessage = oException.getMessage();
					Boolean expectedMessageContained = actualMessage.contains('User does not have permission to upsert Launchpad__Enrollment__c');
					System.assertEquals(true, expectedMessageContained, 'The expected exception was not thrown.');
				} catch (Exception oException) {
					System.Debug(oException.getMessage());
					System.assertEquals(null, oException.getMessage(), 'Error thrown');
				}
			}
			Test.stopTest();
		}
	}

	@isTest
	private static void canQueryObjBlank() {
		createNonSetupObjectRecords();

		String obj;

		Exception thrownException;
		Test.startTest();
		try {
			SObjectHelper.canQueryObj(obj);
		} catch (Exception e) {
			thrownException = e;
		}
		Test.stopTest();

		System.assert(thrownException != null, 'No exception was thrown');
	}

	@isTest
	private static void isObjectCreateable() {
		createNonSetupObjectRecords();

		String obj = 'Account';

		Test.startTest();
		Boolean canQuery = SObjectHelper.isObjectCreateable(obj);
		Test.stopTest();

		System.assert(canQuery, 'Did not return true');
	}

	@isTest
	private static void isObjectDeletable() {
		createNonSetupObjectRecords();

		String obj = 'Account';

		Test.startTest();
		Boolean canQuery = SObjectHelper.isObjectDeletable(obj);
		Test.stopTest();

		System.assert(canQuery, 'Did not return true');
	}

	@isTest
	private static void objInsertList() {
		createNonSetupObjectRecords();

		Account account = (Account) new SObjectBuilder(Account.sObjectType).build().getRecord();

		Test.startTest();
		List<Account> accounts = SObjectHelper.objInsert(new List<Account>{ account });
		Test.stopTest();

		System.assertEquals(1, accounts.size(), 'Did not return exactly 1 account');
		System.assert(accounts[0].Id != null, 'Did not insert the account');
	}

	@isTest
	private static void objInsertListEmptyList() {
		createNonSetupObjectRecords();

		Test.startTest();
		List<Account> accounts = SObjectHelper.objInsert(new List<Account>());
		Test.stopTest();

		System.assertEquals(0, accounts.size(), 'Did not return an empty list');
	}

	@isTest
	private static void objUpdateList() {
		createNonSetupObjectRecords();

		Account account = (Account) new SObjectBuilder(Account.sObjectType).create().getRecord();

		String updatedName = 'Updated Name';
		account.Name = updatedName;

		Test.startTest();
		List<Account> accounts = SObjectHelper.objUpdate(new List<Account>{ account });
		Test.stopTest();

		System.assertEquals(1, accounts.size(), 'Did not return exactly 1 account');
		System.assertEquals(updatedName, accounts[0].Name, 'Did not update the account');
	}

	@isTest
	private static void objUpsertList() {
		createNonSetupObjectRecords();

		Account oldAccount = (Account) new SObjectBuilder(Account.sObjectType).create().getRecord();

		String updatedName = 'Updated Name';
		oldAccount.Name = updatedName;

		Account newAccount = (Account) new SObjectBuilder(Account.sObjectType).build().getRecord();

		Test.startTest();
		List<Account> accounts = SObjectHelper.objUpsert(new List<Account>{ oldAccount, newAccount });
		Test.stopTest();

		System.assertEquals(2, accounts.size(), 'Did not return exactly 2 accounts');
	}

	@isTest
	private static void objInsert() {
		createNonSetupObjectRecords();

		Account account = (Account) new SObjectBuilder(Account.sObjectType).build().getRecord();

		Test.startTest();
		account = (Account) SObjectHelper.objInsert(account);
		Test.stopTest();

		System.assert(account.Id != null, 'Did not insert the account');
	}

	@isTest
	private static void objUpdate() {
		createNonSetupObjectRecords();

		Account account = (Account) new SObjectBuilder(Account.sObjectType).create().getRecord();

		String updatedName = 'Updated Name';
		account.Name = updatedName;

		Test.startTest();
		account = (Account) SObjectHelper.objUpdate(account);
		Test.stopTest();

		System.assertEquals(updatedName, account.Name, 'Did not update the account');
	}

	@isTest
	private static void objUpsert() {
		createNonSetupObjectRecords();

		Account account = (Account) new SObjectBuilder(Account.sObjectType).build().getRecord();

		Test.startTest();
		account = (Account) SObjectHelper.objUpsert(account);
		Test.stopTest();

		System.assert(account.Id != null, 'Did not upsert the account');
	}

	@isTest
	private static void isInsertable() {
		createNonSetupObjectRecords();

		Account account = (Account) new SObjectBuilder(Account.sObjectType).build().getRecord();

		String obj = 'Account';

		Test.startTest();
		Boolean isInsertable = SObjectHelper.isInsertable(account, obj);
		Test.stopTest();

		System.assert(isInsertable, 'Did not return true');
	}

	// * TEST SETUP
	@TestSetup
	static void makeData() {
		createSetupObjectRecords();
	}

	// * HELPER METHODS

	private static void createNonSetupObjectRecords() {
		Labor_Exchange_Community_Setup__c lexCommunitySetup = new Labor_Exchange_Community_Setup__c(
			Events_Page_URL__c = 'www.google.com',
			Jobs_Page_URL__c = 'www.google.com',
			of_Tiles_Per_Page__c = 6,
			ContactRecordTypes__c = 'Employer',
			Eligible_Open_Job_Stages__c = 'Open',
			LEX_Community_Profile_Id__c = [SELECT Id FROM Profile WHERE Name = 'Customer Community User' LIMIT 1][0]
			.Id,
			LEX_Community_Permission_Set_Id__c = [SELECT Id FROM PermissionSet WHERE Name = 'Labor_Exchange_User_Permissions' LIMIT 1][0]
			.Id
		);
		insert lexCommunitySetup;
	}

	private static void createSetupObjectRecords() {
		UserRole ownerRole = new UserRole(Name = 'Owner Role');
		insert ownerRole;

		User adminUser = new User();
		adminUser.FirstName = 'Admin ';
		adminUser.LastName = 'User';
		adminUser.Email = 'admin@example.com';
		adminUser.Username = 'Admin' + Math.random() * 100 + '@lp.com';
		adminUser.Alias = 'admin';
		adminUser.CommunityNickname = 'admin';
		adminUser.TimeZoneSidKey = 'America/Los_Angeles';
		adminUser.LocaleSidKey = 'en_US';
		adminUser.EmailEncodingKey = 'UTF-8';
		adminUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
		adminUser.LanguageLocaleKey = 'en_US';
		adminUser.IsActive = true;
		adminUser.UserRoleId = ownerRole.Id;

		insert adminUser;
	}

	private static User getAdminUser() {
		return [
			SELECT Id
			FROM User
			WHERE Profile.Name LIKE 'System Administrator' AND Email = 'admin@example.com'
			LIMIT 1
		];
	}
}