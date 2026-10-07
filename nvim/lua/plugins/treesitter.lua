-- Syntax highlighting: common languages installed up front (on top of LazyVim's
-- defaults), plus any other supported language installed the first time you open it.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- web
        "css", "scss", "svelte", "vue", "graphql",
        -- systems / backend
        "go", "gomod", "gosum", "rust", "zig", "cpp", "java", "kotlin", "c_sharp", "swift",
        "ruby", "php", "elixir", "heex", "eex", "erlang",
        -- data / config
        "sql", "csv", "proto", "ini", "terraform", "hcl", "nix", "jq",
        -- build / ops
        "dockerfile", "make", "cmake", "just",
        -- git / shell
        "gitcommit", "gitignore", "git_config", "git_rebase", "gitattributes", "ssh_config",
      },
    },
    init = function()
      local pending = {}
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_auto_install", { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang or pending[lang] then
            return
          end
          local ok, ts = pcall(require, "nvim-treesitter")
          if not ok
            or vim.list_contains(ts.get_installed(), lang)
            or not vim.list_contains(ts.get_available(), lang)
          then
            return
          end

          pending[lang] = true
          ts.install(lang):await(function()
            pending[lang] = nil
            vim.schedule(function()
              LazyVim.treesitter.get_installed(true) -- refresh LazyVim's cache
              -- Re-run FileType so LazyVim turns on highlighting for open buffers
              for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == ev.match then
                  vim.api.nvim_buf_call(buf, function()
                    vim.cmd("doautocmd FileType " .. ev.match)
                  end)
                end
              end
            end)
          end)
        end,
      })
    end,
  },
}
