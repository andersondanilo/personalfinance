require.config {
  baseUrl: if typeof(APP_BASE_URL) == 'undefined' then './app' else APP_BASE_URL,
  paths:
    text:       '../vendor/require/text'
    jquery:     '../vendor/jquery/jquery'
    underscore: '../vendor/underscore/underscore'
    backbone:   '../vendor/backbone/backbone'
    epoxy:      '../vendor/backbone/epoxy'
    backbone_indexeddb:  '../vendor/backbone/indexeddb'
    i18n:       '../vendor/i18next/i18next'
    zepto:      '../vendor/zepto/zepto'
}

define [
    'underscore',
    'zepto',
    'i18n',
    'config/i18n',
    'views/main',
    'config/router',
    'widgets/layer_manager',
    'widgets/status',
    'text!templates/main/index.html',
    'epoxy'], (
      _,
      $,
      i18n,
      conf_i18n,
      main,
      router,
      LayerManager,
      Status,
      main_template_raw,
      epoxy
) ->
  class App
    constructor: ->
      @layers = new LayerManager $('#app-layer-container')
      @status = new Status $('#app-status')
      @events = _.extend {}, Backbone.Events
      @router = router
      
      i18n.init conf_i18n, =>
        router.start()

  return new App()