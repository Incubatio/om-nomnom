_   = require 'lodash'

### Create a collection from an Array of Object, each object require an id to be indentified
  ex:
    operatingSystems = new Collection( [ { id: 'APPLE'}, { id: 'LINUX'}, { id: 'MICROSOFT'})
    console.log(operatingSystems.APPLE) // prints { id: 'APPLE' }
    console.log(operatingSystems.get('APPLE')) // prints { id: 'APPLE' }
    console.log(operatingSystems.getIndex('APPLE')) // prints 0

  @param data Array<Object>
###
module.exports = class Collection
  length: null
  data: null

  constructor: (@data) ->
    @length = @data.length
    for v, k in @data
      if v.id == undefined    then throw 'Id is required for each object'
      if @[v.id] != undefined then throw 'The id:"' + id + '" must be unique'
      @[v.id] = k

  getIndex: (value) ->
    return @[value]

  has: (value) ->
    return @[value] != undefined

  get: (value) ->
    return @data[@[value]]
