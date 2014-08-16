define ->

  class NotificationManager

    constructor: (events) ->
      @events = events
      try
        if Notification.permission != 'denied'
          Notification.requestPermission (permission) ->
            if !('permission' in Notification)
              Notification.permission = permission
      catch e
        require('components/logger').warning(e)

    notify: (title, body, options={}) ->
      options.body = body
      options.icon = 'http://s9.postimg.org/aer645kaz/logo48.png'
      @events.trigger 'notification', {
        'title': title,
        'options': options
      }

      try
        if window.Notification
          sendNotification = (title, options) ->
            new Notification title, options
        else if navigator.mozNotification
          sendNotification = (title, options) ->
            result = navigator.mozNotification.createNotification title, options.body, options.icon
            result.show()
        else
          sendNotification = (title, options) ->
            if options.body
              alert title + ": " + options.body
            else
              alert title

        sendNotification title, options

        navigator.vibrate 1000
      catch e
        require('components/logger').warning(e)

  return NotificationManager