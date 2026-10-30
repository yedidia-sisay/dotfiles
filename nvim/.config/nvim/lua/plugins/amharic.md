return {
  {
    "kevinhwang91/nvim-ibus-sw",
    event = "InsertEnter",  -- በinsert mode ሲገባ ብቻ ይሰቀል
    config = function()
      local engines = {
        amharic = "m17n:am:sera",  -- የአማርኛ engine (የ'ibus list-engine' ውጤት ተጠቀም)
        english = "xkb:us::eng",  -- የእንግሊዝኛ (አሁኑ ያለውን ተጠቀም)
      }

      require("ibus-sw").setup({
        -- Insert mode: ወደ አማርኛ ቀይር (በNeovim ውስጥ አማርኛ ትፃፍ)
        insert_engines = { engines.amharic },
        -- Normal mode: ወደ English ቀይር (ኮማንድ ለመጻፍ ብቻ English)
        normal_engine = engines.english,

        -- ከPATH ችግር ጋር (Neovim :!ibus ካልሰራ)
        -- default_command = "/usr/bin/ibus",  -- ካስፈለገ አጭፍ (which ibus ውጤት ተጠቀም)

        -- Asynchronous switch (ቀደም ብሎ ያለ)
        async = true,
      })
    end,
  },
}
