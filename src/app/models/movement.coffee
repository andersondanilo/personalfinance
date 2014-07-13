define ['components/model', 'services/date', 'services/currency', 'collections/parcel'], (Model, dateService, currencyService, ParcelCollection) ->
  
  class Movement extends Model
    database: require 'config/database'
    storeName: 'movements'

    defaults:
      id: '',
      movement_type: 'expense', # income | expense
      parcel_count: '',
      repeated: false,
      cycle_type: 'month', # day| week | month
      cycle_interval: '1',
      expiration_day: '',
      create_date: '',
      update_date: '',
      status: '1',
      start_date: dateService.format('Y-m-d'),
      value: '',
      description: ''

    computeds: 
      edit_value:
        get: ->
          value = @get('value')
          return currencyService.formatComma(value)

        set: (newvalue) ->
          if newvalue is ''
            return {value:''}
          newvalue = newvalue.replace(',', '.')
          aux = newvalue.split('.')
          newvalue = aux.shift()
          if aux.length > 0
            newvalue += '.'
          for n in aux
            newvalue += n.replace(/[^0-9]/g,'')
          newvalue = Number(newvalue)
          if isNaN(newvalue)
            newvalue = ''
          return {value: newvalue}

      repeatedDisplay: ->
        if this.get('repeated')
          return ''
        else
          return 'none'

    fetchParcels: (params2) ->
      if !@parcelCollection
        @parcelCollection = new ParcelCollection

      params = {
          conditions: {'movement_id': @get('id')}
      }

      for k of params2
        if typeof(params[k]) == 'undefined'
          params[k] = params2[k]

      @parcelCollection.fetch params

    getParcelCollection: ->
      if @parcelCollection
        return @parcelCollection
      throw new Error('You need to fetchParcels')

    validate: (attrs) ->
      i18n = require 'i18n'
      errors = {}
      if !attrs.description
        errors.description = i18n.t 'validate.description_required'

      if !attrs.value
        errors.value = i18n.t 'validate.value_is_required'

      if attrs.cycle_type && (attrs.cycle_type != 'day' && attrs.cycle_type != 'week' && attrs.cycle_type != 'month')
        errors.value = i18n.t 'validate.invalid_type_of_repeat_cycle'

      if attrs.repeated || attrs.parcel_count > 1
        if !attrs.expiration_day
          errors.value = i18n.t 'validate.expiration_day_is_required'
        if !attrs.cycle_interval
          errors.value = i18n.t 'validate.repetition_interval_is_required'

      if attrs.start_date
        start_date_obj = dateService.createFromFormat('Y-m-d', attrs.start_date)
        if !start_date_obj
          errors.start_date = i18n.t 'validate.invalid_start_date'

      if !_.isEmpty(errors)
        return errors

  return Movement