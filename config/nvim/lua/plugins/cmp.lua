return {
	"saghen/blink.cmp",
	version = "1.*",
	opts = function(_, opts)
		opts.keymap = { preset = "super-tab" }
		opts.sources = { default = { "lsp", "path" } }

		opts.completion = {
			documentation = { auto_show = true, auto_show_delay_ms = 100 },
			menu = {
				draw = {
					columns = {
						{ "kind_icon", "label", gap = 1 },
						{ "label_description", "source_name", gap = 1 },
					},
				},
			},
		}
	end,
}
