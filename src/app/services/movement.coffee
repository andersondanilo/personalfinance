define ['backbone', 'underscore', 'collections/movement', 'collections/parcel', 'models/parcel', 'services/date'], (Backbone, _, MovementCollection, parcelCollection, Parcel, dateService) ->

  class MovementService
    createMovement: (movement, callbacks={}) ->
      movement.save movement.toJSON(),
        success: ->
          # adicionamos as parcelas
          # Qual o problema?
          # - Precisamos cadastrar o movimento e suas respectivas parcelas
          # E que há nisso?
          # Qual a primeira parcela?
          # - A "start_date" do movimento
          #   - E se o dia de vencimento for diferente
          #     - Só vai valer nas próximas parcelas
          # - E qual a última parcela
          #   - Temos o parcelCount, só precisamos saber somar meses

          currentDate  = dateService.createFromFormat 'Y-m-d', movement.get('start_date')
          parcelCount  = if movement.get('parcel_count') then movement.get('parcel_count') else 1

          parcelSuccess = null
          parcelError   = null

          if callbacks.success
            parcelSuccess = _.after(parcelCount, callbacks.success)

          if callbacks.errors
            parcelError = _.after(parcelCount, callbacks.errors)

          for i in [1..parcelCount]
            # Cadastramos a parcela
            parcel = new Parcel
              movement_id: movement.get('id')
              description: movement.get('description')
              parcel_number: i
              value: movement.get('value')
              date: dateService.format('Y-m-d', currentDate)
              expiration_date: dateService.format('Y-m-d', currentDate)
              payment_date: ''
              create_date: dateService.format('Y-m-d H:i:s')
              update_date: dateService.format('Y-m-d H:i:s')

            if parcelCount > 0
              if movement.get('cycle_type') == 'day'
                dateService.addDay currentDate, movement.get('cycle_interval')

              if movement.get('cycle_type') == 'week'
                dateService.addDay currentDate, movement.get('cycle_interval') * 7

              if movement.get('cycle_type') == 'month'
                dateService.addMonth currentDate, movement.get('cycle_interval')
                dateService.setDay currentDate, movement.get('expiration_day')

            parcel.save parcel.toJSON(),
              success: ->
                parcelSuccess()
              error: ->
                parcelError()
        error: ->
          if callbacks.error
            callbacks.error()

  return new MovementService()