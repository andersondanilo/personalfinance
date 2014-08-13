Cache = requirejs 'components/cache'

describe 'Cache', ->

  it 'Should set and get sync', (done) ->
    @timeout(5000)
    cache = new Cache()
    expect(cache.has('name')).to.be.false
    expect(cache.get('name')).to.be.undefined
    cache.set('name', 'test')
    expect(cache.get('name')).to.be.eql('test')
    done()

  it 'Shoud get async', (done) ->
    @timeout(5000)
    cache = new Cache()
    expect(cache.has('name')).to.be.false

    cache.get 'name', (value) ->
      expect(value).to.be.undefined

      cache.set('name', 'test')

      cache.get 'name', (value) ->
        expect(value).to.be.eql('test')
        done()

  it 'Shoud wait pending', (done) ->
    @timeout 5000
    cache = new Cache()
    expect(cache.has('name')).to.be.false

    expect(cache.isPending('name')).to.be.false

    cache.insertPending 'name'

    expect(cache.isPending('name')).to.be.true

    success = _.after 3, ->
      setTimeout(->
        done()
      , 50)

    cache.get 'name', (value) ->
      expect(value).to.be.eql('test1')
      success()

    cache.get 'name', (value) ->
      expect(value).to.be.eql('test1')
      success()

    cache.get 'name', (value) ->
      expect(value).to.be.eql('test1')
      success()

    cache.set 'name', 'test1'

    expect(cache.isPending('name')).to.be.false 
