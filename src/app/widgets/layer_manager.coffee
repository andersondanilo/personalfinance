define ['zepto', 'underscore', 'backbone', 'i18n'], ($, _, Backbone, i18n) ->

  class LayerManager extends Backbone.View

    constructor: (el) ->
      @el        = el
      @mainLayer = @el.children('.layer').first()
      if @mainLayer and @mainLayer.get(0)
        @tagName = @mainLayer.get(0).tagName
      else
        @tagName = null

    add: ->
      @el.children('.layer').removeClass('active')
      newEl = $(document.createElement(@tagName)).addClass('layer loading active')
      @el.append newEl
      return newEl

    go: (layer) ->
      @el.children('.layer').removeClass('active')
      layer.addClass('active')
      return layer

    exist: (oldEl) ->
      if !oldEl
        return false
      for el in @el.children('.layer')
        if el == oldEl.get(0)
          return true
      return false

    in_main: ->
      return @el.children('.layer.active').get(0) == @mainLayer.get(0)
    
    reset: ->
      listDelete = []
      sthis = this
      @el.children('.layer').each ->
        if this != sthis.mainLayer.get(0)
          listDelete.push this

      _.each listDelete, (item) ->
        $(item).remove()

      sthis.mainLayer.addClass('active')


  return LayerManager