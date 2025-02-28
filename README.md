# shadcn-svelte.nvim

A plugin for quick installation of shadcn-svelte components into your project
![Component Not Installed](showcase/error.png)
![Popup](showcase/popup.png)
![Popup Complete](showcase/popup-complete.png)
![Component Available](showcase/component-available.png)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

Install with you preferred plugin manager

```lua
{
  "phishbacon/shadcn-svelte.nvim"
}
```

## Usage

Use the command ```ShadcnSvelte <component name>``` to quickly install components into your project

## Setup

Customization can be done through the ```setup()``` method. The default configuration is shown below. Supported package managers include ```pnpm | bun | yarn | npm```. There is only one keymap, which will close the floating terminal window. It is mapped to ```<Esc>``` by default.

```lua
require("shadcn-svelte").setup({
  package_manager = "pnpm",
  window_size = {
    height = 60, -- percent of window height (range 1-100)
    width = 30, -- percent of window width (range 1-100)
  },
  keymap = {
    close_window = "<Esc>"
  }
})
```



