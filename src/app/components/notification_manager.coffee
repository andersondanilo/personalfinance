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

    notify: (title, body, options={}, onclick=null) ->
      require('app').requestApp (mozApp) =>
        options.body = body
        options.icon = 'http://s9.postimg.org/aer645kaz/logo48.png'
        @events.trigger 'notification', {
          'title': title,
          'options': options
        }

        try
          if window.Notification
            sendNotification = (title, options) ->
              result = new Notification title, options
              require('components/logger').debug('sendNotification with "new Notification"')
              try
                if onclick
                  require('components/logger').debug("result.onclick = #{onclick}")
                  result.onclick = onclick
              catch e
                # do nothing
              return result
          else if navigator.mozNotification
            sendNotification = (title, options) ->
              result = navigator.mozNotification.createNotification title, options.body, options.icon
              require('components/logger').debug('sendNotification with "createNotification"')
              try
                if onclick
                  require('components/logger').debug("result.onclick = #{onclick}")
                  called = false
                  # result.onclick = 
                  result.onclick = ->
                    request = navigator.mozApps.getSelf()

                    request.onsuccess = ->
                      request.result.launch()

                    window.navigator.mozSetMessageHandler 'notification', ->
                      request = navigator.mozApps.getSelf()
                      request.onsuccess = ->
                        request.result.launch()

                    if onclick and not called
                      onclick
                    called = true
                  result.onclose = ->
                    if onclick and not called
                      onclick
                    called = true
              catch e
                # do nothing
              result.show()
              return result
          else
            sendNotification = (title, options) ->
              require('components/logger').debug('sendNotification with "alert"')
              if options.body
                alert title + ": " + options.body
              else
                alert title
              if onclick
                onclick()

          sendNotification title, options

          navigator.vibrate 1000
        catch e
          require('components/logger').warning(e)

  return NotificationManager