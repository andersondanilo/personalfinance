define ['zepto', 'underscore', 'components/view', 'i18n', 'views/main', 'collections/parcel'], ($, _, View, i18n, main, ParcelCollection) ->

  class IndexView extends View

    constructor: (options={})->
      @collection = new ParcelCollection()
      @movement_type = options.movement_type
      super options

    render: ->
      main.render()

      @el = @getEl()

      app = require 'app'

      if !$('li#income').is(':target')
        $('li#income a').click()

      collection = @collection

      doFetch = =>
        @collection.fetch {
          conditions: {'movement_type': @movement_type}
        }

      doFetch()

      app.events.on 'sync:parcel', doFetch

      require ['text!templates/movement/index.html', 'text!templates/movement/item.html'], (template_raw, item_template_raw) =>
        template = _.template(template_raw)
        item_template = _.template(item_template_raw)
        
        @el.html template()
        @el.removeClass 'loading'

        ItemView = View.extend
          tagName: "div",
          bindings: "data-bind"
          initialize: (options) ->
            $(@el).html(item_template())
            super options

        ListView = View.extend
          el: @el.find(".parcel-list-container")
          itemView: ItemView
          bindings: "data-bind"
          
          initialize: ->
            @collection = collection

        listView = new ListView()

  return IndexView