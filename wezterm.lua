local wezterm = require("wezterm")
local act = wezterm.action
local saved_theme = "nordfox"

local function save_wezterm_theme(theme)
	local config_file = wezterm.config_file

	local f = io.open(config_file, "r")
	if not f then
		return
	end

	local content = f:read("*a")
	f:close()

    local prefix = "local " .. "saved_theme = "

    content = content:gsub(
        prefix .. '"[^"]+"',
        prefix .. '"' .. theme .. '"',
        1
    )

	f = io.open(config_file, "w")
	if f then
		f:write(content)
		f:close()
	end
end

-- Map wezterm color_scheme name -> neovim colorscheme name.
-- Edit the right-hand side to match whatever colorscheme plugins you have
-- installed in neovim.
local nvim_theme_map = {
    ["Catppuccin Mocha"] = {
        nvim = "catppuccin-mocha",
        background = "dark",
        focused = 0.75,
        unfocused = 0.55,

        ansi = {
            "#1e1e2e", -- 1 black:      background / very dark
            "#f38ba8", -- 2 red:        errors
            "#a6e3a1", -- 3 green:      strings / added
            "#f9e2af", -- 4 yellow:     functions / types / warnings
            "#89b4fa", -- 5 blue:       info / links / attributes
            "#cba6f7", -- 6 magenta:    keywords / tags / accent
            "#89dceb", -- 7 cyan:       methods / hints
            "#f5e0dc", -- 8 white:      variables / properties
        },
    },
    ["Rosé Pine Moon (base16)"] = {
        nvim = "rose-pine-moon",
        background = "dark",
        focused = 0.85,
        unfocused = 0.65,

        ansi = {
            "#232136", -- 1 black:      background / very dark
            "#eb6f92", -- 2 red:        errors
            "#f6c177", -- 3 green:      strings / added
            "#ea9a97", -- 4 yellow:     functions / types / warnings
            "#3e8fb0", -- 5 blue:       info / links / attributes
            "#c4a7e7", -- 6 magenta:    keywords / tags / accent
            "#9ccfd8", -- 7 cyan:       methods / hints
            "#e0def4", -- 8 white:      variables / properties
        },
    },
    ["nordfox"] = {
        nvim = "nord",
        background = "dark",
        focused = 0.85,
        unfocused = 0.70,

        ansi = {
            "#3b4252", -- 1 black:      background / very dark
            "#bf616a", -- 2 red:        errors
            "#a3be8c", -- 3 green:      strings / added
            "#ebcb8b", -- 4 yellow:     functions / types / warnings
            "#81a1c1", -- 5 blue:       info / links / attributes
            "#b48ead", -- 6 magenta:    keywords / tags / accent
            "#88c0d0", -- 7 cyan:       methods / hints
            "#e5e9f0", -- 8 white:      variables / properties
        },
    },
    ["Everforest Dark (Gogh)"] = {
        nvim = "everforest",
        background = "dark",
        focused = 0.9,
        unfocused = 0.75,

        ansi = {
            "#3c4841", -- 1 black:      background / very dark
            "#e67e80", -- 2 red:        errors
            "#a7c080", -- 3 green:      strings / added
            "#dbbc7f", -- 4 yellow:     functions / types / warnings
            "#7fbbb3", -- 5 blue:       info / links / attributes
            "#d699b6", -- 6 magenta:    keywords / tags / accent
            "#83c092", -- 7 cyan:       methods / hints
            "#d3c6aa", -- 8 white:      variables / properties
        },
    },
    ['Embers (dark) (terminal.sexy)'] = {
        nvim = "ember-soft",
        background = "dark",
        focused = 0.95,
        unfocused = 0.80,

        ansi = {
            "#242320", -- 1 black:      background / very dark
            "#b07878", -- 2 red:        errors
            "#8a9868", -- 3 green:      strings / added
            "#c8b468", -- 4 yellow:     functions / types / warnings
            "#7890a0", -- 5 blue:       info / links / attributes
            "#e08060", -- 6 magenta:    keywords / tags / accent
            "#80a090", -- 7 cyan:       methods / hints
            "#b0a898", -- 8 white:      variables / properties
        },
    },
    ['Embers (light) (terminal.sexy)'] = {
        nvim = "ember-light",
        background = "light",
        focused = 0.95,
        unfocused = 0.85,

        ansi = {
            "#e6dac4", -- 1 black:      background / very dark
            "#905050", -- 2 red:        errors
            "#4a6830", -- 3 green:      strings / added
            "#7a6820", -- 4 yellow:     functions / types / warnings
            "#3a6080", -- 5 blue:       info / links / attributes
            "#b84c30", -- 6 magenta:    keywords / tags / accent
            "#386858", -- 7 cyan:       methods / hints
            "#282418", -- 8 white:      variables / properties
        },
    },
    ["Catppuccin Latte"] = {
        nvim = "catppuccin-latte",
        background = "light",
        focused = 0.95,
        unfocused = 0.85,

        ansi = { --TODO:
            "#242320", -- 1 black:      background / very dark
            "#b07878", -- 2 red:        errors
            "#8a9868", -- 3 green:      strings / added
            "#c8b468", -- 4 yellow:     functions / types / warnings
            "#7890a0", -- 5 blue:       info / links / attributes
            "#e08060", -- 6 magenta:    keywords / tags / accent
            "#80a090", -- 7 cyan:       methods / hints
            "#b0a898", -- 8 white:      variables / properties
        },
    },
}

local function apply_theme(window, theme_name)
	local theme = nvim_theme_map[theme_name]
	local scheme = wezterm.color.get_builtin_schemes()[theme_name]

	if not theme or not scheme then
		return
	end

	local overrides = window:get_config_overrides() or {}

	overrides.color_scheme = theme_name

	overrides.window_background_opacity =
		window:is_focused() and theme.focused or theme.unfocused

    overrides.colors = {
        background = theme.ansi[1],
        ansi = theme.ansi or scheme.ansi,

        cursor_bg = theme.ansi[8],
		cursor_border = scheme.ansi[8],
		cursor_fg = scheme.background,

		tab_bar = {
			background = "NONE",

			active_tab = {
				bg_color = "NONE",
				fg_color = theme.ansi[6],
			},

			inactive_tab = {
				bg_color = "NONE",
				fg_color = theme.ansi[8],
			},
		},
	}

	window:set_config_overrides(overrides)
end

wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}
	local theme_name = overrides.color_scheme or saved_theme

	apply_theme(window, theme_name)
end)

wezterm.on("gui-startup", function(cmd)
	local screen = wezterm.gui.screens().active

	local width = math.floor(screen.width * 0.7)
	local height = math.floor(screen.height * 0.95)

	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	local gui = window:gui_window()

	gui:set_inner_size(width, height)

	gui:set_position(
		screen.x + (screen.width - width) / 2,
		screen.y + (screen.height - height) / 2
	)
end)

-- Block the CMD+O keybinding from clearing the scrollback when in vim/neovim
wezterm.on("smart-cmd-o", function(window, pane)
	local process = pane:get_foreground_process_name() or ""

	-- Don't clear scrollback if we're in vim/neovim
	if process:match("[/\\]n?vim$") then
		return
	end

	window:perform_action(
		act.ClearScrollback("ScrollbackAndViewport"),
		pane
	)
end)

local theme_state_file = os.getenv("HOME") .. "/.cache/wezterm-nvim-theme"

local function write_theme_state(nvim_theme)
	local f = io.open(theme_state_file, "w")
	if f then
		f:write(nvim_theme)
		f:close()
	end
end

wezterm.on("format-tab-title", function(tab)
  -- Prefer a manually assigned tab name
  if tab.tab_title and #tab.tab_title > 0 then
    return " " .. tab.tab_title .. " "
  end

  local proc = tab.active_pane.foreground_process_name or ""

  -- Only customize tabs running nvim
  if proc:match("n?vim$") then
    local cwd = tab.active_pane.current_working_dir

    if cwd then
      local dir = cwd.file_path:match("([^/\\]+)$")
      return " " .. dir .. " "
    end
  end

  -- Default behavior for everything else
  return tab.active_pane.title
end)



-- Push the colorscheme change into every currently running nvim pane,
-- across all tabs and windows.
local function sync_nvim_panes(theme)
	local mux = wezterm.mux

	for _, mux_win in ipairs(mux.all_windows()) do
		for _, tab in ipairs(mux_win:tabs()) do
			for _, pane in ipairs(tab:panes()) do
				local process = pane:get_foreground_process_name() or ""

                -- Reset terminal colors for hung panes
				if process:match("[/\\]n?vim$") then
					pane:send_text(
						"\x1b:set background="
							.. theme.background
							.. " | colorscheme "
							.. theme.nvim
							.. "\r"
					)
				end
			end
		end
	end
end

wezterm.on("theme-picker", function(window, pane)
    local dark = {}
    local light = {}

    for name, theme in pairs(nvim_theme_map) do
        if theme.background == "light" then
            table.insert(light, name)
        else
            table.insert(dark, name)
        end
    end

    table.sort(dark)
    table.sort(light)

    local formatted_choices = {}

    for _, name in ipairs(dark) do
        table.insert(formatted_choices, {
            label = "󰖔  " .. name,
            id = name,
        })
    end

    for _, name in ipairs(light) do
        table.insert(formatted_choices, {
            label = "󰖙  " .. name,
            id = name,
        })
    end

	window:perform_action(
		act.InputSelector({
			title = "Select Theme",
			fuzzy = false,
			choices = formatted_choices,
            action = wezterm.action_callback(function(win, _, id, _)
				if not id then
					return
				end

                save_wezterm_theme(id)
                apply_theme(win, id)

                local theme = nvim_theme_map[id]

                if theme then
                    write_theme_state(theme.nvim)
                    sync_nvim_panes(theme)
                end
			end),
		}),
		pane
	)
end)

return {
	automatically_reload_config = true,
	-- Window appearance
	window_decorations = "RESIZE", -- hides the title bar buttons
	macos_window_background_blur = 30, -- frosted glass effect
	hide_tab_bar_if_only_one_tab = true, -- hides tab bar when not needed
    show_tab_index_in_tab_bar = false,
	tab_bar_at_bottom = true, -- moves the tab bar to the bottom of the window
    use_fancy_tab_bar = true,
    window_close_confirmation = "NeverPrompt",
    show_new_tab_button_in_tab_bar = false,
    inactive_pane_hsb = {
    saturation = 0.7,
    brightness = 0.8,
    },

    -----------------
	-- Font and theme
    -----------------
	font = wezterm.font("Fira Code"),
	-- font = wezterm.font("JetBrains Mono"),
	font_size = 17.0,

    --------------------
    -- INITIAL THEME
    --------------------
    color_scheme = saved_theme,

    window_background_opacity = nvim_theme_map[saved_theme].focused,

	window_frame = {
		active_titlebar_bg = "rgba(0, 0, 0, 0)",
		inactive_titlebar_bg = "rgba(0, 0, 0, 0)",
	},

	-- Keybindings
	keys = {
		{ key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
		{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },
		{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
		{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },
		{ key = "H", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "L", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "K", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "J", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },
        {
            key = "s",
            mods = "CMD",
            action = act.PaneSelect({
                mode = "SwapWithActiveKeepFocus",
                alphabet = "hjkl",
            }),
        },
		-- Clear terminal
		{
			key = "o",
			mods = "CMD",
            action = act.EmitEvent("smart-cmd-o"),
		},
        {
            key = 'o',
            mods = 'CMD|SHIFT',
            action = wezterm.action.TogglePaneZoomState,
        },
        {
        key = "t",
        mods = "CMD|SHIFT",
        action = act.EmitEvent("theme-picker"),
        },
        {
        key = 'c',
        mods = 'CMD',
        action = wezterm.action.ActivateCopyMode,
        },
        {
            key = "r",
            mods = "CMD|SHIFT",
            action = act.PromptInputLine({
                description = "Rename tab:",
                action = wezterm.action_callback(function(window, pane, line)
                    if line then
                        window:active_tab():set_title(line)
                    end
                end),
            }),
        },
	},
}
