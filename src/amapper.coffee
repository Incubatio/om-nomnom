Promise = require 'bluebird'

module.exports = class AMapper

  Driver: null
  constructor: (@Driver) ->

  getCollectionName: (ModelClass) ->
    return ModelClass.name.toLowerCase()

  validParams: (model) ->
    if model instanceof @ModelClass == false
      name = if model then model.constructor.name else model
      throw new Error("Invalid object type, expect a Model, got " + name)

  create: (model, options = {}) ->
    @validParams(model)
    attrs = model.toJSON()
    if attrs.id == undefined then attrs.id = @Driver.generateId()

    @Driver.create(@name, attrs, options)
    .then (arg) ->
      model.set('id', attrs.id)
      model.updated()
      return model

  update: (model) ->
    @validParams(model)
    if !model.has('id') then throw Error('Object with no id can\'t be updated')
    if !model.isModified()
      return new Promise (resolve, reject) -> resolve(model) #throw Error('trying to update unmodified object')
    else
      attrs = model.getEdits(false)
      if attrs.id != undefined then throw Error('A primary key cannot be modified')
      id = model.get('id')

      return @Driver.update(@name, id, attrs)
      .then (arg) ->
        model.updated()
        return model
        #return Promise.resolve model, arg

  get: (id) ->
    if(!id) then throw new Error("get require an id param to work")
    return @Driver.get(@name, id)
    .then (data) =>
      return if Boolean(data) then new @ModelClass(data) else data

  findOne: (attrs) ->
    @Driver.findOne(@name, attrs)
    .then (data) =>
      return if Boolean(data) then new @ModelClass(data) else data

  incr: (key, value = 1, options = {}) ->
    @Driver.incr(@name, key, value, options)

  remove: (id) ->
    if(!id) then throw new Error("remove require an id param to work")
    return @Driver.remove(@name, id)
    .then (data) =>
      return if Boolean(data) then new @ModelClass(data) else data
