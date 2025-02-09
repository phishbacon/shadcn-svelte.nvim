vim.api.nvim_create_user_command("ShadcnSvelte", function(opts)
  package.loaded["shadcn-svelte"] = nil
  require("shadcn-svelte").install_component(opts.args)
end, { nargs = 1 })
