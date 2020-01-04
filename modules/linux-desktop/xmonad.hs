import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Util.EZConfig

-- The main function.
main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig

-- Command to launch the bar.
myBar = "$HOME/.nix-profile/bin/xmobar"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppOutput = \x -> return () } -- don't write to the output so that the pipe
                                               -- doesn't get blocked while it can't be consumed
                                               -- by xmobar (#417)

-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

-- Main configuration, override the defaults to your liking.
myConfig = defaultConfig
  { terminal = "$HOME/.nix-profile/bin/gnome-terminal"
  , modMask = mod4Mask
  }
  `removeKeysP` [ "M-w"
                , "M-e"
                , "M-r"
                ]
