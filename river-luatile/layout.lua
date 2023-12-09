
package.path = ";/home/cirno99/.config/river-luatile/?.lua;" .. package.path

local bit = require("bit")
local utils = require("utils")

-- Global State

OUTER_GAPS = 3
INNER_GAPS = 3
MAIN_COUNT = 2
MAIN_RATIO = 0.65
REVERSE = false
PREFER_HORIZONTAL = true
SMART_GAP = true


local overrides = {}

local function tag_fingerprint(args)
	local tags = CMD_TAGS or args.tags
	local output = CMD_OUTPUT or args.output
	local least_tag = 1
	while bit.band(bit.rshift(tags, least_tag - 1), 1) == 0 do
		least_tag = least_tag + 1
	end
	return output .. "#" .. tostring(least_tag)
end

local function get_tag_state(args)
	local key = tag_fingerprint(args)
	local overriden = overrides[key]
	if overriden then
		return overriden
	end
	local default = {
		{ name = "tile", symbol = "[]=", gaps = 3, main_ratio = 0.60 },
		{ name = "stack", symbol = "[[]" },
		{ name = "centered", symbol = "[[c]]" },
	}
	overrides[key] = default
	return default
end

-- Layout Implementation

local function tile(args, layout)
	local retval = {}
	if args.count == 1 then
		table.insert(retval, { 0, 0, args.width, args.height })
	elseif args.count > 1 then
		local main_w = (args.width - layout.gaps) * layout.main_ratio
		local side_w = args.width - layout.gaps - main_w
		local main_h = args.height
		local side_h = (args.height - layout.gaps * (args.count - 2)) / (args.count - 1)
		table.insert(retval, {
			0,
			0,
			main_w,
			main_h,
		})
		for i = 0, (args.count - 2) do
			table.insert(retval, {
				main_w + layout.gaps,
				i * (side_h + layout.gaps),
				side_w,
				side_h,
			})
		end
	end
	return retval
end

local function stack(args, layout)
	local retval = {}
	local dx, dy = 15, 15
	local width = args.width - dx * (args.count - 1)
	local height = args.height - dx * (args.count - 1)
	for i = 0, (args.count - 1) do
		table.insert(retval, { dx * i, dy * i, width, height })
	end
	return retval
end

local function centered(args, layout)
	local retval = {}

	--
	local height_for_n = function(n)
		return utils.height_for_n(args, n)
	end
	local y_of_i = function(n, i)
		return utils.y_of_i(args, n, i)
	end
	local revert = function(return_of_layout)
		return utils.revert(args, return_of_layout)
	end
	--

	-- Let N be the number of windows
	-- N = 1 and N = 2 are special cases
	if args.count == 1 then
		if SMART_GAP then
			table.insert(retval, { 0, 0, args.width, args.height })
		else
			table.insert(retval, { OUTER_GAPS, OUTER_GAPS, args.width - OUTER_GAPS * 2, args.height - OUTER_GAPS * 2 })
		end
	elseif args.count <= 1 + MAIN_COUNT then
		local x, y, w, h
		local main_w = (args.width - OUTER_GAPS * 2 - INNER_GAPS) * MAIN_RATIO
		local main_h = height_for_n(math.min(MAIN_COUNT, args.count))
		local side_w = main_w * (1 / MAIN_RATIO - 1)
		-- main window(s)
		local w_accumulated = 0
		for i = 1, math.min(MAIN_COUNT, args.count) do
			if PREFER_HORIZONTAL then
				if args.count <= MAIN_COUNT then
					x = OUTER_GAPS
					w = args.width - OUTER_GAPS * 2
					h = main_h
					y = OUTER_GAPS + INNER_GAPS * (i - 1) + main_h * (i - 1)
				else
					x = OUTER_GAPS + side_w + INNER_GAPS
					w = main_w
					h = main_h
					y = y_of_i(MAIN_COUNT, i)
				end
			else
				if args.count <= MAIN_COUNT then
					local q = (i == 1) and 1 or (math.min(args.count) - 1)
					w = main_w / q
					w_accumulated = w_accumulated + w
					x = OUTER_GAPS + INNER_GAPS * (i - 1) + w_accumulated - w
					y = OUTER_GAPS
					h = args.height - OUTER_GAPS * 2
				else
					x = OUTER_GAPS + side_w + INNER_GAPS
					y = y_of_i(MAIN_COUNT, i)
					w = main_w
					h = main_h
				end
			end
			table.insert(retval, {
				x,
				y,
				w,
				h,
			})
		end

		-- side window
		for _ = MAIN_COUNT + 1, args.count do
			table.insert(retval, {
				OUTER_GAPS,
				OUTER_GAPS,
				side_w,
				args.height - OUTER_GAPS * 2,
			})
		end
	elseif args.count > 1 + MAIN_COUNT then
		-- general case
		local main_w = (args.width - 2 * OUTER_GAPS - 2 * INNER_GAPS) * MAIN_RATIO
		local main_h = height_for_n(MAIN_COUNT)
		local side_w = 0.5 * main_w * (1 / MAIN_RATIO - 1)
		-- main window(s)
		for i = 1, MAIN_COUNT do
			table.insert(retval, {
				OUTER_GAPS + side_w + INNER_GAPS,
				y_of_i(MAIN_COUNT, i),
				main_w,
				main_h,
			})
		end

		local nleft = math.ceil((args.count - MAIN_COUNT) / 2)
		local nright = args.count - MAIN_COUNT - nleft
		for i = MAIN_COUNT + 1, args.count do
			local isLeft = (i - MAIN_COUNT) % 2 == 1
			if isLeft then
				table.insert(retval, {
					OUTER_GAPS,
					y_of_i(nleft, (i - MAIN_COUNT + 1) / 2),
					side_w,
					height_for_n(nleft),
				})
			else
				table.insert(retval, {
					args.width - OUTER_GAPS - side_w,
					y_of_i(nright, (i - MAIN_COUNT) / 2),
					side_w,
					height_for_n(nright),
				})
			end
		end
	end

	if REVERSE then
		retval = revert(retval)
	end
	return retval
end


-- Interface Implementation

function handle_metadata(args)
	local layout = get_tag_state(args)[1]

	local metadata = { name = layout.symbol .. " on " .. args.output }
	METADATA = metadata

	return metadata
end

function handle_layout(args)
	local layout = get_tag_state(args)[1]
	if layout.name == "tile" then
		return tile(args, layout)
	elseif layout.name == "stack" then
		return stack(args, layout)
	elseif layout.name == "centered" then
		return centered(args, layout)
	end
end

-- User Commands

function gaps_inc(delta)
	set_gaps(gaps + delta)
	local layout = get_tag_state()[1]
	if layout.name == "tile" then
		layout.gaps = math.max(0, layout.gaps + delta)
	end
end

function main_ratio_inc(delta)
	local layout = get_tag_state()[1]
	if layout.name == "tile" then
		layout.main_ratio = math.min(math.max(layout.main_ratio + delta, 0.15), 0.85)
	end
end

function layout_cycle()
	local layouts = get_tag_state()
	local LAYOUT_INDEX = 1
  local next_index = 2
	local tmp = layouts[LAYOUT_INDEX]
	layouts[LAYOUT_INDEX] = layouts[next_index]
	layouts[next_index] = tmp
end

function set_layout(name)
	local layouts = get_tag_state()
	for key,layout in pairs(layouts) do --actualcode
		if layout.name == name then 
			local tmp = layouts[1]
			layouts[1] = layouts[key]
			layouts[key] = tmp
		end
	end
	
end
