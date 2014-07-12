define ['zepto', 'underscore', 'components/view', 'components/tab_manager', 'components/layer_manager', 'components/toolbar'], ($, _, View, TabManager, LayerManager, Toolbar) ->

  class MainView extends View
    
    constructor: ->
      @assigned = null
      @el       = null
      require ['app'], (app) =>
        @el = app.layers.mainLayer
      @tabs     = null
      @layers   = null
      @toolbar  = null
      @first_render = true


    assign: ->

      if !@assigned
        i18n = require 'i18n'

        @tabs         = new TabManager($('#main-tab'))
        @tabs.add i18n.t('income'), 'income'
        @tabs.add i18n.t('expense'), 'expense'
        @tabs.add i18n.t('graph'), 'graph'

        @layers       = new LayerManager($('#content-layer-container'))
        @toolbar      = new Toolbar($('#main-toolbar'))
        @assigned     = true

    render: ->
      app  = require 'app'
      i18n = require 'i18n'
      
      # O DOM está pronto, o presentar fará o necessário
      if @first_render
        template_raw = require 'text!templates/main/index.html'
        template = _.template(template_raw)
        @el.html template({'i18n':i18n})
        @el.removeClass 'loading'

        @assign()
        @tabs.render()

      @tabs.show()

      
      if !app.layers.in_main()
        app.layers.reset()

      if !@layers.in_main() || @first_render
        @toolbar.set ['insert']

      @first_render = false

  new MainView()