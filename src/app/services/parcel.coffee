define ['backbone', 'underscore', 'collections/movement', 'collections/parcel', 'models/parcel', 'models/movement', 'services/date'], (Backbone, _, MovementCollection, ParcelCollection, Parcel, Movement, dateService) ->

  class ParcelService
    _saveFrom: (model_target, model_copied, callbacks) ->
      for name in ['description', 'value', 'paid']
        if model_copied.hasChanged(name)
          if String(model_target.get(name)) != String(model_copied.get(name))
            set = {}
            set[name] = model_copied.get name
            model_target.set(set)

      if not model_target.get('paid')
        if model_copied.hasChanged('date')
          date1 = model_target.get 'date_obj'
          date2 = model_copied.get 'date_obj'
          day1 = dateService.getDay date1
          day2 = dateService.getDay date2

          if day1 != day2
            dateService.setDay date1, day2
            model_target.set {'date_obj':date1}

      @_saveParcel model_target, callbacks

    _saveMovementFromParcel: (model_copied, callbacks) ->
      model_target = new Movement {id:model_copied.get('movement_id')}
      model_target.fetch {
        success: ->
          for name in ['description', 'value']
            if model_copied.hasChanged(name)
              if model_target.get(name) != model_copied.get(name)
                set = {}
                set[name] = model_copied.get name
                model_target.set(set)

          if model_copied.hasChanged('date')
            day_copied = model_copied.get('date_obj').getDay()
            if model_target.get('expiration_day') != day_copied
              model_target.set({'expiration_day':day_copied})

          model_target.save model_target.toJSON(), callbacks
      }

    _saveParcel: (model, callbacks) ->
      model.save model.toJSON(),
        success: ->
          require('app').events.trigger "update:parcel", model
          if callbacks and callbacks.success
            callbacks.success.apply this, arguments
        error: ->
          if callbacks and callbacks.error
            callbacks.error.apply this, arguments

    saveOne: (model, callbacks) ->
      # Salva apenas esta parcela
      @_saveParcel model, callbacks

    _saveByCond: (model, callbacks={}, condition) ->
      # Salva esta parcela e as próximas, além de atualizar o movement
      collection = new ParcelCollection()
      collection.fetch {
        conditions:
          'movement_id': model.get('movement_id')
        success: =>
          models = collection.filter (m) =>
            return condition(m)

          if callbacks and callbacks.success
            triggerSuccess = _.after models.length, callbacks.success
          else
            triggerSuccess = null

          _.each models, (m) =>
            if m.get('id') == model.get('id')
              null # Save later
            else
              @_saveFrom m, model, {
                success: triggerSuccess
                error: callbacks.error
              }

          @_saveMovementFromParcel model, {
            success: =>
              @_saveParcel model, {
                success: triggerSuccess
                error: callbacks.error
              }
            error: callbacks.error
          }
      }

    saveNext: (model, callbacks={}) ->
      @_refreshModelChanged model,
        success: =>
          @_saveByCond model, callbacks, (m) =>
            return m.get('parcel_number') >= model.get('parcel_number')
        error: ->
          if callbacks.error
            callbacks.error()


    saveAll: (model, callbacks) ->
      @_refreshModelChanged model,
        success: =>
          @_saveByCond model, callbacks, (m) =>
            return true
        error: ->
          if callbacks.error
            callbacks.error()

    _refreshModelChanged: (model, callbacks={}) ->
      if model.get('id')
        model2 = new Parcel id:model.get('id')

        model2.fetch
          success: ->
            for k of model.attributes
              if String(model.get(k)) != String(model2.get(k))
                model.changed[k] = model.get(k)
                model._previousAttributes = model2.get(k)

            if callbacks.success
              callbacks.success()
          error: ->
            if callbacks.error
              callbacks.error()
      else
        if callbacks.success
          callbacks.success()

    _removeMovementFromParcel: (model_copied, callbacks) ->
      model_target = new Movement {id:model_copied.get('movement_id')}
      model_target.fetch {
        success: ->
          model_target.destroy callbacks
      }

    _removeParcel: (model, callbacks) ->
      require('app').events.trigger "delete:parcel", model
      model.destroy callbacks

    removeOne: (model, callbacks) ->
      # Salva apenas esta parcela
      @_removeParcel model, callbacks

    _removeByCond: (model, callbacks={}, removeMovement, condition) ->
      # Salva esta parcela e as próximas, além de atualizar o movement
      collection = new ParcelCollection()
      collection.fetch {
        conditions:
          'movement_id': model.get('movement_id')
        success: =>
          models = collection.filter (m) =>
            return condition(m)

          if callbacks and callbacks.success
            triggerSuccess = _.after models.length, callbacks.success
          else
            triggerSuccess = null

          _.each models, (m) =>
            if m.get('id') == model.get('id')
              null # Remove later
            else
              @_removeParcel m, {
                success: triggerSuccess
                error: callbacks.error
              }

          if removeMovement
            @_removeMovementFromParcel model, {
              success: =>
                @_removeParcel model, {
                  success: triggerSuccess
                  error: callbacks.error
                }
              error: callbacks.error
            }
          else
            @_removeParcel model, {
              success: triggerSuccess
              error: callbacks.error
            }

      }

    removeNext: (model, callbacks) ->
      @_removeByCond model, callbacks, false, (m) =>
        return m.get('parcel_number') >= model.get('parcel_number')

    removeAll: (model, callbacks) ->
      @_removeByCond model, callbacks, true, (m) =>
        return true

  return new ParcelService()