return {
	s(
		"uuid",
		f(function()
			local uuid = vim.fn.system("uuidgen")
			return string.sub(uuid, 1, -2)
		end)
	),
}
