class Notifs{
    int? enableNotif;

    Notifs({this.enableNotif});

    Notifs.fromMap(Map map){
      this.enableNotif = map['enableNotif'];
    }

    Map<String, Object?> toMap(){
      return{
        'enableNotif': this.enableNotif!
      };
    }

    String toString(){
      if(enableNotif == 1){
        return "Notifications Enabled";
      }
      return "Notifications not Enabled";
    }
}