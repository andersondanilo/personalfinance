define ['backbone_indexeddb'], (indexeddb) ->
  id: if typeof(APP_DATABASE_ID) == 'undefined' then "personal_finance_maindb" else APP_DATABASE_ID
  description: "The main database"
  migrations: [
    {
      version: 1
      migrate: (transaction, next) ->
          movementsStore = transaction.db.createObjectStore "movements", {
                               keyPath:'id'
                               autoIncrement:true
                           }
          parcelsStore   = transaction.db.createObjectStore "parcels", {
                               keyPath:'id'
                               autoIncrement:true
                           }
          
          movementsStore.createIndex "movement_type_idx", "movement_type", {unique: false}
          movementsStore.createIndex "description_idx", "description", {unique: false}

          parcelsStore.createIndex "date_idx", "date", {unique: false}
          parcelsStore.createIndex "movement_id_idx", "movement_id", {unique: false}
          parcelsStore.createIndex "movement_type_idx", "movement_type", {unique: false}

          next()
    }
  ]