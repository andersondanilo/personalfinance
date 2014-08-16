
Parcel = requirejs 'models/parcel'
notificationService = requirejs 'services/notification'
dateService = requirejs 'services/date'
AlarmManager = requirejs 'components/alarm_manager'
ParcelCollection    = requirejs 'collections/parcel'

parcelCollection = new ParcelCollection
'''
describe 'AlarmManager', ->

  it 'Should trigger alarm', (done) ->
    events = _.extend {}, Backbone.Events
    alarmManager = new AlarmManager(events)
    mozAlarm = {
      'id': 5,
      'date': new Date(),
      'data': 'olá'
    }

    events.on 'alarm', (alarmObj) ->
      expect(alarmObj.getId()).to.be.eql(mozAlarm.id)
      expect(alarmObj.getDate()).to.be.eql(mozAlarm.date)
      expect(alarmObj.getData()).to.be.eql(mozAlarm.data)
      done()

    alarmManager.triggerAlarm mozAlarm

  it 'Should add alarm', (done) ->
    @timeout(3000)
    events = _.extend {}, Backbone.Events
    alarmManager = new AlarmManager(events)
    date = new Date()
    date.setSeconds(date.getSeconds()+2)
    alarmManager.add date, 'Olá', (alarmId) ->
      expect(Number(alarmId)).to.be.at.least(1)
      events.on 'alarm', (alarmObj) ->
        expect(alarmObj.getId()).to.be.eql(alarmId)
        expect(alarmObj.getDate()).to.be.eql(date)
        expect(alarmObj.getData()).to.be.eql('Olá')
        done()

  it 'Should dalete alarm', (done) ->
    @timeout(4000)
    events = _.extend {}, Backbone.Events
    alarmManager = new AlarmManager(events)
    date = new Date()
    date.setSeconds(date.getSeconds()+2)
    count = 0
    alarmManager.add date, 'Olá', (alarmId) ->
      expect(Number(alarmId)).to.be.at.least(1)
      alarmManager.delete(alarmId)

      events.on 'alarm', (alarmObj) ->
        count += 1

      setTimeout(->
        expect(count).to.be.eql(0)
        done()
      , 2500)

'''
describe 'NotificationService', ->

  it 'Should create alarm', (done) ->
    @timeout(8000)
    require ['app'], (app) ->
      date = new Date
      date.setDate date.getDate()+1
      date.setSeconds date.getSeconds() + 2
      dateAlarm = new Date
      dateAlarm.setSeconds date.getSeconds() + 2
      parcel = new Parcel {
        description: 'Cartao'
        date: dateService.format 'YYYY-MM-DD', date
        movement_type: 'income'
        movement_id: 1,
        parcel_number: 1,
        value: 10
      }

      app.events.on 'notification', (notification) ->
        expect(notification.title).to.have.string('Cartao')
        done()

      parcel.save parcel.toJSON(),
        success: ->
          result = notificationService.createAlarm parcel
          expect(result.getDate()).to.be.eql(parcel.get('date_obj').getDate() - 1)
          expect(result.getHours()).to.be.eql(10)
          expect(result.getMinutes()).to.be.eql(0)
          expect(result.getSeconds()).to.be.eql(0)
          notificationService.createAlarm parcel, dateAlarm
        error: ->
          alert 'error'