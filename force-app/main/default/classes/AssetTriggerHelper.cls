public without sharing class AssetTriggerHelper {
    public static void addSerialNumber(List<Asset> assetList){
        for(Asset a: assetList){
            a.SerialNumber = generateSerialNumber();
        }
    }
    public static String generateSerialNumber(){
        //final String chars = 'xaxPmno2IDdEwLzbtEvhv6oG1RDT6xQJX3MvF4amaDQ9TUvHgJfdbodlllPTnnuw';
        string chars = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890';
        Integer len = 10;        
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        System.debug(randStr);
        return randStr;
    }
}