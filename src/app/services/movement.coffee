define ['backbone', 'underscore', 'collections/movement', 'collections/parcel', 'models/parcel', 'services/date'], (Backbone, _, MovementCollection, parcelCollection, Parcel, dateService) ->

  MONTHS_PRE_REGISTER = 5

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
            # Cadastramos a parcela
            parcel = new Parcel
              movement_id: movement.get('id')
              movement_type: movement.get('movement_type')
              description: movement.get('description')
              parcel_number: i
              value: movement.get('value')
              date: dateService.format('YYYY-MM-DD', currentDate)
              payment_date: ''
              create_date: dateService.format('YYYY-MM-DD HH:mm:ss')
              update_date: dateService.format('YYYY-MM-DD HH:mm:ss')

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
                if parcelSuccess
                  parcelSuccess()
              error: ->
                if parcelError
                  parcelError()
        error: ->
          if callbacks.error
            callbacks.error()

    processAllInfinite: (callbacks={}) ->
      collection = new MovementCollection()
      collection.fetch
        conditions: {repeated:true}
        success: =>
          models = collection.filter (m) =>
            m.get('is_infinite')

          triggerSuccess = _.after models.length, ->
            if callbacks.success
              callbacks.success()

          triggerError = ->
            if callbacks.error
              callbacks.error()

          for model in models:
            @proccessInfinite model, {
              success: triggerSuccess,
              error: triggerError
            }

          if callbacks.success:
            callbacks.success.apply this, arguments
        error: ->
          if callbacks.error:
            callbacks.error.apply this, arguments

    proccessInfinite: (model, callbacks) ->
      if not model
        throw new Error 'model is required'
      model.fetchParcels
        success: ->
          parcels = model.getParcelCollection().models

          lastParcel = parcels.pop()

          if lastParcel
            lastDate = lastParcel.get('date_obj')
            today = new Date()
            
          else
            model.destroy()
        error: ->
          if callbacks.error
            callbacks.error()


  return new MovementService()