
isBrowser = typeof(window) != 'undefined'

requireJsConfig =
    paths:
      text:       '../vendor/require/text'
      jquery:     '../vendor/jquery/jquery'
      underscore: '../vendor/underscore/underscore'
      backbone:   '../vendor/backbone/backbone'
      backbone_indexeddb:  '../vendor/backbone/indexeddb'
      epoxy:      '../vendor/backbone/epoxy'
      i18n:       '../vendor/i18next/i18next'
      zepto:      '../vendor/zepto/zepto'

if !isBrowser
  indexeddb = require 'indexeddb-js'
  sqlite3 = require 'sqlite3'

  engine    = new sqlite3.Database ':memory:'

  indexedDB      = new indexeddb.indexedDB 'sqlite3', engine
  IDBTransaction = indexeddb.Transaction
  IDBKeyRange    = indexeddb.IDBKeyRange
  IDBCursor      = indexeddb.Cursor

  GLOBAL.window = {
    document: {
      createElement: ->
        null
    },
    'indexedDB': indexedDB
    'IDBTransaction': IDBTransaction
    'IDBKeyRange': IDBKeyRange
    'IDBCursor': IDBCursor
  }

  GLOBAL.getComputedStyle = ->
    null

  GLOBAL.amdefine = require 'amdefine'
  GLOBAL.requirejs = require 'requirejs'
  GLOBAL.chai = require 'chai'

  requireJsConfig.baseUrl     = "#{__dirname}/../build/app"
  requireJsConfig.nodeRequire = require
  requireJsConfig.compilers = [
      {
          extensions: ['.coffee']
          compiler: require('coffee-script').compile
      }
  ]
else
  GLOBAL = window
  requireJsConfig.baseUrl     = "./../build/app"

GLOBAL.expect = chai.expect
GLOBAL.requirejs.config(requireJsConfig)