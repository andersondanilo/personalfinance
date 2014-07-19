define ->
  class CurrencyInput
    constructor: (el) ->
      @el_decimal = el.find('.side-decimal input')
      @el_integer = el.find('.side-integer input')
      @events = _.extend {}, Backbone.Events
      @bind_all()

    bind_all: ->

      @el_integer.on 'focus', =>
        @el_decimal.focus()

      @el_decimal.on 'focus', =>
        @el_decimal.get(0).selectionStart = @el_decimal.val().length
        @el_decimal.get(0).selectionEnd = @el_decimal.val().length

      @el_decimal.on 'click', =>
        @el_decimal.get(0).selectionStart = @el_decimal.val().length
        @el_decimal.get(0).selectionEnd = @el_decimal.val().length

      @el_decimal.on 'keypress', (event) =>
        value = @el_decimal.val()
        if Number(event.keyCode) == 8
          if value.length <= 2
            integer_value = @el_integer.val()
            if integer_value.length > 0
              setTimeout(=>
                decimal_piece = @el_integer.val().substr(-1)
                integer = @el_integer.val().substring(0, @el_integer.val().length - 1)
                @el_integer.val(String(integer))
                @el_decimal.val(String(decimal_piece) + @el_decimal.val())
              , 1)
        else
          char = String.fromCharCode(event.charCode)
          if /[0-9]/.test char
            if value.length >= 2
              integer_piece = value.substring(0, 1)

              @el_integer.val(@el_integer.val() + integer_piece)
              setTimeout(=>
                @el_decimal.val(@el_decimal.val().substr(-2))
              , 1)
          else
            if event.keyCode != 9
              event.preventDefault()

        @el_decimal.get(0).selectionStart = @el_decimal.val().length
        @el_decimal.get(0).selectionEnd = @el_decimal.val().length

        setTimeout(=>
          @trigger_change()
        , 100)

    trigger_change: ->
      integer = @el_integer.val() || 0
      decimal = @el_decimal.val() || 0
      value = ''
      if decimal
        value = [Number(integer), Number(decimal)].join('.')
      else
        value = Number(integer)
      @events.trigger 'change', Number(value)

    on: (event, callback) ->
      @events.on event, callback

  return CurrencyInput