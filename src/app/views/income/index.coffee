define ['views/movement/index', 'views/main'], (MovementView, MainView) ->

  class IndexView extends MovementView

    constructor: (options={}) ->
      options.movement_type = 'income'
      super options

    getEl: ->
      mainView = require 'MainView'
      if (not @el?) or (not mainView.layers.exist(@el))
        @el = mainView.layers.add()
      return @el

  new IndexView()