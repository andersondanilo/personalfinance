define ['zepto', 'i18n'], ($, i18n) ->

  class ActionMenu

    constructor: (title, options) ->
      @title = title
      @options = []
      for params in options
        do (params) =>
          option = new Option(params)
          option.on 'click', =>
            @close()
          @options.push(option)
      @options.push new Option {
        label: i18n.t 'cancel'
        action: =>
          @close()
      }
      @el = @createEl()

    createEl: ->
      el = $ '<form onsubmit="return false;"></form>'
      el.attr 'role', 'dialog'
      el.attr 'data-type', 'action'
      header = $ '<header></header>'
      header.html @title
      el.append(header)
      menu = $ '<menu></menu>'
      menu.attr 'type', 'toolbar'
      for option in @options
        menu.append(option.el)
      el.append(menu)
      return el

    show: ->
      $('body').append @el

    close: ->
      @el.remove()

  class Option

    constructor: (params) ->
      @action = params.action
      @label = params.label
      @el = @createEl()
      @el.on 'click', =>
        @action()

    on: (ev, callback) ->
      @el.on ev, callback

    createEl: ->
      el = $ '<button></button>'
      el.html @label
      return el

  return ActionMenu