define ['moment'], (moment) ->

  class DateService

    createFromFormat: (format, str) ->
      moment(str, format).toDate()

    format: (format, date) ->
      if not date
        date = new Date()
      moment(date).format(format)

    addMonth: (dateObj, months=1) ->
      months = Number(months)
      actualDay = @getDay(dateObj)
      dateObj.setDate(1)
      dateObj.setMonth(dateObj.getMonth()+months)
      bestDay = Math.min actualDay, @getLastDay(dateObj)
      dateObj.setDate(bestDay)
      return dateObj

    addDay: (dateObj, days=1) ->
      days = Number(days)
      dateObj.setDate(dateObj.getDate()+days)
      return dateObj

    setDay: (dateObj, day) ->
      day = Number(day)
      bestDay   = Math.min day, @getLastDay(dateObj)
      dateObj.setDate(bestDay)

    getDay: (dateObj) ->
      return dateObj.getDate()

    getLastDay: (dateObj) ->
      d = new Date(dateObj.getYear(), dateObj.getMonth()+1, 0)
      return d.getDate()

  return new DateService