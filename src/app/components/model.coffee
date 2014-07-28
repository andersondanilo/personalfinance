define ['backbone', 'epoxy', 'config/database', 'app'], (Backbone, epoxy, database, app) ->

  class Model extends Backbone.Epoxy.Model
    initialize: (options) ->
      if @storeName?
        modelName = @storeName.substr(0, Number(@storeName.length) - 1)
        @on 'sync', ->
          app.events.trigger("sync:#{modelName}", this)
      super options

  return Model