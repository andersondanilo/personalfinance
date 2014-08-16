define ['models/parcel', 'i18n', 'services/date'], (Parcel, i18n, dateService) ->

  class NotificationService

    createAlarm: (model, dateAlarm=null) ->
      # Cria um alarme para determinada parcela
      alarms = require('app').alarms
      if model.get 'alarm_id'
        try
          alarms.delete model.get('alarm_id')
        catch e
          require('components/logger').warning(e)
      if dateAlarm
        date = dateAlarm
      else
        date = dateService.clone model.get('date_obj')
        date.setMinutes 0
        date.setHours 10
        date.setSeconds 0
        date.setDate date.getDate()-1
      alarm_data = {id_parcel:model.get('id')}
      try
        alarms.add date, alarm_data, (alarmId) ->
          model.set {alarm_id:alarmId}
      catch e
        require('components/logger').warning(e)
      return date

    triggerNotification: (alarm) ->

      # Exibe uma notificação originada de um alarm
      if alarm.getData() and alarm.getData().id_parcel
        notifications = require('app').notifications
        id_parcel = alarm.getData().id_parcel
        parcel = new Parcel {id:id_parcel}
        parcel.fetch
          success: ->
            title = parcel.get('description') + ' ' + i18n.t('due_tomorrow')
            description = i18n.t('the_due_date_is') + ' ' + parcel.get('date_formatted')
            notifications.notify title, description
          error: ->
            require('components/logger').warning("Error: #{JSON.stringify(arguments)}")

  return new NotificationService()