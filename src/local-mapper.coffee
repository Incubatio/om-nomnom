module.exports = (dataSource) ->
  bson    = require 'bson'
  AModel  = require './amodel'
  AMapper = require './amapper'
  Promise = require 'bluebird'
  _ = require 'lodash'

  collections = dataSource || {}

  class LocalMapper extends AMapper

    @generateId: () -> return new bson.ObjectID()

    @create: (name, data) ->
      if collections[name] == undefined then collections[name] = {}
      #if collections[name][data.id] then throw new Error('Item already exists')
      collections[name][data.id] = data
      #return new Promise (resolve, reject) -> resolve(_.cloneDeep(collections[name][data.id]))
      return new Promise (resolve, reject) -> resolve(collections[name][data.id])

    @update: (name, id, data) ->
      if collections[name] == undefined then throw new Error('Collection doesn\'t exists')
      if collections[name][id] == undefined then throw new Error('Item doesn\'t exists')
      #_.extend collections[name][id], data
      for k of data
        collections[name][id][k] = data[k]
      #return new promise (resolve, reject) -> resolve(_.clonedeep(collections[name][id]))
      return new Promise (resolve, reject) -> resolve(collections[name][id])

    @get: (name, id) ->
      if collections[name] == undefined then throw new Error('Collection doesn\'t exists')
      #return new Promise (resolve, reject) -> resolve(_.cloneDeep(collections[name][id]))
      return new Promise (resolve, reject) -> resolve(collections[name][id])

    @remove: (name, id) ->
      if collections[name] == undefined then throw new Error('Collection doesn\'t exists')
      delete collections[name][id]
      return new Promise (resolve, reject) -> resolve(null)

    @findOne:(name, data) ->
      if collections[name] == undefined then throw new Error('Collection doesn\'t exists')
      ret = null
      for id, item of collections[name]
        matched = true
        for k of data then if item[k] != data[k]
          matched = false
          break
        if matched
          ret = item
          break
      return new Promise (resolve, reject) -> resolve(ret)

    #@findMany:
    #@batch:

    ModelClass: null
    constructor: (@ModelClass) ->
      super(LocalMapper)
      @name = @getCollectionName(@ModelClass)

    getCollectionName: (ModelClass) ->
      return ModelClass.name.toLowerCase() + 's'

    #batch: () ->
      # @collection.bulkWrite
