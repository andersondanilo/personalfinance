define ['zepto', 'underscore', 'components/view', 'i18n', 'views/main', 'collections/parcel'], ($, _, View, i18n, main, ParcelCollection) ->

  class IndexView extends View
    @instances = {}

    constructor: (options)->
      @collection = new ParcelCollection()
      @movement_type = options.movement_type
      super options
      @el = null

    @instance: (movement_type) ->
      if not (movement_type of @instances)
        @instances[movement_type] = new IndexView {
          movement_type: movement_type
        }
      return @instances[movement_type]

    getEl: ->
      if (not @el?) or (not main.layers.exist(@el))
        @el = main.layers.add()
      main.layers.go(@el)
      return @el

    render: ->
      main.render()

      @el = @getEl()

      app = require 'app'

      main.toolbar.set ["insert/#{@movement_type}"]

      if !$('li#'+@movement_type).is(':target')
        $('li#'+@movement_type+' a').click()

      collection = @collection

      doFetch = =>
        @collection.fetch {
          conditions: {'movement_type': @movement_type}
        }

      doFetch()

      app.events.on 'sync:parcel', doFetch

      require ['text!templates/parcel/index.html', 'text!templates/parcel/item.html'], (template_raw, item_template_raw) =>
        template = _.template(template_raw)
        item_template = _.template(item_template_raw)
        
        @el.html template()
        @el.removeClass 'loading'

        ItemView = View.extend
          tagName: "li",
          bindings: "data-bind"
          initialize: (options) ->
            $(@el).html(item_template())
            super options

        ListView = View.extend
          el: @el.find(".parcel-list")
          itemView: ItemView
          bindings: "data-bind"
          
          initialize: ->
            @collection = collection

        listView = new ListView()

  return IndexView