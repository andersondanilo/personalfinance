define ['zepto', 'underscore', 'components/view', 'i18n', 'views/main', 'collections/parcel', 'services/currency', 'components/model', 'services/date'], ($, _, View, i18n, main, ParcelCollection, currencyService, Model, dateService) ->

  class IndexView extends View
    @instances = {}

    bindings: "data-bind"

    constructor: (options)->
      @collection = new ParcelCollection()
      @movement_type = options.movement_type
      super options
      $el = @el = null


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
      movement_type = @movement_type

      @el = @getEl()

      app = require 'app'

      main.toolbar.set ["insert/#{@movement_type}"]

      if !$('li#'+@movement_type).is(':target')
        $('li#'+@movement_type+' a').click()

      collection = @collection

      @sumModel = new (Model.extend {
        defaults:
          sum: null
          empty: true
        computeds:
          sum_display: 
            deps: ['sum']
            get: ->
              if @get('sum') is null
                return ''
              else
                return currencyService.format @get('sum')
          color: ->
            if movement_type == 'income'
              return '#2EB944'
            else
              return '#E22A00'
      })

      doFetch = =>

        date_start = new Date()
        date_start.setDate(date_start.getDate() - 1)
        date_limit = new Date()
        date_limit.setDate(date_limit.getDate() + 31)

        date_start = dateService.format 'YYYY-MM-DD', date_start
        date_limit = dateService.format 'YYYY-MM-DD', date_limit

        @collection.fetch {
          conditions: {'date': [date_start, date_limit]}
          success: =>
            @collection.set @collection.where({'movement_type':@movement_type})
            sum = 0
            for model in @collection.models
              sum += model.get 'value'
            @sumModel.set {'sum':sum}
            @sumModel.set {'empty':@collection.models.length==0}
        }

      doFetch()

      app.events.on 'sync:parcel', doFetch

      require ['text!templates/parcel/index.html', 'text!templates/parcel/item.html'], (template_raw, item_template_raw) =>
        template = _.template(template_raw)
        item_template = _.template(item_template_raw)
        
        @el.html template({
          i18n: i18n
        })
        @el.removeClass 'loading'

        ItemView = View.extend
          tagName: "li",
          bindings: "data-bind"
          initialize: (options) ->
            $(@el).html(item_template())
            super options

        movement_type = @movement_type

        ListView = View.extend
          el: @el.find(".parcel-list")
          itemView: ItemView
          bindings: "data-bind"
          model: @sumModel
          initialize: ->
            @collection = collection

        @listView = new ListView()

  return IndexView