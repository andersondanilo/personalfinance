require.config {
  baseUrl: if typeof(APP_BASE_URL) == 'undefined' then './app' else APP_BASE_URL,
  paths:
    text:       '../vendor/require/text'
    underscore: '../vendor/underscore/underscore'
    backbone:   '../vendor/backbone/backbone'
    epoxy:      '../vendor/backbone/epoxy'
    backbone_indexeddb:  '../vendor/backbone/indexeddb'
    i18n:       '../vendor/i18next/i18next'
    zepto:      '../vendor/zepto/zepto'
    moment:      '../vendor/moment/moment'
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
    'epoxy'], (
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
      epoxy
) ->
  class App
    constructor: ->
      @layers = new LayerManager $('#app-layer-container')
      @status = new Status $('#app-status')
      @events = _.extend {}, Backbone.Events
      @router = router

      _.delay (->
        require ['services/movement'], (movementService) ->
          movementService.processAllInfinite()
      ), 500

      i18n.init conf_i18n, =>
        router.start()

  return new App()