# lang_modeline
## a lua plugin for neovim that adds a modeline at the end of a buffer if a modeline for the buffer's language has been configured calling setup.
  
This a very rough, naif, primordial thing, it's my first Lua plugin, lua/neovim experts will probably laugh at it, but it's a start.  
I'll write a minimal documentation as soon as I have time, but I'm such a noob at this stuff that the code is pretty self-explaining.

A quick example:

require("lang_modeline").setup({
          modelines = { java = "// vim: ts=2" },
})

whenever you open or save a java file it will check if there's a // vim: line at the end, if there isn't, adds it.
If you open a file of a type not set in the modeline tables it does nothing.

Maybe someone will find it useful, it is useful to me and its main purpose is to actually learn coding nvim plugins in Lua.

Enjoy

Irio
