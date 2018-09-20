Joi = require 'joi'
_   = require 'lodash'

module.exports = class AModel

  _attrs: null
  _edits: null
  _schema: null
  _defaults: null

  constructor: (attrs, @_schema, @_defaults = null) ->
    if attrs.constructor.name != 'Object' then throw 'A Model only accepts raw Object type, got "' + attrs.constructor.name + '"'
    if @_defaults && @_defaults instanceof Function == false then throw new Error('defaults has to be a fuction returning an object of new default value')
    @_edits = {}
    @merge(attrs || {})
    @_attrs = @_edits
    @updated()

  get: (key) ->
    if @_schema.hasOwnProperty(key) == false then throw new Error(key + ' is not defined in the schema')
    return if @_edits.hasOwnProperty(key) then @_edits[key] else @_attrs[key]

  set: (key, value) ->
    if @_schema.hasOwnProperty(key) == false then throw new Error(key + ' is not defined in the schema')
    if @_schema and @_schema[key] then value = Joi.attempt(value, @_schema[key])
    @_edits[key] = value
    return @

  unset: (key) ->
    return @set(key, undefined)

  merge: (attrs) ->
    for k, v of attrs then @set(k, v)
    return @

  toJSON: () ->
    return _.extend {}, @_attrs, @_edits

  inspect: AModel.prototype.toJSON

  updated: () ->
    _.extend @_attrs, @_edits
    @_edits = {}

  getEdits: (clone = true) ->
    return if clone then _.cloneDeep(@_edits) else @_edits

  has: (key) ->
    return @get(key) != undefined

  isNew: () ->
    return @has('id')

  isModified: () ->
    return _.keys(@_edits).length > 0

  isSynced: () ->
    return !(@isNew() || @isModified())

  empty: () ->
    @_attrs = if @_defaults then @_defaults() else {}
    @_edits = {}
