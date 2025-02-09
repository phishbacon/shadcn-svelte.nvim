vim.api.nvim_create_user_command("ShadcnSvelte", function(opts)
  require("shadcn-svelte").install_component(opts.args)
  package.loaded["shadcn-svelte"] = nil
end, { nargs = 1 })
