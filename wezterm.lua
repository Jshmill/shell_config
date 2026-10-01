local wezterm = require("wezterm")
local act = wezterm.action
local saved_theme = "Embers (dark) (terminal.sexy)"

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
    },
    ["Rebecca (base16)"] = {
        nvim = "base16-rebecca",
        background = "dark",
        focused = 0.95,
        unfocused = 0.70,
    },
    ["Rosé Pine Moon (base16)"] = {
        nvim = "rose-pine-moon",
        background = "dark",
        focused = 0.85,
        unfocused = 0.65,
    },
    ["nordfox"] = {
        nvim = "nord",
        background = "dark",
        focused = 0.85,
        unfocused = 0.70,
    },
    ["Everforest Dark (Gogh)"] = {
        nvim = "everforest",
        background = "dark",
        focused = 0.85,
        unfocused = 0.70,
    },
    ['Embers (dark) (terminal.sexy)'] = {
        nvim = "ember-soft",
        background = "dark",
        focused = 0.9,
        unfocused = 0.80,
    },
    ['Embers (light) (terminal.sexy)'] = {
        nvim = "ember-light",
        background = "light",
        focused = 0.9,
        unfocused = 0.85,
    },
    ["Gruvbox dark, hard (base16)"] = {
        nvim = "gruvbox-material",
        background = "dark",
        focused = 0.95,
        unfocused = 0.80,
    },
    ["Gruvbox light, medium (base16)"] = {
        nvim = "gruvbox",
        background = "light",
        focused = 0.95,
        unfocused = 0.85,
    },
    ["Catppuccin Latte"] = {
        nvim = "catppuccin-latte",
        background = "light",
        focused = 0.95,
        unfocused = 0.85,
    },
    ["tokyonight-storm"] = {
        nvim = "tokyonight",
        background = "dark",
        focused = 0.95,
        unfocused = 0.70,
    },
    ["nightfox"] = {
        nvim = "night-owl",
        background = "dark",
        focused = 0.95,
        unfocused = 0.70,
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
		cursor_bg = scheme.ansi[8],
		cursor_border = scheme.ansi[8],
		cursor_fg = scheme.background,

		tab_bar = {
			background = "NONE",

			active_tab = {
				bg_color = "NONE",
				fg_color = scheme.ansi[6],
			},

			inactive_tab = {
				bg_color = "NONE",
				fg_color = scheme.ansi[8],
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

                save_wezterm_theme(label)
                apply_theme(win, label)

				win:perform_action(wezterm.action.ReloadConfiguration, pane)

                local theme = nvim_theme_map[label]

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
