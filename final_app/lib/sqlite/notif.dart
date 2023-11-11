class Notifs{
    int? enableNotif;

    Notifs({bool notificationEnabled = false}) : enableNotif = notificationEnabled ? 1 : 0;

    Notifs.fromMap(Map map){
      this.enableNotif = map['enableNotif'];
    }

    Map<String, Object?> toMap(){
      return{
        'enableNotif': this.enableNotif!
      };
    }

    @override
    String toString(){
      if(enableNotif == 1){
        return "Notifications Enabled";
      }
      return "Notifications not Enabled";
    }
}