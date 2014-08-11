define ['components/model', 'underscore', 'localstorage'], (Model, _, localstorage) ->

  class Configuration extends Model

    defaults:
      currency: '$'
      decimal_separator: ','
      thousands_separator: '.'

    validate: (attrs) ->
      i18n = require 'i18n'
      errors = {}

      if !attrs.currency
        errors.currency = i18n.t('validate.currency_required')
      else
        if String(attrs.currency).length > 3
          errors.currency = i18n.t('validate.the_limit_are_3_character')

      if !attrs.decimal_separator
        errors.decimal_separator = i18n.t('validate.decimal_separator_required')

      if !attrs.thousands_separator
        errors.thousands_separator = i18n.t('validate.thousands_separator_required')

      if !_.isEmpty(errors)
        return errors

  return Configuration