public with sharing class DeactivateAccount {
    public static void deactivate(String recId){
        Account acc = [Select id, Active__c from account where id=:recId limit 1];
        acc.Active__c = 'No';
        update acc;
    }
}