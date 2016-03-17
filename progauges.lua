class 'ProGauges'

function ProGauges:__init()
    self.speed = 0
	self.rpm = 0
	self.unit = 1
	self.unit_str = "km/h"

	Events:Subscribe( "Render", self, self.Render )
end

-- Returns the Current Speed of Vehicle, and set the correct string for Unit Text (m/s, km/h or mph)
function ProGauges:GetSpeed(unit)
	local vehicle = LocalPlayer:GetVehicle()
	local speed = vehicle:GetLinearVelocity():Length()

	if unit == 0 then
		self.unit_str = "m/s"
		return speed -- m/s
	elseif unit == 1 then
		self.unit_str = "km/h"
		return speed * 3.6 -- km/h
	elseif unit == 2 then
		self.unit_str = "mph"
		return speed * 2.237 -- mph
	end
end

function ProGauges:GetRpm()
	local vehicle = LocalPlayer:GetVehicle()
	return vehicle:GetRPM(), vehicle:GetMaxRPM()
end

function ProGauges:GetTransmission()
	local vehicle = LocalPlayer:GetVehicle()
	local transmission = vehicle:GetTransmission()

	return transmission:GetGear()
end

-- Draws a desired Text on Screen
function ProGauges:DrawText(position, str, colour, size, scale)
	Render:DrawText(position, str, colour, size)
end

-- Draw the velocity data, formated to fit in screen on bottom-right corner
function ProGauges:DrawVelocity()
	local str = string.format("%.1f", self.speed)
	local colour = Color(55,  204, 113)
	local velocity_pos = Vector2(Render.Width - Render:GetTextWidth(str, TextSize.Large) - 150, Render.Height - Render:GetTextHeight(str, TextSize.Large) - 50)
	local velocity_unit_pos = Vector2(velocity_pos.x + Render:GetTextWidth(str, TextSize.Large), Render.Height - Render:GetTextHeight(self.unit_str, TextSize.Large) - 50)

	self:DrawText(velocity_pos, str, colour, TextSize.Large, 1)
	self:DrawText(velocity_unit_pos, self.unit_str, Color.White, TextSize.Default, 1)
end

function ProGauges:DrawGear()
	local gear = self:GetTransmission()

	local str = string.format("%i", gear)
	local circle_radius = 10
	local gear_pos = Vector2(Render.Width - 60, Render.Height - 100)
	local circle_gear_pos = Vector2(gear_pos.x + (circle_radius/2), gear_pos.y + (circle_radius/2))
	local colour = Color.White
	local circle_colour = Color(55, 204, 113)
	--Render:DrawCircle(circle_gear_pos, circle_radius, Color.Gray * 1.5)
	Render:FillCircle(circle_gear_pos, circle_radius, circle_colour)
	self:DrawText(gear_pos, str, colour, TextSize.Default, 1)
end

-- Draws the RPM of Vehicle's Engine
function ProGauges:DrawRpm()
	local Rpm, maxRpm = self:GetRpm()
	-- Algorithm to transform Rpm in bars to display on gauge, and set the position for gauge
	local bars = ((maxRpm/100)*2)/10 -- How Many Bars will my car have in it's gauge
	local gauge_width = 150
	local gauge_pos = Vector2(Render.Width - gauge_width, Render.Height - 50) -- Bottom-Right...
	
	local bars_width = gauge_width/(bars * 2)
	local bars_height = 50
	-- <<
	-- Loop for each bar in gauge
	for bar=0, bars, 1 do
		--cur_height = ((bars_height / bars) * (bar+1)) + 5
		cur_height = (2^((bar+1)*0.46/(bars*0.08))) + 10
		local bar_size = Vector2(bars_width, cur_height)
		local bar_pos = Vector2(gauge_pos.x + (bars_width * (bar*2)) - 20, (Render.Height - 20) - cur_height)
		
		-- Check if is a On Bar, or a Off Bar
		local rpm_percent = Rpm / maxRpm
		local bar_on = bars * rpm_percent
		bar_on = math.floor(bar_on)

		local bar_color = Color.Gray

		if (bar <= bar_on) then
			bar_color = Color(55,  204, 113)
			bar_color = bar_color * (3*(bar/bars))
			if (bar/bars) > 0.8 then
				bar_color = bar_color + Color.Red
			end
		end

		Render:FillArea(bar_pos, bar_size, bar_color)
	end
end

-- main loop :)
function ProGauges:Render()
	if not LocalPlayer:InVehicle() then return end
	self.speed = self:GetSpeed(self.unit)

	-- Drawning Velocity into the screen
	self:DrawVelocity()
	-- Drawning RPM Gauge into the Screen
	self:DrawRpm()
	self:DrawGear()
end

proGauges = ProGauges()