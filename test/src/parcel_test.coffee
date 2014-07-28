Movement = requirejs 'models/movement'
Parcel = requirejs 'models/parcel'
MovementCollection = requirejs 'collections/movement'
ParcelCollection = requirejs 'collections/parcel'
movementService = requirejs 'services/movement'
parcelService = requirejs 'services/parcel'

describe 'ParcelService', ->

  it 'Should save one', (done) ->
    model = new Parcel
    model.set {
      description: 'Olá Mundo'
      value: 10.50
      date: '2014-02-05'
    }
    model.save model.toJSON(), {
      success: ->
        model.set date:'2014-03-05'
        parcelService.saveOne model, {
          success: ->
            model2 = new Parcel id:model.get('id')
            model2.fetch {
              success: ->
                expect(model2.get('date')).to.be.eql '2014-03-05'
                done()
              error: ->
                expect(false).to.be.eql(true)
                done()
            }
          error: ->
            expect(false).to.be.eql(true)
            done()
        }
      error: ->
        expect(false).to.be.eql(true)
        done()
    }

  it 'Should save next', (done) ->
    @timeout(8000)
    movement = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: true
      parcel_count: 5
      cycle_type: 'month'
      cycle_interval: 1
      expiration_day: 31
      start_date: '2014-01-01'
    })
    movementService.createMovement movement,
      success: ->
        movement.fetchParcels {
          success: ->
            parcels = movement.getParcelCollection().models

            expect(parcels.length).to.be.eql(5)
            expect(parcels[0].get('date')).to.be.eql('2014-01-01')
            expect(parcels[1].get('date')).to.be.eql('2014-02-28')
            expect(parcels[2].get('date')).to.be.eql('2014-03-31')
            expect(parcels[3].get('date')).to.be.eql('2014-04-30')
            expect(parcels[4].get('date')).to.be.eql('2014-05-31')

            parcel = parcels[2]
            parcel.set
              date: '2014-03-15'
              description: 'Yes We Can'

            parcelService.saveNext parcel, {
              success: ->
                movement.fetch {
                  success: ->
                    movement.fetchParcels {
                      success: ->
                        parcels = movement.getParcelCollection().models

                        continueCallback = _.after parcels.length, =>
                          expect(movement.get('description')).to.be.eql('Yes We Can')

                          expect(parcels.length).to.be.eql(5)
                          expect(parcels[0].get('date')).to.be.eql('2014-01-01')
                          expect(parcels[1].get('date')).to.be.eql('2014-02-28')
                          expect(parcels[2].get('date')).to.be.eql('2014-03-15')
                          expect(parcels[3].get('date')).to.be.eql('2014-04-15')
                          expect(parcels[4].get('date')).to.be.eql('2014-05-15')
                          done()

                        expect(parcels.length).to.be.eql(5)

                        for k of parcels
                          do (k) =>
                            p = parcels[k]
                            p.fetch
                              success: =>
                                if k >= 2
                                  expect(p.get('description')).to.be.eql('Yes We Can')
                                else
                                  expect(p.get('description')).to.be.eql('My Repeated Model')
                                continueCallback()

                      error: (c,e)->
                        expect('error').to.be.false
                        done()
                    }
                  error: (c,e)->
                    expect('error').to.be.false
                    done()
                }
              error: (c,e)->
                expect('error').to.be.false
                done()
            }
          error: (c,e)->
            expect('error').to.be.false
            done()
        }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()

  it 'Should save all', (done) ->
    @timeout(8000)
    movement = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: true
      parcel_count: 5
      cycle_type: 'month'
      cycle_interval: 1
      expiration_day: 31
      start_date: '2014-01-01'
    })
    movementService.createMovement movement,
      success: ->
        movement.fetchParcels {
          success: ->
            parcels = movement.getParcelCollection().models

            expect(parcels.length).to.be.eql(5)
            expect(parcels[0].get('date')).to.be.eql('2014-01-01')
            expect(parcels[1].get('date')).to.be.eql('2014-02-28')
            expect(parcels[2].get('date')).to.be.eql('2014-03-31')
            expect(parcels[3].get('date')).to.be.eql('2014-04-30')
            expect(parcels[4].get('date')).to.be.eql('2014-05-31')

            parcel = parcels[2]
            parcel.set
              date: '2014-03-15'
              description: 'Yes We Can'

            parcelService.saveAll parcel, {
              success: ->
                movement.fetch {
                  success: ->
                    movement.fetchParcels {
                      success: ->
                        parcels = movement.getParcelCollection().models

                        continueCallback = _.after parcels.length, =>
                          expect(movement.get('description')).to.be.eql('Yes We Can')

                          expect(parcels.length).to.be.eql(5)
                          expect(parcels[0].get('date')).to.be.eql('2014-01-15')
                          expect(parcels[1].get('date')).to.be.eql('2014-02-15')
                          expect(parcels[2].get('date')).to.be.eql('2014-03-15')
                          expect(parcels[3].get('date')).to.be.eql('2014-04-15')
                          expect(parcels[4].get('date')).to.be.eql('2014-05-15')
                          done()

                        for k of parcels
                          do (k) =>
                            p = parcels[k]
                            p.fetch
                              success: =>
                                expect(p.get('description')).to.be.eql('Yes We Can')
                                continueCallback()

                      error: (c,e)->
                        expect('error').to.be.false
                        done()
                    }
                  error: (c,e)->
                    expect('error').to.be.false
                    done()
                }
              error: (c,e)->
                expect('error').to.be.false
                done()
            }
          error: (c,e)->
            expect('error').to.be.false
            done()
        }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()





















  it 'Should remove one', (done) ->
    model = new Parcel
    model.set {
      description: 'Olá Mundo'
      value: 10.50
      date: '2014-02-05'
    }
    model.save model.toJSON(), {
      success: ->
        model.set date:'2014-03-05'
        parcelService.removeOne model, {
          success: ->
            model2 = new Parcel id:model.get('id')
            model2.fetch {
              success: ->
                expect(false).to.be.true
                done()
              error: (model, msg) ->
                expect(msg).to.be.eql('Not Found')
                done()
            }
          error: ->
            expect(false).to.be.true
            done()
        }
      error: ->
        expect(false).to.be.true
        done()
    }

  it 'Should remove next', (done) ->
    @timeout(8000)
    movement = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: true
      parcel_count: 5
      cycle_type: 'month'
      cycle_interval: 1
      expiration_day: 31
      start_date: '2014-01-01'
    })
    movementService.createMovement movement,
      success: ->
        movement.fetchParcels {
          success: ->
            parcels = movement.getParcelCollection().models

            expect(parcels.length).to.be.eql(5)
            expect(parcels[0].get('date')).to.be.eql('2014-01-01')
            expect(parcels[1].get('date')).to.be.eql('2014-02-28')
            expect(parcels[2].get('date')).to.be.eql('2014-03-31')
            expect(parcels[3].get('date')).to.be.eql('2014-04-30')
            expect(parcels[4].get('date')).to.be.eql('2014-05-31')

            parcel = parcels[2]
            parcel.set
              date: '2014-03-15'
              description: 'Yes We Can'

            parcelService.removeNext parcel, {
              success: ->
                movement.fetch {
                  success: ->
                    movement.fetchParcels {
                      success: ->
                        parcels = movement.getParcelCollection().models

                        expect(movement.get('description')).to.be.eql('My Repeated Model')

                        expect(parcels.length).to.be.eql(2)
                        expect(parcels[0].get('date')).to.be.eql('2014-01-01')
                        expect(parcels[1].get('date')).to.be.eql('2014-02-28')
                        done()

                      error: (c,e)->
                        expect('error').to.be.false
                        done()
                    }
                  error: (c,e)->
                    expect('error').to.be.false
                    done()
                }
              error: (c,e)->
                expect('error').to.be.false
                done()
            }
          error: (c,e)->
            expect('error').to.be.false
            done()
        }
      error: (collection, error)->
        expect(error).to.be.undefined
        done()


  it 'Should remove all', (done) ->
    @timeout(8000)
    movement = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: true
      parcel_count: 5
      cycle_type: 'month'
      cycle_interval: 1
      expiration_day: 31
      start_date: '2014-01-01'
    })
    movementService.createMovement movement,
      success: ->
        movement.fetchParcels {
          success: ->
            parcels = movement.getParcelCollection().models

            expect(parcels.length).to.be.eql(5)
            expect(parcels[0].get('date')).to.be.eql('2014-01-01')
            expect(parcels[1].get('date')).to.be.eql('2014-02-28')
            expect(parcels[2].get('date')).to.be.eql('2014-03-31')
            expect(parcels[3].get('date')).to.be.eql('2014-04-30')
            expect(parcels[4].get('date')).to.be.eql('2014-05-31')

            parcel = parcels[2]

            old_movement_id = parcel.get('movement_id')

            parcelService.removeAll parcel, {
              success: ->
                movement.fetch {
                  success: ->
                    expect('success').to.be.false
                  error: (c, message)->
                    expect(message).to.be.eql('Not Found')
                    collection = new ParcelCollection()
                    collection.fetch
                      conditions:
                        movement_id: old_movement_id
                      success: ->
                        expect(collection.models.length).to.be.eql(0)
                        done()
                      error: (m, message) ->
                        expect(message).to.be.undefined
                        done()
                }
              error: (c,e)->
                expect('removeAll').to.be.true
                done()
            }
          error: (c,e)->
            expect('fetchParcels').to.be.true
            done()
        }
      error: (collection, error)->
        expect('createMovement').to.be.true
        done()
