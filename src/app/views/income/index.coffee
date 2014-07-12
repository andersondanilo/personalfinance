define ['zepto', 'underscore', 'components/view', 'i18n', 'views/main'], ($, _, View, i18n, main) ->

  class IndexView extends View

    constructor: ->

    render: ->
      main.render()

      if !$('li#income').is(':target')
        $('li#income a').click()

      # @TODO: Listagem de entradas

  new IndexView()