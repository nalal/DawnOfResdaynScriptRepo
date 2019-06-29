local rpdata = {}

	function rpdata.save(nameData)
		if rpconfig.dataType == "json" then
			jsonInterface.save("rpchat/" .. rpconfig.fileNames.rpdata .. ".json", nameData)
		end
	end
	
	function rpdata.load()
		if rpconfig.dataType == "json" then
			local data = jsonInterface.load("rpchat/" .. rpconfig.fileNames.rpdata .. ".json")
			return data
		end
	end

return rpdata
