return(function( ... )
	local module, args, configs, nets = { ... } , {} , {}, {}
	local _env = (getgenv or getrenv or args[4])()
	
	local connections = _env.connections or {} do
		_env.connections = connections

		for i = 1, #connections do
			connections[i]:Disconnect()
		end

		table.clear(connections)
	end

	local function packages(index, value)
		local result = value()
		
		module[index] = result
		
		return module[index]
	end

	local cloneref = cloneref or (function( ... ) return( ... ) end)

	local function reference(a)
		return cloneref(game:GetService(a))
	end
	
	local RunService = reference('RunService')
	local TeleportService = reference('TeleportService')
	local HttpService = reference('HttpService')
	local Players = reference('Players')
	local UserInputService = reference('UserInputService')
	local VirtualUser = reference('VirtualUser')
	local CoreGui = reference('CoreGui')
	
	local PlaceId = game.PlaceId
	
	local double = (function()
		if not RunService:IsStudio() then
			return (gethui and gethui()) or CoreGui
		end

		return Players.LocalPlayer.PlayerGui
	end)()
	
	local Liquid = double:FindFirstChild('Liquid') do
		if Liquid then
			Liquid:Destroy()
		end
	end

	packages("database", function()
		local database = {
			folder = "XZER"
		}
		
		local isfolder = isfolder or (function( ... ) return( ... ) end)
		local makefolder = makefolder or (function( ... ) return( ... ) end)
		local isfile = isfile or (function( ... ) return( ... ) end)
		local readfile = readfile or (function( ... ) return( ... ) end)
		local writefile = writefile or (function( ... ) return( ... ) end)
		
		local function build()
			local paths = {
				database.folder, database.folder .. "/settings"
			}

			for i = 1, #paths do
				local str = paths[i]
				
				if not isfolder(str) then
					makefolder(str)
				end
			end
		end
		
		local fullPath = database.folder .. "/settings/" .. PlaceId .. ".json"
		
		function database:def(index, value)
			if configs[index] == nil then
				configs[index] = value
			end
		end
		
		function database:save(index, value)
			if index ~= nil then
				configs[index] = value
			end

			if not isfolder(database.folder) then
				makefolder(database.folder)
			end

			if not isfolder(database.folder .. "/settings") then
				makefolder(database.folder .. "/settings")
			end

			writefile(fullPath, HttpService:JSONEncode(configs))
		end
		
		function database:load()
			if not isfile(fullPath) then
				database:save()
			end

			return HttpService:JSONDecode(readfile(fullPath))
		end
		
		function database:getpath()
			return fullPath
		end
		
		build()
		database:def('Initailized', true)

		return database
	end)
	
	packages("others", function()
		local others = {}
		
		function others:newconnection(signal, callback)
			local connection = signal:Connect(callback)
			
			table.insert(connections, connection)
			
			return connection
		end
		
		function others:fontcolors(text, color)
			if type(text) == "string" and typeof(color) == "Color3" then
				local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)

				return string.format('<font color="rgb(%d, %d, %d)">%s</font>', r, g, b, text)
			end

			return text
		end
		
		do
			others:newconnection(Players.LocalPlayer.Idled, function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end)
		end
		
		return others
	end)
	
	packages("theards", function()
		local theards = {}
		
		function theards:whiles(a, b, c, d)
			while a do
				local t = tick()

				if c then c() end
				if d and d() then break end

				repeat
					RunService.Heartbeat:Wait()
				until tick() - t >= (b or 0.1)
			end
		end
		
		function theards:create(a, b, c)
			nets[a] = function(Value)
				module.whiles(Value, b or 0.1, c, function()
					return not Value
				end)
			end
		end
		
		return theards
	end)
	
	packages('import', function()
		local import = {
			owner = "setmetata6le",
			once = true,
		}
		
		function import:fetch(repository, file)
			local url = string.format(
				'https://raw.githubusercontent.com/%s/%s/refs/heads/main/Packages/%s.luau',
				self.owner,
				repository,
				file
			)
			
			local result = game:HttpGet(url)
			return loadstring(result, self.once)()
		end
		
		return import
	end)
	
	packages('components', function()
		local components = {}
		local liquid = module.import:fetch("Script", 'init')
		
		function components:window()
			return liquid:Window({
				Title = "Xzer's official",
				Description = 'Enchanted by <font color="#488ab6"><b>vita6it</b></font>',
				Logo = 96551286443180,
				Transparent = true,
				Keybind = Enum.KeyCode.LeftControl
			})
		end
		
		function components:tabs(window, asset)
			return window:Tabs(asset)
		end
		
		function components:section(tabs, text, asset)
			return tabs:Section({
				Title = text,
				Icon = asset
			})
		end
		
		function components:paragraph(tabs, title, desc)
			return tabs:Paragraph({
				Title = title,
				Desc = desc
			})
		end
		
		function components:button(tabs, title, desc, call)
			return tabs:Button({
				Title = title,
				Desc = desc,
				Callback = call
			})
		end
		
		function components:toggle(tabs, title, desc, setting, call)
			local thread = nil
			
			return tabs:Toggle({
				Title = title,
				Desc = desc,
				Value = configs[setting],
				Callback = function(self, state)
					configs[setting] = state
					module.database:save(setting, state)

					if state then
						thread = task.spawn(function()
							if nets[setting] then
								nets[setting](configs[setting])
							end
						end)
					else
						if thread then
							task.cancel(thread)
						end
					end

					if call then
						call(state)
					end
				end,
			})
		end
		
		function components:textbox(tabs, title, desc, setting, call)
			return tabs:Textbox({
				Title = title,
				Desc = desc,
				Value = tostring(configs[setting]),
				Callback = function(self, text)
					configs[setting] = text
					module.database:save(setting, text)
					
					if call then
						call(text)
					end
				end,
			})
		end
		
		function components:slider(tabs, asset, min, max, setting, rounding, call)
			return tabs:Slider({
				Icon = asset,
				Min = min,
				Max = max,
				Value = configs[setting],
				Rounding = rounding,
				Callback = function(value)
					configs[setting] = value
					module.database:save(setting, value)
					
					if call then
						call(value)
					end
				end,
			})
		end
		
		function components:input(tabs, title, desc, enum, call)
			return tabs:Input({
				Title = title,
				Desc = desc,
				Key = enum,
				Value = false,
				Callback = function(self, key, state)
					if call then
						call(key, state)
					end
				end,
			})
		end
		
		function components:list(tabs, title, list, setting, call)
			return tabs:Dropdown({
				Title = title,
				List = list,
				Value = configs[setting],
				Multi = typeof(configs[setting]) == 'table' and true or false,
				Callback = function(value)
					configs[setting] = value
					module.database:save(setting, value)

					if call then
						call(value)
					end
				end,
			})
		end
		
		function components:managers(window)
			local misc = components:tabs(window, 136648496711424) do
				components:section(misc, "Website", 95120001782450) do
					misc:CodeBlock({
						Header = "dashboard.json",
						Code = 'https://xzerhub.pro',
						Icon = 95120001782450
					})
				end
				
				components:section(misc, "Performance", 106864141877672) do
					components:toggle(misc, '3d Rendering [ White Screen ]', 'Disables 3D rendering by applying a white overlay, improving performance on low-load mode.', '3d Rendering', function(value)
						RunService:Set3dRenderingEnabled(if value then false else true)
					end)
					
					components:button(misc, "Low Graphic Quality", 'Reduces visual quality to lower system load and improve overall performance.', function()
						local Terrain = workspace:FindFirstChildOfClass('Terrain') do
							Terrain.WaterWaveSize = 0
							Terrain.WaterWaveSpeed = 0
							Terrain.WaterReflectance = 0
							Terrain.WaterTransparency = 0
							game.Lighting.GlobalShadows = false
							game.Lighting.FogEnd = 9e9
							settings().Rendering.QualityLevel = 1
						end
						
						window:Notification({
							Title = 'Low graphic quality has been enabled.',
							Icon = 134678676020956,
							Duration = 3
						})
					end)
				end
				
				components:section(misc, "Server", 110725435294852) do
					module.database:def('JobId', "N/A")
					
					packages('server', function()
						local server = {}

						function server:Reversed(cursor)
							local url = `https://games.roblox.com/v1/games/{PlaceId}/servers/Public?sortOrder=Asc&limit=100`

							if cursor then
								url ..= `&cursor={cursor}`
							end

							return HttpService:JSONDecode(game:HttpGet(url))
						end

						function server:Rejoin()
							if #Players:GetPlayers() <= 1 then
								Players.LocalPlayer:Kick("\nRejoining")
								wait()

								return TeleportService:Teleport(PlaceId, Players.LocalPlayer)
							end
							
							window:Notification({
								Title = 'Rejoining ( ... )',
								Icon = 134678676020956,
								Duration = 3
							})

							return TeleportService:TeleportToPlaceInstance(PlaceId, game.JobId, Players.LocalPlayer)
						end

						function server:Changed()
							local Server, Next

							return (function(a)
								repeat
									local Servers = server:Reversed(a)

									Server = Servers and Servers.data and Servers.data[1]
									Next = Servers and Servers.nextPageCursor
								until Server

								if not Server or not Server.id then return end
								return TeleportService:TeleportToPlaceInstance(PlaceId, Server.id, Players.LocalPlayer)
							end)(Next)
						end

						function server:Join(id)
							return TeleportService:TeleportToPlaceInstance(PlaceId, id, Players.LocalPlayer)
						end

						return server
					end)
					
					misc:CodeBlock({
						Header = "JobId.luau",
						Code = tostring(game.JobId),
						Icon = 84780130894041
					})
					
					components:textbox(misc, 'Job Identifier [ JobId ]', 'Enter a Job Identifier here to join a specific server', 'JobId')
					
					components:button(misc, "Join", 'Join the selected JobId', function()
						window:Notification({
							Title = 'Joining ( ... )',
							Icon = 134678676020956,
							Duration = 3
						})
						
						module.server:Join(configs['JobId'])
					end)
					
					components:button(misc, "Rejoin", 'Leave and rejoin the current server', function()
						module.server:Rejoin()
					end)
					
					components:button(misc, "Change Server", 'Move to another server instance for a fresh session.', function()
						window:Notification({
							Title = 'Changing ( ... )',
							Icon = 134678676020956,
							Duration = 3
						})
						
						module.server:Changed()
					end)
				end
			end
			
			local settings = window:Managers()
			
			do
				components:section(settings, "Configuration", 108001290138717) do
					components:button(settings, "Remove workspace [ Current game ]", 'Reset all saved workspace data back to default settings.', function()
						local file = module.database:getpath()

						if isfile(file) then
							pcall(delfile, file)

							window:Notification({
								Title = 'Deleted file success',
								Icon = 136704231139251,
								Duration = 3
							})
						else
							window:Notification({
								Title = 'File not found.',
								Icon = 127194456372995,
								Duration = 3
							})
						end
					end)

					components:button(settings, "Remove workspace [ Any game ]", 'Reset all saved workspace data back to default settings.', function()
						local file = module.database:getpath()

						if isfile(file) then
							pcall(delfile, 'XZER')

							window:Notification({
								Title = 'Deleted file success',
								Icon = 136704231139251,
								Duration = 3
							})
						else
							window:Notification({
								Title = 'File not found.',
								Icon = 127194456372995,
								Duration = 3
							})
						end
					end)
				end
			end
			
			return misc
		end
		
		return components
	end)
	
	configs = module.database:load() 
	
	module.configs = configs
	module.reference = reference

	return module
end)(setmetatable, newproxy, getfenv)
