module.exports = (mongodb) ->
  bson    = require 'bson'
  AModel  = require './amodel'
  AMapper = require './amapper'
  Promise = require 'bluebird'


  class MongoMapper extends AMapper

    @mongodb: mongodb
    @generateId: () -> return new bson.ObjectID()

    @create: (name, data) ->
      if data.id != undefined then data._id = data.id
      delete data.id
      return mongodb.collection(name).insertOne(data)

    @update: (name, id, data) -> return mongodb.collection(name).updateOne({ _id: id }, { $set: data })
    @get:    (name, id)       -> return mongodb.collection(name).findOne({ _id: id})
    @findOne:(name, data)     -> return mongodb.collection(name).findOne(data)
    #@findMany:
    #@batch:

    ModelClass: null
    constructor: (@ModelClass) ->
      super(MongoMapper)
      @name = @getCollectionName(@ModelClass)

    getCollectionName: (ModelClass) ->
      return ModelClass.name.toLowerCase() + 's'

    create: (model) ->
      @validParams(model)
      attrs = model.toJSON()
      attrs._id = if attrs.id == undefined then attrs.id = MongoMapper.generateId() else attrs.id
      delete attrs.id

      MongoMapper.create(@name, attrs)
      .then (arg) ->
        model.set('id', attrs._id)
        model.updated()
        return model

    get: (id) ->
      if(!id) then throw new Error('get require an id param to work')
      return MongoMapper.get(@name, id)
      .then (data) =>
        ret = data
        if data != null
          data.id = data._id
          delete data._id
          ret = new @ModelClass(data)
        return ret

    findOne: (attrs) ->
      MongoMapper.findOne(@name, attrs)
      .then (data) =>
        ret = data
        if data != null
          data.id = data._id
          delete data._id
          ret = new @ModelClass(data)
        return ret

    #batch: () ->
      # @collection.bulkWrite
