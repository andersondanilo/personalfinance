define ['models/parcel', 'i18n', 'services/date'], (Parcel, i18n, dateService) ->

  DEFAULT_HOUR = if typeof(TEST_HOUR) == 'undefined' then 10 else TEST_HOUR
  DEFAULT_MINUTE = if typeof(TEST_MINUTE) == 'undefined' then 0 else TEST_MINUTE

  class NotificationService

    resetAlarm: (model) ->
      # Apaga os alarmes de um model
      # NÃO SALVA!
      alarms = require('app').alarms
      if model.get 'alarms_id'
        try
          for alarm_id in model.get('alarms_id')
            alarms.delete alarm_id
        catch e
          require('components/logger').warning(e)
      model.set {'alarms_id':[]}

    createDefaultAlarms: (model, callback=null) ->
      # Apagamos os alarmes antigos
      @resetAlarm(model)

      today = new Date()

      dates = []

      # Um dia antes
      date = dateService.clone model.get('date_obj')
      date.setMinutes DEFAULT_MINUTE
      date.setHours DEFAULT_HOUR
      date.setSeconds 0
      date.setDate date.getDate()-1

      if date > today
        dates.push date

      # Sete dias antes
      date = dateService.clone model.get('date_obj')
      date.setMinutes DEFAULT_MINUTE
      date.setHours DEFAULT_HOUR
      date.setSeconds 0
      date.setDate date.getDate()-7

      if date > today
        dates.push date

      if dates.length > 0
        callbacks = _.after dates.length, ->
          try
            require('components/logger').debug("Yes, Success")
            require('components/logger').debug("callback: #{callback}")
            model.save model.toJSON()
            if callback
              callback()
          catch e
            require('components/logger').debug("Ops: #{e}")
            throw e

        for date in dates
          @createAlarm model, date, callbacks
      else
        callback()

    createAlarm: (model, date, callback=null) ->
      # Cria um alarme para determinada parcela
      # NÃO SALVA!
      alarms = require('app').alarms
      alarm_data = {
        id_parcel: model.get('id')
      }
      try
        alarms.add date, alarm_data, (alarmId) ->
          try
            alarms_id = model.get('alarms_id')
            if not alarms_id
              alarms_id = []
            alarms_id.push alarmId
            model.set {'alarms_id':alarms_id}
            if callback
              callback()
          catch e
            require('components/logger').debug("error = #{e}")
            throw e
      catch e
        require('components/logger').debug("error = #{e}")
      return date

    triggerNotification: (alarm) ->

      # Exibe uma notificação originada de um alarm
      if alarm.getData() and alarm.getData().id_parcel
        notifications = require('app').notifications
        id_parcel = alarm.getData().id_parcel
        parcel = new Parcel {id:id_parcel}
        parcel.fetch
          success: ->
            if not parcel.get('paid')
              date_parcel = parcel.get('date_obj')
              date_cmp = new Date
              cmp1 = "#{date_cmp.getFullYear()} #{date_cmp.getMonth()} #{date_cmp.getDate()}"
              cmp2 = "#{date_parcel.getFullYear()} #{date_parcel.getMonth()} #{date_parcel.getDate()}"
              if cmp1 == cmp2
                title = parcel.get('description') + ' ' + i18n.t('due_tomorrow')
              else
                title = parcel.get('description')
              description = i18n.t('the_due_date_is') + ' ' + parcel.get('date_formatted')
              notifications.notify title, description, {}, ->
                require('components/logger').debug('before launch')
                require('app').launch()
                require('components/logger').debug('after launch')
          error: ->
            require('components/logger').warning("Error: #{JSON.stringify(arguments)}")

  return new NotificationService()