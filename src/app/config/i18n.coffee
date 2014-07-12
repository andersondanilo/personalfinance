define ->
  return { 
    #lng: "en"
    fallbackLng: 'en'

    # change path
    resPostPath: 'app/locales/__lng__/__ns__.json'
    resGetPath:  'app/locales/__lng__/__ns__.json'
 
    # change sendType
    sendType: 'GET'
    debug: true
  
    # send missing values to
    sendMissingTo: 'fallback|current|all'
 
    # change async / sync
    postAsync: false
  }
