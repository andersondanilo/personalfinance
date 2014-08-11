define ['services/configuration'], (configurationService) ->

  class CurrencyService

    getPreffix: ->
      return configurationService.getCurrency()

    getComma: ->
      return configurationService.getDecimalSeparator()

    getThousands: ->
      return configurationService.getThousandsSeparator()

    formatThousands: (number, separator) ->
      separator = separator || @getThousands()
      number = String(number)
      result = number.split('').reverse().join('').replace(/([0-9]{3})/g, '$1'+separator)
      result = result.replace(new RegExp('\\'+separator+'$'),'').split('').reverse().join('')
      return result

    format: (value) ->
      number_result = Number(value).toFixed(2).replace('.', @getComma())

      aux = number_result.split(@getComma())
      aux[0] = @formatThousands(aux[0])

      number_result = aux.join(@getComma())

      return @getPreffix() + " " + number_result

  return new CurrencyService
