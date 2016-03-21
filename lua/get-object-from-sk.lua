--[[

  getObjectFromSecondaryKey

  Schema: EVAL get-object-from-sk.lua 1 <object_name> <object_sk_value>
  Examples:
    - EVAL get-from-secondary-key.lua 1 user fb_id:56a2524f4e4fe1cb337d1e17
    - EVAL get-from-secondary-key.lua 1 user email:foo@bar.test

  Current script consider object are stored in <object_name> namespace and relative SK in <object_name>.sk

  NOTE: Secondary Key (SK) are to be differenciated from column index
    A SK is a simple hash.
    An index is a sorted set.

  RETURN: json_object
--]]
-- KEYS={"user"}
-- ARGV={"56a294579c355857397c88a0"}

local objectName = KEYS[1]
local objectSK = objectName .. ".sk:" .. ARGV[1]
local result

-- print(1, objectName, ARGV[1]);
local objId = redis.call("GET", objectSK)
-- print(2, objId);
if(objId) then
  local objectPK = objectName .. ":" .. objId
  result = redis.call("HGETALL", objectPK)
end

-- print(3, result);
return result
