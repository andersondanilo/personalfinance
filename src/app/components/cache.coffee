define ['backbone'], (Backbone) ->

  class Cache

    constructor: ->
      @events = _.extend {}, Backbone.Events
      @data = {}
      @pendings = []

      @events.on 'set', (name, value) =>
        idx = @pendings.indexOf(name)
        if idx >= 0
          @pendings.splice(idx, 1)

    insertPending: (name) ->
      @pendings.push(name)

    isPending: (name) ->
      return @pendings.indexOf(name) >= 0

    get: (name, callback=null) ->
      @events.trigger 'get', name, callback
      if @has name
        if callback
          callback(@data[name])
        else
          return @data[name]
      else
        if callback
          if @isPending(name)
            @events.on "set:#{name}", (value) ->
              callback(value)
          else
            callback(undefined)

    set: (name, value, expiry_time=5000) ->
      @data[name] = value

      @events.trigger "set:#{name}", value, expiry_time
      @events.trigger 'set', name, value, expiry_time

      setTimeout(=>
        delete @data[name]
      , expiry_time)

    has: (name) ->
      if name of @data
        return true
      else
        return false