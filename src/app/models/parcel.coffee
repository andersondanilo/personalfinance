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
      paid: false,
      status: '1',
      create_date: '',
      update_date: ''

    computeds:
      color: ->
        if @get('paid')
          return '#666666'

        if @get('movement_type') == 'income'
          return '#2EB944'
        else
          return '#E22A00'

      date_obj:
        get: ->
          return dateService.createFromFormat('YYYY-MM-DD', @get('date'))
        set: (value) ->
          return {date:dateService.format('YYYY-MM-DD', value)}

      date_formatted: ->
        return dateService.format('LL', @get('date_obj'))

      value_formatted: ->
        return currencyService.format(@get('value'))

      route_update: ->
        return "#parcel/update/#{@get('id')}"

    fetchMovement: (callbacks) ->
      cache = require('app').cache

      key = "movement_model_#{@get('movement_id')}"

      if cache.has(key) or cache.isPending(key)
        cache.get key, (value) ->
          callbacks.success value
        return true

      cache.insertPending(key)

      require ['models/movement'], (Movement) =>
        movement = new Movement id:@get('movement_id')
        movement.fetch
          success: (model) ->
            cache.set(key, model)
            callbacks.success.apply(this, arguments)
          error: ->
            callbacks.error.apply(this, arguments)

    validate: (attrs) ->
      i18n = require 'i18n'
      errors = {}

      if !attrs.description
        errors.description = i18n.t('validate.description_required')

      if !attrs.value || !Number(attrs.value)
        errors.value = i18n.t 'validate.value_is_required'

      if !attrs.date
        errors.description = i18n.t('validate.date_required')
      else
        date_obj = dateService.createFromFormat('YYYY-MM-DD', attrs.date)
        if !date_obj
          errors.start_date = i18n.t 'validate.invalid_date'

      if !_.isEmpty(errors)
        return errors

  return Parcel