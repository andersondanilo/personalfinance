define ['views/parcel/index', 'views/main'], (MovementView, mainView) ->

  class IndexView extends MovementView

    constructor: (options={}) ->
      options.movement_type = 'income'
      super options
      @el = null

    getEl: ->
      if (not @el?) or (not mainView.layers.exist(@el))
        @el = mainView.layers.add()
      return @el

  new IndexView()