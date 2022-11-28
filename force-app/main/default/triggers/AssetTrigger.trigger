trigger AssetTrigger on Asset (before insert) {
    AssetTriggerHelper.addSerialNumber(Trigger.New);
}