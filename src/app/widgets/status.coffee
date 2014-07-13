define ['zepto'], ->
  class Status
    constructor: (@el) ->
      @elP  = @el.children('p')
      @tout = null

    show: (message, timeout=3000) ->
      @elP.html(message)
      @el.css 'bottom', (@el[0].offsetHeight * -1) + 'px'
      @el.addClass 'active'
      @el.animate {
        bottom: 0,
        opacity: 1
      }, 500, 'ease-out'

      if @tout
        clearTimeout @tout

      @tout = setTimeout(=>
        @el.css 'bottom', '0px'
        @el.animate {
          bottom: (@el[0].offsetHeight * -1)
          opacity: 0.5
        }, 500, 'ease-out'
        @el.removeClass 'active'
      , timeout)


  return Status