define ['zepto', 'i18n'], ($, i18n) ->

  class TabManager

    constructor: (el) ->
      @el = el
      @items = []

    add: (label, route) ->
      @items.push new TabItem(label, route)

    list: ->
      @items

    render: ->
      for tab in @list()
        @el.append(tab.get_element())

    # Exibe a barra de tab's
    show: ->
      @el.removeClass 'inactive'

    # Esconde a barra de tab's
    hide: ->
      @el.addClass 'inactive'


  class TabItem
    constructor: (@label, @route) ->
      @_element = null

    get_element: ->
      if !@_element
        @_element = $('<li></li>').attr('role', 'tab').attr('id', @route)
        @_element.append(
          $('<a></a>').html(@label).attr('href', "##{@route}")
        )
      @_element

  return TabManager