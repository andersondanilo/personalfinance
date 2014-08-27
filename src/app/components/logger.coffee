define ->

  class Logger
    show: []

    _out: ->
      new_arguments = @_argsToArray arguments
      type = new_arguments.shift()
      new_arguments.unshift("(LOG) #{type}: ")
      try
        $('body').append($("<div style=\"border:1px solid black;\">
          #{new_arguments.join(' ')}
        </div>"))
        console.log.apply(this, new_arguments)
      catch e
        # Do Nothing


    _argsToArray: (args) ->
      result = []
      for item in args
        result.push item
      return result

    info: ->
      if @show.indexOf('info') >= 0
        new_arguments = @_argsToArray arguments
        new_arguments.unshift('Info')
        @_out.apply(this, new_arguments)

    warning: ->
      if @show.indexOf('warning') >= 0
        new_arguments = @_argsToArray arguments
        new_arguments.unshift('Warning')
        @_out.apply(this, new_arguments)

    debug: ->
      if @show.indexOf('debug') >= 0
        new_arguments = @_argsToArray arguments
        new_arguments.unshift('Debug')
        @_out.apply(this, new_arguments)

  return new Logger()