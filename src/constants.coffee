_   = require 'lodash'

ID = 0
constants = []

### Create a list of constants from an Array
  ex:
    operatingSystems = new Constants( ['APPLE', 'LINUX', 'MICROSOFT'])
    console.log(operatingSystems.getIndex('APPLE')) // prints 0
    console.log(operatingSystems.APPLE) // prints 0
    console.log(operatingSystems.get(0)) // prints 'APPLE'

  @param data Array
###
module.exports = class Constants
  id: null
  length: null

  constructor: (data) ->
    @id = ID++
    constants[@id] = data
    @length = data.length
    for v, k in data then @[v.toUpperCase()] = k

  getIndex: (value) ->
    return constants[@id].indexOf(value)

  hasIndex: (index) ->
    return constants[@id][index] != undefined

  get: (index) ->
    return constants[@id][index]

  has: (value) ->
    return @getIndex(value) > -1
