define ->
  return { 
    #lng: "en"
    fallbackLng: 'en'

    # change path
    resPostPath: if typeof(APP_TRANSLATE_PATH) == 'undefined' then 'app/locales/__lng__/__ns__.json' else APP_TRANSLATE_PATH
    resGetPath: if typeof(APP_TRANSLATE_PATH) == 'undefined' then 'app/locales/__lng__/__ns__.json' else APP_TRANSLATE_PATH
 
    # change sendType
    sendType: 'GET'
    debug: true
  
    # send missing values to
    sendMissingTo: 'fallback|current|all'
 
    # change async / sync
    postAsync: false
  }
