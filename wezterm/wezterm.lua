---@diagnostic disable: unused-local
local wezterm = require("wezterm")
local act = wezterm.action

local function modify_colorscheme(colorscheme)
    local file_path = os.getenv("HOME") .. "/.config/wezterm/wezterm.lua"
    local _f = assert(io.open(file_path, "r"))
    local data = _f:read("*a")
    _f:close()

    local f = assert(io.open(file_path, "w"))
    data = data:gsub(
        'local color_scheme = "[^%%]-"',
        ('local color_scheme = "%s"'):format(colorscheme)
    )
    f:write(data)
    f:close()
end

wezterm.on("user-var-changed", function(window, pane, name, value)
    local overrides = window:get_config_overrides() or {}
    if name == "Nvim_Colorscheme" then
        overrides.color_scheme = value
        modify_colorscheme(value)
    end
    window:set_config_overrides(overrides)
end)

local color_scheme = "Rosé Pine Moon"

return {
    -- font = wezterm.font_with_fallback({
    --     {
    --         family = "CartographCF Nerd Font",
    --         harfbuzz_features = {
    --             "cv01=1",
    --             "cv02=1",
    --             "ss01=1",
    --             "ss02=1",
    --             "ss03=1",
    --             "ss04=1",
    --             "ss05=1",
    --         },
    --     },
    --     "CartographCF Nerd Font",
    --     "MapleMono NF", -- for Chinese
    --     "Noto Color Emoji",

    --     -- icons
    --     "Font Awesome 6 Pro Solid",
    --     "Material Design Icons Desktop",
    --     "MesloLGSDZ Nerd Font Mono",
    --     "feather",
    -- }),
    font = wezterm.font("CartographCF Nerd Font"),
    font_size = 12.5,

    color_scheme = color_scheme,

    -- default_prog = { "/bin/bash", "-l", "-c", "tmux attach || tmux" },

    window_padding = {
        left = 10,
        right = 2,
        top = 0,
        bottom = 0,
    },
    window_background_opacity = 0.95,
    window_decorations = "RESIZE",
    window_close_confirmation = "NeverPrompt",

    enable_tab_bar = false,
    use_fancy_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true,
    tab_bar_at_bottom = false,

    cursor_blink_ease_in = "Constant",
    cursor_blink_ease_out = "Constant",

    hyperlink_rules = {
        -- Linkify things that look like URLs
        -- This is actually the default if you don't specify any hyperlink_rules
        {
            regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b",
            format = "$0",
        },
        -- match the URL with a PORT
        -- such 'http://localhost:3000/index.html'
        {
            regex = "\\b\\w+://(?:[\\w.-]+):\\d+\\S*\\b",
            format = "$0",
        },
        -- linkify email addresses
        {
            regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
            format = "mailto:$0",
        },
        -- file:// URI
        {
            regex = "\\bfile://\\S*\\b",
            format = "$0",
        },
    },

    disable_default_key_bindings = false,
    keys = {
        {
            key = "Enter",
            mods = "SHIFT",
            action = act.SendString("\x1b[13;2u"),
        },
        { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
        { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
        { key = "Tab", mods = "CTRL", action = act({ ActivateTabRelative = 1 }) },
        {
            key = "Tab",
            mods = "CTRL|SHIFT",
            action = act({ ActivateTabRelative = -1 }),
        },
        -- activate pane selection mode with the default alphabet (labels are "a", "s", "d", "f" and so on)
        { key = 'y', mods = 'CTRL', action = act.PaneSelect },
        -- activate pane selection mode with numeric labels
        -- {
        --   key = '9',
        --   mods = 'CTRL',
        --   action = act.PaneSelect {
        --     alphabet = '1234567890',
        --   },
        -- },
        -- show the pane selection mode, but have it swap the active and selected panes
        {
          key = 'u',
          mods = 'CTRL',
          action = act.PaneSelect {
            mode = 'SwapWithActive',
          },
        },

    },
    -- use_ime = true,
    -- xim_im_name = "fcitx",
    -- ime_preedit_rendering = "Builtin",
}
