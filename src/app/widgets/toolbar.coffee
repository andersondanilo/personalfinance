define ['zepto', 'underscore', 'backbone', 'i18n'], ($, _, Backbone, i18n) ->

  class Toolbar extends Backbone.View

    constructor: (el) ->
      @el = el
      @buttons = []

    set: (buttons) ->
      @reset()
      _.each buttons, (button) =>
        @buttons.push new ToolbarButton(button)
      @render()

    reset: ->
      @el.children().each ->
        $(this).remove()
      @buttons = []

    render: ->
      _.each @buttons, (button) =>
        @el.append button.el

  class ToolbarButton extends Backbone.View

    constructor: (params) ->
      if params == 'insert/income'
        params = type:'add', label: i18n.t('save') , href:'#insert/income'

      if params == 'insert/expense'
        params = type:'add', label: i18n.t('save') , href:'#insert/expense'

      if params.save?
        params = type:'save', label: i18n.t('save'), callback: params['save']

      if params.href
        @el = $(document.createElement('a'))
        @el.attr 'href', params.href
      else
        @el = $(document.createElement('button'))
        @el.click ->
          params.callback()

      @el_label = $(document.createElement('span')).html(params.label)

      if params.type == 'add'
        @el_label.addClass('icon').addClass('icon-add')

      #if params.type == 'save'
        #@el_label.addClass('icon').addClass('icon-edit')

      #if params.type == 'edit'
        #@el_label.addClass('icon').addClass('icon-edit')

      @el.append(@el_label)

  return Toolbar