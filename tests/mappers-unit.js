var should = require('chai').should(),
    expect = require('chai').expect,
    bson   = require('bson'),
    Joi     = require('joi'),
    Redis   = require('ioredis'),
    MongoDB = require('mongodb'),
    Promise = require('bluebird'),
    User    = require('./models/user');

var MongoClient = Promise.promisifyAll(MongoDB).MongoClient;
//var MongoClient = require('mongodb').MongoClient;

var redisURI = process.env.REDIS_URI || 'redis://:@127.0.0.1:6379/0'
var mongoURI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/test'
var redis = new Redis(redisURI);

//console.log(1, redisURI, mongoURI);

var mappers = [ 'Local', 'Mongo', 'Redis'];
var promise = MongoClient.connect(mongoURI).then(function(mongo) {
  return {
    Local: require('../lib/local-mapper')(),
    Mongo: require('../lib/mongo-mapper')(mongo.db()),
    Redis: require('../lib/redis-mapper')(redis)
  }
});

next = function(key) {
  describe(key + '-Mapper', function() {
    User.schema.id = Joi.any()
    this.timeout(10000);

    var userMapper;
    var id;
    var email = "foo@bar.test";
    var user;
    var mail;
    var Mapper;

    before(function(done) {
      promise.then(function(mappers) {
        Mapper = mappers[key];
        userMapper = new Mapper(User);
        id = Mapper.generateId();
        mail = id + '@test.com';1
        user = new User({ id: id, name: "test1", age: 31, hash: "testtesttesttesttesttesttesttesttesttesttest", mail: mail});
        done();
      });
    });

    it('Save a user', function(done) {
      userMapper.create(user, { sk: 'mail' })
      .then(function(user2) {
        expect(user2).instanceof(User);
        expect(user2.get('name')).equals('test1');
        done();
      }).catch(done)
    });

    it('Update a user', function(done) {
      userDelta = { name: "test1", age: 62, hash: "TESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTES3"};
      user.merge(userDelta)
      userMapper.update(user)
      .then(function(user2) {
        expect(user2).instanceof(User);
        expect(userDelta.age).equals(user2.get('age'));
        done();
      }).catch(done)
    });

    it('Save a user with no id', function(done) {
      user = new User({ name: "test2", age: 13, hash: "testtesttesttesttesttesttesttesttesttesttest"});
      userMapper.create(user)
      .then(function(user2) {
        expect(user2).instanceof(User);
        expect(user2.get('name')).equals('test2');
        done();
      }).catch(done)
    });

    it('Retreive a user from primary key, then directly update using model', function(done) {
      userMapper.get(id)
      .then(function(user2) {
        user2.set('age', 54);
        expect(user2).instanceof(User);
        return userMapper.update(user2);
      }).then( function(user3) {
        expect(user3).instanceof(User);
        expect(user3.get('age')).equals(54);
        done();
      }).catch(done)
    });

    it('Retreive a user from secondary key', function(done) {
      userMapper.findOne({ mail: mail })
      .then(function(user2) {
        expect(user2).instanceof(User);
        expect(user2.get('id').toString() == id.toString()).equal(true);
        done();
      }).catch(done)
    });

    it('Retreive a non-existant user from primary', function(done) {
      userMapper.get("lalala")
      .then(function(user2) {
        expect(user2).to.satisfy(function() { return user2 == null || user2 == undefined } );
        done();
      }).catch(done)
    });

    it('Retreive a non-existant user from secondary key', function(done) {
      userMapper.findOne({ mail: "lalala@lala.com" })
      .then(function(user2) {
        expect(user2).to.satisfy(function() { return user2 == null || user2 == undefined } );
        done();
      }).catch(done)
    });

    after(function(done) {
      //if(mappers.length > 0) next(mappers.pop())
      done();
    });
  });
}

for(k in mappers) next(mappers[k])
