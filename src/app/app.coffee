require.config {
  baseUrl: if typeof(APP_BASE_URL) == 'undefined' then './app' else APP_BASE_URL,
  paths:
    text:         '../vendor/require/text'
    underscore:   '../vendor/underscore/underscore'
    backbone:     '../vendor/backbone/backbone'
    epoxy:        '../vendor/backbone/epoxy'
    indexeddb:    '../vendor/backbone/indexeddb'
    localstorage: '../vendor/backbone/localstorage'
    i18n:         '../vendor/i18next/i18next'
    zepto:        '../vendor/zepto/zepto'
    moment:       '../vendor/moment/moment'
  map:
    '*':
      jquery: 'zepto'
}

define [
    'underscore',
    'zepto',
    'i18n',
    'backbone',
    'config/i18n',
    'views/main',
    'config/router',
    'widgets/layer_manager',
    'widgets/status',
    'text!templates/main/index.html',
    'components/logger',
    'components/view',
    'epoxy',
    'components/cache',
    'components/alarm_manager',
    'components/notification_manager'], (
      _,
      $,
      i18n,
      Backbone,
      conf_i18n,
      main,
      router,
      LayerManager,
      Status,
      main_template_raw,
      Logger, # Only Pre-load
      View,
      epoxy,
      Cache,
      AlarmManager,
      NotificationManager
) ->
  class App
    constructor: ->
      @layers = new LayerManager $('#app-layer-container')
      @status = new Status $('#app-status')
      @events = _.extend {}, Backbone.Events
      @router = router
      @cache = new Cache()

      @events.on 'alarm', (alarm) ->
        alert 'app alarm'
        require ['services/notification'], (notificationService) ->
          notificationService.triggerNotification(alarm)

      @alarms = new AlarmManager(@events)
      @notifications = new NotificationManager(@events)

      _.delay (->
        require ['services/movement'], (movementService) ->
          movementService.processAllInfinite()
      ), 500

      i18n.init conf_i18n, =>
        i18n.initialized = true
        router.start()

  return new App()