public without sharing class WorkOrderTriggerHandler {
    public static void assignPersonnel(List<WorkOrder> woList){
        Personnel__c pers = [Select ID from Personnel__c where Resource_Type__c != 'Doctor' ORDER BY Name limit 1];
        for(WorkOrder c: woList){
            c.Personnel__c = pers.ID;
        }
    }
    public static void completeCase(List<WorkOrder> woList){
        List<case> csList = new List<case>();
        Case cs;
        for(WorkOrder wo: woList){
            cs = [Select id, status from Case where Id=:wo.CaseId limit 1];
            cs.status = 'Completed';
            csList.add(cs);
        }
        if(!csList.isEmpty()){
            update csList;
        }
    }
    
}