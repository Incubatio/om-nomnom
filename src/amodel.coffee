Joi = require 'joi'
_   = require 'lodash'

module.exports = class AModel

  attrs: null
  edits: null

  constructor: (attrs, @schema) ->
    if attrs.constructor.name != 'Object' then throw 'A Model only accepts raw Object type, got "' + attrs.constructor.name + '"'
    @edits = {}
    @merge(attrs || {})
    @attrs = @edits
    @updated()

  get: (key) ->
    return if @edits.hasOwnProperty(key) then @edits[key] else @attrs[key]

  set: (key, value) ->
    if @schema and @schema[key] then value = Joi.attempt(value, @schema[key])
    @edits[key] = value
    return @

  unset: (key) ->
    return @set(key, undefined)

  merge: (attrs) ->
    for k, v of attrs then @set(k, v)
    return @

  toJSON: () ->
    return _.extend {}, @attrs, @edits

  inspect: AModel.prototype.toJSON

  updated: () ->
    _.extend @attrs, @edits
    @edits = {}

  getEdits: (clone = true) ->
    return if clone then _.cloneDeep(@edits) else @edits

  has: (key) ->
    return @get(key) != undefined

  isNew: () ->
    return @has('id')

  isModified: () ->
    return _.keys(@edits).length > 0

  isSynced: () ->
    return !(@isNew() || @isModified())
