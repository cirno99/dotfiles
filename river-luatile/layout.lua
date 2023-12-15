package.path = ";/home/cirno99/.config/river-luatile/?.lua;" .. package.path

local bit = require("bit")
local utils = require("utils")

-- Global State

MAIN_COUNT = 1
REVERSE = false
PREFER_HORIZONTAL = true
SMART_GAPS = true

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
    local default = { -- { name = "tile", symbol = "[]=", gaps = 3, main_ratio = 0.60 },
    {
        name = "bspwm",
        symbol = "[]+",
        inner_gaps = 3,
        outer_gaps = 3,
        main_ratio = 0.60
    }, {
        name = "stack",
        symbol = "[[]",
        inner_gaps = 3,
        outer_gaps = 3,
        main_ratio = 0.60
    }, {
        name = "centered",
        symbol = "[[c]]",
        inner_gaps = 3,
        outer_gaps = 3,
        main_ratio = 0.60
    }}
    overrides[key] = default
    return default
end

-- Layout Implementation

local function tile(args, layout)
    local retval = {}
    if args.count == 1 then
        table.insert(retval, {0, 0, args.width, args.height})
    elseif args.count > 1 then
        local main_w = (args.width - layout.gaps) * layout.main_ratio
        local side_w = args.width - layout.gaps - main_w
        local main_h = args.height
        local side_h = (args.height - layout.gaps * (args.count - 2)) / (args.count - 1)
        table.insert(retval, {0, 0, main_w, main_h})
        for i = 0, (args.count - 2) do
            table.insert(retval, {main_w + layout.gaps, i * (side_h + layout.gaps), side_w, side_h})
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
        table.insert(retval, {dx * i, dy * i, width, height})
    end
    return retval
end

local function bspwm(args, layout)
    args.inner_gaps = layout.inner_gaps
    args.outer_gaps = layout.outer_gaps
    local revert = function(retval)
        return require("utils").revert(args, retval)
    end
    --

    local retval = {}
    if args.count == 1 then
        if SMART_GAPS then
            table.insert(retval, {0, 0, args.width, args.height})
        else
            table.insert(retval, {layout.outer_gaps, layout.outer_gaps, args.width - layout.outer_gaps * 2,
                                  args.height - layout.outer_gaps * 2})
        end
    elseif args.count > 1 then
        local main_w = (args.width - layout.outer_gaps * 2 - layout.inner_gaps) * layout.main_ratio
        local main_h = args.height - layout.outer_gaps * 2
        table.insert(retval, {layout.outer_gaps, layout.outer_gaps, main_w, main_h})
        -- we are doing a dwindle layout here. first window is the biggest, the rest are smaller
        for i = 2, args.count do
            local w, h, x, y
            local isEven = i % 2 == 0
            local isOdd = not isEven
            -- width:
            -- if it is even, its width is previous window's width * (1/ratio - 1)
            -- if it is odd, its width depends on:
            -- it is the last: width = previous window's width
            -- it is not the last: width = (previous window's width - gaps ) * ratio
            if isEven then
                w = retval[i - 1][3] * (1 / layout.main_ratio - 1)
            else
                if i == args.count then
                    w = retval[i - 1][3]
                else
                    w = (retval[i - 1][3] - layout.inner_gaps) * layout.main_ratio
                end
            end

            -- height:
            -- if is the second window (i == 2) it depends on:
            -- it is the last window: h = previous window's height
            -- it is not the last window: h = (main_h - 3 * gaps) * ratio
            -- otherwise:
            -- if it is odd, h = previous window's height * (1/ratio - 1)
            -- if it is even, it depends on:
            -- it is the last: h = previous window's height
            -- it is not the last: h = (previous window's height - gaps) * ratio
            if i == 2 then
                if i == args.count then
                    h = retval[i - 1][4]
                else
                    h = (args.height - 2 * layout.outer_gaps - layout.inner_gaps) * layout.main_ratio
                end
            else
                if isOdd then
                    h = retval[i - 1][4] * (1 / layout.main_ratio - 1)
                else
                    if i == args.count then
                        h = retval[i - 1][4]
                    else
                        h = (retval[i - 1][4] - layout.inner_gaps) * layout.main_ratio
                    end
                end
            end

            -- x:
            -- if it is even, x = previous window's x + previous window's width + gaps
            -- if it is odd, x = previous window's x
            if isEven then
                x = retval[i - 1][1] + retval[i - 1][3] + layout.inner_gaps
            else
                x = retval[i - 1][1]
            end

            -- y:
            -- if it is even, y = previous window's y
            -- if it is odd, y = previous window's y + previous window's height + gaps
            if isEven then
                y = retval[i - 1][2]
            else
                y = retval[i - 1][2] + retval[i - 1][4] + layout.inner_gaps
            end

            table.insert(retval, {x, y, w, h})
        end
    end

    if REVERSE then
        retval = revert(retval)
    end

    return retval

end

local function centered(args, layout)
    local retval = {}
    args.inner_gaps = layout.inner_gaps
    args.outer_gaps = layout.outer_gaps

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
        if SMART_GAPS then
            table.insert(retval, {0, 0, args.width, args.height})
        else
            table.insert(retval, {layout.outer_gaps, layout.outer_gaps, args.width - layout.outer_gaps * 2,
                                  args.height - layout.outer_gaps * 2})
        end
    elseif args.count <= 1 + MAIN_COUNT then
        local x, y, w, h
        local main_w = (args.width - layout.outer_gaps * 2 - layout.inner_gaps) * layout.main_ratio
        local main_h = height_for_n(math.min(MAIN_COUNT, args.count))
        local side_w = main_w * (1 / layout.main_ratio - 1)
        -- main window(s)
        local w_accumulated = 0
        for i = 1, math.min(MAIN_COUNT, args.count) do
            if PREFER_HORIZONTAL then
                if args.count <= MAIN_COUNT then
                    x = layout.outer_gaps
                    w = args.width - layout.outer_gaps * 2
                    h = main_h
                    y = layout.outer_gaps + layout.inner_gaps * (i - 1) + main_h * (i - 1)
                else
                    x = layout.outer_gaps + side_w + layout.inner_gaps
                    w = main_w
                    h = main_h
                    y = y_of_i(MAIN_COUNT, i)
                end
            else
                if args.count <= MAIN_COUNT then
                    local q = (i == 1) and 1 or (math.min(args.count) - 1)
                    w = main_w / q
                    w_accumulated = w_accumulated + w
                    x = layout.outer_gaps + layout.inner_gaps * (i - 1) + w_accumulated - w
                    y = layout.outer_gaps
                    h = args.height - layout.outer_gaps * 2
                else
                    x = layout.outer_gaps + side_w + layout.inner_gaps
                    y = y_of_i(MAIN_COUNT, i)
                    w = main_w
                    h = main_h
                end
            end
            table.insert(retval, {x, y, w, h})
        end

        -- side window
        for _ = MAIN_COUNT + 1, args.count do
            table.insert(retval, {layout.outer_gaps, layout.outer_gaps, side_w, args.height - layout.outer_gaps * 2})
        end
    elseif args.count > 1 + MAIN_COUNT then
        -- general case
        local main_w = (args.width - 2 * layout.outer_gaps - 2 * layout.inner_gaps) * layout.main_ratio
        local main_h = height_for_n(MAIN_COUNT)
        local side_w = 0.5 * main_w * (1 / layout.main_ratio - 1)
        -- main window(s)
        for i = 1, MAIN_COUNT do
            table.insert(retval, {layout.outer_gaps + side_w + layout.inner_gaps, y_of_i(MAIN_COUNT, i), main_w, main_h})
        end

        local nleft = math.ceil((args.count - MAIN_COUNT) / 2)
        local nright = args.count - MAIN_COUNT - nleft
        for i = MAIN_COUNT + 1, args.count do
            local isLeft = (i - MAIN_COUNT) % 2 == 1
            if isLeft then
                table.insert(retval,
                    {layout.outer_gaps, y_of_i(nleft, (i - MAIN_COUNT + 1) / 2), side_w, height_for_n(nleft)})
            else
                table.insert(retval, {args.width - layout.outer_gaps - side_w, y_of_i(nright, (i - MAIN_COUNT) / 2),
                                      side_w, height_for_n(nright)})
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

    local metadata = {
        name = layout.symbol .. " on " .. args.output
    }
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
    elseif layout.name == "bspwm" then
        return bspwm(args, layout)
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

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function main_ratio_inc(delta)
    local layout = get_tag_state()[1]
    if has_value({"tile", "bspwm", "centered"}, layout.name) then
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
    for key, layout in pairs(layouts) do -- actualcode
        if layout.name == name then
            local tmp = layouts[1]
            layouts[1] = layouts[key]
            layouts[key] = tmp
        end
    end

end
