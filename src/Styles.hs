-----------------------------------------------------------------------------
-- | The look of the table: a neon slot parlor on deep violet velvet.
-- Glassy purple tiles, a gold coin for every mark, cyan glow on wild
-- picks, and a screen-filling SLINGO! slam when a line lands.
-----------------------------------------------------------------------------
module Styles (skin) where
-----------------------------------------------------------------------------
import           Miso ((=:))
import qualified Miso.CSS as CSS
import           Miso.CSS
  ( StyleSheet, sheet_, selector_, keyframes_, from_, to_, at, pct
  , media_, rule_, screen_, and_, maxWidth_, maxHeight_, px
  )
import           Miso.CSS.Types (MediaQuery(..))
import           Miso.CSS.Color hiding (gold, pink)
import           Miso.String (MisoString)
-----------------------------------------------------------------------------
-- palette: velvet, neon, and a lot of gold
gold, pink, cyanN, milk, mist :: Color
gold  = RGB 255 201 60   -- coins, the spin button, the slam
pink  = RGB 255 92 168   -- accents, the game-over seal
cyanN = RGB 77 225 255   -- wild-pick glow, help headings
milk  = RGB 237 232 255  -- primary text
mist  = RGB 169 156 214  -- muted text
-----------------------------------------------------------------------------
funStack :: MisoString
funStack = "'Baloo 2', 'Nunito', 'Avenir Next', system-ui, sans-serif"
-----------------------------------------------------------------------------
retroStack :: MisoString
retroStack = "Georgia, 'Times New Roman', Times, serif"
-----------------------------------------------------------------------------
skin :: StyleSheet
skin = sheet_
  [ selector_ ":root"
      [ "--bs" =: "min(430px, calc(100dvh - 322px), 94vw)"
      , "--fun" =: funStack
      ]
  , selector_ "*" [ CSS.boxSizing "border-box" ]
  , selector_ "html, body"
      [ CSS.margin "0", CSS.height "100%", CSS.overflow "hidden" ]
  , selector_ "body"
      [ CSS.background velvet
      , CSS.color milk
      , CSS.fontFamily "var(--fun)"
      , CSS.userSelect "none"
      , "-webkit-tap-highlight-color" =: "transparent"
      , "-webkit-text-size-adjust" =: "100%"
      , "overscroll-behavior" =: "none"
      ]
  , selector_ "button:focus-visible"
      [ CSS.outline "2px solid #4DE1FF", CSS.outlineOffset "2px" ]
  -- top chrome ------------------------------------------------------------
  , selector_ ".topbar"
      [ CSS.position "fixed"
      , "inset" =: "0 0 auto 0"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "space-between"
      , CSS.padding "10px 18px"
      , CSS.zIndex 90
      , CSS.pointerEvents "none"
      , CSS.gap "12px"
      ]
  , selector_ ".topbar > *" [ CSS.pointerEvents "auto" ]
  , selector_ ".brand"
      [ CSS.fontFamily "var(--fun)"
      , CSS.fontWeight "800"
      , CSS.letterSpacing ".2em"
      , CSS.fontSize "17px"
      , CSS.color gold
      , CSS.textShadow "0 0 14px rgba(255,201,60,.5)"
      , CSS.whiteSpace "nowrap"
      ]
  , selector_ ".hudStats"
      [ CSS.display "flex"
      , CSS.gap "clamp(8px, 2vw, 24px)"
      , CSS.alignItems "center"
      , CSS.fontSize "13px"
      , CSS.letterSpacing ".06em"
      , CSS.color mist
      , CSS.whiteSpace "nowrap"
      ]
  , selector_ ".hudStats b"
      [ CSS.color milk
      , "font-variant-numeric" =: "tabular-nums"
      , CSS.fontWeight "700"
      ]
  , selector_ ".scoreChip"
      [ CSS.fontSize "16px" ]
  , selector_ ".scoreChip b"
      [ CSS.color gold
      , CSS.fontWeight "800"
      , CSS.textShadow "0 0 12px rgba(255,201,60,.35)"
      ]
  , selector_ ".tbBtns"
      [ CSS.display "flex", CSS.gap "8px"
      , CSS.flexWrap "wrap", CSS.justifyContent "flex-end" ]
  , selector_ ".iconBtn"
      [ CSS.background "rgba(255,255,255,.07)"
      , CSS.border "1px solid rgba(255,255,255,.16)"
      , CSS.color milk
      , CSS.borderRadius (px 10)
      , CSS.padding "7px 14px"
      , CSS.fontSize "13px"
      , CSS.letterSpacing ".06em"
      , CSS.fontFamily "var(--fun)"
      , CSS.cursor "pointer"
      , CSS.backdropFilter "blur(10px)"
      , CSS.transition "transform .15s ease, background .2s ease, border-color .2s ease"
      , CSS.whiteSpace "nowrap"
      , "touch-action" =: "manipulation"
      ]
  -- layout ------------------------------------------------------------------
  , selector_ ".stageWrap"
      [ CSS.position "fixed"
      , "inset" =: "52px 0 8px 0"
      , CSS.display "flex"
      , CSS.flexDirection "column"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.gap "clamp(8px, 1.6vh, 14px)"
      ]
  -- the card ------------------------------------------------------------------
  , selector_ ".cardSheet"
      [ CSS.width "var(--bs)"
      , CSS.height "var(--bs)"
      , CSS.padding "12px"
      , CSS.background "linear-gradient(180deg, rgba(255,255,255,.08), rgba(255,255,255,.03))"
      , CSS.border "1px solid rgba(255,255,255,.14)"
      , CSS.borderRadius (px 20)
      , CSS.boxShadow "0 24px 60px rgba(0,0,0,.55), inset 0 1px 0 rgba(255,255,255,.14), 0 0 60px rgba(155,107,255,.12)"
      , CSS.animation "riseIn .5s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".cardGrid"
      [ CSS.width "100%"
      , CSS.height "100%"
      , CSS.display "grid"
      , CSS.gridTemplateColumns "repeat(5, 1fr)"
      , CSS.gridTemplateRows "repeat(5, 1fr)"
      , CSS.gap "8px"
      ]
  , selector_ ".tile"
      [ CSS.position "relative"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.borderRadius (px 12)
      , CSS.background "linear-gradient(180deg, #3D2A73, #2B1B56)"
      , CSS.border "1px solid rgba(255,255,255,.10)"
      , CSS.boxShadow "inset 0 1px 0 rgba(255,255,255,.12), 0 3px 8px rgba(0,0,0,.35)"
      , CSS.color milk
      , CSS.fontFamily "var(--fun)"
      , CSS.fontWeight "700"
      , CSS.fontSize "calc(var(--bs) / 12)"
      , CSS.transition "transform .12s ease, box-shadow .12s ease, filter .12s ease"
      , "touch-action" =: "manipulation"
      , "font-variant-numeric" =: "tabular-nums"
      ]
  , selector_ ".tile.mk"
      [ CSS.background "radial-gradient(circle at 35% 28%, #FFE08A, #FFC93C 48%, #E89B12 100%)"
      , CSS.color (RGB 74 43 0)
      , CSS.border "1px solid rgba(255,255,255,.4)"
      , CSS.boxShadow "0 0 16px rgba(255,201,60,.4), inset 0 1px 0 rgba(255,255,255,.6), 0 3px 8px rgba(0,0,0,.35)"
      , CSS.fontWeight "800"
      ]
  , selector_ ".tile.mk::after"
      [ "content" =: "'★'"
      , CSS.position "absolute"
      , CSS.top "4%"
      , CSS.right "9%"
      , CSS.fontSize "calc(var(--bs) / 30)"
      , CSS.color (RGBA 122 63 0 0.55)
      ]
  , selector_ ".tile.el"
      [ CSS.cursor "pointer"
      , CSS.border "2px solid #4DE1FF"
      , CSS.animation "elPulse 1.1s ease-in-out infinite"
      ]
  , selector_ ".tile.pop"
      [ CSS.animation "markPop .4s cubic-bezier(.2,.9,.3,1.4) backwards" ]
  , selector_ ".tile.fl"
      [ CSS.animation "lineFlare .9s ease" ]
  , selector_ ".tile.pop.fl"
      [ "animation" =: "markPop .4s cubic-bezier(.2,.9,.3,1.4) backwards, lineFlare .9s ease" ]
  -- the reels -----------------------------------------------------------------
  , selector_ ".reelRow"
      [ CSS.width "var(--bs)"
      , CSS.display "grid"
      , CSS.gridTemplateColumns "repeat(5, 1fr)"
      , CSS.gap "8px"
      , CSS.padding "0 12px"
      , CSS.animation "riseIn .5s .08s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".reel"
      [ CSS.position "relative"
      , CSS.height "calc(var(--bs) / 5.4)"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.overflow "hidden"
      , CSS.borderRadius (px 12)
      , CSS.background "linear-gradient(180deg, #170933, #0F0524)"
      , CSS.border "1px solid rgba(155,107,255,.4)"
      , CSS.boxShadow "inset 0 6px 14px rgba(0,0,0,.6), 0 0 12px rgba(155,107,255,.18)"
      , CSS.fontFamily "var(--fun)"
      , CSS.fontWeight "800"
      , CSS.fontSize "calc(var(--bs) / 13)"
      , CSS.color milk
      , "font-variant-numeric" =: "tabular-nums"
      ]
  , selector_ ".idleGlyph"
      [ CSS.color (RGBA 155 107 255 0.5)
      , CSS.fontSize "calc(var(--bs) / 18)"
      ]
  , selector_ ".strip"
      [ CSS.display "flex"
      , CSS.flexDirection "column"
      , CSS.animation "reelWhirl .3s linear infinite"
      , CSS.filter "blur(1px)"
      ]
  , selector_ ".strip span"
      [ CSS.height "calc(var(--bs) / 5.4)"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.opacity 0.8
      ]
  , selector_ ".face"
      [ CSS.animation "popIn .25s cubic-bezier(.2,.9,.3,1.3) backwards" ]
  , selector_ ".hitFace"
      [ CSS.color gold
      , CSS.textShadow "0 0 14px rgba(255,201,60,.7)"
      ]
  -- controls ------------------------------------------------------------------
  , selector_ ".ctrlRow"
      [ CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.gap "14px"
      , CSS.animation "riseIn .5s .16s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".spinBtn"
      [ CSS.position "relative"
      , CSS.padding "12px 56px 22px"
      , CSS.borderRadius (px 999)
      , CSS.border "none"
      , CSS.fontFamily "var(--fun)"
      , CSS.fontWeight "800"
      , CSS.fontSize "21px"
      , CSS.letterSpacing ".16em"
      , CSS.color (RGB 74 43 0)
      , CSS.background "linear-gradient(180deg, #FFE08A, #FFC93C 45%, #F5A80F)"
      , CSS.boxShadow spinShadow
      , CSS.cursor "pointer"
      , CSS.transition "transform .12s ease, box-shadow .12s ease, filter .2s ease"
      , CSS.animation "glowPulse 1.6s ease-in-out infinite"
      , "touch-action" =: "manipulation"
      ]
  , selector_ ".spinBtn small"
      [ CSS.position "absolute"
      , "inset" =: "auto 0 6px 0"
      , CSS.fontSize "11px"
      , CSS.fontWeight "700"
      , CSS.letterSpacing ".1em"
      , CSS.color (RGBA 74 43 0 0.7)
      ]
  , selector_ ".spinBtn:active"
      [ CSS.transform "translateY(3px)"
      , CSS.boxShadow "0 3px 0 #B87A00, 0 8px 18px rgba(255,168,22,.3)"
      ]
  , selector_ ".spinBtn.off"
      [ CSS.filter "grayscale(.8) brightness(.72)"
      , CSS.cursor "default"
      , CSS.animation "none"
      , CSS.boxShadow "0 6px 0 #3A3350, 0 10px 22px rgba(0,0,0,.4)"
      ]
  , selector_ ".toast"
      [ "min-height" =: "20px"
      , CSS.maxWidth "94vw"
      , CSS.padding "7px 18px"
      , CSS.borderRadius (px 999)
      , CSS.background "rgba(255,255,255,.06)"
      , CSS.border "1px solid rgba(255,255,255,.1)"
      , CSS.backdropFilter "blur(8px)"
      , CSS.color (RGB 201 188 242)
      , CSS.fontSize "13.5px"
      , CSS.letterSpacing ".04em"
      , CSS.whiteSpace "nowrap"
      , CSS.overflow "hidden"
      , "text-overflow" =: "ellipsis"
      ]
  -- the slam ------------------------------------------------------------------
  , selector_ ".slam"
      [ CSS.position "fixed"
      , "inset" =: "0"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.zIndex 95
      , CSS.pointerEvents "none"
      , CSS.fontFamily "var(--fun)"
      , CSS.fontWeight "800"
      , CSS.fontSize "clamp(44px, 13vmin, 110px)"
      , CSS.letterSpacing ".06em"
      , CSS.color gold
      , CSS.textShadow "0 0 24px rgba(255,201,60,.65), 0 6px 0 rgba(122,63,0,.9), 0 0 80px rgba(255,92,168,.5)"
      , CSS.animation "slamA 1.2s cubic-bezier(.2,.9,.3,1.2) forwards"
      ]
  , selector_ ".slam.alt" [ "animation-name" =: "slamB" ]
  -- overlays: glass panels ------------------------------------------------------
  , selector_ ".overlay"
      [ CSS.position "fixed"
      , "inset" =: "0"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.background "rgba(10,4,26,.66)"
      , CSS.backdropFilter "blur(7px)"
      , CSS.zIndex 100
      , CSS.animation "overlayIn .25s ease"
      ]
  , selector_ ".panel"
      [ CSS.background "linear-gradient(180deg, rgba(48,26,92,.97), rgba(26,12,52,.98))"
      , CSS.color milk
      , CSS.border "1px solid rgba(155,107,255,.45)"
      , CSS.borderRadius (px 18)
      , CSS.padding "28px 44px"
      , CSS.boxShadow "0 30px 90px rgba(0,0,0,.6), 0 0 50px rgba(155,107,255,.25)"
      , CSS.textAlign "center"
      , CSS.animation "panelIn .4s cubic-bezier(.2,.9,.25,1.2) backwards"
      , CSS.maxWidth "min(92vw, 560px)"
      ]
  , selector_ ".seal"
      [ CSS.display "inline-block"
      , CSS.margin "0 auto 10px"
      , CSS.padding "8px 18px"
      , CSS.border "3px solid #FF5CA8"
      , CSS.borderRadius (px 12)
      , CSS.color pink
      , CSS.fontFamily "var(--fun)"
      , CSS.fontWeight "800"
      , CSS.fontSize "22px"
      , CSS.letterSpacing ".22em"
      , CSS.background (renderColor (RGBA 255 92 168 0.06))
      , CSS.transform "rotate(-6deg)"
      , CSS.animation "stampIn .5s .2s cubic-bezier(.34,1.56,.64,1) backwards"
      ]
  , selector_ ".seal.sealWin"
      [ CSS.borderColor gold
      , CSS.color gold
      , CSS.background (renderColor (RGBA 255 201 60 0.07))
      ]
  , selector_ ".finalScore"
      [ CSS.fontFamily "var(--fun)"
      , CSS.fontWeight "800"
      , CSS.fontSize "clamp(40px, 9vmin, 64px)"
      , CSS.color gold
      , CSS.textShadow "0 0 24px rgba(255,201,60,.5)"
      , "font-variant-numeric" =: "tabular-nums"
      , CSS.lineHeight "1.1"
      ]
  , selector_ ".starRow"
      [ CSS.fontSize "26px"
      , CSS.letterSpacing ".28em"
      , CSS.color gold
      , CSS.margin "2px 0 14px"
      , CSS.textShadow "0 0 14px rgba(255,201,60,.4)"
      ]
  , selector_ ".statRow"
      [ CSS.display "flex"
      , CSS.justifyContent "space-between"
      , CSS.gap "60px"
      , CSS.padding "8px 4px"
      , CSS.fontSize "15px"
      , CSS.color mist
      , CSS.borderBottom "1px solid rgba(255,255,255,.12)"
      , CSS.animation "riseIn .4s ease backwards"
      ]
  , selector_ ".statRow b"
      [ CSS.color milk, "font-variant-numeric" =: "tabular-nums" ]
  , selector_ ".panel .btn" [ CSS.margin "20px 6px 0" ]
  -- buttons -------------------------------------------------------------------
  , selector_ ".btn"
      [ CSS.padding "12px 30px"
      , CSS.borderRadius (px 999)
      , CSS.border "none"
      , CSS.background "linear-gradient(180deg, #FFE08A, #FFC93C 45%, #F5A80F)"
      , CSS.color (RGB 74 43 0)
      , CSS.fontWeight "800"
      , CSS.fontFamily "var(--fun)"
      , CSS.fontSize "16px"
      , CSS.letterSpacing ".12em"
      , CSS.cursor "pointer"
      , CSS.boxShadow "0 5px 0 #B87A00, 0 10px 26px rgba(255,168,22,.3)"
      , CSS.transition "transform .15s ease, box-shadow .15s ease, filter .15s ease"
      , "touch-action" =: "manipulation"
      ]
  , selector_ ".btn:active" [ CSS.transform "translateY(2px) scale(.98)" ]
  , selector_ ".btn.ghost"
      [ CSS.background "rgba(255,255,255,.07)"
      , CSS.color milk
      , CSS.border "1px solid rgba(255,255,255,.22)"
      , CSS.boxShadow "none"
      , CSS.backdropFilter "blur(8px)"
      ]
  , media_ (MediaQuery "(hover: hover)")
      [ rule_ ".iconBtn:hover"
          [ CSS.background "rgba(255,255,255,.13)"
          , CSS.borderColor (RGBA 255 255 255 0.4)
          , CSS.transform "translateY(-1px)"
          ]
      , rule_ ".btn:hover"
          [ CSS.transform "translateY(-2px)"
          , CSS.filter "brightness(1.08)"
          ]
      , rule_ ".spinBtn:hover:not(.off)"
          [ CSS.transform "translateY(-2px)"
          , CSS.filter "brightness(1.08)"
          ]
      , rule_ ".tile.el:hover"
          [ CSS.transform "translateY(-3px) scale(1.05)"
          , CSS.boxShadow "0 0 18px rgba(77,225,255,.6), 0 8px 16px rgba(0,0,0,.4)"
          ]
      ]
  -- how-to-play modal ---------------------------------------------------------
  , selector_ ".overlay.help"
      [ CSS.zIndex 120
      , CSS.alignItems "flex-start"
      , CSS.padding "min(7vh, 60px) 14px 14px"
      ]
  , selector_ ".helpPanel"
      [ CSS.textAlign "left"
      , CSS.maxWidth "min(94vw, 620px)"
      , CSS.maxHeight "min(86dvh, 760px)"
      , CSS.overflowY "auto"
      , CSS.position "relative"
      , CSS.padding "24px 34px 28px"
      , CSS.animation "dropIn .45s cubic-bezier(.2,.9,.25,1.15) backwards"
      , "overscroll-behavior" =: "contain"
      , "scrollbar-width" =: "thin"
      , "scrollbar-color" =: "rgba(155,107,255,.5) transparent"
      ]
  , selector_ ".helpPanel::-webkit-scrollbar" [ CSS.width "8px" ]
  , selector_ ".helpPanel::-webkit-scrollbar-thumb"
      [ CSS.background "rgba(155,107,255,.4)", CSS.borderRadius (px 8) ]
  , selector_ ".helpPanel::-webkit-scrollbar-track" [ CSS.background "transparent" ]
  , selector_ ".helpClose"
      [ CSS.position "absolute"
      , CSS.top "10px"
      , CSS.right "14px"
      , CSS.background "none"
      , CSS.border "none"
      , CSS.color mist
      , CSS.fontSize "22px"
      , CSS.cursor "pointer"
      , CSS.padding "6px 8px"
      , CSS.transition "color .15s ease, transform .15s ease"
      ]
  , selector_ ".helpClose:hover" [ CSS.color pink, CSS.transform "scale(1.15)" ]
  , selector_ ".helpH"
      [ CSS.fontFamily "var(--fun)"
      , CSS.fontSize "24px", CSS.fontWeight "800"
      , CSS.letterSpacing ".14em", CSS.color gold, CSS.margin "0 0 2px" ]
  , selector_ ".helpSub"
      [ CSS.color mist, CSS.fontSize "13px"
      , CSS.letterSpacing ".1em", CSS.marginBottom "10px" ]
  , selector_ ".helpSec"
      [ CSS.color cyanN, CSS.fontSize "12px", CSS.fontWeight "800"
      , CSS.letterSpacing ".24em", CSS.margin "18px 0 4px" ]
  , selector_ ".helpP"
      [ CSS.color (RGB 207 197 239), CSS.fontSize "14px"
      , CSS.lineHeight "1.6", CSS.margin "4px 0" ]
  , selector_ ".legendRow"
      [ CSS.display "flex", CSS.alignItems "center"
      , CSS.gap "10px", CSS.margin "8px 0" ]
  , selector_ ".legendCell"
      [ CSS.width "36px", CSS.height "36px"
      , CSS.display "flex", CSS.alignItems "center", CSS.justifyContent "center"
      , CSS.background "linear-gradient(180deg, #170933, #0F0524)"
      , CSS.border "1px solid rgba(155,107,255,.4)"
      , CSS.borderRadius (px 8)
      , CSS.fontSize "19px"
      , "flex" =: "0 0 auto"
      ]
  , selector_ ".helpCap" [ CSS.color (RGB 207 197 239), CSS.fontSize "13.5px" ]
  -- title screen ---------------------------------------------------------------
  , selector_ ".titleWrap"
      [ CSS.position "fixed"
      , "inset" =: "0"
      , CSS.display "flex"
      , CSS.flexDirection "column"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.gap "10px"
      , CSS.zIndex 110
      , CSS.background velvet
      , CSS.overflow "hidden"
      ]
  , selector_ ".floatSym"
      [ CSS.position "absolute"
      , CSS.fontSize "clamp(30px, 6vmin, 54px)"
      , CSS.opacity 0.55
      , CSS.animation "floaty 7s ease-in-out infinite"
      , CSS.pointerEvents "none"
      , CSS.filter "drop-shadow(0 10px 22px rgba(0,0,0,.5))"
      ]
  , selector_ ".logo"
      [ CSS.display "flex"
      , CSS.gap "1px"
      , CSS.margin "0"
      , CSS.fontFamily "var(--fun)"
      , CSS.fontWeight "800"
      , CSS.fontSize "clamp(58px, 15vmin, 124px)"
      , CSS.lineHeight "1"
      , CSS.animation "riseIn .7s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".logo span"
      [ CSS.display "inline-block"
      , CSS.animation "bounceL 2.4s ease-in-out infinite"
      , CSS.textShadow "0 8px 0 rgba(0,0,0,.35), 0 0 44px rgba(255,92,168,.35)"
      ]
  , selector_ ".tagline"
      [ CSS.letterSpacing ".4em"
      , CSS.color mist
      , CSS.fontSize "clamp(11px, 2vmin, 15px)"
      , CSS.marginBottom "22px"
      , CSS.animation "riseIn .7s .15s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".playBtn"
      [ CSS.fontSize "20px"
      , CSS.padding "16px 60px"
      , CSS.animation "riseIn .7s .3s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".howBtn"
      [ CSS.fontSize "13px"
      , CSS.padding "10px 30px"
      , CSS.marginTop "10px"
      , CSS.animation "riseIn .7s .4s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".altPlayBtn"
      [ CSS.fontSize "15px"
      , CSS.padding "12px 44px"
      , CSS.marginTop "8px"
      , CSS.animation "riseIn .7s .35s cubic-bezier(.2,.9,.25,1.2) backwards"
      ]
  , selector_ ".titleHint"
      [ CSS.marginTop "18px"
      , CSS.color (RGB 122 108 170)
      , CSS.fontSize "12px"
      , CSS.letterSpacing ".14em"
      , CSS.animation "riseIn .7s .5s ease backwards"
      ]
  -- the classic 1994 table -----------------------------------------------------
  -- green felt, beveled cream tiles, chrome reels, a big red button,
  -- and a gold coin slapped on every mark. AOL, sweet AOL.
  , selector_ ".classic"
      [ CSS.position "fixed"
      , "inset" =: "0"
      , CSS.background felt
      , CSS.fontFamily retroStack
      ]
  , selector_ ".classic .brand"
      [ CSS.fontFamily retroStack
      , CSS.color (RGB 255 215 94)
      , CSS.textShadow "0 2px 0 #7E1010"
      ]
  , selector_ ".classic .hudStats" [ CSS.color (RGB 207 232 217) ]
  , selector_ ".classic .hudStats b" [ CSS.color (RGB 255 255 255) ]
  , selector_ ".classic .scoreChip b"
      [ CSS.color (RGB 255 215 94), CSS.textShadow "0 1px 0 rgba(0,0,0,.5)" ]
  , selector_ ".classic .iconBtn"
      [ CSS.background "linear-gradient(180deg, #F2F0E9, #CFCBBD)"
      , CSS.border "2px solid"
      , "border-color" =: "#FFFDF4 #8F8971 #8F8971 #FFFDF4"
      , CSS.borderRadius (px 3)
      , CSS.color (RGB 51 48 42)
      , CSS.backdropFilter "none"
      , CSS.fontFamily retroStack
      ]
  , selector_ ".classic .cardSheet"
      [ CSS.background "rgba(4, 40, 30, .55)"
      , CSS.border "3px solid"
      , "border-color" =: "#E9C24F #7A5A12 #7A5A12 #E9C24F"
      , CSS.borderRadius (px 8)
      , CSS.boxShadow "0 20px 50px rgba(0,0,0,.5)"
      ]
  , selector_ ".classic .tile"
      [ CSS.background "linear-gradient(180deg, #FBF3DE, #EFE3C2)"
      , CSS.border "3px solid"
      , "border-color" =: "#FFFDF2 #B99C62 #B99C62 #FFFDF2"
      , CSS.borderRadius (px 4)
      , CSS.color (RGB 142 27 27)
      , CSS.fontFamily retroStack
      , CSS.boxShadow "0 2px 4px rgba(0,0,0,.35)"
      ]
  , selector_ ".classic .tile.mk"
      [ CSS.background "linear-gradient(180deg, #FBF3DE, #EFE3C2)"
      , CSS.color (RGBA 142 27 27 0.28)
      , CSS.border "3px solid"
      , "border-color" =: "#B99C62 #FFFDF2 #FFFDF2 #B99C62"
      , CSS.boxShadow "inset 0 2px 6px rgba(0,0,0,.2)"
      ]
  , selector_ ".classic .tile.mk::after"
      [ "content" =: "'🪙'"
      , "inset" =: "0"
      , CSS.top "auto"
      , CSS.right "auto"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.fontSize "calc(var(--bs) / 9)"
      , CSS.filter "drop-shadow(0 3px 3px rgba(0,0,0,.4))"
      ]
  , selector_ ".classic .tile.el"
      [ CSS.border "3px solid #E8B33C"
      , CSS.animation "classicElPulse 1.1s ease-in-out infinite"
      ]
  , selector_ ".classic .reel"
      [ CSS.background "linear-gradient(180deg, #FFFFFF, #D9DEE4 45%, #AEB6BF)"
      , CSS.border "3px solid"
      , "border-color" =: "#F4F6F8 #6E7680 #6E7680 #F4F6F8"
      , CSS.borderRadius (px 4)
      , CSS.color (RGB 32 36 43)
      , CSS.fontFamily retroStack
      , CSS.boxShadow "inset 0 4px 10px rgba(0,0,0,.25)"
      ]
  , selector_ ".classic .idleGlyph" [ CSS.color (RGBA 32 36 43 0.35) ]
  , selector_ ".classic .hitFace"
      [ CSS.color (RGB 176 24 24), CSS.textShadow "none" ]
  , selector_ ".classic .spinBtn"
      [ CSS.background "linear-gradient(180deg, #FF6A5A, #D42B1E 45%, #A31207)"
      , CSS.color (RGB 255 255 255)
      , CSS.fontFamily retroStack
      , CSS.borderRadius (px 10)
      , CSS.textShadow "0 2px 0 rgba(0,0,0,.35)"
      , CSS.boxShadow "0 6px 0 #6E0C04, 0 10px 22px rgba(0,0,0,.45)"
      , CSS.animation "none"
      ]
  , selector_ ".classic .spinBtn small" [ CSS.color (RGBA 255 240 230 0.85) ]
  , selector_ ".classic .spinBtn:active"
      [ CSS.boxShadow "0 3px 0 #6E0C04, 0 6px 14px rgba(0,0,0,.4)" ]
  , selector_ ".classic .toast"
      [ CSS.background "#E9E3D0"
      , CSS.color (RGB 58 52 40)
      , CSS.border "2px solid"
      , "border-color" =: "#8F8971 #FFFDF4 #FFFDF4 #8F8971"
      , CSS.borderRadius (px 2)
      , CSS.backdropFilter "none"
      , CSS.fontFamily retroStack
      ]
  , selector_ ".classic .slam"
      [ CSS.fontFamily retroStack
      , CSS.color (RGB 255 215 94)
      , CSS.textShadow "0 4px 0 #7E1010, 0 10px 30px rgba(0,0,0,.5)"
      ]
  , selector_ ".classic .panel"
      [ CSS.background "linear-gradient(180deg, #F4ECD8, #E4D8B8)"
      , CSS.color (RGB 58 48 32)
      , CSS.border "3px solid"
      , "border-color" =: "#FFFDF2 #A8905E #A8905E #FFFDF2"
      , CSS.borderRadius (px 6)
      ]
  , selector_ ".classic .finalScore"
      [ CSS.color (RGB 176 24 24)
      , CSS.fontFamily retroStack
      , CSS.textShadow "none"
      ]
  , selector_ ".classic .starRow"
      [ CSS.color (RGB 201 154 27), CSS.textShadow "none" ]
  , selector_ ".classic .statRow"
      [ CSS.color (RGB 107 94 66)
      , CSS.borderBottom "1px solid rgba(0,0,0,.15)"
      ]
  , selector_ ".classic .statRow b" [ CSS.color (RGB 46 39 24) ]
  , selector_ ".classic .seal.sealWin"
      [ CSS.borderColor (RGB 168 122 16)
      , CSS.color (RGB 168 122 16)
      , CSS.background "rgba(168,122,16,.08)"
      ]
  , selector_ ".classic .btn"
      [ CSS.background "linear-gradient(180deg, #FF6A5A, #D42B1E 45%, #A31207)"
      , CSS.color (RGB 255 255 255)
      , CSS.fontFamily retroStack
      , CSS.borderRadius (px 8)
      , CSS.boxShadow "0 4px 0 #6E0C04, 0 8px 18px rgba(0,0,0,.35)"
      ]
  , selector_ ".classic .btn.ghost"
      [ CSS.background "#EDE6D2"
      , CSS.color (RGB 58 48 32)
      , CSS.border "2px solid"
      , "border-color" =: "#FFFDF4 #8F8971 #8F8971 #FFFDF4"
      , CSS.boxShadow "none"
      ]
  -- the devil / cherub cartoon slam (classic only)
  , selector_ ".popup"
      [ CSS.position "fixed"
      , "inset" =: "0"
      , CSS.display "flex"
      , CSS.alignItems "center"
      , CSS.justifyContent "center"
      , CSS.zIndex 96
      , CSS.pointerEvents "none"
      , CSS.fontFamily retroStack
      , CSS.fontWeight "800"
      , CSS.fontSize "clamp(40px, 11vmin, 96px)"
      , CSS.color (RGB 255 255 255)
      , CSS.textShadow "0 4px 0 rgba(0,0,0,.55), 0 0 40px rgba(0,0,0,.6)"
      , CSS.animation "popupA 1.5s ease forwards"
      ]
  , selector_ ".popup.alt" [ "animation-name" =: "popupB" ]
  , keyframes_ "popupA" popupStops
  , keyframes_ "popupB" popupStops
  , keyframes_ "classicElPulse"
      [ from_ [ CSS.boxShadow "0 0 6px rgba(232,179,60,.4)" ]
      , at (pct 50) [ CSS.boxShadow "0 0 20px rgba(232,179,60,.85)" ]
      , to_ [ CSS.boxShadow "0 0 6px rgba(232,179,60,.4)" ]
      ]
  -- responsive ----------------------------------------------------------------
  , media_ (screen_ `and_` maxWidth_ (px 740))
      [ rule_ ":root"
          [ "--bs" =: "min(94vw, calc(100dvh - 342px))" ]
      , rule_ ".topbar"
          [ CSS.flexWrap "wrap"
          , CSS.padding "6px 8px"
          , CSS.justifyContent "center"
          , "row-gap" =: "4px"
          , CSS.gap "8px"
          ]
      , rule_ ".stageWrap" [ "inset" =: "84px 0 8px 0" ]
      , rule_ ".btnLabel" [ CSS.display "none" ]
      , rule_ ".iconBtn" [ CSS.padding "7px 11px", CSS.fontSize "15px" ]
      , rule_ ".hudStats" [ CSS.fontSize "12px" ]
      , rule_ ".spinBtn" [ CSS.fontSize "18px", CSS.padding "10px 44px 20px" ]
      , rule_ ".panel" [ CSS.padding "20px 24px" ]
      , rule_ ".helpPanel" [ CSS.padding "18px 18px 20px" ]
      , rule_ ".overlay.help" [ CSS.padding "10px 8px 8px" ]
      , rule_ ".statRow" [ CSS.gap "30px" ]
      ]
  , media_ (screen_ `and_` maxWidth_ (px 480))
      [ rule_ ".brand" [ CSS.display "none" ] ]
  , media_ (screen_ `and_` maxHeight_ (px 560))
      [ rule_ ":root" [ "--bs" =: "min(58vw, calc(100dvh - 200px))" ]
      , rule_ ".topbar" [ CSS.padding "4px 8px" ]
      , rule_ ".btnLabel" [ CSS.display "none" ]
      , rule_ ".brand" [ CSS.display "none" ]
      , rule_ ".stageWrap" [ "inset" =: "42px 0 4px 0", CSS.gap "8px" ]
      ]
  , media_ (MediaQuery "(prefers-reduced-motion: reduce)")
      [ rule_ "*"
          [ "animation-duration" =: ".01ms"
          , "animation-iteration-count" =: "1"
          , "transition-duration" =: ".01ms"
          ]
      ]
  -- keyframes ------------------------------------------------------------------
  , keyframes_ "popIn"
      [ from_ [ CSS.transform "scale(.3)", CSS.opacity 0 ]
      , at (pct 65) [ CSS.transform "scale(1.15)", CSS.opacity 1 ]
      , to_ [ CSS.transform "scale(1)", CSS.opacity 1 ]
      ]
  , keyframes_ "markPop"
      [ from_ [ CSS.transform "scale(.55)" ]
      , at (pct 60) [ CSS.transform "scale(1.14)" ]
      , to_ [ CSS.transform "scale(1)" ]
      ]
  , keyframes_ "elPulse"
      [ from_ [ CSS.boxShadow "0 0 6px rgba(77,225,255,.35)" ]
      , at (pct 50) [ CSS.boxShadow "0 0 20px rgba(77,225,255,.75)" ]
      , to_ [ CSS.boxShadow "0 0 6px rgba(77,225,255,.35)" ]
      ]
  , keyframes_ "lineFlare"
      [ from_ [ CSS.filter "brightness(1)" ]
      , at (pct 30) [ CSS.filter "brightness(2.1) saturate(1.5)" ]
      , to_ [ CSS.filter "brightness(1)" ]
      ]
  , keyframes_ "reelWhirl"
      [ from_ [ CSS.transform "translateY(0)" ]
      , to_ [ CSS.transform "translateY(-50%)" ]
      ]
  , keyframes_ "glowPulse"
      [ from_ [ CSS.boxShadow spinShadow ]
      , at (pct 50)
          [ CSS.boxShadow "0 6px 0 #B87A00, 0 16px 44px rgba(255,168,22,.6)" ]
      , to_ [ CSS.boxShadow spinShadow ]
      ]
  , keyframes_ "slamA" slamStops
  , keyframes_ "slamB" slamStops
  , keyframes_ "stampIn"
      [ from_ [ CSS.transform "scale(2.1) rotate(-20deg)", CSS.opacity 0 ]
      , to_ [ CSS.transform "scale(1) rotate(-6deg)", CSS.opacity 1 ]
      ]
  , keyframes_ "overlayIn" [ from_ [ CSS.opacity 0 ], to_ [ CSS.opacity 1 ] ]
  , keyframes_ "panelIn"
      [ from_ [ CSS.transform "translateY(26px) scale(.92)", CSS.opacity 0 ]
      , to_ [ CSS.transform "translateY(0) scale(1)", CSS.opacity 1 ]
      ]
  , keyframes_ "dropIn"
      [ from_ [ CSS.transform "translateY(-52px) scale(.97)", CSS.opacity 0 ]
      , to_ [ CSS.transform "translateY(0) scale(1)", CSS.opacity 1 ]
      ]
  , keyframes_ "riseIn"
      [ from_ [ CSS.transform "translateY(18px)", CSS.opacity 0 ]
      , to_ [ CSS.transform "translateY(0)", CSS.opacity 1 ]
      ]
  , keyframes_ "bounceL"
      [ from_ [ CSS.transform "translateY(0)" ]
      , at (pct 50) [ CSS.transform "translateY(-9px)" ]
      , to_ [ CSS.transform "translateY(0)" ]
      ]
  , keyframes_ "floaty"
      [ from_ [ CSS.transform "translateY(0) rotate(var(--fr, 0deg))" ]
      , at (pct 50) [ CSS.transform "translateY(-18px) rotate(var(--fr, 0deg))" ]
      , to_ [ CSS.transform "translateY(0) rotate(var(--fr, 0deg))" ]
      ]
  ]
  where
    slamStops =
      [ from_ [ CSS.opacity 0, CSS.transform "scale(2.8) rotate(-7deg)" ]
      , at (pct 30) [ CSS.opacity 1, CSS.transform "scale(1) rotate(-3deg)" ]
      , at (pct 70) [ CSS.opacity 1, CSS.transform "scale(1) rotate(-3deg)" ]
      , to_ [ CSS.opacity 0, CSS.transform "scale(.92) translateY(-40px)" ]
      ]
    popupStops =
      [ from_ [ CSS.opacity 0, CSS.transform "scale(2.4)" ]
      , at (pct 15) [ CSS.opacity 1, CSS.transform "scale(1) rotate(-3deg)" ]
      , at (pct 30) [ CSS.transform "scale(1) rotate(3deg)" ]
      , at (pct 45) [ CSS.transform "scale(1) rotate(-2deg)" ]
      , at (pct 60) [ CSS.transform "scale(1) rotate(0deg)" ]
      , at (pct 80) [ CSS.opacity 1 ]
      , to_ [ CSS.opacity 0, CSS.transform "scale(.9) translateY(30px)" ]
      ]
-----------------------------------------------------------------------------
-- | The 1994 casino: green felt under a hanging lamp.
felt :: MisoString
felt = mconcat
  [ "radial-gradient(120% 90% at 50% 8%, rgba(255,244,200,.10), rgba(0,0,0,0) 55%), "
  , "linear-gradient(180deg, #1E6B45 0%, #0F4736 55%, #093226 100%)"
  ]
-----------------------------------------------------------------------------
-- | Deep violet velvet with neon haze in the corners.
velvet :: MisoString
velvet = mconcat
  [ "radial-gradient(90% 60% at 15% 0%, rgba(155,107,255,.25), rgba(0,0,0,0) 60%), "
  , "radial-gradient(80% 60% at 85% 10%, rgba(255,92,168,.18), rgba(0,0,0,0) 55%), "
  , "linear-gradient(180deg, #2B1257 0%, #1D0C40 55%, #12072B 100%)"
  ]
-----------------------------------------------------------------------------
spinShadow :: MisoString
spinShadow = "0 6px 0 #B87A00, 0 10px 26px rgba(255,168,22,.32)"
