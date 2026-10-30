return {
  {
    "hakonharnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        dir_path = "images", -- 1. Force the folder name to 'images'
        extension = "png",   -- Ensure a standard format for Typst
        embed_image_as_base64 = false,
        prompt_for_file_name = true,
        drag_and_drop = {
          insert_mode = true,
        },
      },
      filetypes = {
        typst = {
          -- 2. Use $FILE_PATH so the inserted code matches the saved file
          template = '#figure(image("$FILE_PATH", width: 80%), caption: [$CURSOR])',
        },
      },
    },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
    },
  },
}
