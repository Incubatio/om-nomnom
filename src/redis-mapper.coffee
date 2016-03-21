module.exports = (redis) ->
  bson    = require 'bson'
  AModel  = require './amodel'
  AMapper = require './amapper'
  Promise = require 'bluebird'
  Redis = require 'ioredis'
  fs    = require 'fs'

  redis.defineCommand('getObjectFromSK', {
    numberOfKeys: 1,
    lua: fs.readFileSync('./lua/get-object-from-sk.lua')
  })


  class RedisMapper extends AMapper

    @redis: redis
    @generateId: () -> return new bson.ObjectID().toString()
    #@generateId: () -> return new bson.ObjectID()

    @create: (name, data, options = {}) ->
      queries =  [
        ['hmset', name + ':' + data.id, data],
        ['sadd', name + 's', data.id]
      ]
      if options.sk
        if options.sk.constructor.name == 'String' then options.sk = [options.sk]
        if options.sk.constructor.name != 'Array'
          throw "Option sk can only be a String or an Array<String>, got" + options.sk.constructor.name
        for v in options.sk then queries.push ['set', name + '.sk:' + data[v], data.id]
      redis.pipeline(queries).exec()

    @update: (name, id, data) ->
      return redis.hmset(name + ":" + id, data)

    @get: (name, id) ->
      return redis.hgetall(name + ':' + id)
      .then (data) ->
        data.id = id
        return data

    @findOne: (name, data) ->
      sk = ''
      if Object.keys(data).length > 1 then throw new Error 'RedisMapper.findOne can only look for one column at a time'
      for k, v of data then sk = v
      if sk.length == 0 then throw new Error('Can\'t lookup for a key with 0 length')
      return redis.getObjectFromSK(name, sk)
      .then redis.constructor.Command._transformer.reply['hgetall']

    @incr: (name, key, value = 1, options = {}) ->
      fullKey = name + ':' + key
      if value instanceof Object
        for k, v of value
          promise = redis.hincrby fullKey, k, v
          break
      else
        promise = redis.incrby fullKey, value

      return promise
      .then (res) ->
        if options.on_create && options.on_create.expire && res - value < 2
          redis.expire(fullKey, options.on_create.expire)
        return res


    #@findMany

    # If we implement batch, we gonna need to get away from simple, and start being generic
    # adding a lot more code, generic code that support lots of cases, loosing in simplicity
    #@batch:
      #queries = []
      #for k, v of options.on_create
      #  queries.push if _.isArray(v) then v.unshift(k) else v = [k, v]
      #redis.pipeline(queries)

    name: null
    redis: null

    constructor: (@ModelClass) ->
      super(RedisMapper)
      @name = @getCollectionName(@ModelClass)
