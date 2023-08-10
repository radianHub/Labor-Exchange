public virtual class SObjectHelperException extends Exception {
	public virtual class InsertPermissionException extends SOBjectHelperException {
	}
	public virtual class UpdatePermissionException extends SOBjectHelperException {
	}
	public virtual class DeletePermissionException extends SOBjectHelperException {
	}
	public virtual class UpsertPermissionException extends SOBjectHelperException {
	}
	public virtual class QueryPermissionException extends SOBjectHelperException {
	}
	public virtual class InvalidParametersException extends SOBjectHelperException {
	}
	public virtual class InvalidQueryException extends SObjectHelperException {
	}
	public virtual class InvalidParameterException extends SObjectHelperException {
	}
	public virtual class NullPointerException extends SObjectHelperException {
	}
	public virtual class InvalidIdException extends SObjectHelperException {
	}
	public virtual class DMLException extends SObjectHelperException {
	}

	//Declare all the user friendly error msgs heree...
	public static final String QUERY_PERMISSION_EXCEPTION_MSG = system.label.SObjectHelper_Error_NoQueryPermission;
	public static final String INSERT_PERMISSION_EXCEPTION_MSG = system.label.SObjectHelper_Error_NoInsertPermission;
	public static final String UPDATE_PERMISSION_EXCEPTION_MSG = system.label.SObjectHelper_Error_NoUpdatePermission;
	public static final String DELETE_PERMISSION_EXCEPTION_MSG = system.label.SObjectHelper_Error_NoDeletePermission;
	public static final String UPSERT_PERMISSION_EXCEPTION_MSG = system.label.SObjectHelper_Error_NoUpsertPermission;
	public static final String ADMIN_MSG = system.label.SObjectHelper_Admin_Msg;
	public static final String NULLPARAMETERERROR = system.label.SObjectHelper_Error_Null;
	public static final String OBJECT_STR = 'Object';
	/**
	 * @description Construct the exception msg
	 * @param String - Object Name
	 * @return SObjectHelperException.QueryPermissionException
	 */
	public static SObjectHelperException.QueryPermissionException queryPermissionException(String objName) {
		return new SObjectHelperException.QueryPermissionException(
			String.format(QUERY_PERMISSION_EXCEPTION_MSG + ' {0} ' + ADMIN_MSG, new List<String>{ objName })
		);
	}

	/**
	 * @description Construct the exception msg
	 * @param String - Object Name
	 * @return SObjectHelperException.InsertPermissionException
	 */
	public static SObjectHelperException.InsertPermissionException insertPermissionException(String objName) {
		return new SObjectHelperException.InsertPermissionException(
			String.format(SObjectHelperException.INSERT_PERMISSION_EXCEPTION_MSG + ' into {0} ', new List<String>{ objName })
		);
	}

	/**
	 * @description Construct the exception msg
	 * @param String - Object Name
	 * @return SObjectHelperException.UpdatePermissionException
	 */
	public static SObjectHelperException.UpdatePermissionException updatePermissionException(String objName) {
		return new SObjectHelperException.UpdatePermissionException(String.format(UPDATE_PERMISSION_EXCEPTION_MSG + ' of {0} ', new List<String>{ objName }));
	}

	/**
	 * @description Construct the exception msg
	 * @param String - Object Name
	 * @return SObjectHelperException.DeletePermissionException
	 */
	public static SObjectHelperException.DeletePermissionException deletePermissionException(String objName) {
		return new SObjectHelperException.DeletePermissionException(
			String.format(SObjectHelperException.DELETE_PERMISSION_EXCEPTION_MSG + ' of {0} ', new List<String>{ objName })
		);
	}

	/**
	 * @description Construct the exception msg
	 * @param String - Object Name
	 * @return SObjectHelperException.DeletePermissionException
	 */
	public static SObjectHelperException.UpsertPermissionException upsertPermissionException(String objName) {
		return new SObjectHelperException.UpsertPermissionException(
			String.format(SObjectHelperException.UPSERT_PERMISSION_EXCEPTION_MSG + ' into {0} ', new List<String>{ objName })
		);
	}
}