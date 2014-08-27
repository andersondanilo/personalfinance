
Parcel = requirejs 'models/parcel'
notificationService = requirejs 'services/notification'
dateService = requirejs 'services/date'
AlarmManager = requirejs 'components/alarm_manager'
ParcelCollection    = requirejs 'collections/parcel'

parcelCollection = new ParcelCollection

require('components/logger').show.push('info')
require('components/logger').show.push('warning')
require('components/logger').show.push('debug')

describe 'AlarmManager', ->

  it 'Should trigger alarm', (done) ->
    require ['app'], (app) ->
      events = app.events
      alarmManager = app.alarms
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
    @timeout(6000)
    events = _.extend {}, Backbone.Events
    alarmManager = new AlarmManager(events)
    date = new Date()
    date.setSeconds(date.getSeconds()+2)
    data = {id_parcel:'abcde'}
    alarmManager.add date, data, (alarmId) ->
      expect(Number(alarmId)).to.be.at.least(1)
      events.on 'alarm', (alarmObj) ->
        expect(alarmObj.getId()).to.be.eql(alarmId)
        expect(alarmObj.getDate()).to.be.eql(date)
        expect(alarmObj.getData().id_parcel).to.be.eql('abcde')
        done()

  it 'Should delete alarm', (done) ->
    @timeout(4000)
    require ['app'], (app) ->
      events = app.events
      alarmManager = app.alarms
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

describe 'NotificationService', ->

  it 'Should create alarm', (done) ->
    @timeout(10000)
    require ['app'], (app) ->
      date = new Date
      date.setDate date.getDate()+1
      date.setSeconds date.getSeconds() + 3
      dateAlarm = new Date
      dateAlarm.setSeconds date.getSeconds() + 3
      parcel = new Parcel {
        description: 'Cartao'
        date: '2090-01-01'
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
          result = notificationService.createDefaultAlarms parcel, ->
            expect(parcel.get('alarms_id').length).to.be.eql(2)
            done()
        error: ->
          alert 'error'

  it 'Should create notification now', (done) ->
    @timeout(10000)
    require ['app'], (app) ->
      parcel = new Parcel {
        description: 'Cartao'
        movement_type: 'income'
        movement_id: 1,
        parcel_number: 1,
        value: 10
      }

      date = new Date
      date.setSeconds date.getSeconds() + 2
      parcel.set {date_obj:date}

      app.events.on 'notification', (notification) ->
        expect(notification.title).to.have.string('Cartao')
        done()

      parcel.save parcel.toJSON(),
        success: ->
          result = notificationService.createAlarm parcel, date, ->
            expect(parcel.get('alarms_id').length).to.be.eql(1)
            done()
        error: ->
          alert 'error'

  it 'Should trigger notification', (done) ->
    @timeout(10000)
    require ['app'], (app) ->
      parcel = new Parcel {
        description: 'Cartao'
        movement_type: 'income'
        movement_id: 1,
        parcel_number: 1,
        value: 10
      }

      date = new Date
      date.setDate date.getDate() + 7
      date.setSeconds date.getSeconds() + 2
      parcel.set {date_obj:date}

      app.launch()

      parcel.save parcel.toJSON(),
        success: ->
          mockAlarm = {
            getData: ->
              return {id_parcel:parcel.get('id')}
          }
          notificationService.triggerNotification mockAlarm
          done()
        error: ->
          alert 'error'
