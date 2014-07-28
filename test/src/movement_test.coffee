Movement            = requirejs 'models/movement'
MovementCollection  = requirejs 'collections/movement'
ParcelCollection    = requirejs 'collections/parcel'
movementService     = requirejs 'services/movement'
dateService         = requirejs 'services/date'

movementCollection = new MovementCollection
parcelCollection   = new ParcelCollection

describe 'Movement', ->
  it 'Should valid', ->
    model = new Movement()
    result = model.validate {
      description: 'Teste',
      value: '100.2'
    }
    expect(result).to.be.undefined

  it 'Shoud invalid', ->
    model = new Movement()
    result = model.validate({
      'description': 'Olá Mundo',
      'value': ''
    })
    expect(result).to.be.not.undefined

describe 'MovementService', ->
  
  it 'Should not repeat', (done) ->
    @timeout(5000)
    model = new Movement({
      'description': 'Credit Card - It',
      'value': '10.0'
    })
    movementCollection.set([])
    movementService.createMovement model,
      success: ->
        movementCollection.fetch {
          conditions: {'description': 'Credit Card - It'}
          success: ->
            models = movementCollection.models
            expect(models.length).to.be.eql(1)

            model = models[0]
            model.fetchParcels {
              success: ->
                parcels = model.getParcelCollection().models

                expect(parcels.length).to.be.eql(1)
                done()
              error: (c,e)->
                expect(e).to.be.eql('')
                done()
            }
          error: (collection, error)->
            expect(error).to.be.undefined
            done()
        }
      error: (c, e) ->
        expect(e).to.be.eql('')
        done()

  it 'Should repeat monthly', (done) ->
    @timeout(5000)
    model = new Movement({
      description: 'Its is My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: 5
      cycle_type: 'month'
      cycle_interval: 1
      expiration_day: 31
      start_date: '2014-01-01'
    })
    movementService.createMovement model,
      success: ->
        model.fetchParcels {
          success: ->
            parcels = model.getParcelCollection().models

            expect(parcels.length).to.be.eql(5)

            expect(parcels[0].get('date')).to.be.eql('2014-01-01')
            expect(parcels[1].get('date')).to.be.eql('2014-02-28')
            expect(parcels[2].get('date')).to.be.eql('2014-03-31')
            expect(parcels[3].get('date')).to.be.eql('2014-04-30')
            expect(parcels[4].get('date')).to.be.eql('2014-05-31')

            expect(parcels[0].get('parcel_number')).to.be.eql(1)
            expect(parcels[1].get('parcel_number')).to.be.eql(2)
            expect(parcels[2].get('parcel_number')).to.be.eql(3)
            expect(parcels[3].get('parcel_number')).to.be.eql(4)
            expect(parcels[4].get('parcel_number')).to.be.eql(5)

            done()
          error: (c,e)->
            expect(e).to.be.eql('')
            done()
        }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should repeat, interval: two month', (done) ->
    @timeout(5000)
    model = new Movement({
      description: 'Its is My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: 5
      cycle_type: 'month'
      cycle_interval: 2
      expiration_day: 15
      start_date: '2014-01-01'
    })
    movementService.createMovement model,
      success: ->
        model.fetchParcels {
          success: ->
            parcels = model.getParcelCollection().models

            expect(parcels.length).to.be.eql(5)

            expect(parcels[0].get('date')).to.be.eql('2014-01-01')
            expect(parcels[1].get('date')).to.be.eql('2014-03-15')
            expect(parcels[2].get('date')).to.be.eql('2014-05-15')
            expect(parcels[3].get('date')).to.be.eql('2014-07-15')
            expect(parcels[4].get('date')).to.be.eql('2014-09-15')

            expect(parcels[0].get('parcel_number')).to.be.eql(1)
            expect(parcels[1].get('parcel_number')).to.be.eql(2)
            expect(parcels[2].get('parcel_number')).to.be.eql(3)
            expect(parcels[3].get('parcel_number')).to.be.eql(4)
            expect(parcels[4].get('parcel_number')).to.be.eql(5)

            done()
          error: (c,e)->
            expect(e).to.be.eql('')
            done()
        }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should repeat weekly', (done) ->
    @timeout(5000)
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: 5
      cycle_type: 'week'
      cycle_interval: 1
      expiration_day: 31
      start_date: '2014-01-01'
    })
    movementService.createMovement model,
      success: ->
          model.fetchParcels {
            success: ->
              parcels = model.getParcelCollection().models

              expect(parcels.length).to.be.eql(5)

              expect(parcels[0].get('date')).to.be.eql('2014-01-01')
              expect(parcels[1].get('date')).to.be.eql('2014-01-08')
              expect(parcels[2].get('date')).to.be.eql('2014-01-15')
              expect(parcels[3].get('date')).to.be.eql('2014-01-22')
              expect(parcels[4].get('date')).to.be.eql('2014-01-29')

              expect(parcels[0].get('parcel_number')).to.be.eql(1)
              expect(parcels[1].get('parcel_number')).to.be.eql(2)
              expect(parcels[2].get('parcel_number')).to.be.eql(3)
              expect(parcels[3].get('parcel_number')).to.be.eql(4)
              expect(parcels[4].get('parcel_number')).to.be.eql(5)

              done()
            error: (c,e)->
              expect(e).to.be.eql('')
              done()
          }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should repeat, interval: two week', (done) ->
    @timeout(5000)
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: 5
      cycle_type: 'week'
      cycle_interval: 2
      expiration_day: 31
      start_date: '2014-01-01'
    })
    movementService.createMovement model,
      success: ->
          model.fetchParcels {
            success: ->
              parcels = model.getParcelCollection().models

              expect(parcels.length).to.be.eql(5)

              expect(parcels[0].get('date')).to.be.eql('2014-01-01')
              expect(parcels[1].get('date')).to.be.eql('2014-01-15')
              expect(parcels[2].get('date')).to.be.eql('2014-01-29')
              expect(parcels[3].get('date')).to.be.eql('2014-02-12')
              expect(parcels[4].get('date')).to.be.eql('2014-02-26')

              expect(parcels[0].get('parcel_number')).to.be.eql(1)
              expect(parcels[1].get('parcel_number')).to.be.eql(2)
              expect(parcels[2].get('parcel_number')).to.be.eql(3)
              expect(parcels[3].get('parcel_number')).to.be.eql(4)
              expect(parcels[4].get('parcel_number')).to.be.eql(5)

              done()
            error: (c,e)->
              expect(e).to.be.eql('')
              done()
          }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should repeat daily', (done) ->
    @timeout(5000)
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: 5
      cycle_type: 'day'
      cycle_interval: 1
      expiration_day: 31
      start_date: '2014-01-01'
    })
    movementService.createMovement model,
      success: ->
          model.fetchParcels {
            success: ->
              parcels = model.getParcelCollection().models

              expect(parcels.length).to.be.eql(5)

              expect(parcels[0].get('date')).to.be.eql('2014-01-01')
              expect(parcels[1].get('date')).to.be.eql('2014-01-02')
              expect(parcels[2].get('date')).to.be.eql('2014-01-03')
              expect(parcels[3].get('date')).to.be.eql('2014-01-04')
              expect(parcels[4].get('date')).to.be.eql('2014-01-05')

              expect(parcels[0].get('parcel_number')).to.be.eql(1)
              expect(parcels[1].get('parcel_number')).to.be.eql(2)
              expect(parcels[2].get('parcel_number')).to.be.eql(3)
              expect(parcels[3].get('parcel_number')).to.be.eql(4)
              expect(parcels[4].get('parcel_number')).to.be.eql(5)

              done()
            error: (c,e)->
              expect(e).to.be.eql('')
              done()
          }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should repeat, interval: two day', (done) ->
    @timeout(5000)
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: 5
      cycle_type: 'day'
      cycle_interval: 2
      expiration_day: 31
      start_date: '2014-01-01'
    })
    movementService.createMovement model,
      success: ->
          model.fetchParcels {
            success: ->
              parcels = model.getParcelCollection().models

              expect(parcels.length).to.be.eql(5)

              expect(parcels[0].get('date')).to.be.eql('2014-01-01')
              expect(parcels[1].get('date')).to.be.eql('2014-01-03')
              expect(parcels[2].get('date')).to.be.eql('2014-01-05')
              expect(parcels[3].get('date')).to.be.eql('2014-01-07')
              expect(parcels[4].get('date')).to.be.eql('2014-01-09')

              expect(parcels[0].get('parcel_number')).to.be.eql(1)
              expect(parcels[1].get('parcel_number')).to.be.eql(2)
              expect(parcels[2].get('parcel_number')).to.be.eql(3)
              expect(parcels[3].get('parcel_number')).to.be.eql(4)
              expect(parcels[4].get('parcel_number')).to.be.eql(5)

              done()
            error: (c,e)->
              expect(e).to.be.eql('')
              done()
          }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should create Infinite', (done) ->
    @timeout(5000)
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: ''
      cycle_type: 'month'
      cycle_interval: 1
      expiration_day: 31
      start_date: '2014-01-01'
    })
    movementService.createMovement model,
      success: ->
          model.fetchParcels {
            success: ->
              parcels = model.getParcelCollection().models

              expect(parcels.length).to.be.eql(6)
              expect(parcels[0].get('date')).to.be.eql('2014-01-01')
              expect(parcels[1].get('date')).to.be.eql('2014-02-28')
              expect(parcels[2].get('date')).to.be.eql('2014-03-31')
              expect(parcels[3].get('date')).to.be.eql('2014-04-30')
              expect(parcels[4].get('date')).to.be.eql('2014-05-31')
              expect(parcels[5].get('date')).to.be.eql('2014-06-30')
              done()
            error: (c,e)->
              expect(e).to.be.eql('')
              done()
          }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should Process Infinite', (done) ->
    @timeout(5000)
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: ''
      cycle_type: 'month'
      cycle_interval: 1
      expiration_day: 15
      start_date: '2013-01-01'
    })
    movementService.createMovement model,
      success: ->
          model.fetchParcels {
            success: ->
              parcels = model.getParcelCollection().models

              expect(parcels.length).to.be.eql(6)
              expect(parcels[0].get('date')).to.be.eql('2013-01-01')
              expect(parcels[1].get('date')).to.be.eql('2013-02-15')
              expect(parcels[2].get('date')).to.be.eql('2013-03-15')
              expect(parcels[3].get('date')).to.be.eql('2013-04-15')
              expect(parcels[4].get('date')).to.be.eql('2013-05-15')
              expect(parcels[5].get('date')).to.be.eql('2013-06-15')

              movementService.processInfinite model,
                success: ->
                  model.fetchParcels {
                    success: ->
                      parcels = model.getParcelCollection().models

                      expect(parcels[0].get('date')).to.be.eql('2013-01-01')
                      expect(parcels[1].get('date')).to.be.eql('2013-02-15')
                      expect(parcels[2].get('date')).to.be.eql('2013-03-15')
                      expect(parcels[3].get('date')).to.be.eql('2013-04-15')
                      expect(parcels[4].get('date')).to.be.eql('2013-05-15')
                      expect(parcels[5].get('date')).to.be.eql('2013-06-15')

                      currentDate = dateService.createFromFormat 'YYYY-MM-DD', '2013-07-15'
                      todayDate = new Date()
                      nextDate = dateService.addMonth todayDate, 1
                      dateService.setDay nextDate, 15

                      i = 6
                      while currentDate <= nextDate
                        myDateStr = dateService.format 'YYYY-MM-DD', currentDate
                        expect(parcels[i].get('date')).to.be.eql(myDateStr)
                        i += 1
                        currentDate = dateService.addMonth currentDate, 1

                      done()

                    error: (c,e)->
                      expect(e).to.be.eql('')
                      done()
                  }

                error: ->
                  expect(false).to.be.true
                  done()

            error: (c,e)->
              expect(e).to.be.eql('')
              done()
          }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should Process All Infinite', (done) ->
    @timeout(17000)
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: ''
      cycle_type: 'month'
      cycle_interval: 1
      expiration_day: 15
      start_date: '2013-01-01'
    })
    movementService.createMovement model,
      success: ->
          model.fetchParcels {
            success: ->
              parcels = model.getParcelCollection().models

              expect(parcels.length).to.be.eql(6)
              expect(parcels[0].get('date')).to.be.eql('2013-01-01')
              expect(parcels[1].get('date')).to.be.eql('2013-02-15')
              expect(parcels[2].get('date')).to.be.eql('2013-03-15')
              expect(parcels[3].get('date')).to.be.eql('2013-04-15')
              expect(parcels[4].get('date')).to.be.eql('2013-05-15')
              expect(parcels[5].get('date')).to.be.eql('2013-06-15')

              movementService.processAllInfinite
                success: ->
                  model.fetchParcels {
                    success: ->
                      parcels = model.getParcelCollection().models

                      expect(parcels[0].get('date')).to.be.eql('2013-01-01')
                      expect(parcels[1].get('date')).to.be.eql('2013-02-15')
                      expect(parcels[2].get('date')).to.be.eql('2013-03-15')
                      expect(parcels[3].get('date')).to.be.eql('2013-04-15')
                      expect(parcels[4].get('date')).to.be.eql('2013-05-15')
                      expect(parcels[5].get('date')).to.be.eql('2013-06-15')

                      currentDate = dateService.createFromFormat 'YYYY-MM-DD', '2013-07-15'
                      todayDate = new Date()
                      nextDate = dateService.addMonth todayDate, 1
                      dateService.setDay nextDate, 15

                      i = 6
                      while currentDate <= nextDate
                        myDateStr = dateService.format 'YYYY-MM-DD', currentDate
                        expect(parcels[i].get('date')).to.be.eql(myDateStr)
                        i += 1
                        currentDate = dateService.addMonth currentDate, 1

                      done()

                    error: (c,e)->
                      expect(e).to.be.eql('')
                      done()
                  }

                error: ->
                  expect(false).to.be.true
                  done()

            error: (c,e)->
              expect(e).to.be.eql('')
              done()
          }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should Process Infinite, interval daily', (done) ->
    @timeout(5000)
    todayDate = new Date()
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: ''
      cycle_type: 'day'
      cycle_interval: 1
      expiration_day: 15
      start_date: dateService.format('YYYY-MM-DD', todayDate)
    })
    movementService.createMovement model,
      success: ->
          model.fetchParcels {
            success: ->
              parcels = model.getParcelCollection().models

              expect(parcels.length).to.be.eql(6)
              currentDate = new Date(todayDate)

              for parcel in parcels
                expect(parcel.get('date')).to.be.eql(dateService.format('YYYY-MM-DD', currentDate))
                dateService.addDay currentDate, 1

              movementService.processInfinite model,
                success: ->
                  model.fetchParcels {
                    success: ->
                      parcels = model.getParcelCollection().models

                      currentDate = new Date(todayDate)
              
                      for parcel in parcels
                        expect(parcel.get('date')).to.be.eql(dateService.format('YYYY-MM-DD', currentDate))
                        dateService.addDay currentDate, 1

                      expect(parcels.length).to.be.above 28
                      expect(parcels.length).to.be.least 32

                      done()

                    error: (c,e)->
                      expect(e).to.be.eql('')
                      done()
                  }

                error: ->
                  expect(false).to.be.true
                  done()

            error: (c,e)->
              expect(e).to.be.eql('')
              done()
          }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should Process Infinite, interval two day', (done) ->
    @timeout(5000)
    todayDate = new Date()
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: ''
      cycle_type: 'day'
      cycle_interval: 2
      expiration_day: 15
      start_date: dateService.format('YYYY-MM-DD', todayDate)
    })
    movementService.createMovement model,
      success: ->
          model.fetchParcels {
            success: ->
              parcels = model.getParcelCollection().models

              expect(parcels.length).to.be.eql(6)
              currentDate = new Date(todayDate)

              for parcel in parcels
                expect(parcel.get('date')).to.be.eql(dateService.format('YYYY-MM-DD', currentDate))
                dateService.addDay currentDate, 2

              movementService.processInfinite model,
                success: ->
                  model.fetchParcels {
                    success: ->
                      parcels = model.getParcelCollection().models

                      currentDate = new Date(todayDate)
              
                      for parcel in parcels
                        expect(parcel.get('date')).to.be.eql(dateService.format('YYYY-MM-DD', currentDate))
                        dateService.addDay currentDate, 2

                      expect(parcels.length).to.be.above 14
                      expect(parcels.length).to.be.least 16

                      done()

                    error: (c,e)->
                      expect(e).to.be.eql('')
                      done()
                  }

                error: ->
                  expect(false).to.be.true
                  done()

            error: (c,e)->
              expect(e).to.be.eql('')
              done()
          }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should Process Infinite, interval weekly', (done) ->
    @timeout(5000)
    todayDate = new Date()
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: ''
      cycle_type: 'week'
      cycle_interval: 1
      expiration_day: 15
      start_date: dateService.format('YYYY-MM-DD', todayDate)
    })
    movementService.createMovement model,
      success: ->
          model.fetchParcels {
            success: ->
              parcels = model.getParcelCollection().models

              expect(parcels.length).to.be.eql(6)
              currentDate = new Date(todayDate)

              for parcel in parcels
                expect(parcel.get('date')).to.be.eql(dateService.format('YYYY-MM-DD', currentDate))
                dateService.addDay currentDate, 7

              movementService.processInfinite model,
                success: ->
                  model.fetchParcels {
                    success: ->
                      parcels = model.getParcelCollection().models

                      currentDate = new Date(todayDate)
              
                      for parcel in parcels
                        expect(parcel.get('date')).to.be.eql(dateService.format('YYYY-MM-DD', currentDate))
                        dateService.addDay currentDate, 7

                      expect(parcels.length).to.be.above 3
                      expect(parcels.length).to.be.least 5

                      done()

                    error: (c,e)->
                      expect(e).to.be.eql('')
                      done()
                  }

                error: ->
                  expect(false).to.be.true
                  done()

            error: (c,e)->
              expect(e).to.be.eql('')
              done()
          }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should Process Infinite, interval two week', (done) ->
    @timeout(5000)
    todayDate = new Date()
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: 1
      parcel_count: ''
      cycle_type: 'week'
      cycle_interval: 2
      expiration_day: 15
      start_date: dateService.format('YYYY-MM-DD', todayDate)
    })
    movementService.createMovement model,
      success: ->
          model.fetchParcels {
            success: ->
              parcels = model.getParcelCollection().models

              expect(parcels.length).to.be.eql(6)
              currentDate = new Date(todayDate)

              for parcel in parcels
                expect(parcel.get('date')).to.be.eql(dateService.format('YYYY-MM-DD', currentDate))
                dateService.addDay currentDate, 14

              movementService.processInfinite model,
                success: ->
                  model.fetchParcels {
                    success: ->
                      parcels = model.getParcelCollection().models

                      currentDate = new Date(todayDate)
              
                      for parcel in parcels
                        expect(parcel.get('date')).to.be.eql(dateService.format('YYYY-MM-DD', currentDate))
                        dateService.addDay currentDate, 14

                      expect(parcels.length).to.be.above 3
                      expect(parcels.length).to.be.least 5

                      done()

                    error: (c,e)->
                      expect(e).to.be.eql('')
                      done()
                  }

                error: ->
                  expect(false).to.be.true
                  done()

            error: (c,e)->
              expect(e).to.be.eql('')
              done()
          }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()