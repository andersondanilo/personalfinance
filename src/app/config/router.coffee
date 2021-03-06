define [
    'zepto',
    'underscore',
    'backbone'
  ], ($, _, Backbone) ->

  class Router extends Backbone.Router
    routes:
      'index'   : 'expense'
      'income'  : 'income'
      'expense' : 'expense'
      'graph'   : 'graph'
      'drawer'  : 'drawer'
      'configuration'  : 'configuration'
      'insert/:type'  : 'insert'
      'parcel/update/:id': 'parcel_update'
      '*actions': 'expense'

    start: ->
      $(window).on 'hashchange', =>
        @navigate window.location.hash, {trigger:true}
      @startHistory()

    startHistory: ->
      Backbone.history.start({pushState: false, root: 'expense'})

    back: ->
      if window.history.length > 1
        window.history.go(-1)
      else
        @navigate 'index', {trigger:true}

  router = new Router

  router.on 'route:income', ->
    require ['views/parcel/index'], (IndexView) ->
      IndexView.instance('income').render()
      

  router.on 'route:expense', ->
    require ['views/parcel/index'], (IndexView) ->
      IndexView.instance('expense').render()

  router.on 'route:graph', ->
    require ['views/graph/index'], (graphView) ->
      graphView.render()

  router.on 'route:insert', (type) ->
    require ['views/movement/insert'], (insertView) ->
      insertView.render type

  router.on 'route:parcel_update', (id) ->
    require ['views/parcel/update'], (updateView) ->
      updateView.render(id)

  router.on 'route:configuration', (type) ->
    require ['views/configuration/index'], (configurationView) ->
      configurationView.render()

  router