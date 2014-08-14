define ['zepto', 'underscore', 'components/view', 'i18n', 'views/main', 'collections/parcel', 'services/currency', 'components/model', 'services/date', 'services/configuration'], ($, _, View, i18n, main, ParcelCollection, currencyService, Model, dateService, configurationService) ->

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

    existEl: ->
      return !((not @el?) or (not main.layers.exist(@el)))

    getEl: ->
      if not @existEl()
        @el = main.layers.add()
      @goToLayer()
      return @el

    goToLayer: ->
      require('app').layers.reset()
      main.layers.go(@el)

    firstRender: ->
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
          empty: false
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

      doRefreshSum = =>
        sum = 0
        for model in @collection.models
          if not model.get('paid')
            sum += model.get 'value'
        @sumModel.set {'sum':sum}
        @sumModel.set {'empty':@collection.models.length==0}

      doRefreshSum = _.throttle(doRefreshSum, 300)

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
            doRefreshSum()
        }

      doFetch()

      doFetch = _.throttle(doFetch, 300)

      #app.events.on 'sync:parcel', doFetch
      #app.events.on 'sync:parcel', doFetch

      app.events.on 'create:parcel', (parcel) =>
        if parcel.get('movement_type') == @movement_type
          @collection.add([parcel])
          doRefreshSum()

      app.events.on 'update:parcel', (parcel) =>
        if parcel.get('movement_type') == @movement_type
          # Remove old
          results = @collection.where {id:parcel.get('id')}
          @collection.remove(results)
          @collection.add([parcel])
          doRefreshSum()

      app.events.on 'delete:parcel', (parcel) =>
        if parcel.get('movement_type') == @movement_type
          # Remove old
          results = @collection.where {id:parcel.get('id')}
          @collection.remove(results)
          doRefreshSum()

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

            @model.set('_parcel_count', null)
            @model.set('_show_parcel', false)

            @model.fetchMovement
              success: (movement) =>
                @model.set('_parcel_count', movement.get('parcel_count'))
                if Number(movement.get('parcel_count')) > 0
                  @model.set('_show_parcel', true)


        movement_type = @movement_type

        ListView = View.extend
          el: @el.find(".parcel-list")
          itemView: ItemView
          bindings: "data-bind"
          model: @sumModel
          initialize: ->
            @collection = collection            

        @listView = new ListView()

        configurationService.on 'sync', =>
          @listView.applyBindings()

    render: ->
      if !@existEl()
        @firstRender()
      @goToLayer()

  return IndexView