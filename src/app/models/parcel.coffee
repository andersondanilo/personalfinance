define ['components/model', 'services/date', 'services/currency'], (Model, dateService, currencyService) ->

  class Parcel extends Model
    database: require 'config/database'
    storeName: 'parcels'

    defaults:
      id: '',
      movement_id: '',
      movement_type: '', # income | expense (usado para filtrar)
      description: '',
      parcel_number: '',
      value: '',
      date: '',
      payment_date: '',
      expiration_date: '',
      status: '1',
      create_date: '',
      update_date: ''

    computeds:

      color: ->
        if @get('movement_type') == 'income'
          return '#2EB944'
        else
          return '#E22A00'

      date_formatted: ->
        return dateService.format('d/m/Y', dateService.createFromFormat('Y-m-d', @get('date')))

      value_formatted: ->
        return currencyService.format(@get('value'))

      route_update: ->
        return "#parcel/update/#{@get('id')}"

    validate: (attrs) ->
      i18n = require 'i18n'
      errors = {}

      if !attrs.description
        errors.description = i18n.t('validate.description_required')

      if !attrs.date
        errors.description = i18n.t('validate.date_required')
      else
        date_obj = dateService.createFromFormat('Y-m-d', attrs.date)
        if !date_obj
          errors.start_date = i18n.t 'validate.invalid_date'

      if !_.isEmpty(errors)
        return errors

  return Parcel