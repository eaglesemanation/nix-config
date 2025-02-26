local augroup = vim.api.nvim_create_augroup("kubernetes_ft", { clear = true })

local query_string = [[
  (
    (document
      (block_node
        (block_mapping
          (block_mapping_pair key: (_) @_api_key (#eq? @_api_key "apiVersion"))
          (block_mapping_pair key: (_) @_kind_key (#eq? @_kind_key "kind"))
          (block_mapping_pair 
            key: (_) @_meta_key (#eq? @_meta_key "metadata")
            value: (block_node(block_mapping(
              block_mapping_pair key: (_) @_name_key (#eq? @_name_key "name")
            )))
          )
        )
      )
    )
  ) @kubernetes
]]

local query_cache = nil

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "yaml",
	callback = function(args)
		local buf = args.buf
		if vim.fn.bufloaded(buf) == 0 then
			return
		end

		-- Check for Tree-sitter YAML parser availability
		local ok, parser = pcall(vim.treesitter.get_parser, buf, "yaml")
		if not ok or not parser then
			return
		end

		-- Parse buffer content
		local tree = parser:parse()[1]
		if not tree then
			return
		end
		local root = tree:root()

		-- Lazy-load and cache the query
		if not query_cache then
			local ok_query, parsed_query = pcall(vim.treesitter.query.parse, "yaml", query_string)
			if ok_query and parsed_query then
				query_cache = parsed_query
			else
				return
			end
		end

		-- Check for Kubernetes pattern matches
		for _, _ in query_cache:iter_matches(root, buf) do
			vim.schedule(function()
				vim.api.nvim_buf_set_option(buf, "filetype", "yaml.kubernetes")
			end)
			return
		end
	end,
})
