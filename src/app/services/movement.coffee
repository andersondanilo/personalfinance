define ['backbone', 'underscore', 'collections/movement', 'collections/parcel', 'models/parcel', 'services/date'], (Backbone, _, MovementCollection, parcelCollection, Parcel, dateService) ->

  MONTHS_PRE_REGISTER = 6
  logger = require('components/logger')

  class MovementService
    createMovement: (movement, callbacks={}) ->
      movement.save movement.toJSON(),
        success: =>
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

          currentDate  = dateService.createFromFormat 'YYYY-MM-DD', movement.get('start_date')
          isInfinite = movement.get('is_infinite')
          if isInfinite
            parcelCount = MONTHS_PRE_REGISTER
          else
            parcelCount = if movement.get('parcel_count') then movement.get('parcel_count') else 1

          parcelSuccess = null
          parcelError   = null

          if callbacks.success
            parcelSuccess = _.after(parcelCount, callbacks.success)

          if callbacks.errors
            parcelError = _.after(parcelCount, callbacks.errors)

          for i in [1..parcelCount]
            do (currentDate) =>
              @createParcelFromMovement movement, {
                'parcel_number': i,
                'date': dateService.format 'YYYY-MM-DD', currentDate
              }, {
                success: ->
                  if parcelSuccess
                    parcelSuccess()
                error: ->
                  if parcelError
                    parcelError()
              }

            if parcelCount > 0
              if movement.get('cycle_type') == 'day'
                dateService.addDay currentDate, movement.get('cycle_interval')

              if movement.get('cycle_type') == 'week'
                dateService.addDay currentDate, movement.get('cycle_interval') * 7

              if movement.get('cycle_type') == 'month'
                dateService.addMonth currentDate, movement.get('cycle_interval')
                dateService.setDay currentDate, movement.get('expiration_day')
        error: ->
          if callbacks.error
            callbacks.error()

    processAllInfinite: (callbacks={}) ->
      collection = new MovementCollection()
      logger.info 'processAllInfinite'
      collection.fetch
        conditions: {repeated:1}
        success: =>
          models = collection.filter (m) =>
            m.get('is_infinite')

          logger.info "Found #{models.length} models"

          if models.length == 0
            if callbacks.success
              callbacks.success()
          else
            triggerSuccess = _.after models.length, ->
              if callbacks.success
                callbacks.success.apply this, arguments

            triggerError = ->
              if callbacks.error
                callbacks.error.apply this, arguments

            for model in models
              @processInfinite model,
                success: triggerSuccess
                error: triggerError

        error: ->
          logger.warning "Error on fetch: ", arguments
          if callbacks.error
            callbacks.error.apply this, arguments

    processInfinite: (movement, callbacks) ->
      if not movement
        throw new Error 'movement is required'

      movement.fetchParcels
        success: =>
          parcels = movement.getParcelCollection().models

          lastParcel = parcels.pop()

          if lastParcel
            parcels.push(lastParcel) # para evitar o bug

            lastDate = lastParcel.get('date_obj')
            
            todayDate = new Date()

            nextDate = dateService.addMonth todayDate, 1

            currentDate = new Date lastDate.getTime()

            if movement.get('cycle_type') == 'day'
              dateService.addDay currentDate, Number(movement.get('cycle_interval')) || 1

            if movement.get('cycle_type') == 'week'
              dateService.addDay currentDate, Number(movement.get('cycle_interval')) * 7

            if movement.get('cycle_type') == 'month'
              currentDate = dateService.addMonth currentDate, 1
              dateService.setDay currentDate, movement.get('expiration_day')
              dateService.setDay nextDate, movement.get('expiration_day')

            queue = []
            count = 0

            parcel_number = Number(lastParcel.get('parcel_number')) + 1

            while currentDate <= nextDate
              do (currentDate) =>
                queue.push {
                  'date': dateService.format 'YYYY-MM-DD', currentDate
                  'parcel_number': parcel_number
                }
                
              if movement.get('cycle_type') == 'day'
                dateService.addDay currentDate, movement.get('cycle_interval')

              if movement.get('cycle_type') == 'week'
                dateService.addDay currentDate, movement.get('cycle_interval') * 7

              if movement.get('cycle_type') == 'month'
                currentDate = dateService.addMonth currentDate, 1
                dateService.setDay currentDate, movement.get('expiration_day')

                parcel_number += 1

            triggerSuccess = _.after queue.length, ->
              if callbacks.success
                callbacks.success.apply(this, arguments)

            triggerError = ->
              if callbacks.error
                callbacks.error.apply(this, arguments)

            if queue.length > 0
              for params in queue
                @createParcelFromMovement movement, params, {
                  success: triggerSuccess
                  error: triggerError
                }
            else
              if callbacks.success
                callbacks.success.apply(this, arguments)

          else
            movement.destroy()
            if callbacks.success
              callbacks.success.apply(this, arguments)

        error: ->
          if callbacks.error
            callbacks.error()


    createParcelFromMovement: (movement, params, callbacks) ->
      # Cadastramos a parcela
      parcel = new Parcel
        movement_id: movement.get('id')
        movement_type: movement.get('movement_type')
        description: movement.get('description')
        parcel_number: params['parcel_number']
        date: params['date']
        value: movement.get('value')
        create_date: dateService.format('YYYY-MM-DD HH:mm:ss')
        update_date: dateService.format('YYYY-MM-DD HH:mm:ss')

      parcel.save parcel.toJSON(),
        success: ->
          if callbacks.success
            callbacks.success.apply this, arguments

        error: ->
          if callbacks.error
            callbacks.error.apply this, arguments

  return new MovementService()