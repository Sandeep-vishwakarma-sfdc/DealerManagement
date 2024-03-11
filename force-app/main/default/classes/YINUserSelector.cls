/**
 * @description       : This class provides methods to select and query User records.
 * @author            : Saurabh Pandey
 * @group             : 
 * @last modified on  : 02-14-2024
 * @last modified by  : saurabh.pandey@skinternational.com
 **/
public with sharing class YINUserSelector extends LibSObjectSelector {

    /**
     * @Description - Constructor for UserSelector class.
     */
    public YINUserSelector() {
        super(true, false, false, false);
    }

    /**
     * @Description - Gets the SObjectType for User records.
     * @return Schema.SObjectType : User object type.
     */
    public Schema.SObjectType getSObjectType() {
        return User.SObjectType;
    }

    /**
     * @Description - Gets a list of SObject fields for User records.
     * @return List<Schema.SObjectField> : List of SObject fields.
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            User.Id,
            User.Name,
            User.ProfileId,
            User.Email,
            User.Profile.Name,
            User.contactId,
            User.TimeZoneSidKey,
            User.AccountId 
        };
    }

    /**
     * @Description - Retrieves a list of all User records.
     * @return List<User> : List of User records.
     */
    public List<User> getAllUsers() {
        return Database.query(
            newQueryFactory()
                .toSOQL()
        );
    }

    /**
     * @Description - Retrieves a list of User records for specific profiles (GMs - General Managers).
     * @return List<User> : List of User records.
     */
    public List<User> getUsersForGM() {
        return Database.query(
            newQueryFactory()
                .setCondition('Profile.Name IN (\'BDM (Beverages)\', \'RKAM (Beverages)\', \'NKAM (Beverages)\')')
                .toSOQL()
        );
    }

    /**
     * @Description - Retrieves a User record by its ID.
     * @param usr_id : ID of the User to retrieve.
     * @return List<User> : List containing a single User record.
     */
    public List<User> getUserbyId(String usr_id) 
    {
        return Database.query(
            newQueryFactory()
                .selectField('Profile.Name')
                .setCondition('Id = :usr_id')
                //.setLimit(1)
                .toSOQL()
        );
    }

    
    public List<User> currentUser(String usr_id) {
        return Database.query(
            newQueryFactory()
                .setCondition('Id = :usr_id')
                //.setLimit(1)
                .toSOQL()
        );
    }

    /**
     * @Description - Retrieves a list of User records by matching profile name (RKAM).
     * @param profile : Profile name to match.
     * @return List<User> : List of User records.
     */
    public List<User> getRkamUser(String profile) {
        String p = '%' + profile + '%';
        return Database.query(
            newQueryFactory()
                .setCondition('Profile.Name LIKE :p')
               // .setLimit(2)
                .toSOQL()
        );
    }

    /**
     * @Description - Retrieves a list of User records by matching profile name (NKAM).
     * @param profile : Profile name to match.
     * @return List<User> : List of User records.
     */
    public List<User> getNkamUser(String profile) {
        String p = '%' + profile + '%';
        return Database.query(
            newQueryFactory()
                .setCondition('Profile.Name LIKE :p')
                //.setLimit(1)
                .toSOQL()
        );
    }

    public List<User> getUsersByManager(String userId){ // Nik....
        return Database.query(
                newQueryFactory()
                        .selectField('ManagerId')
                        .setCondition('ManagerId =: userId')
                        //.setLimit(10)
                        .toSOQL()
        );
    }

    /**
     * @author - Nikhil Dhoke
     * @Description - Retrieves a user's account details.
     * @param String userid: user id.
     * @return User : User record with account details.
     */
    public User getUserAccountDetails(String userId){
        return Database.query(
                newQueryFactory()
                        .selectField('Contact')
                        .selectField('Contact.AccountId')
                        .selectField('Contact.Account.Name')
                        .selectField('Contact.Account.Contact_Person_Phone__c')
                        .selectField('Contact.Account.ERP_Customer_Code__c')
                        .selectField('Contact.Account.City__r.Name')
                        .selectField('Contact.Account.State__r.Name')
                        .selectField('Contact.Account.RecordTypeId')
                        .selectField('Contact.Account.RecordType.Name')
                        .selectField('Contact.Account.Account_4S__c')
                        .setCondition('Id =: userId')
                        .setLimit(1)
                        .toSOQL()
        );
    }

}