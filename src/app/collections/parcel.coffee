define ['components/collection', 'models/parcel'], (Collection, Parcel) ->

  class ParcelCollection extends Collection
    database: require 'config/database'
    storeName: 'parcels'
    model: Parcel

  return ParcelCollection