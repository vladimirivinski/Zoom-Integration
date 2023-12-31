@isTest
public with sharing class ZoomTestDataFactory {
    public static User createUser(String prof, String email) {
        CallCenter cc = [SELECT Id FROM CallCenter LIMIT 1];
        Profile profId = [SELECT Id FROM Profile WHERE Name = :prof LIMIT 1];
        User usr = new User();
        usr.Email = 'testuser' + email;
        usr.Username = 'testuser' + email;
        usr.FirstName = 'Test';
        usr.LastName = 'User';
        usr.Alias = 'tuser';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.isActive = true;
        usr.ProfileId = profId.Id;
        usr.CallCenterId = cc.Id;
        insert usr;
        return usr;
    }

    public static List<User> createListUsers(Integer count, String prof, String email) {
        CallCenter cc = [SELECT Id, name FROM CallCenter LIMIT 1];
        Profile profId = [SELECT Id FROM Profile WHERE Name = :prof LIMIT 1];
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < count; i++) {
            User usr = new User();
            usr.Email = 'testuser' + i + email;
            usr.Username = 'testuser' + i + email;
            usr.FirstName = 'Test' + i;
            usr.LastName = 'User ' + i;
            usr.Alias = 'tuser' + i;
            usr.TimeZoneSidKey = 'America/Los_Angeles';
            usr.LocaleSidKey = 'en_US';
            usr.EmailEncodingKey = 'UTF-8';
            usr.LanguageLocaleKey = 'en_US';
            usr.isActive = true;
            usr.ProfileId = profId.Id;
            usr.CallCenterId = cc.Id;
            testUsers.add(usr);
        }
        insert testUsers;
        return testUsers;
    }

    public static List<Zoom_Users_Info__c> createListZoomUsersInfo(Integer count, String prof, String email) {
        createListUsers(count, prof, email);
        List<User> usrLst = [SELECT Id, Name, Email FROM User WHERE Email LIKE :'%testuser%'];
        List<Zoom_Users_Info__c> zoomUsersInfo = new List<Zoom_Users_Info__c>();
        List<String> statuses = new List<String>{ 'Available', 'Away', 'In_Calendar_Event', 'In_Meeting', 'Offline', 'On_Phone_Call', 'Presenting', 'Do_Not_Disturb' };
        for (Integer i = 0; i < count; i++) {
            Zoom_Users_Info__c zoomUser = new Zoom_Users_Info__c();
            zoomUser.User__c = usrLst[i].Id;
            zoomUser.Email__c = usrLst[i].Email;
            zoomUser.Name = usrLst[i].Name;
            zoomUser.Presence_Status__c = statuses[i];
            zoomUser.Status_Updated__c = DateTime.now();
            zoomUser.Tracking_Date__c = Date.today();
            zoomUser.Available__c = 0;
            zoomUser.Away__c = 0;
            zoomUser.In_Calendar_Event__c = 0;
            zoomUser.In_Meeting__c = 0;
            zoomUser.Offline__c = 0;
            zoomUser.On_Phone_Call__c = 0;
            zoomUser.Presenting__c = 0;
            zoomUser.Do_Not_Disturb__c = 0;
            zoomUsersInfo.add(zoomUser);
        }
        insert zoomUsersInfo;
        return zoomUsersInfo;
    }
}