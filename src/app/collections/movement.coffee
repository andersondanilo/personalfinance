define ['components/collection', 'models/movement'], (Collection, Movement) ->
  
  class MovementCollection extends Collection
    database: require 'config/database'
    storeName: 'movements'
    
    model: Movement

  return MovementCollection