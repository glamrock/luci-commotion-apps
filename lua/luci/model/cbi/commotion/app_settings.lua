local ccbi = require "luci.commotion.ccbi"
local db = require "luci.commotion.debugger"
local ccbi = require "luci.commotion.ccbi"

local m = Map("applications", translate("Application Settings"), translate("Change settings for applications publicly announced by this node."))
m.on_after_save = ccbi.conf_page


s = m:section(TypedSection, "settings", translate("Categories"))

categories = s:option(DynamicList, "category")
categories.optional = false
expire = s:option(Flag, "allowpermanent", translate("Force local applications to expire? Yes/No"), translate("By default, all applications expire after a time period you specify. Un-check this box if applications should not expire."))
expire.remove=ccbi.flag_off
expire.write=ccbi.flag_write
expire.optional = false

ex_time_num = s:option(Value, "expiration", translate("Time before applications expire"))
ex_time_num:depends("allowpermanent","1")
ex_time_num.forcewrite = true --This is required for a modification of the unit to cause a change in the number.

--! ex_time_num.write
--! @brief Multiple the expiration time by the unit chosen to modify it to seconds.
function ex_time_num.write(self, section, value)
   local units = {seconds=1, minutes=60, hours=3600, days=86400}
   local unit = ex_time_units:formvalue(section)
   local sets = nil

   for unt,num in pairs(units) do
	  if unit == unt then
		 value = tonumber(value) * num
		 sets = true
		 db.log("3")
	  end
   end
   if sets then
	  return self.map:set(section, self.option, value)
   else
	  return nil
   end
end



ex_time_units = s:option(ListValue, "_units")
ex_time_units:value("seconds")
ex_time_units:value("minutes")
ex_time_units:value("hours")
ex_time_units:value("days")
ex_time_units:depends("allowpermanent","1")
function ex_time_units.write() return true end

apprv = s:option(Flag, "autoapprove", translate("Automatically approve all publicly announced applications on this network"))
apprv.remove=ccbi.flag_off
apprv.write=ccbi.flag_write
apprv.optional = false

chk_conn = s:option(Flag, "checkconnect", translate("Periodically check connection to announced applications on this network"), translate("If “Yes” is selected here, applications are checked to see if they are still online. If they are not responsive, they will be removed from the application list. Select “No” to disable this option If you have poor or intermittent connectivity."))
chk_conn.remove=ccbi.flag_off
chk_conn.write=ccbi.flag_write
chk_conn.optional = false

allow_anon = s:option(Flag, "enable_unauth", translate("Allow users to add application advertisements from your access point."), translate("If “Yes” is selected here, any user on your device can add an application from the view apps mainpage. Select “No” to disable this option If you would like to require administrator access to add advertisements."))
allow_anon.remove=ccbi.flag_off
allow_anon.write=ccbi.flag_write
allow_anon.optional = false

return m

