#!/usr/bin/lua

require "luci.model.uci"
require "luci.sys"
local db = require "luci.commotion.debugger"
local encode = require "luci.commotion.encode"

local uci = luci.model.uci.cursor()
local node_key = luci.sys.exec("serval-client id self"):match('^[A-F0-9]+')

if not node_key then
	db.log('(convert-apps) Failed to fetch serval key')
	return
end

local to_delete = {}
uci:foreach("applications",
	    "application",
	    function(app)
		if not app.version or app.version ~= '1.0' then
			local new_uuid = encode.uci(app.uri .. app.port .. node_key)
			to_delete[#to_delete + 1] = new_uuid
			local vals = {}
			for k,v in pairs(app) do
				if k ~= 'type' then
					vals[k] = v
				end
			end
			vals['version'] = '1.0'
			uci:section('applications','application',new_uuid,vals)
			local types = uci:get_list('applications',app['.name'],'type')
			if types then
				uci:set_list('applications', new_uuid, "type", types)
			end
		end
	    end)
to_delete_known = {}
uci:foreach("applications",
	    "known_apps",
	    function(known_apps)
		for old,val in known_apps do
			if old in to_delete then
				uci:set("applications","known_apps",to_delete[old],val)
				table.insert(to_delete_known,old)
			end
		end
	    end)
for old,_ in to_delete do
	uci:delete("applications",old)
end
for old,_ in to_delete_known do
	uci:delete("applications","known_apps",old)
end
uci:save('applications')
uci:commit('applications')