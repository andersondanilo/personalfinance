define ->

  HOUR = 1000 * 60 * 60
  DAY  = HOUR * 24
  WEEK = DAY * 7

  class DateService

    createFromFormat: (format, str) ->

      unless typeof (str) is "string"
        console.log "str must be string in createFromFormat"
        return false

      grupos = {}
      grupo_n = 0
      regexStr = "^"
      i = 0

      while i < format.length
        c = format[i]
        switch c
          when "d"
            regexStr += "([0-9]{2})"
            grupos["day"] = ++grupo_n
          when "m"
            regexStr += "([0-9]{2})"
            grupos["month"] = ++grupo_n
          when "Y"
            regexStr += "([0-9]{4})"
            grupos["year"] = ++grupo_n
          when "y"
            regexStr += "([0-9]{2})"
            grupos["year_two"] = ++grupo_n
          when "H"
            regexStr += "([0-9]{2})"
            grupos["hour"] = ++grupo_n
          when "i"
            regexStr += "([0-9]{2})"
            grupos["minute"] = ++grupo_n
          when "s"
            regexStr += "([0-9]{2})"
            grupos["second"] = ++grupo_n
          else
            regexStr += (c + "").replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1")
        i++
      regexStr += "$"
      re = new RegExp(regexStr)
      rs = str.match(re)
      return false  unless rs
      return false  if typeof (grupos["year"]) is "undefined" and typeof (grupos["year_two"]) is "undefined"
      year = null
      month = null
      day = null
      hour = null
      minute = null
      second = null
      year = Number(rs[grupos["year"]])  unless typeof (grupos["year"]) is "undefined"
      unless typeof (grupos["year_two"]) is "undefined"
        year_two = Number(rs[grupos["year_two"]])
        year_now = (new Date()).getFullYear()
        if year_two > 50 and year_now < 2040
          year = Number("19" + String(year_two))
        else
          year = Number("20" + String(year_two))
      month = Number(String(rs[grupos["month"]]))  unless typeof (grupos["month"]) is "undefined"
      day = Number(String(rs[grupos["day"]]))  unless typeof (grupos["day"]) is "undefined"
      hour = Number(rs[grupos["hour"]])  unless typeof (grupos["hour"]) is "undefined"
      minute = Number(rs[grupos["minute"]])  unless typeof (grupos["minute"]) is "undefined"
      second = Number(rs[grupos["second"]])  unless typeof (grupos["second"]) is "undefined"
      date = new Date(year, (if month then month - 1 else month), day, hour, minute, second)

      if date
        date
      else
        false

    format: (format, date) ->
      date = new Date() if typeof (date) is "undefined"

      return false unless date

      day    = date.getDate()
      month  = date.getMonth() + 1
      year   = date.getFullYear()
      hour   = date.getHours()
      minute = date.getMinutes()
      second = date.getSeconds()

      r =
        "(^|[^\\\\])d": (if day <= 9 then "0" + day else String(day))
        "(^|[^\\\\])m": (if month <= 9 then "0" + month else String(month))
        "(^|[^\\\\])Y": String(year)
        "(^|[^\\\\])H": (if hour <= 9 then "0" + hour else String(hour))
        "(^|[^\\\\])i": (if minute <= 9 then "0" + minute else String(minute))
        "(^|[^\\\\])s": (if second <= 9 then "0" + second else String(second))

      resp = format
      for re of r
        resp = resp.replace(new RegExp(re, "g"), "$1" + r[re])
      resp

    addMonth: (dateObj, months=1) ->
      actualDay = @getDay(dateObj)
      dateObj.setDate(1)
      dateObj.setMonth(dateObj.getMonth()+months)
      bestDay = Math.min actualDay, @getLastDay(dateObj)
      dateObj.setDate(bestDay)
      return dateObj

    addDay: (dateObj, days=1) ->
      dateObj.setDate(dateObj.getDate()+days)
      return dateObj

    setDay: (dateObj, day) ->
      bestDay   = Math.min day, @getLastDay(dateObj)
      dateObj.setDate(bestDay)

    getDay: (dateObj) ->
      return dateObj.getDate()

    getLastDay: (dateObj) ->
      d = new Date(dateObj.getYear(), dateObj.getMonth()+1, 0)
      return d.getDate()


  return new DateService