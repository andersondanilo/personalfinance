// Generated by CoffeeScript 1.7.1
(function() {
  var AlarmManager, Parcel, notificationService;

  Parcel = requirejs('models/parcel');

  notificationService = requirejs('services/parcel');

  AlarmManager = requirejs('components/alarm_manager');

  describe('AlarmManager', function() {
    return it('Should trigger alarm', function(done) {
      var alarmManager, events, mozAlarm;
      events = _.extend({}, Backbone.Events);
      alarmManager = AlarmManager(events);
      mozAlarm = {
        'id': 5,
        'date': new Date(),
        'data': 'olá'
      };
      alarmManager.triggerAlarm(mozAlarm);
      return events.on('alarm', function(alarmObj) {
        expect(alarmObj.getId()).to.be.eql(mozAlarm.id);
        expect(alarmObj.getDate()).to.be.eql(mozAlarm.date);
        expect(alarmObj.getData()).to.be.eql(mozAlarm.data);
        return done();
      });
    });
  });

}).call(this);