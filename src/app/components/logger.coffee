define ->
  class Logger
    _out: ->
      new_arguments = @_argsToArray arguments
      type = new_arguments.shift()
      new_arguments.unshift("(LOG) #{type}: ")
      try
        console.log.apply(this, new_arguments)
      catch e
        null # Do Nothing


    _argsToArray: (args) ->
      result = []
      for item in args
        result.push item
      return result

    info: ->
      new_arguments = @_argsToArray arguments
      new_arguments.unshift('Info')
      @_out.apply(this, new_arguments)

    warning: ->
      new_arguments = @_argsToArray arguments
      new_arguments.unshift('Warning')
      @_out.apply(this, new_arguments)

    debug: ->
      new_arguments = @_argsToArray arguments
      new_arguments.unshift('Debug')
      @_out.apply(this, new_arguments)

  return new Logger()