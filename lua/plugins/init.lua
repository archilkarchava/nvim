local Util = require("util")

return {
  -- Standalone Neovim only plugins
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    version = "v2",
    config = true,
  },
  {
    "projekt0n/github-nvim-theme",
    lazy = false,
    priority = 1000,
    version = "*",
    config = function()
      require("github-theme").setup({
        options = {
          styles = {
            functions = "italic"
          }
        }
      })
      vim.cmd("colorscheme github_dark_high_contrast")
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    enabled = false,
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-path",
    },
  },
  -- fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "jvgrootveld/telescope-zoxide",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    version = "*",
    keys = function()
      return {
        { "<leader>,",  "<cmd>Telescope buffers show_all_buffers=true<cr>",       desc = "Switch Buffer" },
        { "<leader>/",  Util.telescope("live_grep"),                              desc = "Find in Files (Grep)" },
        { "<leader>:",  "<cmd>Telescope command_history<cr>",                     desc = "Command History" },
        -- find
        { "<leader>fb", "<cmd>Telescope buffers<cr>",                             desc = "Buffers" },
        { "<leader>ff", Util.telescope("files"),                                  desc = "Find Files (root dir)" },
        { "<leader>fF", Util.telescope("files", { cwd = false }),                 desc = "Find Files (cwd)" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                            desc = "Recent" },
        { "<leader>fz", "<cmd>Telescope zoxide list<cr>",                         desc = "Zoxide" },
        -- git
        { "<leader>gc", "<cmd>Telescope git_commits<CR>",                         desc = "commits" },
        { "<leader>gs", "<cmd>Telescope git_status<CR>",                          desc = "status" },
        -- search
        { "<leader>sa", "<cmd>Telescope autocommands<cr>",                        desc = "Auto Commands" },
        { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>",           desc = "Buffer" },
        { "<leader>sc", "<cmd>Telescope command_history<cr>",                     desc = "Command History" },
        { "<leader>sC", "<cmd>Telescope commands<cr>",                            desc = "Commands" },
        { "<leader>sd", "<cmd>Telescope diagnostics<cr>",                         desc = "Diagnostics" },
        { "<leader>sg", Util.telescope("live_grep"),                              desc = "Grep (root dir)" },
        { "<leader>sG", Util.telescope("live_grep", { cwd = false }),             desc = "Grep (cwd)" },
        { "<leader>sh", "<cmd>Telescope help_tags<cr>",                           desc = "Help Pages" },
        { "<leader>sH", "<cmd>Telescope highlights<cr>",                          desc = "Search Highlight Groups" },
        { "<leader>sk", "<cmd>Telescope keymaps<cr>",                             desc = "Key Maps" },
        { "<leader>sM", "<cmd>Telescope man_pages<cr>",                           desc = "Man Pages" },
        { "<leader>sm", "<cmd>Telescope marks<cr>",                               desc = "Jump to Mark" },
        { "<leader>so", "<cmd>Telescope vim_options<cr>",                         desc = "Options" },
        { "<leader>sR", "<cmd>Telescope resume<cr>",                              desc = "Resume" },
        { "<leader>sw", Util.telescope("grep_string"),                            desc = "Word (root dir)" },
        { "<leader>sW", Util.telescope("grep_string", { cwd = false }),           desc = "Word (cwd)" },
        { "<leader>uC", Util.telescope("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
        {
          "<leader>ss",
          Util.telescope("lsp_document_symbols", {
            symbols = {
              "Class",
              "Function",
              "Method",
              "Constructor",
              "Interface",
              "Module",
              "Struct",
              "Trait",
              "Field",
              "Property",
            },
          }),
          desc = "Goto Symbol",
        },
        {
          "<leader>sS",
          Util.telescope("lsp_workspace_symbols", {
            symbols = {
              "Class",
              "Function",
              "Method",
              "Constructor",
              "Interface",
              "Module",
              "Struct",
              "Trait",
              "Field",
              "Property",
            },
          }),
          desc = "Goto Symbol (Workspace)",
        },
      }
    end,
    config = function()
      local function flash(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fzf_opts = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      }
      telescope.setup({
        extensions = {
          fzf = fzf_opts
        },
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          mappings = {
            i = {
              ["<C-s>"] = flash,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-h>"] = "which_key",
              ["<C-t>"] = function(...)
                return require("trouble.providers.telescope").open_with_trouble(...)
              end,
              ["<A-t>"] = function(...)
                return require("trouble.providers.telescope").open_selected_with_trouble(...)
              end,
              ["<A-i>"] = function()
                Util.telescope("find_files", { no_ignore = true })()
              end,
              ["<A-h>"] = function()
                Util.telescope("find_files", { hidden = true })()
              end,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<C-f"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
            },
            n = {
              ["s"] = flash,
              ["q"] = actions.close,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
      })
      telescope.load_extension("zoxide")
      telescope.load_extension("fzf")
    end,
  },
  {
    "hrsh7th/cmp-path",
    enabled = false,
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup()
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    cmd = "Neotree",
    keys = {
      { "<M-e>", "<Cmd>Neotree toggle right<CR>", desc = "NeoTree" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      {
        "MunifTanjim/nui.nvim",
        version = "*"
      },
    },
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    -- event = { "BufReadPost", "BufAdd", "BufNewFile" },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "github-nvim-theme",
      -- "vscode.nvim"
    },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
      },
      sections = {
        lualine_x = {
          {
            require("lazy.status").updates,
            cond = require("lazy.status").has_updates,
            color = { fg = "orange" },
          },
        },
      },
    },
    config = function(_, opts)
      require("lualine").setup(opts)
      vim.opt.laststatus = 3
    end,
    init = function()
      vim.opt.laststatus = 0
    end
  },
  {
    "akinsho/bufferline.nvim",
    event = { "BufNew", "BufRead" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.opt.termguicolors = true
      require("bufferline").setup {}
      vim.keymap.set("n", "H", ":BufferLineCyclePrev<CR>", { silent = true })
      vim.keymap.set("n", "L", ":BufferLineCycleNext<CR>", { silent = true })
    end,
  },
  -- {
  --   "folke/lua-dev.nvim",
  -- },

  {
    "williamboman/mason.nvim",
    enabled = false,
    cmd = "Mason",
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" }
    },
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "flake8",
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },
  -- {
  --   "williamboman/mason-lspconfig.nvim",
  -- },
  -- formatters
  {
    "jose-elias-alvarez/null-ls.nvim",
    enabled = false,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason.nvim" },
    opts = function()
      local nls = require("null-ls")
      return {
        root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
        sources = {
          nls.builtins.formatting.fish_indent,
          nls.builtins.diagnostics.fish,
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.shfmt,
          nls.builtins.diagnostics.flake8,
        },
      }
    end,
  },
  -- {
  --   "neovim/nvim-lspconfig",
  -- },
  -- {
  --   "ray-x/lsp_signature.nvim",
  -- },
  {
    "SmiteshP/nvim-navic",
    event = "VeryLazy",
  },
  {
    "simrat39/symbols-outline.nvim",
    event = "VeryLazy",
  },
  {
    "b0o/SchemaStore.nvim",
    enabled = false,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    version = "*",
    dependencies = { "nvim-treesitter" },
    config = function()
      require("treesitter-context").setup({
        enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
        throttle = true, -- Throttles plugin updates (may improve performance)
        max_lines = 0,   -- How many lines the window should span. Values <= 0 mean no limit.
        patterns = {
          -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          -- For all filetypes
          -- Note that setting an entry here replaces all other patterns for this entry.
          -- By setting the "default" entry below, you can control which nodes you want to
          -- appear in the context window.
          default = {
            "class",
            "function",
            "method",
          },
        },
      })
    end,
  },
  -- Git
  {
    "lewis6991/gitsigns.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map({ "n", "v" }, "]g", gs.next_hunk, "Next Hunk")
        map({ "n", "v" }, "[g", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  -- Editing support
  {
    "windwp/nvim-autopairs",
    event = "VeryLazy",
    opts = {
      check_ts = true,
      ts_config = { java = false },
    },
  },

  {
    "nvim-zh/better-escape.vim",
    vscode = true,
    enabled = false,
    event = "InsertEnter",
    config = function()
      vim.g.better_escape_shortcut = { "jk", "kj", "ол", "ло" }
    end,
  },

  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    keys = {
      { "<leader>j", "<Plug>(VM-Add-Cursor-Down)", mode = { "n" }, silent = true },
      { "<leader>k", "<Plug>(VM-Add-Cursor-Up)",   mode = { "n" }, silent = true },
    },
    init = function()
      -- disable backspace mapping
      vim.g.VM_maps = { ["I BS"] = "" }
      vim.g.VM_maps["Undo"] = "u"
      vim.g.VM_maps["Redo"] = "<C-r>"
      vim.g.VM_theme = "codedark"
    end
  },
  -- UI
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      -- dashboard.section.header.val = {
      --   "███    ██ ██    ██ ██ ███    ███",
      --   "████   ██ ██    ██ ██ ████  ████",
      --   "██ ██  ██ ██    ██ ██ ██ ████ ██",
      --   "██  ██ ██  ██  ██  ██ ██  ██  ██",
      --   "██   ████   ████   ██ ██      ██",
      -- }

      dashboard.section.header.val = {
        "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
        dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
        -- dashboard.button("s", " " .. " Restore Session", [[:lua require("persistence").load() <cr>]]),
        dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
        dashboard.button("q", " " .. " Quit", ":qa<CR>"),
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"
      dashboard.opts.layout[1].val = 8
      return dashboard
    end,
    config = function(_, dashboard)
      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
  {
    "nanotee/zoxide.vim",
    cmd = {
      "Z",
      "Lz",
      "Tz",
      "Zi",
      "Lzi",
      "Tzi",
    }
  },
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },

  -- VS Code only plugins
  {
    "archilkarchava/vscode.nvim",
  },

  -- Common plugins
  {
    "andymass/vim-matchup",
    vscode = true,
    event = "VeryLazy",
    init = function()
      vim.g.matchup_matchparen_deferred = 1
      if vim.g.vscode then
        vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
        vim.g.matchup_matchparen_enabled = 0
      else
        vim.g.matchup_matchparen_offscreen = {}
      end
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    vscode = true,
    ft = {
      "html",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
      "vue",
      "tsx",
      "jsx",
      "rescript",
      "xml",
      "php",
      "markdown",
      "glimmer",
      "handlebars",
      "hbs",
    },
    opts = {
      opts = {
        enable_close = not vim.g.vscode,
        enable_close_on_slash = not vim.g.vscode,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    vscode = true,
    event = "VeryLazy",
    cmd = {
      "TSBufDisable",
      "TSBufEnable",
      "TSBufToggle",
      "TSDisable",
      "TSEnable",
      "TSToggle",
      "TSInstall",
      "TSInstallInfo",
      "TSInstallSync",
      "TSModuleInfo",
      "TSUninstall",
      "TSUpdate",
      "TSUpdateSync",
    },
    build = ":TSUpdate",
    dependencies = {
      "andymass/vim-matchup",
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        vscode = true,
        init = function(plugin)
          -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
          -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
          -- no longer trigger the **nvim-treeitter** module to be loaded in time.
          -- Luckily, the only thins that those plugins need are the custom queries, which we make available
          -- during startup.
          require("lazy.core.loader").add_to_rtp(plugin)
          require("nvim-treesitter.query_predicates")
        end,
        config = function()
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
          local configs = require("nvim-treesitter.configs")
          for name, fn in pairs(move) do
            if name:find("goto") == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
                    if q == query and key:find("[%]%[][cC]") then
                      vim.cmd("normal! " .. key)
                      return
                    end
                  end
                end
                return fn(q, ...)
              end
            end
          end
        end,
      },
    },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>",      desc = "Shrink selection",   mode = "x" },
    },
    opts = {
      highlight = {
        enable = not vim.g.vscode,
      },
      indent = { enable = true },
      matchup = {
        enable = true,
        enable_quotes = true,
      },
      context_commentstring = { enable = not vim.g.vscode, enable_autocmd = not vim.g.vscode },
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "graphql",
        "vim",
        "yaml",
        "go",
        "gomod",
        "rust",
        "toml"
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = {
            ["]k"] = { query = "@block.outer", desc = "Next block start" },
            ["]f"] = { query = "@function.outer", desc = "Next function start" },
            ["]c"] = { query = "@class.outer", desc = "Next class start" },
            ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
          },
          goto_next_end = {
            ["]K"] = { query = "@block.outer", desc = "Next block end" },
            ["]F"] = { query = "@function.outer", desc = "Next function end" },
            ["]C"] = { query = "@class.outer", desc = "Next class end" },
            ["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
          },
          goto_previous_start = {
            ["[k"] = { query = "@block.outer", desc = "Previous block start" },
            ["[f"] = { query = "@function.outer", desc = "Previous function start" },
            ["[c"] = { query = "@class.outer", desc = "Previous class start" },
            ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
          },
          goto_previous_end = {
            ["[K"] = { query = "@block.outer", desc = "Previous block end" },
            ["[F"] = { query = "@function.outer", desc = "Previous function end" },
            ["[C"] = { query = "@class.outer", desc = "Previous class end" },
            ["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            [">K"] = { query = "@block.outer", desc = "Swap next block" },
            [">F"] = { query = "@function.outer", desc = "Swap next function" },
            [">C"] = { query = "@class.outer", desc = "Swap next class" },
            [">A"] = { query = "@parameter.inner", desc = "Swap next argument" },
          },
          swap_previous = {
            ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
            ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
            ["<C"] = { query = "@class.outer", desc = "Swap previous class" },
            ["<A"] = { query = "@parameter.inner", desc = "Swap previous argument" },
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "kiyoon/treesitter-indent-object.nvim",
    enabled = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter"
    },
    keys = {
      {
        "ai",
        "<Cmd>lua require'treesitter_indent_object.textobj'.select_indent_outer()<CR>",
        mode = { "x", "o" },
        desc = "context-aware indent (outer)",
      },
      {
        "aI",
        "<Cmd>lua require'treesitter_indent_object.textobj'.select_indent_outer(true)<CR>",
        mode = { "x", "o" },
        desc = "context-aware indent (outer, line-wise)",
      },
      {
        "ii",
        "<Cmd>lua require'treesitter_indent_object.textobj'.select_indent_inner()<CR>",
        mode = { "x", "o" },
        desc = "context-aware indent (inner, partial range)",
      },
      {
        "iI",
        "<Cmd>lua require'treesitter_indent_object.textobj'.select_indent_inner(true)<CR>",
        mode = { "x", "o" },
        desc = "context-aware indent (inner, entire range)",
      },
    },
  },
  -- Editing support
  {
    "echasnovski/mini.indentscope",
    vscode = true,
    version = "*",
    enabled = false,
    event = "VeryLazy",
    opts = function()
      return {
        symbol = "",
        draw = {
          delay = 100,
          animation = require("mini.indentscope").gen_animation.none()
        },
      }
    end,
    config = function(_, opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy", "mason" },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
      require("mini.indentscope").setup(opts)
    end,
  },
  {
    "echasnovski/mini.ai",
    vscode = true,
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      local custom_textobjects = {
        -- Tweak argument textobject
        -- a = require("mini.ai").gen_spec.argument({ brackets = { "%b()" } }),
        t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
        b = { "%b()", "^.%s*().-()%s*.$" },
        B = { "%b{}", "^.%s*().-()%s*.$" },
        r = { "%b[]", "^.%s*().-()%s*.$" },
        -- Now `vax` should select `xxx` and `vix` - middle `x`
        -- x = { "x()x()x" },
      }
      local spec_treesitter = ai.gen_spec.treesitter
      custom_textobjects.o = spec_treesitter({
        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
      })
      custom_textobjects.f = spec_treesitter({ a = "@function.outer", i = "@function.inner" })
      custom_textobjects.a = spec_treesitter({ a = "@parameter.outer", i = "@parameter.inner" })
      custom_textobjects.c = spec_treesitter({ a = "@class.outer", i = "@class.inner" })
      return {
        n_lines = 500,
        custom_textobjects = custom_textobjects,
        silent = true,
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      -- register all text objects with which-key
      if require("util").has("which-key.nvim") then
        ---@type table<string, string|table>
        local i = {
          [" "] = "Whitespace",
          ['"'] = 'Balanced "',
          ["'"] = "Balanced '",
          ["`"] = "Balanced `",
          ["("] = "Balanced (",
          [")"] = "Balanced ) including white-space",
          [">"] = "Balanced > including white-space",
          ["<lt>"] = "Balanced <",
          ["]"] = "Balanced ] including white-space",
          ["["] = "Balanced [",
          ["}"] = "Balanced } including white-space",
          ["{"] = "Balanced {",
          ["?"] = "User Prompt",
          _ = "Underscore",
          a = "Argument",
          b = "Balanced (",
          B = "Balanced {",
          r = "Balanced [",
          c = "Class",
          f = "Function",
          o = "Block, conditional, loop",
          q = "Quote `, \", '",
          t = "Tag",
        }
        local a = vim.deepcopy(i)
        for k, v in pairs(a) do
          a[k] = v:gsub(" including.*", "")
        end

        local ic = vim.deepcopy(i)
        local ac = vim.deepcopy(a)
        for key, name in pairs({ n = "Next", l = "Last" }) do
          i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
          a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
        end
        require("which-key").register({
          mode = { "o", "x" },
          i = i,
          a = a,
        })
      end
    end,
  },
  {
    "echasnovski/mini.bracketed",
    vscode = true,
    version = "*",
    event = "VeryLazy",
    keys = {
      {
        "<M-O>",
        function()
          pcall(require("mini.bracketed").jump, "backward", { wrap = false })
        end,
        mode = "n",
      },
      {
        "<M-I>",
        function()
          pcall(require("mini.bracketed").jump, "forward", { wrap = false })
        end,
        mode = "n",
      },
    },
    -- keys = function(_, keys)
    -- 	local mini_bracketed = require("mini.bracketed")
    -- 	-- Populate the keys based on the user's options
    -- 	local plugin = require("lazy.core.config").spec.plugins["mini.bracketed"]
    -- 	local opts = require("lazy.core.plugin").values(plugin, "opts", false)
    -- 	local mappings = not not vim.g.vscode and {
    -- 				{
    -- 					"<C-o>",
    -- 					function()
    -- 						pcall(mini_bracketed.jump, "backward", { wrap = false })
    -- 					end,
    -- 					mode = "n",
    -- 				},
    --
    -- 				{
    -- 					"<C-i>",
    -- 					function()
    -- 						pcall(mini_bracketed.jump, "forward", { wrap = false })
    -- 					end,
    -- 					mode = "n",
    -- 				},
    -- 			} or {}
    -- 	for _, options in pairs(opts) do
    -- 		if type(options) == "table" and options.suffix then
    -- 			table.insert(mappings, {
    -- 				"[" .. options.suffix,
    -- 				mode = { "n", "x" },
    -- 			})
    -- 			table.insert(mappings, {
    -- 				"]" .. options.suffix,
    -- 				mode = { "n", "x" },
    -- 			})
    -- 			table.insert(mappings, {
    -- 				"[" .. string.upper(options.suffix),
    -- 				mode = { "n", "x" },
    -- 			})
    -- 			table.insert(mappings, {
    -- 				"]" .. string.upper(options.suffix),
    -- 				mode = { "n", "x" },
    -- 			})
    -- 		end
    -- 	end
    -- 	return vim.list_extend(mappings, keys)
    -- end,
    opts = {
      -- First-level elements are tables describing behavior of a target:
      --
      -- - <suffix> - single character suffix. Used after `[` / `]` in mappings.
      --   For example, with `b` creates `[B`, `[b`, `]b`, `]B` mappings.
      --   Supply empty string `''` to not create mappings.
      --
      -- - <options> - table overriding target options.
      --
      -- See `:h mini_bracketed.config` for more info.

      buffer     = { suffix = vim.g.vscode and "" or "b", options = {} },
      comment    = { suffix = "/", options = {} },
      conflict   = { suffix = vim.g.vscode and "" or "x", options = {} },
      diagnostic = { suffix = vim.g.vscode and "" or "d", options = {} },
      file       = { suffix = vim.g.vscode and "" or "f", options = {} },
      indent     = { suffix = "i", options = {} },
      jump       = { suffix = "j", options = {} },
      location   = { suffix = "l", options = {} },
      oldfile    = { suffix = vim.g.vscode and "" or "o", options = {} },
      quickfix   = { suffix = vim.g.vscode and "" or "q", options = {} },
      treesitter = { suffix = "t", options = {} },
      undo       = { suffix = "", options = {} },
      window     = { suffix = vim.g.vscode and "" or "w", options = {} },
      yank       = { suffix = "y", options = {} },
    },
  },
  {
    "echasnovski/mini.splitjoin",
    vscode = true,
    version = "*",
    keys = function(_, keys)
      local plugin = require("lazy.core.config").spec.plugins["mini.splitjoin"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.toggle, mode = { "n", "v" } },
        { opts.mappings.split,  mode = { "n", "v" } },
        { opts.mappings.join,   mode = { "n", "v" } },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      -- Module mappings. Use `''` (empty string) to disable one.
      -- Created for both Normal and Visual modes.
      mappings = {
        toggle = "gz",
        split = "",
        join = "",
      },
    }
  },
  {
    "echasnovski/mini.move",
    vscode = true,
    version = "*",
    keys = {
      { "<M-h>",     mode = "n", desc = "Move line left" },
      { "<M-Left>",  "<M-h>",    mode = "n",                   desc = "Move line left",       remap = true },
      { "<M-j>",     mode = "n", desc = "Move line down" },
      { "<M-Down>",  "<M-j>",    mode = "n",                   desc = "Move line down",       remap = true },
      { "<M-k>",     mode = "n", desc = "Move line up" },
      { "<M-Up>",    "<M-k>",    mode = "n",                   desc = "Move line up",         remap = true },
      { "<M-l>",     mode = "n", desc = "Move line right" },
      { "<M-Right>", "<M-l>",    mode = "n",                   desc = "Move line right",      remap = true },
      { "<M-h>",     mode = "v", desc = "Move selection left" },
      { "<M-Left>",  "<M-h>",    mode = "v",                   desc = "Move selection left",  remap = true },
      { "<",         "<M-h>",    mode = "v",                   desc = "Move selection left",  remap = true },
      { "<M-j>",     mode = "v", desc = "Move selection down" },
      { "<M-Down>",  "<M-j>",    mode = "v",                   desc = "Move selection down",  remap = true },
      { "<M-k>",     mode = "v", desc = "Move selection up" },
      { "<M-Up>",    "<M-k>",    mode = "v",                   desc = "Move selection up",    remap = true },
      { "<M-l>",     mode = "v", desc = "Move selection right" },
      { "<M-Right>", "<M-l>",    mode = "v",                   desc = "Move selection right", remap = true },
      { ">",         "<M-l>",    mode = "v",                   desc = "Move selection right", remap = true },
    },
    opts = {
      mappings = {
        left = "<M-h>",
        right = "<M-l>",
        down = "<M-j>",
        up = "<M-k>",
        line_left = "<M-h>",
        line_right = "<M-l>",
        line_down = "<M-j>",
        line_up = "<M-k>",
      },
    },
  },
  -- surround
  {
    "echasnovski/mini.surround",
    vscode = true,
    enabled = false,
    version = "*",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add,            desc = "Add surrounding",                     mode = { "n", "v" } },
        { opts.mappings.delete,         desc = "Delete surrounding" },
        { opts.mappings.find,           desc = "Find right surrounding" },
        { opts.mappings.find_left,      desc = "Find left surrounding" },
        { opts.mappings.highlight,      desc = "Highlight surrounding" },
        { opts.mappings.replace,        desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `Minisurround_config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gs",             -- Add surrounding in Normal and Visual modes
        delete = "gsd",         -- Delete surrounding
        find = "gsf",           -- Find surrounding (to the right)
        find_left = "gsF",      -- Find surrounding (to the left)
        highlight = "gsh",      -- Highlight surrounding
        replace = "gsc",        -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
      n_lines = 500,
      custom_surroundings = {
        b = {
          input = { "%b()", "^.().*().$" },
          output = { left = "(", right = ")" }
        },
        B = {
          input = { "%b{}", "^.().*().$" },
          output = { left = "{", right = "}" }
        },
        r = {
          input = { "%b[]", "^.().*().$" },
          output = { left = "[", right = "]" }
        }
      },
    },
    config = function(_, opts)
      require("mini.surround").setup(opts)
    end,
  },
  {
    "wellle/targets.vim",
    vscode = true,
    enabled = false,
    version = "*",
    event = "VeryLazy",
    config = function()
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("targets", { clear = true }),
        pattern = "targets#mappings#user",
        callback = function()
          vim.fn["targets#mappings#extend"]({
            b = {
              pair = {
                {
                  o = "(",
                  c = ")"
                }
              }
            },
            r = {
              pair = {
                {
                  o = "[",
                  c = "]"
                }
              }
            }
          })
        end
      })
    end,
    init = function()
      vim.g.targets_aiAI = "aIAi"
      vim.g.targets_seekRanges = 'cc cr cb cB lc ac Ac lr lb ar ab lB Ar aB Ab AB rr ll rb al rB Al bb aa bB Aa BB AA'
    end
  },
  {
    "kana/vim-textobj-entire",
    vscode = true,
    enabled = false,
    dependencies = {
      "kana/vim-textobj-user"
    },
    version = "*",
    keys = {
      { "ie", "<Plug>(textobj-entire-i)", mode = { "o", "x" }, desc = "entire buffer" },
      {
        "ae",
        "<Plug>(textobj-entire-a)",
        mode = { "o", "x" },
        desc =
        "entire buffer including leading/trailing empty lines"
      },
    },
    init = function()
      vim.g.textobj_entire_no_default_key_mappings = true
    end
  },
  {
    "gbprod/substitute.nvim",
    vscode = true,
    version = "*",
    keys = {
      {
        "gr",
        function()
          require("substitute").operator()
        end,
        mode = { "n" },
        desc = "Substitute"
      },
      {
        "gra",
        function()
          require("substitute").operator({
            motion = "a"
          })
        end,
        mode = { "n" },
        desc = "Substitute"
      },
      {
        "grr",
        function()
          require("substitute").line()
        end,
        mode = { "n" },
        desc = "Substitute line"
      },
      {
        "gr",
        function()
          require("substitute").visual()
        end,
        mode = { "x" },
        desc = "Substitute"
      },
    },
    opts = {
      highlight_substituted_text = {
        enabled = true,
        timer = 175,
      },
    }
  },
  {
    "kylechui/nvim-surround",
    vscode = true,
    version = "*",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["nvim-surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.keymaps.insert,          desc = "Surround",              mode = "i" },
        { opts.keymaps.insert_line,     desc = "Surround line",         mode = "i" },
        { opts.keymaps.normal,          desc = "Surround",              mode = "n" },
        { opts.keymaps.normal_cur,      desc = "Surround current",      mode = "n" },
        { opts.keymaps.normal_line,     desc = "Surround line",         mode = "n" },
        { opts.keymaps.normal_cur_line, desc = "Surround current line", mode = "n" },
        { opts.keymaps.visual,          desc = "Surround",              mode = "x" },
        { opts.keymaps.visual_line,     desc = "Surround line",         mode = "x" },
        { opts.keymaps.delete,          desc = "Delete surround",       mode = "n" },
        { opts.keymaps.change,          desc = "Change surround",       mode = "n" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    -- event = "VeryLazy",
    opts = {
      keymaps = {
        insert          = "<C-g>s",
        insert_line     = "<C-g>S",
        normal          = "gs",
        normal_cur      = "gS",
        normal_line     = "gss",
        normal_cur_line = "gSS",
        visual          = "gs",
        visual_line     = "gS",
        delete          = "gsd",
        change          = "gsc",
      },
    },
    config = function(_, opts)
      if vim.g.vscode then
        vim.api.nvim_set_hl(0, "NvimSurroundHighlight", { link = "FakeVisual" })
        vim.api.nvim_create_autocmd({ "ColorScheme" }, {
          callback = function()
            vim.api.nvim_set_hl(0, "NvimSurroundHighlight", { link = "FakeVisual" })
          end,
        })
      end
      require("nvim-surround").setup(opts)
    end
  },
  {
    "chaoren/vim-wordmotion",
    vscode = true,
    enabled = false,
    event = "VeryLazy",
    keys = {
      { "<Leader>w",  "<Plug>WordMotion_w",  desc = "Next subword",                 mode = { "n", "x", "o" } },
      { "<Leader>ge", "<Plug>WordMotion_ge", desc = "Previous end of subword",      mode = { "n", "x", "o" } },
      { "<Leader>e",  "<Plug>WordMotion_e",  desc = "Next end of subword",          mode = { "n", "x", "o" } },
      { "<Leader>b",  "<Plug>WordMotion_b",  desc = "Previous subword",             mode = { "n", "x", "o" } },
      { "i<Leader>w", "<Plug>WordMotion_iw", desc = "inner subword",                mode = { "x", "o" } },
      { "a<Leader>w", "<Plug>WordMotion_aw", desc = "a subword (with white-space)", mode = { "x", "o" } },
    },
    init = function()
      vim.g.wordmotion_nomap = true
    end,
  },
  {
    "chrisgrieser/nvim-spider",
    vscode = true,
    keys = {
      {
        "<Leader>w",
        "<Cmd>lua require('spider').motion('w')<CR>",
        mode = { "n", "o", "x" },
        desc = "Next subword"
      },
      {
        "<Leader>e",
        "<Cmd>lua require('spider').motion('e')<CR>",
        mode = { "n", "o", "x" },
        desc = "Next end of subword"
      },
      {
        "<Leader>b",
        "<Cmd>lua require('spider').motion('b')<CR>",
        mode = { "n", "o", "x" },
        desc = "Previous subword"
      },
      {
        "<Leader>ge",
        "<Cmd>lua require('spider').motion('ge')<CR>",
        mode = { "n", "o", "x" },
        desc = "Previous end of subword"
      }
    }
  },
  {
    "chrisgrieser/nvim-various-textobjs",
    vscode = true,
    keys = {
      -- exception: indentation textobj requires two parameters, the first for
      -- exclusion of the starting border, the second for the exclusion of ending
      -- border
      {
        "ii",
        '<Cmd>lua require("various-textobjs").indentation("inner", "inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside indent",
      },
      {
        "iI",
        '<Cmd>lua require("various-textobjs").indentation("inner", "inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside indent",
      },
      {
        "ai",
        '<Cmd>lua require("various-textobjs").indentation("outer", "inner")<CR>',
        mode = { "o", "x" },
        desc = "around indent",
      },
      {
        "aI",
        '<Cmd>lua require("various-textobjs").indentation("outer", "outer")<CR>',
        mode = { "o", "x" },
        desc = "Around indent",
      },
      {
        "ie",
        '<Cmd>lua require("various-textobjs").entireBuffer()<CR>',
        mode = { "o", "x" },
        desc = "Entire buffer",
      },
      {
        "ae",
        '<Cmd>lua require("various-textobjs").entireBuffer()<CR>',
        mode = { "o", "x" },
        desc = "Entire buffer",
      },
      {
        "<Leader>r",
        '<Cmd>lua require("various-textobjs").restOfParagraph()<CR>',
        mode = { "o", "x" },
        desc = "Rest of paragraph",
      },
      {
        "R",
        '<Cmd>lua require("various-textobjs").restOfIndentation()<CR>',
        mode = { "o", "x" },
        desc = "Rest of indentation",
      },
      {
        "|",
        '<Cmd>lua require("various-textobjs").column()<CR>',
        mode = { "o", "x" },
        desc = "Column",
      },
      {
        "ik",
        '<Cmd>lua require("various-textobjs").key("inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside key",
      },
      {
        "ak",
        '<Cmd>lua require("various-textobjs").key("outer")<CR>',
        mode = { "o", "x" },
        desc = "Around key",
      },
      {
        "iv",
        '<Cmd>lua require("various-textobjs").value("inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside value",
      },
      {
        "av",
        '<Cmd>lua require("various-textobjs").value("outer")<CR>',
        mode = { "o", "x" },
        desc = "Around value",
      },
      {
        "im",
        '<Cmd>lua require("various-textobjs").chainMember("inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside chain member",
      },
      {
        "am",
        '<Cmd>lua require("various-textobjs").chainMember("outer")<CR>',
        mode = { "o", "x" },
        desc = "Around chain member",
      },
      {
        "i<Leader>w",
        '<Cmd>lua require("various-textobjs").subword("inner")<CR>',
        mode = { "o", "x" },
        desc = "Inside subword",
      },
      {
        "a<Leader>w",
        '<Cmd>lua require("various-textobjs").subword("outer")<CR>',
        mode = { "o", "x" },
        desc = "Around subword",
      },
    },
  },
  {
    "tpope/vim-repeat",
    vscode = true,
    event = "VeryLazy"
  },
  {
    "bronson/vim-visual-star-search",
    vscode = true,
    enabled = false,
    event = "VeryLazy",
    config = function()
      vim.keymap.del({ "n", "x" }, "<Leader>*")
    end
  },
  {
    "phaazon/hop.nvim",
    vscode = true,
    enabled = false,
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "Hop 2 chars" },
      { "S", mode = { "n", "x", "o" }, desc = "Hop word" },
    },
    version = "*", -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require("hop").setup()
      vim.keymap.set("n", "s", "<Cmd>HopChar2<CR>", { silent = true })
      vim.keymap.set("n", "S", "<Cmd>HopWord<CR>", { silent = true })
    end
  },
  -- Flit and leap create issues with dot-repeat in VSCode when used in operator pending mode
  {
    "ggandor/flit.nvim",
    vscode = true,
    dependencies = {
      "ggandor/leap.nvim"
    },
    keys = function(_, keys)
      local mappings = {}
      local mode = vim.g.vscode and { "n", "x" } or { "n", "x", "o" }
      for _, key in ipairs({ "f", "F", "t", "T" }) do
        mappings[#mappings + 1] = { key, mode = mode, desc = key }
      end
      return vim.list_extend(keys, mappings)
    end,
    opts = {
      labeled_modes = "nx",
      multiline = true,
    },
  },
  {
    "ggandor/leap.nvim",
    vscode = true,
    dependencies = {
      "tpope/vim-repeat",
    },
    keys = {
      {
        "s",
        function()
          local current_window = vim.fn.win_getid()
          require("leap").leap({ target_windows = { current_window } })
        end,
        mode = { "n", "x", "o" },
        desc = "Leap"
      },
      -- {
      --   "s",
      --   "<Plug>(leap-forward-to)",
      --   mode = { "n", "x", "o" },
      --   desc =
      --   "Leap forward to"
      -- },
      -- {
      --   "S",
      --   "<Plug>(leap-backward-to)",
      --   mode = { "n", "x", "o" },
      --   desc =
      --   "Leap backward to"
      -- },
      -- { "gs", mode = { "n", "x", "o" }, desc = "Leap from windws" },
    },
    config = function(_, opts)
      -- Hack to make it work with langmapper
      -- require("leap.util")["get-input"] = function()
      --   local ok, ch = pcall(vim.fn.getcharstr)
      --   if ok and ch ~= vim.api.nvim_replace_termcodes("<esc>", true, false, true) then
      --     return require("langmapper.utils").translate_keycode(ch, "default", vim.g.secondary_locale)
      --   end
      -- end

      if vim.g.vscode then
        vim.api.nvim_create_autocmd("User", {
          pattern = "LeapEnter",
          desc = "Center neovim viewport before calling leap.",
          command = "normal! zz"
        })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "LeapEnter",
        callback = function()
          vim.b.leap_active = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "LeapLeave",
        callback = function()
          vim.b.leap_active = false
        end,
      })

      local leap = require("leap")

      for k, v in pairs(opts) do
        leap.opts[k] = v
      end

      -- vim.keymap.del({ "x", "o" }, "x")
      -- vim.keymap.del({ "x", "o" }, "X")

      local function set_highlights()
        vim.api.nvim_set_hl(0, "LeapBackdrop", { fg = "gray" })
        vim.api.nvim_set_hl(0, "LeapMatch", {
          -- For light themes, set to "black" or similar.
          fg = "white",
          bold = true,
          nocombine = true,
        })
        -- Of course, specify some nicer shades instead of the default "red" and "blue".
        vim.api.nvim_set_hl(0, "LeapLabelPrimary", {
          fg = "#ff0000", bold = true, nocombine = true,
        })
        vim.api.nvim_set_hl(0, "LeapLabelSecondary", {
          fg = "#ffb400", bold = true, nocombine = true,
        })
      end
      -- set_highlights()
      -- vim.api.nvim_create_autocmd({ "ColorScheme" }, {
      -- 	callback = set_highlights,
      -- })
    end,
    opts = {
      -- VS Code doesn't sync its viewport with neovim so autojump rarely works
      -- These settings make autojump always work in VS Code
      -- labels = vim.g.vscode and {} or nil,
      -- safe_labels = vim.g.vscode and { "s", "f", "n", "u", "t", "/",
      --   "S", "F", "N", "L", "H", "M", "Q", "K", "U", "G", "T", "Z", "[", "]", "\\", "?", '"' } or nil,
      -- Disables autojump in VS Code
      safe_labels = vim.g.vscode and {} or nil,
    }
  },
  {
    "folke/flash.nvim",
    vscode = true,
    enabled = false,
    version = "*",
    event = "VeryLazy",
    opts = {
      highlight = {
        backdrop = false
      },
      jump = {
        autojump = true
      },
      modes = {
        search = {
          enabled = true
        },
        char = {
          enabled = true,
          highlight = { backdrop = false },
        }
      }
    },
    keys = function(_, keys)
      local function wrapped_flash()
        if vim.g.vscode then
          vim.cmd("normal! zz")
        end
        return require("flash")
      end
      local mappings = {
        {
          "s",
          mode = { "n", "o", "x" },
          function()
            wrapped_flash().jump({
              jump = {
                inclusive = false
              }
            })
          end,
          desc = "Flash",
        },
        {
          "s<Enter>",
          mode = { "n", "o", "x" },
          function()
            wrapped_flash().jump({
              continue = true
            })
          end,
          desc = "Flash continue last search",
        },
      }

      if not vim.g.vscode then
        vim.list_extend(mappings,
          {
            {
              "r",
              mode = "o",
              function()
                require("flash").remote()
              end,
              desc = "Remote Flash",
            },
            {
              "S",
              mode = { "n", "x", "o" },
              function() require("flash").treesitter() end,
              desc = "Flash treesitter"
            },
          })
      end

      return vim.list_extend(keys, mappings)
    end,
    config = function(_, opts)
      local function set_highlights()
        vim.api.nvim_set_hl(0, "FlashBackdrop", { fg = "gray" })
        if vim.g.vscode then
          vim.api.nvim_set_hl(0, "FlashLabel", {
            fg = "#ff0000", bold = true, nocombine = true,
          })
          vim.api.nvim_set_hl(0, "FlashMatch", { fg = "NONE", bg = "#613315" })
        end
      end
      vim.api.nvim_create_autocmd({ "ColorScheme" }, {
        callback = set_highlights,
      })
      set_highlights()
      require("flash").setup(opts)
    end
  },
  {
    "vscode-neovim/vscode-multi-cursor.nvim",
    vscode = true,
    enabled = false,
    keys = {
      {
        mode = { 'n', 'x' },
        'mc',
        function()
          require('vscode-multi-cursor').create_cursor()
        end,
        expr = true,
        desc =
        'Create cursor'
      },
      {
        mode = { 'n' },
        'mcc',
        function()
          require('vscode-multi-cursor').cancel()
        end,
        desc =
        'Cancel/Clear all cursors'
      },
      {
        mode = { 'n', 'x' },
        'mi',
        function()
          require('vscode-multi-cursor').start_left()
        end,
        desc =
        'Start cursors on the left'
      },
      {
        mode = { 'n', 'x' },
        'mI',
        function()
          require('vscode-multi-cursor').start_left_edge()
        end,
        desc =
        'Start cursors on the left edge'
      },
      {
        mode = { 'n', 'x' },
        'ma',
        function()
          require('vscode-multi-cursor').start_right()
        end,
        desc =
        'Start cursors on the right'
      },
      {
        mode = { 'n', 'x' },
        'mA',
        function()
          require('vscode-multi-cursor').start_right()
        end,
        desc =
        'Start cursors on the right'
      },
      {
        mode = { 'n' },
        '[mc',
        function()
          require('vscode-multi-cursor').prev_cursor()
        end,
        desc = 'Goto prev cursor'
      },
      {
        mode = { 'n' },
        ']mc',
        function()
          require('vscode-multi-cursor').next_cursor()
        end,
        desc = 'Goto next cursor'
      },
      {
        mode = { 'n' },
        'mcs',
        function()
          require('vscode-multi-cursor').flash_jump()
        end,
        desc =
        'Create cursor using flash'
      },
    },
    cond = not not vim.g.vscode,
    opts = {
      default_mappings = false
    },
    config = function(_, opts)
      require("vscode-multi-cursor").setup(opts)
      local function set_highlight()
        vim.api.nvim_set_hl(0, 'VSCodeCursor', { link = "IncSearch" })
        vim.api.nvim_set_hl(0, 'VSCodeCursorRange', { link = "IncSearch" })
      end
      set_highlight()
    end
  },
  {
    "monaqa/dial.nvim",
    vscode = true,
    keys = {
      { mode = { "n" }, "<C-a>",  function() return require("dial.map").manipulate("increment", "normal") end,  desc = "Increment" },
      { mode = { "n" }, "<C-x>",  function() return require("dial.map").manipulate("decrement", "normal") end,  desc = "Decrement" },
      { mode = { "n" }, "g<C-a>", function() return require("dial.map").manipulate("increment", "gnormal") end, desc = "Increment" },
      { mode = { "n" }, "g<C-x>", function() return require("dial.map").manipulate("decrement", "gnormal") end, desc = "Decrement" },
      { mode = { "v" }, "<C-a>",  function() return require("dial.map").manipulate("increment", "visual") end,  desc = "Increment" },
      { mode = { "v" }, "<C-x>",  function() return require("dial.map").manipulate("decrement", "visual") end,  desc = "Decrement" },
      { mode = { "x" }, "g<C-a>", function() return require("dial.map").manipulate("increment", "gvisual") end, desc = "Increment" },
      { mode = { "x" }, "g<C-x>", function() return require("dial.map").manipulate("decrement", "gvisual") end, desc = "Decrement" },
    },
    config = function()
      local augend = require "dial.augend"
      require("dial.config").augends:register_group {
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
          augend.date.new {
            pattern = "%B", -- titlecased month names
            default_kind = "day",
          },
          augend.constant.new {
            elements = {
              "january",
              "february",
              "march",
              "april",
              "may",
              "june",
              "july",
              "august",
              "september",
              "october",
              "november",
              "december",
            },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = {
              "Monday",
              "Tuesday",
              "Wednesday",
              "Thursday",
              "Friday",
              "Saturday",
              "Sunday",
            },
            word = true,
            cyclic = true,
          },
          augend.constant.new {
            elements = {
              "monday",
              "tuesday",
              "wednesday",
              "thursday",
              "friday",
              "saturday",
              "sunday",
            },
            word = true,
            cyclic = true,
          },
          augend.case.new {
            types = { "camelCase", "PascalCase", "snake_case", "SCREAMING_SNAKE_CASE" },
          },
        },
      }
    end,
  },
  {
    "ThePrimeagen/harpoon",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "Harpoon" },
    keys = function(_, keys)
      local prefix = "<leader><leader>"
      local mappings = {
        { prefix .. "a", function() require("harpoon.mark").add_file() end,        desc = "Add file" },
        { prefix .. "s", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Toggle quick menu" },
        { "<C-p>",       function() require("harpoon.ui").nav_prev() end,          desc = "Goto previous mark" },
        { "<C-n>",       function() require("harpoon.ui").nav_next() end,          desc = "Goto next mark" },
        { "<M-p>",       "<cmd>Telescope harpoon marks<CR>",                       desc = "Show marks in Telescope" },
        { "<M-1>",       function() require("harpoon.ui").nav_file(1) end,         desc = "Goto editor 1" },
        { "<M-2>",       function() require("harpoon.ui").nav_file(2) end,         desc = "Goto editor 2" },
        { "<M-3>",       function() require("harpoon.ui").nav_file(3) end,         desc = "Goto editor 3" },
        { "<M-4>",       function() require("harpoon.ui").nav_file(4) end,         desc = "Goto editor 4" },
        { "<M-5>",       function() require("harpoon.ui").nav_file(5) end,         desc = "Goto editor 5" },
        { "<M-6>",       function() require("harpoon.ui").nav_file(6) end,         desc = "Goto editor 6" },
        { "<M-7>",       function() require("harpoon.ui").nav_file(7) end,         desc = "Goto editor 7" },
        { "<M-8>",       function() require("harpoon.ui").nav_file(8) end,         desc = "Goto editor 8" },
        { "<M-9>",       function() require("harpoon.ui").nav_file(9) end,         desc = "Goto editor 9" },
      }
      return vim.list_extend(mappings, keys)
    end,
  },
  {
    "stsewd/gx-extended.vim",
    vscode = true,
    enabled = false,
    keys = {
      { "gx", mode = vim.g.vscode and "v" or { "n", "v" }, desc = "Open URL under the cursor" },
    }
  },
  {
    "nvim-lua/plenary.nvim",
    version = "*",
    vscode = true
  },
  {
    "chrishrb/gx.nvim",
    vscode = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    version = "*",
    keys = {
      -- In VS Code normal mode "gx" will be mapped to the VS Code's "Open Link" command
      { "gx", mode = vim.g.vscode and "v" or { "n", "v" }, desc = "Open URL under the cursor" },
    },
    config = function(_, opts)
      require("gx").setup(opts)
      -- Workaround to bring back VSCode's "gx" in normal mode after this plugin overrides the mapping
      if vim.g.vscode then
        vim.keymap.set("n", "gx", "<Cmd>call VSCodeNotify('editor.action.openLink')<CR>")
      end
    end
  },
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaRead", "SudaWrite" },
  },
  {
    "archilkarchava/nvim-numbertoggle",
    vscode = true,
    event = "VeryLazy",
  },
  {
    "archilkarchava/xkbswitch.nvim",
    vscode = true,
    enabled = false,
    event = "VeryLazy",
    config = true,
  },
  -- {
  --   "ybian/smartim",
  --   -- Only works on macos
  --   enabled = vim.fn.has("macunix"),
  --   event = "InsertEnter",
  --   config = function()
  --     -- By default CTRL-C mapping does not check for abbreviations, and it does not trigger the InsertLeave event
  --     -- so we have to remap CTRL-C to Escape to make it work with the plugin
  --     vim.keymap.set("i", "<C-c>", "<Esc>")
  --   end
  -- },
  -- -- lyokha/vim-xkbswitch doesn't work with vscode-neovim
  -- {
  --   "lyokha/vim-xkbswitch",
  --   event = "InsertEnter",
  --   init = function()
  --     vim.g.XkbSwitchEnabled = 1
  --     vim.g.XkbSwitchLib = "/usr/local/lib/libxkbswitch.dylib"
  --   end
  -- }
}
