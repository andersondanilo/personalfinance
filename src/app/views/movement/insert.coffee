define ['zepto', 'underscore', 'components/view', 'i18n', 'models/movement', 'collections/movement', 'services/movement'], ($, _, View, i18n, Movement, movementCollection, movementService) ->

  class InsertView extends View

    constructor: ->
      @el      = null
      @toolbar = null


    render: ->
      app     = require 'app'
      Toolbar = require 'components/toolbar'

      require ['text!templates/movement/insert.html'], (template_raw) =>
        template = _.template template_raw

        if !app.layers.exist(@el)
          @el = app.layers.add()

        @el.html template({
          'i18n'   : i18n
        })
        
        @el.removeClass 'loading'

        FormView = View.extend {
          el: "#form-movement-insert",
          bindings: "data-bind"
        }

        model = new Movement()
        form  = new  FormView({model:model})

        @toolbar = new Toolbar(@el.find('menu[type=toolbar]').first())
        @toolbar.set [
          {
            'save': ->
              # Temos que validar primeiro
              errors = model.validate(model.toJSON())
              #if not errors
              
          }
        ]


  new InsertView()