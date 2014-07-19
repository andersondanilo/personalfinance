define ['zepto', 'underscore', 'components/view', 'i18n', 'models/movement', 'collections/movement', 'services/movement'], ($, _, View, i18n, Movement, movementCollection, movementService) ->

  class InsertView extends View

    constructor: ->
      @el      = null
      @toolbar = null


    render: ->
      app     = require 'app'
      Toolbar = require 'widgets/toolbar'

      require ['text!templates/movement/insert.html', 'widgets/currency_input'], (template_raw, CurrencyInput) =>
        template = _.template template_raw

        if !app.layers.exist(@el)
          @el = app.layers.add()

        @el.html template({
          'i18n': i18n
        })

        
        @el.removeClass 'loading'

        FormView = View.extend {
          el: "#form-movement-insert",
          bindings: "data-bind"
        }

        model = new Movement()
        form  = new  FormView({model:model})

        currencyInput = new CurrencyInput(@el.find('.input-currency'))
        currencyInput.on 'change', (newvalue) =>
          model.set {value:newvalue}

        @toolbar = new Toolbar(@el.find('menu[type=toolbar]').first())
        @toolbar.set [
          {
            'save': ->
              # Temos que validar primeiro
              errors = model.validate model.toJSON()
              if errors
                for field of errors
                  app.status.show errors[field]
                  break
              else
                app.status.show i18n.t('successfully_added')
                movementService.createMovement model
                app.router.navigate '/', trigger:true
          }
        ]

  new InsertView()