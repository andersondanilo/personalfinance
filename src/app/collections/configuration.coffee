define ['components/collection', 'localstorage', 'models/configuration'], (Collection, localstorage, Configuration) ->
  
  class ConfigurationCollection extends Collection
    model: Configuration
    localStorage: new Backbone.LocalStorage("Configuration")

  return ConfigurationCollection