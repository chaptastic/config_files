if has("gui_macvim")
  macmenu &File.New\ Tab key=<nop>
  " macmenu &File.Open\ Tab... key=<nop>
  map <D-t> <Plug>PeepOpen
  " map <D-T> <Plug>PeepOpen
end
