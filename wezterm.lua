local wezterm = require("wezterm")
local act = wezterm.action

wezterm.on("window-focus-changed", function(window, pane)
	local overrides = window:get_config_overrides() or {}

	if window:is_focused() then
		overrides.window_background_opacity = 0.8
	else
		overrides.window_background_opacity = 0.6
	end

	window:set_config_overrides(overrides)
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

-- Map wezterm color_scheme name -> neovim colorscheme name.
-- Edit the right-hand side to match whatever colorscheme plugins you have
-- installed in neovim.
local nvim_theme_map = {
	["Catppuccin Mocha"] = "catppuccin-mocha",
	["Rebecca (base16)"] = "base16-rebecca",
	["Rosé Pine Moon (base16)"] = "rose-pine-moon",
	["nordfox"] = "nord",
	["Everforest Dark (Gogh)"] = "everforest",
	["Gruvbox Dark (base16)"] = "gruvbox",
	["Github"] = "github_light",
	["tokyonight-storm"] = "tokyonight",
}

local theme_state_file = os.getenv("HOME") .. "/.cache/wezterm-nvim-theme"

local function write_theme_state(nvim_theme)
	local f = io.open(theme_state_file, "w")
	if f then
		f:write(nvim_theme)
		f:close()
	end
end

-- Push the colorscheme change into every currently running nvim pane,
-- across all tabs and windows.
local function sync_nvim_panes(nvim_theme)
	local mux = wezterm.mux
	for _, mux_win in ipairs(mux.all_windows()) do
		for _, tab in ipairs(mux_win:tabs()) do
			for _, pane in ipairs(tab:panes()) do
				local process = pane:get_foreground_process_name() or ""
				if process:match("[/\\]n?vim$") then
					-- Esc to leave insert/visual mode, run the command, then Enter
					pane:send_text("\x1b:colorscheme " .. nvim_theme .. "\r")
				end
			end
		end
	end
end

wezterm.on("theme-picker", function(window, pane)
	local choices = {}
	for name, _ in pairs(nvim_theme_map) do
		table.insert(choices, name)
	end
	table.sort(choices)

	local formatted_choices = {}
	for _, name in ipairs(choices) do
		table.insert(formatted_choices, { label = name })
	end

	window:perform_action(
		act.InputSelector({
			title = "Select Theme",
			fuzzy = true,
			choices = formatted_choices,
			action = wezterm.action_callback(function(win, _, _, label)
				if not label then
					return
				end

				local overrides = win:get_config_overrides() or {}
				overrides.color_scheme = label
				win:set_config_overrides(overrides)
				win:perform_action(wezterm.action.ReloadConfiguration, pane)

				local nvim_theme = nvim_theme_map[label]
				if nvim_theme then
					write_theme_state(nvim_theme)
					sync_nvim_panes(nvim_theme)
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
	macos_window_background_blur = 40, -- frosted glass effect
	hide_tab_bar_if_only_one_tab = true, -- hides tab bar when not needed
	tab_bar_at_bottom = true, -- moves the tab bar to the bottom of the window
    window_close_confirmation = "NeverPrompt",

    -----------------
	-- Font and theme
    -----------------
	font = wezterm.font("Fira Code"),
	font_size = 14.0,

    --------------------
    -- DARK MODE
    --------------------
	-- color_scheme = "Catppuccin Mocha",
	-- color_scheme = "Rebecca (base16)",
	-- color_scheme = "Rosé Pine Moon (base16)",
    color_scheme = "nordfox",
    -- color_scheme = 'Everforest Dark (Gogh)',
	-- color_scheme = "Gruvbox Dark (base16)",

    --------------------
    -- LIGHT MODE
    --------------------
	-- color_scheme = "Github",

	-- Initial window size and position
	initial_cols = 170,
	initial_rows = 50,

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
	},

	colors = {
		tab_bar = {
			active_tab = {
				bg_color = "NONE",
				fg_color = "#BAC2DE",
			},
			inactive_tab = {
				bg_color = "NONE",
				fg_color = "#F5E0DC",
			},
		},
	},
}

