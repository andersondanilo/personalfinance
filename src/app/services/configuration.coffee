define ['collections/configuration', 'models/configuration'], (ConfigurationCollection, ConfigurationModel) ->

  class ConfigurationService

    constructor: ->
      @collection = new ConfigurationCollection()
      @collection.fetch()
      @model = null

    on: ->
      @getModel()
      @model.on.call(@model, arguments)

    getModel: ->
      if not @model
        try
          @model = @collection.models[0]
        catch e
          @model = null

        if not @model
          @model = new ConfigurationModel()
          @collection.set [@model]

      return @model

    getCurrency: ->
      @getModel().get('currency')

    getDecimalSeparator: ->
      @getModel().get('decimal_separator')

    getThousandsSeparator: ->
      @getModel().get('thousands_separator')

  return new ConfigurationService