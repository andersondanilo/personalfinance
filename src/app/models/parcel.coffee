define ['components/model', 'services/date'], (Model, dateService) ->

  class Parcel extends Model
    database: require 'config/database'
    storeName: 'parcels'

    defaults:
      id: '',
      movement_id: '', # income | expense
      description: '',
      parcel_number: '',
      value: '',
      date: '',
      payment_date: '',
      expiration_date: '',
      status: '1',
      create_date: '',
      update_date: ''

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