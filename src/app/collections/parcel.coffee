define ['components/collection', 'models/parcel'], (Collection, Parcel) ->

  class ParcelCollection extends Collection
    database: require 'config/database'
    storeName: 'parcels'
    model: Parcel

    comparator: (model) ->
      return Number(model.get('date').replace(/[^0-9]/g, ''))

  return ParcelCollection