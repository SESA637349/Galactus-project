public without sharing class CaseTriggerHandler {
    public static void assignPersonnel(List<Case> caseList){
        ID newID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Device').getRecordTypeId();
        String skill;
        for(Case c: caseList){
            if(String.isNotBlank(c.Product2__c)){
                skill = [Select id, Machine_Type__c from Product2 where id=:c.Product2__c limit 1].Machine_Type__c;
            }
            else{
                Asset ast = [Select id, Product2.Machine_Type__c from Asset where id=:c.AssetId limit 1];
                skill = ast.Product2.Machine_Type__c;
            }
            if(c.Level__c == 1 || c.Level__c == null){
                if(c.RecordTypeId == newID){
                    Personnel__c docPers = [Select ID from Personnel__c where Resource_Type__c = 'Doctor' AND Skill_Type__c=:skill limit 1];
                    c.Assigned_To__c = docPers.ID;
                }
                else{
                    Personnel__c techPers = [Select ID from Personnel__c where Level__c = 1 AND Resource_Type__c = 'Technician' AND Skill_Type__c=:skill limit 1];
                    c.Assigned_To__c = techPers.ID;
                }
                c.Level__c = 1;
            }
            c.Case_Date__c = System.today();
        }
    }

    public static void addAsset(List<Case> caseList){
        List<Asset> assetList = new List<Asset>();
        List<Case> updateCaseList = new List<Case>();
        Asset ast;
        ID newID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Device').getRecordTypeId();
        ID ndClosedId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ND Closed').getRecordTypeId();
        ID closedID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Closed').getRecordTypeId();
        ID installID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Installation').getRecordTypeId();
        Case updateCase;
        Case newCase;
        for(Case c: caseList){
            if(c.Status.equalsIgnoreCase('Approved') && c.RecordTypeId==newID){
                Product2 pro = [Select id, name, Price__c from Product2 where Id=:c.Product2__c];
                updateCase = new Case();
                updateCase.id = c.id;        
                ast = new Asset();
                ast.Name = pro.Name;
                ast.Status = 'Purchased';
                ast.PurchaseDate = System.today();
                ast.Quantity = 1;
                ast.Price = pro.Price__c;
                ast.Product2Id = pro.Id;
                ast.AccountId = c.AccountId;
                ast.Active__c = true;
                ast.SerialNumber = AssetTriggerHelper.generateSerialNumber();
                assetList.add(ast);
                updateCase.RecordTypeId = ndClosedId;
            }
            else if(c.Status.equalsIgnoreCase('Completed') && c.RecordTypeId != newID){
                updateCase = new Case();
                updateCase.id = c.id;
                updateCase.RecordTypeId = closedID;
            }
            updateCaseList.add(updateCase);
        }
        if(!assetList.isEmpty()){
            insert assetList;
            
            newCase = new Case();
            newCase.RecordTypeId = installID;
            newCase.Status = 'New';
            newCase.Priority = 'Medium';
            newCase.Subject = 'Installation of ' + assetList[0].Name;
            newCase.AccountId = assetList[0].AccountId;
            newCase.AssetId = assetList[0].Id;
            insert newCase;
        }
        if(!updateCaseList.isEmpty()){
            update updateCaseList;
        }
    }

    /* public static void addInstallCase(List<Case> caseList){
        List<case> newCaseList = new List<Case>();
        for(Case c: caseList){
            if(c.Status.equalsIgnoreCase('Approved') && c.RecordTypeId==newID){
                Product2 pro = [Select id, name, Price__c from Product2 where Id=:c.Product2__c];
                newCase = new Case();
                newCase.id = c.id;        
                ast = new Asset();
                ast.Name = pro.Name;
                ast.Status = 'Purchased';
                ast.PurchaseDate = System.today();
                ast.Quantity = 1;
                ast.Price = pro.Price__c;
                ast.Product2Id = pro.Id;
                ast.AccountId = c.AccountId;
                ast.Active__c = true;
                ast.SerialNumber = AssetTriggerHelper.generateSerialNumber();
                assetList.add(ast);
                newCase.RecordTypeId = ndClosedId;
            }
            else if(c.Status.equalsIgnoreCase('Completed') && c.RecordTypeId != newID){
                newCase.RecordTypeId = closedID;
            }
            updateCaseList.add(newCase);
        }
        if(!newCaseList.isEmpty()){
            insert newCaseList;
        }
    } */

    public static void createWorkOrder(List<Case> caseList){
        List<WorkOrder> woList = new List<WorkOrder>();
        WorkOrder wo;
        Case cs;
        String astName;
        ID newID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Device').getRecordTypeId();
        for(Case c: caseList){
            List<WorkOrder> existWOList = [Select id, WorkOrderNumber from WorkOrder where CaseId=:c.Id];
            String rtName = [select id, Name from RecordType where Id=:c.RecordTypeId limit 1].Name;
            if(String.isNotBlank(c.AssetId)){
                astName = [Select Id, name from Asset where id=:c.AssetId limit 1].Name;
            }
            //cs = oldMap.get(c.Id);
            if(existWOList.isEmpty() && c.Status.equalsIgnoreCase('New') && c.RecordTypeId != newID){
                wo = new WorkOrder();
                wo.Status = 'New';
                wo.Priority = 'Medium';
                wo.AccountId = c.AccountId;
                wo.CaseId = c.Id;
                wo.AssetId = c.AssetId;
                wo.Personnel__c = c.Assigned_To__c;
                wo.Subject = rtName + ' of ' + astName;
                woList.add(wo);
            }
        }
        if(!woList.isEmpty()){
            insert woList;
        }
    }

    public static void sendMail(List<Case> caseList, Map<ID, Case> oldMap, Boolean isUpdate){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Case cs;
        String[] toAddress = new String[]{'hasnain.mudassir@mscsa.christuniversity.in'};
        String mail;
        String ticket;
        for(Case c:caseList){
            if(!isUpdate){
                mail = [Select id, Email__c from Personnel__c where Id=:c.Assigned_To__c limit 1].Email__c;
                toAddress.add(mail);
                ticket = c.CaseNumber;
            }
            else{
                cs = oldMap.get(c.Id);
                if(!String.valueof(c.Assigned_To__c).equalsIgnoreCase(String.valueof(cs.Assigned_To__c))){
                    mail = [Select id, Email__c from Personnel__c where Id=:c.Assigned_To__c limit 1].Email__c;
                    toAddress.add(mail);
                    ticket = c.CaseNumber;
                }
            }
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddress);
        
        String htmlbody = '<br/>Hello there,<br/><br/>'
            + 'The ticket number ' + ticket + ' is assigned to you, please take action on this matter before 48 hrs of the ticket creation, or re-assign it, in case of your unavailability.'
            + '<br/><br/>Thank You,'
            + '<br/>Team Galactus';

        email.setHtmlBody(htmlbody);
        email.setSubject('Ticket Assignment');
        email.setSaveAsActivity(false);
        emailList.add(email);
        Messaging.SendEmailResult[] r = Messaging.sendEmail(emailList);
    }

    public static void updateInstallDate(List<Case> caseList){
        List<Asset> astList = new List<Asset>();
        ID newID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Device').getRecordTypeId();
        for(Case c:caseList){
            if(c.status=='Completed' && String.isNotBlank(c.AssetId) && c.RecordTypeId!=newID){
                Asset ast = [Select id, installdate from asset where id=:c.AssetId];
                ast.installdate = System.today();
                astList.add(ast);
            }
        }
        if(!astList.isEmpty()){
            update astList;
        }
    }
}