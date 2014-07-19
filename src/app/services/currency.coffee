define ->

  class CurrencyService

    parse: (number) ->
      null

    getPreffix: ->
      return 'R$'

    getComma: ->
      return ','

    format: (value) ->
      return @getPreffix() + " " + Number(value).toFixed(2).replace('.', @getComma())




  return new CurrencyService