trigger CaseTrigger on Case (before insert, after insert, after update) {
    if(Trigger.isBefore){
        CaseTriggerHandler.assignPersonnel(Trigger.New);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        CaseTriggerHandler.createWorkOrder(Trigger.New);
        //CaseTriggerHandler.sendMail(Trigger.New, null, Trigger.isUpdate);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        CaseTriggerHandler.addAsset(Trigger.New);
        //CaseTriggerHandler.addInstallCase(Trigger.New);
        //CaseTriggerHandler.sendMail(Trigger.New, Trigger.oldMap, Trigger.isUpdate);
        CaseTriggerHandler.updateInstallDate(Trigger.New);
    }
}