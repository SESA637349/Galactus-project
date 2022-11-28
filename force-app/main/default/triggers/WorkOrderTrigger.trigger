trigger WorkOrderTrigger on WorkOrder (after update) {
    /* if(Trigger.isBefore){
        WorkOrderTriggerHandler.assignPersonnel(Trigger.New);
    } */
    WorkOrderTriggerHandler.completeCase(Trigger.New);
}