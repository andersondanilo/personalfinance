Movement            = requirejs 'models/movement'
MovementCollection  = requirejs 'collections/movement'
ParcelCollection    = requirejs 'collections/parcel'
movementService     = requirejs 'services/movement'

movementCollection = new MovementCollection
parcelCollection   = new ParcelCollection

describe 'Movement', ->
  it 'Should valid', ->
    model = new Movement()
    result = model.validate({
      description: 'Teste',
      value: '100,2'
    })
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
                parcels = model.getParcelCollection().sortBy (p) ->
                  return Number(p.get('date').replace(/-/g, ''))

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

  it 'Should repeat', (done) ->
    @timeout(5000)
    model = new Movement({
      description: 'My Repeated Model'
      value: '10.0'
      repeated: true
      parcel_count: 5
      cycle_type: 'month'
      cycle_interval: 1
      expiration_day: 31
      start_date: '2014-01-01'
    })
    movementService.createMovement model,
      success: ->
        movementCollection.set([])
        movementCollection.fetch {
          conditions: {'description': 'My Repeated Model'}
          success: ->
            models = movementCollection.models
            expect(models.length).to.be.eql(1)

            model = models[0]
            model.fetchParcels {
              success: ->
                parcels = model.getParcelCollection().sortBy (p) ->
                  return Number(p.get('date').replace(/-/g, ''))

                expect(parcels.length).to.be.eql(5)
                expect(parcels[0].get('date')).to.be.eql('2014-01-01')
                expect(parcels[1].get('date')).to.be.eql('2014-02-28')
                expect(parcels[2].get('date')).to.be.eql('2014-03-31')
                expect(parcels[3].get('date')).to.be.eql('2014-04-30')
                expect(parcels[4].get('date')).to.be.eql('2014-05-31')
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