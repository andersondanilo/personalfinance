define ['zepto', 'underscore', 'components/view', 'i18n', 'services/configuration'], ($, _, View, i18n, configurationService) ->

  class IndexView extends View

    getEl: ->
      app = require('app')
      if !app.layers.exist(@el)
        @el = app.layers.add()
      app.layers.go(@el)
      this.$el = @el

    render: ->
      app     = require 'app'
      Toolbar = require 'widgets/toolbar'

      require ['text!templates/configuration/index.html'], (template_raw) =>
        template = _.template template_raw

        @getEl()

        @el.html template({
          'i18n': i18n
        })

        @el.removeClass 'loading'

        FormView = View.extend {
          el: "#form-configuration",
          bindings: "data-bind"
        }

        model = configurationService.getModel()
        form = new FormView({model:model})

        @toolbar = new Toolbar(@el.find('menu[type=toolbar]').first())
        @toolbar.set [
          {
            'save': =>
              @el.find('input').trigger('change')
              errors = model.validate model.toJSON()
              if errors
                for field of errors
                  app.status.show errors[field]
                  break
              else
                form.removeBindings()
                model.save()
                app.status.show i18n.t('edited_successfully')
                
                app.router.navigate 'expense', trigger:true
          }
        ]

  return new IndexView()