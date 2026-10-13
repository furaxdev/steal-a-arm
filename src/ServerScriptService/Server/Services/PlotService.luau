-- Assigne un plot libre à chaque joueur qui rejoint, le libère quand il part.
local Players = game:GetService("Players")

local PlotService = {}
local plots = nil :: any
local assignments: { [number]: number } = {} -- userId -> index de plot

function PlotService.init(worldPlots: any)
	plots = worldPlots
end

function PlotService.assign(player: Player): number?
	for index, plot in plots do
		if plot.owner == nil then
			plot.owner = player
			plot.sign.Text = player.DisplayName .. "\nvivier d'armes"
			assignments[player.UserId] = index
			return index
		end
	end
	return nil
end

function PlotService.release(player: Player)
	local index = assignments[player.UserId]
	if index and plots[index] then
		plots[index].owner = nil
		plots[index].sign.Text = "Plot libre"
	end
	assignments[player.UserId] = nil
end

function PlotService.getPlotOf(player: Player)
	local index = assignments[player.UserId]
	return index and plots[index] or nil
end

function PlotService.getPlotIndexOf(player: Player): number?
	return assignments[player.UserId]
end

function PlotService.getAllPlots()
	return plots
end

function PlotService.getOwnerAtPosition(position: Vector3, range: number): (Player?, number?)
	for index, plot in plots do
		if plot.owner and (plot.rack.Position - position).Magnitude <= range then
			return plot.owner, index
		end
	end
	return nil, nil
end

Players.PlayerRemoving:Connect(function(player)
	PlotService.release(player)
end)

return PlotService
