define ->

  class CurrencyService

    parse: (number) ->
      null

    formatComma: (value) ->
      # Todo: internacionalizado
      if value is '' || value is null
        return ''
      display = String(value).replace('.', ',')
      display = display.replace(/[^0-9.,]/g, '')
      return display


  return new CurrencyService