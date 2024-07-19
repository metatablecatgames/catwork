if not script then script = require("./RelativeString") end
if not task then task = require("@lune/task") end

local Dispatcher = require(script.Parent.Dispatcher)
local Common = require(script.Parent.Common)
local ERROR = require(script.Parent.Error)
local REFLECTION = require(script.Parent.Reflection)

local OBJECT_PARAMS = {
	Name = "string?",
	ID = "string?",
	Destroying = "function?",
	Init = "function?",
	Updating = "function?",
}

local function OBJECT_REFLECTION_TEST(object, oName)
	return object and object[Common.ObjectHeader], "BAD_SELF_CALL", oName
end

local OBJECT_PRIVATE = {}

return function(params: {[string]: any}, service)
	local raw, metakeys = Common.validateTable(params, "Object", OBJECT_PARAMS)

	local private = {
		ID = "",
		FullID = "",
		Service = service,
		TimeoutDisabled = if metakeys.TimeoutDisabled then metakeys.TimeoutDisabled else false,
		AwaitFor = metakeys.AwaitFor or {}
	}

	OBJECT_PRIVATE[raw] = private
	raw[Common.ObjectHeader] = true
	Common.assignObjectID(raw, private, service)
	raw.Name = params.Name or `CatworkAsyncObject`
	
	function raw:Spawn(xpcallHandler, asyncHandler)
		if Common.AnalysisMode then return end

		REFLECTION.CUSTOM(1, "Object.Spawn", self, OBJECT_REFLECTION_TEST)
		REFLECTION.ARG(2, "Object.Spawn", REFLECTION.OPT_FUNCTION, xpcallHandler)
		REFLECTION.ARG(3, "Object.Spawn", REFLECTION.OPT_FUNCTION, asyncHandler)

		return Dispatcher.spawnObject(self, OBJECT_PRIVATE[self], xpcallHandler, asyncHandler)
	end
	
	function raw:Await()
		REFLECTION.CUSTOM(1, "Object.Await", self, OBJECT_REFLECTION_TEST)
		
		if Dispatcher.isSelfAsyncCall(self) then ERROR.OBJECT_SELF_AWAIT(self:GetID(true)) end
		return Dispatcher.slotAwait(self)
	end
	
	function raw:HandleAsync(asyncHandler)
		REFLECTION.CUSTOM(1, "Object.HandleAsync", self, OBJECT_REFLECTION_TEST)
		REFLECTION.ARG(2, "Object.HandleAsync", REFLECTION.FUNCTION, asyncHandler)
		
		Dispatcher.slotHandleAsync(self, asyncHandler)
	end
	
	function raw:GetID(full: boolean?)
		REFLECTION.CUSTOM(1, "Object.GetID", self, OBJECT_REFLECTION_TEST)
		REFLECTION.ARG(2, "Object.GetID", REFLECTION.OPT_BOOLEAN, full)		
		
		return full and OBJECT_PRIVATE[self].FullID or OBJECT_PRIVATE[self].ID
	end

	function raw:Destroy()
		REFLECTION.CUSTOM(1, "Object.Destroy", self, OBJECT_REFLECTION_TEST)
		
		if not self[Common.ObjectHeader] then ERROR.BAD_SELF_CALL("Object.Destroy") end
		local service = OBJECT_PRIVATE[self].Service
		local state = Dispatcher.getObjectState(self)

		if Dispatcher.getObjectState(self) then
			Dispatcher.cleanObjectState(self)
			OBJECT_PRIVATE[self] = nil

			local destroying = self.Destroying
			local fragRemoved = service.ObjectRemoved

			if destroying then task.spawn(destroying, self) end
			if fragRemoved then task.spawn(fragRemoved, service, self) end

			Dispatcher.stop(self, state)
		end
	end

	if not Common.Flags.DONT_ASSIGN_OBJECT_MT then
		setmetatable(raw, {
			__tostring = function(self)
				local private = OBJECT_PRIVATE[self]
				return `CatworkAsyncObject({self.Name}::{private.FullID})`
			end
		})
	end
	
	return raw
end