define ['backbone'], (Backbone) ->
  class AlarmManager
    constructor: (events) ->
      navigator.mozSetMessageHandler "alarm", (mozAlarm) ->
        events.trigger 'alarm', new AlarmProxy(manager, mozAlarm)

    add: (date, data, callback) ->
      request = navigator.mozAlarms.add date, "ignoreTimezone", data

      request.onsuccess = ->
        alarmId = this.result
        callback(alarmId)

    delete: (alarmId) ->
      navigator.mozAlarms.remove alarmId

    update: (alarmId) ->
      # Atenção, Gera um novo alarmId
      @delete(alarmId)

  class AlarmProxy
    constructor: (manager, mozAlarm) ->
      @alarm = mozAlarm
      @manager = manager

    getId: ->
      return @alarm.id

    getDate: ->
      return @alarm.date

    getData: ->
      return @alarm.data