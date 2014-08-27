define ['backbone', 'zepto'], (Backbone, $) ->

  class AlarmManager

    constructor: (events) ->
      @events = events
      try 
        navigator.mozHasPendingMessage('alarm')
      catch e
        require('components/logger').warning(e)

      try
        if window.alertPendingMessages != null
          for mozAlarm in window.alertPendingMessages
            @triggerAlarm(mozAlarm)
            window.alertPendingMessages
      catch e
        require('components/logger').warning(e)

      try
        navigator.mozSetMessageHandler "alarm", (mozAlarm) =>
          @triggerAlarm(mozAlarm)
      catch e
        require('components/logger').warning(e)

    triggerAlarm: (mozAlarm) ->
      try
        @events.trigger 'alarm', new AlarmProxy(this, mozAlarm)
      catch e
        require('components/logger').warning(e)


    add: (date, data, callback) ->
      if not navigator.mozAlarms
        return false

      request = navigator.mozAlarms.add date, "ignoreTimezone", data

      require('components/logger').debug("Requested alarm for #{date} with #{JSON.stringify(data)}")

      request.onsuccess = ->
        alarmId = this.result
        require('components/logger').debug("Success alarm with id #{alarmId}")
        callback(alarmId)
      request.onerror = ->
        require('components/logger').debug("Error alarm on: #{this.error.name}")

    delete: (alarmId) ->
      if not navigator.mozAlarms
        return false
      navigator.mozAlarms.remove alarmId

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

  return AlarmManager