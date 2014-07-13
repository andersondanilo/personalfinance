define ['zepto', 'underscore', 'components/view', 'i18n', 'views/main', 'collections/parcel'], ($, _, View, i18n, main, ParcelCollection) ->

  class IndexView extends View

    constructor: (options={})->
      @collection = new ParcelCollection()
      @movement_type = options.movement_type
      super options

    render: ->
      @el = @getEl()
      main.render()

      if !$('li#income').is(':target')
        $('li#income a').click()

      collection = @collection

      @collection.fetch {
        conditions: {'movement_type': @movement_type}
      }

      require ['text!templates/movement/index'], (template_raw) =>
        template = _.template(template_raw)

        @el.html(template())

        ItemView = View.extend
          tagName: "div",
          initialize: ->
              console.log 'iniciou esta view', @model

        ListView = View.extend
          el: @el.find("#movement-list"),
          itemView: ItemView,
          
          initialize: ->
            @collection = collection
            @collection.reset([{description: "Luke Skywalker"}, {description: "Han Solo"}])

  return IndexView