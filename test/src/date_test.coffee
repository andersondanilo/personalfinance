dateService  = requirejs 'services/date'

describe 'DateService', ->
  it 'Should format date', ->
    date = new Date(2014, 2, 5)
    str  = dateService.format('YYYY-MM-DD', date)
    expect(str).to.be.eql('2014-03-05')

    date = new Date(2014, 11, 30)
    str  = dateService.format('DD/MM/YYYY', date)
    expect(str).to.be.eql('30/12/2014')

  it 'Should create from format', ->
    date   = new Date(2014, 11, 30)
    result = dateService.createFromFormat('DD/MM/YYYY', '30/12/2014')
    expect(result).to.be.eql(date)

  it 'Should create from format YYYY-MM-DD', ->
    date   = new Date(2014, 11, 30)
    result = dateService.createFromFormat('YYYY-MM-DD', '2014-12-30')
    expect(result.getDate()).to.be.eql(30)
    expect(result).to.be.eql(date)

  it 'Should add month', ->
    date = new Date(2014, 11, 31)
    dateService.addMonth(date)
    expect(date).to.be.eql(new Date(2015, 0, 31))

    date = new Date(2015, 0, 31)
    dateService.addMonth(date)
    expect(date).to.be.eql(new Date(2015, 1, 28))

    date = new Date(2014, 11, 31)
    dateService.addMonth(date, 2)
    expect(date).to.be.eql(new Date(2015, 1, 28))

  it 'Shoud set day', ->
    date = new Date(2014, 11, 31)
    dateService.setDay(date, 40)
    expect(date).to.be.eql(new Date(2014, 11, 31))

    date = new Date(2014, 1, 1)
    dateService.setDay(date, 40)
    expect(date).to.be.eql(new Date(2014, 1, 28))

    date = new Date(2014, 1, 1)
    dateService.setDay(date, 28)
    expect(date).to.be.eql(new Date(2014, 1, 28))

    date = new Date(2014, 1, 1)
    dateService.setDay(date, 25)
    expect(date).to.be.eql(new Date(2014, 1, 25))