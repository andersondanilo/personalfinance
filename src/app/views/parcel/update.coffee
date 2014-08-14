define ['zepto', 'underscore', 'components/view', 'i18n', 'models/parcel', 'services/parcel', 'models/movement', 'widgets/action_menu'], ($, _, View, i18n, Parcel, parcelService, Movement, ActionMenu) ->

  class UpdateView extends View

    constructor: ->
      super()
      @el      = null
      @toolbar = null
      @movement = null
      @model = null
      sthis = this
      @events  = 
        'click button.btn-exclude': ->
          sthis.exclude()

    render: (id) ->
      app = require 'app'
      Toolbar = require 'widgets/toolbar'

      require ['text!templates/parcel/update.html', 'widgets/currency_input'], (template_raw, CurrencyInput) =>
        template = _.template template_raw

        @model = new Parcel {id:id}
        @model.fetch {
          success: =>
            if !app.layers.exist(@el)
              @el = app.layers.add()

            this.$el = @el
        
            @el.html template({
              'i18n': i18n,
              'model': @model
            })

            @toolbar = new Toolbar(@el.find('menu[type=toolbar]').first())
            @toolbar.set [
              {
                'save': =>
                  @el.find('input').trigger('change')
                  # Temos que validar primeiro
                  errors = @model.validate @model.toJSON()
                  if errors
                    for field of errors
                      app.status.show errors[field]
                      break
                  else
                    @getUpdateMenu {
                      updateOne: =>
                        parcelService.saveOne @model
                      updateNext: =>
                        parcelService.saveNext @model
                      updateAll: =>
                        parcelService.saveAll @model
                      afterUpdate: =>
                        app = require('app')
                        app.status.show i18n.t('edited_successfully')
                        @remove()
                        if @model.get('movement_type') == 'income'
                          app.router.navigate 'income', trigger:true
                        else
                          app.router.navigate 'expense', trigger:true
                    }, (am) ->
                      am.show()
              }
            ]

            @delegateEvents()

            @el.removeClass 'loading'

            FormView = View.extend {
              el: "#form-parcel-update",
              bindings: "data-bind"
            }

            form  = new FormView({model:@model})

            @needMultiple @model, ->
              null # apenas para fazer o cache

            currencyInput = new CurrencyInput @el.find('.input-currency'), @model.get('value')
            currencyInput.on 'change', (newvalue) =>
              @model.set {value:newvalue}
        }

    exclude: ->
      menu = @getDeleteMenu {
        deleteOne: =>
          parcelService.removeOne @model
        deleteNext: =>
          parcelService.removeNext @model
        deleteAll: =>
          parcelService.removeAll @model
        afterDelete: =>
          app = require('app')
          app.status.show i18n.t('deleted_successfully')
          if @model.get('movement_type') == 'income'
            app.router.navigate 'income', trigger:true
          else
            app.router.navigate 'expense', trigger:true
      }, (am) ->
        am.show()

    getUpdateMenu: (callbacks, callback) ->

      @needMultiple @model, (need) =>
        if need
          options = []
          
          options.push {
            label: i18n.t('update_only_this_parcel'),
            action: ->
              callbacks.updateOne()
              callbacks.afterUpdate()
          }

          if @movement.get('is_infinite') || (@movement.get('repeated') && Number(@model.get('parcel_number')) < Number(@movement.get('parcel_count')))
            options.push {
              label: i18n.t('update_this_and_all_future'),
              action: ->
                callbacks.updateNext()
                callbacks.afterUpdate()
            }

          if Number(@model.get('parcel_number')) > 1
            options.push {
              label: i18n.t('update_all_including_previous'),
              action: ->
                callbacks.updateAll()
                callbacks.afterUpdate()
            }

          if options.length == 1
            callbacks.updateOne()
            callbacks.afterUpdate()
            return null

          am = new ActionMenu i18n.t('select_an_option'), options

          callback(am)
        else
          callbacks.updateOne()
          callbacks.afterUpdate()

    getDeleteMenu: (callbacks, callback) ->
      @needMultiple @model, (need) =>
        options = []

        window.z = this
        
        options.push {
          label: i18n.t('delete_only_this_parcel'),
          action: ->
            callbacks.deleteOne()
            callbacks.afterDelete()
        }

        if @movement.get('is_infinite') || (@movement.get('repeated') && Number(@model.get('parcel_number')) < Number(@movement.get('parcel_count')))
          options.push {
            label: i18n.t('delete_this_and_all_future'),
            action: ->
              callbacks.deleteNext()
              callbacks.afterDelete()
          }

        if Number(@model.get('parcel_number')) > 1
          options.push {
            label: i18n.t('delete_all_including_previous'),
            action: ->
              callbacks.deleteAll()
              callbacks.afterDelete()
          }

        am = new ActionMenu i18n.t('select_an_option'), options

        callback(am)

    # Verifica se pode é necessário atualizar várias parcelas
    needMultiple: (parcel, callback) ->
      doSuccess = =>
        if @movement.get('repeated')
          callback(true)
        else
          callback(false)

      if not @movement
        @movement = new Movement {id:parcel.get('movement_id')}
        @movement.fetch {
          success: ->
            doSuccess()
        }
      else
        doSuccess()

  new UpdateView()