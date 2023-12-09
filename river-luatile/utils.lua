
local M = {}

--- mirror the layout with respect to the center of the screen (x axis)
M.revert = function(args, return_of_layout)
	local retval = return_of_layout
	for _, v in ipairs(retval) do
		v[1] = args.width - v[1] - v[3]
	end
	return retval
end

--- given n windows on a side, return the height of each window
M.height_for_n = function(args, n)
	-- return (args.height - GAPS * (n + 1)) / n
	return (args.height - (INNER_GAPS * (n - 1)) - (OUTER_GAPS * 2)) / n
end

--- given n windows on a side, return the height of i-th window
M.y_of_i = function(args, n, i)
	-- return GAPS * i + M.height_for_n(args, n) * (i - 1)
	return OUTER_GAPS + INNER_GAPS * (i - 1) + M.height_for_n(args, n) * (i - 1)
end

--- given n windows on a row, return the width of each window
M.width_for_n = function(args, n)
	-- return (args.width - GAPS * (n + 1)) / n
	return (args.width - (INNER_GAPS * (n - 1)) - (OUTER_GAPS * 2)) / n
end

--- given n windows on a row, return the x position of i-th window
M.x_of_i = function(args, n, i)
	-- return GAPS * i + M.width_for_n(args, n) * (i - 1)
	return OUTER_GAPS + INNER_GAPS * (i - 1) + M.width_for_n(args, n) * (i - 1)
end

return M
