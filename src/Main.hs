-----------------------------------------------------------------------------
-- | miso-slingo: part slots, part bingo, in the miso game family.
-----------------------------------------------------------------------------
module Main where
-----------------------------------------------------------------------------
import           Control.Concurrent (threadDelay)
import           Control.Monad (when)
import           Data.List (intersperse)
import qualified Data.IntSet as IS
-----------------------------------------------------------------------------
import           Miso hiding ((!!), view, Phase)
import           Miso.Lens hiding (view)
import qualified Miso.CSS as CSS
import           Miso.CSS.Color (Color(RGB))
import qualified Miso.Html.Element as H
import qualified Miso.Html.Event as HE
import qualified Miso.Html.Property as HP
import           Miso.Random (replicateRM)
-----------------------------------------------------------------------------
import           Logic
import           Model
import           Sound
import           Styles (skin)
-----------------------------------------------------------------------------
main :: IO ()
main = startApp defaultEvents app
-----------------------------------------------------------------------------
app :: App Model Action
app = (component initialModel updateModel viewModel)
  { styles = [ Sheet skin ]
  , subs = [ keyboardSub Keys ]
  }
-----------------------------------------------------------------------------
#ifdef WASM
foreign export javascript "hs_start" main :: IO ()
#endif
-----------------------------------------------------------------------------
type Fx = Effect () () Model Action
-----------------------------------------------------------------------------
-- * Update
-----------------------------------------------------------------------------
updateModel :: Action -> Fx
updateModel = \case
  NoOp -> pure ()

  ToggleSound -> soundOn %= not

  ShowHelp -> showHelp .= True

  CloseHelp -> showHelp .= False

  Play v -> do
    variant .= v
    io_ soundInit
    io $ do
      supply <- replicateRM cardSupply
      pure (CardReady (makeCard supply))

  CardReady c -> do
    m <- get
    put initialModel
      { _variant = m ^. variant
      , _card = c
      , _phase = Playing
      , _soundOn = m ^. soundOn
      , _heldKeys = m ^. heldKeys
      }
    playFx "deal"

  NewGame -> do
    phase .= Title
    showHelp .= False

  Spin -> do
    m <- get
    when (canSpin m) $ do
      let cl = m ^. variant == Classic
          fee = if cl then spinFee (m ^. spinsUsed + 1) else 0
          waived = fee > 0 && m ^. freeHeld > 0
      when waived (freeHeld %= subtract 1)
      when (fee > 0 && not waived) (score %= max 0 . subtract fee)
      spins %= subtract 1
      spinsUsed += 1
      stage .= Spinning
      reels .= replicate 5 Whirl
      banner .= Nothing
      popup .= Nothing
      flash .= []
      fresh .= []
      toast .= if
        | waived -> "🔄 a held free spin pays the " <> ms fee <> " toll…"
        | fee > 0 -> "💸 spin bought for " <> ms fee <> "…"
        | otherwise -> "round and round…"
      playFx "spin"
      io $ do
        supply <- replicateRM spinSupply
        luck <- replicateRM 1
        threadDelay 500000
        pure $ if cl
          then Spun (classicRollReels supply) (any (< classicCherubChance) luck)
          else Spun (rollReels supply) False

  Spun syms save -> do
    m <- get
    when (m ^. stage == Spinning) $ do
      pending .= syms
      cherubSave .= save
      issue (StopReel 0)

  StopReel i -> do
    m <- get
    when (m ^. stage == Spinning) $
      case drop i (m ^. pending) of
        (s : _) -> do
          reels %= \rs -> [ if j == i then Face s else r | (j, r) <- zip [0 ..] rs ]
          playFx "stop"
          if i < 4
            then io (threadDelay 220000 >> pure (StopReel (i + 1)))
            else io (threadDelay 380000 >> pure Resolve)
        [] -> pure ()

  Resolve -> do
    m <- get
    when (m ^. stage == Spinning) $ do
      let v = m ^. variant
          cl = v == Classic
          syms = zip [0 .. 4] (m ^. pending)
          hits =
            [ i
            | (c, Number n) <- syms
            , Just i <- [findCell (m ^. card) c n]
            , not ((m ^. marked) !! i)
            ]
          coins  = length [ () | (_, Coin)     <- syms ]
          frees  = length [ () | (_, FreeSpin) <- syms ]
          angels = length [ () | (_, Cherub)   <- syms ]
          imps   = length [ () | (_, Devil)    <- syms ]
          cols   = [ ColWild c | (c, Joker) <- syms ]
          supers = [ AnyWild | (_, SuperJoker) <- syms ]
          -- the classic super joker must be played first
          ws = if cl then supers ++ cols else cols ++ supers
          -- classic: the cherub is an event, and saves the whole spin
          blocked
            | cl = if m ^. cherubSave then imps else 0
            | otherwise = min imps (m ^. guards + angels)
          landed = imps - blocked
          jays = if cl then jokerBonus (length ws) else 0
      marked %= markCells hits
      fresh .= hits
      score += markPointsV v * length hits + coinPointsV v * coins + jays
      if cl then freeHeld += frees else spins += frees
      guards .= (if cl then 0 else m ^. guards + angels - blocked)
      devilsHit += landed
      when (landed > 0) $ score %= (`div` (2 ^ landed))
      when (cl && landed > 0) (popupShow "😈 HALVED!")
      when (cl && blocked > 0) (popupShow "😇 SAVED!")
      wilds .= ws
      toast .= spinToast v jays hits coins frees angels blocked landed
      playFx $ if
        | landed > 0        -> "devil"
        | blocked > 0       -> "cherub"
        | jays > 0          -> "slingo"
        | not (null hits)   -> "mark"
        | coins > 0         -> "coin"
        | frees > 0         -> "free"
        | angels > 0        -> "cherub"
        | otherwise         -> "blank"
      awardLines
      advanceWilds

  PickCell i -> do
    m <- get
    case (m ^. phase, m ^. stage, m ^. wilds) of
      (Playing, Picking, w : rest)
        | i `elem` eligible w (m ^. marked) -> do
            marked %= markCells [i]
            fresh %= (i :)
            score += markPointsV (m ^. variant)
            wilds .= rest
            playFx "mark"
            awardLines
            advanceWilds
        | otherwise -> playFx "deny"
      _ -> pure ()

  Keys ks -> do
    m <- get
    let pressed = IS.toList (ks IS.\\ (m ^. heldKeys))
    heldKeys .= ks
    mapM_ (issueKey (m ^. showHelp) (m ^. phase) (m ^. variant)) pressed
-----------------------------------------------------------------------------
canSpin :: Model -> Bool
canSpin m =
  m ^. phase == Playing
    && m ^. stage == Idle
    && m ^. spins > 0
    && not (m ^. showHelp)
-----------------------------------------------------------------------------
issueKey :: Bool -> Phase -> Variant -> Int -> Fx
issueKey helpOpen ph v k
  | helpOpen, k == 27 = issue CloseHelp
  | helpOpen = pure ()
  | k == 32 || k == 13 = case ph of
      Playing -> issue Spin
      _ -> issue (Play v)
  | otherwise = pure ()
-----------------------------------------------------------------------------
-- | The classic devil/cherub cartoon slam.
popupShow :: MisoString -> Fx
popupShow p = do
  popup ?= p
  popupAlt %= not
-----------------------------------------------------------------------------
-- | Award any newly completed lines: points, flash, and the big slam.
awardLines :: Fx
awardLines = do
  m <- get
  let done = completedLines (m ^. marked)
      landed = [ l | l <- done, l `notElem` (m ^. slingos) ]
  when (not (null landed)) $ do
    slingos .= done
    score += slingoPointsV (m ^. variant) * length landed
    flash %= (++ concatMap lineCells landed)
    banner .= Just (bannerFor (length landed))
    bannerAlt %= not
    playFx "slingo"
-----------------------------------------------------------------------------
-- | Serve the next wild: cash in any that have no open tile, then
-- either wait for a pick or finish the turn.
advanceWilds :: Fx
advanceWilds = do
  m <- get
  case m ^. wilds of
    [] -> finishTurn
    (w : rest)
      | null (eligible w (m ^. marked)) -> do
          score += coinPointsV (m ^. variant)
          toast .= "🃏 no open tile — cashed for 🪙 +"
            <> ms (coinPointsV (m ^. variant))
          wilds .= rest
          playFx "coin"
          advanceWilds
      | otherwise -> do
          stage .= Picking
          toast .= case w of
            ColWild c -> "🃏 JOKER — pick any open tile in column " <> ms (c + 1)
            AnyWild -> "🌟 SUPER JOKER — pick any open tile on the card"
          playFx "wild"
-----------------------------------------------------------------------------
-- | Between turns: full card ends in glory, an empty spin counter ends
-- the run, anything else hands the spin button back.
finishTurn :: Fx
finishTurn = do
  m <- get
  if and (m ^. marked)
    then do
      score += if m ^. variant == Classic
        then fullCardBonus (m ^. spinsUsed)
        else fullCardPoints + spareSpinPoints * (m ^. spins)
      phase .= Over True
      stage .= Idle
      playFx "win"
    else if m ^. spins <= 0
      then do
        phase .= Over False
        stage .= Idle
        playFx "over"
      else stage .= Idle
-----------------------------------------------------------------------------
spinToast :: Variant -> Int -> [Int] -> Int -> Int -> Int -> Int -> Int -> MisoString
spinToast v jays hits coins frees angels blocked landed
  | null parts = "nothing this time… spin again!"
  | otherwise = mconcat (intersperse "  ·  " parts)
  where
    cl = v == Classic
    parts = concat
      [ [ "✏️ " <> ms (length hits) <> " matched" | not (null hits) ]
      , [ "🪙 +" <> ms (coinPointsV v * coins) | coins > 0 ]
      , [ "🃏 JOKER BONUS +" <> ms jays | jays > 0 ]
      , [ if cl
            then "🔄 +" <> ms frees <> " in hand"
            else "🔄 +" <> ms frees <> " spin" <> (if frees > 1 then "s" else "")
        | frees > 0 ]
      , [ "😇 cherub in hand" | angels > blocked ]
      , [ if cl
            then "😇 the cherub shot the devil!"
            else "😇 blocked the devil!"
        | blocked > 0 ]
      , [ "😈 score halved!" | landed > 0 ]
      ]
-----------------------------------------------------------------------------
playFx :: MisoString -> Fx
playFx name = do
  m <- get
  io_ (playSound (m ^. soundOn) name)
-----------------------------------------------------------------------------
-- * View
-----------------------------------------------------------------------------
viewModel :: () -> () -> Model -> View () Model Action
viewModel _ _ m = case m ^. phase of
  Title -> H.div_ []
    ( titleView : [ helpOverlay | m ^. showHelp ] )
  _ -> H.div_ [ HP.class_ (clsWhen (m ^. variant == Classic) "classic") ]
    ( [ topbar m
      , H.div_ [ HP.class_ "stageWrap" ]
          [ boardView m, reelView m, controlView m, toastView m ]
      ]
      ++ [ bannerView b (m ^. bannerAlt) | Just b <- [m ^. banner] ]
      ++ [ popupView p (m ^. popupAlt) | Just p <- [m ^. popup] ]
      ++ [ overOverlay m w | Over w <- [m ^. phase] ]
      ++ [ helpOverlay | m ^. showHelp ]
    )
-----------------------------------------------------------------------------
titleView :: View () Model Action
titleView = H.div_ [ HP.class_ "titleWrap" ] $
  [ deco v x y r dl
  | (v, x, y, r, dl) <-
      [ ("🪙", "8%",  "14%", "-9deg",  "0s")
      , ("⭐", "86%", "16%", "7deg",   ".9s")
      , ("🃏", "12%", "70%", "6deg",   "1.7s")
      , ("😈", "85%", "68%", "-6deg",  ".4s")
      , ("😇", "24%", "34%", "12deg",  "2.3s")
      , ("🪙", "74%", "40%", "-12deg", "1.2s")
      ]
  ] ++
  [ H.h1_ [ HP.class_ "logo" ]
      [ H.span_
          [ CSS.style_ [ CSS.color col, CSS.animationDelay dl ] ]
          [ text l ]
      | (l, col, dl) <- zip3
          [ "S", "L", "I", "N", "G", "O" ]
          [ RGB 255 201 60, RGB 255 92 168, RGB 77 225 255
          , RGB 155 107 255, RGB 124 255 107, RGB 255 157 60 ]
          [ "0s", ".1s", ".2s", ".3s", ".4s", ".5s" ]
      ]
  , H.div_ [ HP.class_ "tagline" ] [ text "PART SLOTS · PART BINGO · ALL LUCK" ]
  , H.button_ [ HP.class_ "btn playBtn", HE.onClick (Play Modern) ]
      [ text "▶ PLAY MODERN" ]
  , H.button_ [ HP.class_ "btn ghost altPlayBtn", HE.onClick (Play Classic) ]
      [ text "▶ PLAY CLASSIC '94" ]
  , H.button_ [ HP.class_ "btn ghost howBtn", HE.onClick ShowHelp ]
      [ text "HOW TO PLAY" ]
  , H.div_ [ HP.class_ "titleHint" ]
      [ text ("20 spins · 12 lines · one full card · built with miso 🍜") ]
  ]
  where
    deco v x y r dl = H.div_
      [ HP.class_ "floatSym"
      , CSS.style_
          [ CSS.left x, CSS.top y, "--fr" =: r, CSS.animationDelay dl ]
      ] [ text v ]
-----------------------------------------------------------------------------
topbar :: Model -> View () Model Action
topbar m = H.div_ [ HP.class_ "topbar" ]
  [ H.div_ [ HP.class_ "brand" ] [ text "SLINGO" ]
  , H.div_ [ HP.class_ "hudStats" ] $
      [ H.span_ [ HP.class_ "scoreChip" ]
          [ text "🏆 ", H.b_ [] [ text (fmtScore (m ^. score)) ] ]
      , stat "🎰" (ms (m ^. spins) <> " spins")
      , stat "⭐" (ms (length (m ^. slingos)) <> " / " <> ms lineCount)
      ] ++ [ stat "😇" ("×" <> ms (m ^. guards)) | m ^. guards > 0 ]
        ++ [ stat "🔄" ("×" <> ms (m ^. freeHeld)) | m ^. freeHeld > 0 ]
  , H.div_ [ HP.class_ "tbBtns" ]
      [ iconBtn ShowHelp "❓" "how to play"
      , iconBtn ToggleSound
          (if m ^. soundOn then "🔊" else "🔇")
          (if m ^. soundOn then "sound" else "muted")
      , iconBtn NewGame "↺" "new game"
      ]
  ]
  where
    stat icon v = H.span_ [] [ text (icon <> " "), H.b_ [] [ text v ] ]
    iconBtn act icon label = H.button_
      [ HP.class_ "iconBtn", HE.onClick act ]
      [ text icon
      , H.span_ [ HP.class_ "btnLabel" ] [ text (" " <> label) ]
      ]
-----------------------------------------------------------------------------
boardView :: Model -> View () Model Action
boardView m = H.div_ [ HP.class_ "cardSheet" ]
  [ H.div_ [ HP.class_ "cardGrid" ] (map tileView [0 .. 24]) ]
  where
    elig = case (m ^. stage, m ^. wilds) of
      (Picking, w : _) -> eligible w (m ^. marked)
      _ -> []
    tileView i = H.div_
      [ HP.class_ cls, HE.onClick (PickCell i) ]
      [ H.span_ [ HP.class_ "num" ] [ text (ms ((m ^. card) !! i)) ] ]
      where
        cls = joinCls
          [ "tile"
          , clsWhen ((m ^. marked) !! i) "mk"
          , clsWhen (i `elem` elig) "el"
          , clsWhen (i `elem` m ^. fresh) "pop"
          , clsWhen (i `elem` m ^. flash) "fl"
          ]
-----------------------------------------------------------------------------
reelView :: Model -> View () Model Action
reelView m = H.div_ [ HP.class_ "reelRow" ]
  (map reel (zip [0 ..] (m ^. reels)))
  where
    reel (c, r) = H.div_
      [ HP.class_ (joinCls [ "reel", clsWhen (r == Whirl) "spin" ]) ]
      (case r of
        Blank -> [ H.span_ [ HP.class_ "idleGlyph" ] [ text "✦" ] ]
        Whirl ->
          [ H.div_ [ HP.class_ "strip" ]
              [ H.span_ [] [ text s ] | s <- strip c ++ strip c ]
          ]
        Face s -> [ faceView m c s ])
    strip c = [ ms (15 * c + 7), "🃏", ms (15 * c + 2), "🪙" ]
-----------------------------------------------------------------------------
faceView :: Model -> Int -> Symbol -> View () Model Action
faceView m c = \case
  Number n ->
    let hit = maybe False ((m ^. marked) !!) (findCell (m ^. card) c n)
    in H.span_
         [ HP.class_ (joinCls [ "face", clsWhen hit "hitFace" ]) ]
         [ text (ms n) ]
  Joker      -> glyph "🃏"
  SuperJoker -> glyph "🌟"
  FreeSpin   -> glyph "🔄"
  Coin       -> glyph "🪙"
  Devil      -> glyph "😈"
  Cherub     -> glyph "😇"
  where
    glyph g = H.span_ [ HP.class_ "face" ] [ text g ]
-----------------------------------------------------------------------------
controlView :: Model -> View () Model Action
controlView m = H.div_ [ HP.class_ "ctrlRow" ]
  [ H.button_
      [ HP.class_ (joinCls [ "spinBtn", clsWhen (not (canSpin m)) "off" ])
      , HE.onClick Spin
      ]
      [ text label
      , H.small_ [] [ text sub ]
      ]
  ]
  where
    label = case m ^. stage of
      Picking -> "PICK A TILE"
      Spinning -> "SPINNING…"
      Idle -> "SPIN"
    fee = if m ^. variant == Classic then spinFee (m ^. spinsUsed + 1) else 0
    sub
      | fee > 0, m ^. freeHeld > 0 =
          ms (m ^. spins) <> " left · 🔄 pays −" <> ms fee
      | fee > 0 = ms (m ^. spins) <> " left · fee −" <> ms fee
      | otherwise = ms (m ^. spins) <> " left"
-----------------------------------------------------------------------------
toastView :: Model -> View () Model Action
toastView m = H.div_ [ HP.class_ "toast" ] [ text (m ^. toast) ]
-----------------------------------------------------------------------------
bannerView :: MisoString -> Bool -> View () Model Action
bannerView b alt = H.div_
  [ HP.class_ (joinCls [ "slam", clsWhen alt "alt" ]) ]
  [ text b ]
-----------------------------------------------------------------------------
popupView :: MisoString -> Bool -> View () Model Action
popupView p alt = H.div_
  [ HP.class_ (joinCls [ "popup", clsWhen alt "alt" ]) ]
  [ text p ]
-----------------------------------------------------------------------------
overOverlay :: Model -> Bool -> View () Model Action
overOverlay m won = H.div_ [ HP.class_ "overlay" ]
  [ H.div_ [ HP.class_ "panel" ] $
      [ H.div_ [ HP.class_ (joinCls [ "seal", clsWhen won "sealWin" ]) ]
          [ text (if won then "FULL CARD" else "GAME OVER") ]
      , H.div_ [ HP.class_ "finalScore" ] [ text (fmtScore (m ^. score)) ]
      , H.div_ [ HP.class_ "starRow" ]
          [ text (mconcat
              [ if k <= starsForV (m ^. variant) (m ^. score) then "★" else "☆"
              | k <- [1 .. 5]
              ]) ]
      , statRow 0 "Slingos" (ms (length (m ^. slingos)) <> " / " <> ms lineCount)
      , statRow 1 "Tiles marked"
          (ms (length (filter id (m ^. marked))) <> " / 25")
      , statRow 2 "Devils hit" (ms (m ^. devilsHit))
      , statRow 3 "Spins used" (ms (m ^. spinsUsed))
      ]
      ++ [ if m ^. variant == Classic
             then statRow 4 "Full-card bonus"
                    ("+" <> ms (fullCardBonus (m ^. spinsUsed)))
             else statRow 4 "Spare-spin bonus"
                    ("+" <> ms (spareSpinPoints * (m ^. spins)))
         | won ]
      ++
      [ H.div_ []
          [ H.button_ [ HP.class_ "btn", HE.onClick (Play (m ^. variant)) ]
              [ text "PLAY AGAIN" ]
          , H.button_ [ HP.class_ "btn ghost", HE.onClick NewGame ] [ text "TITLE" ]
          ]
      ]
  ]
  where
    statRow :: Int -> MisoString -> MisoString -> View () Model Action
    statRow k label v = H.div_
      [ HP.class_ "statRow"
      , CSS.style_ [ CSS.animationDelay (ms (200 + k * 130) <> "ms") ]
      ]
      [ H.span_ [] [ text label ], H.b_ [] [ text v ] ]
-----------------------------------------------------------------------------
helpOverlay :: View () Model Action
helpOverlay = H.div_ [ HP.class_ "overlay help" ]
  [ H.div_ [ HP.class_ "panel helpPanel" ]
      [ H.button_ [ HP.class_ "helpClose", HE.onClick CloseHelp ] [ text "✕" ]
      , H.div_ [ HP.class_ "helpH" ] [ text "HOW TO PLAY" ]
      , H.div_ [ HP.class_ "helpSub" ] [ text "slingo · part slots, part bingo" ]
      , sec "THE OBJECTIVE"
      , para $
          "Your card is 5×5, bingo style: column one holds numbers 1–15, "
          <> "column two 16–30, and so on up to 75. You get 20 spins. Each "
          <> "spin rolls five reels — one under each column — and any "
          <> "number that matches your card marks itself. Complete a row, "
          <> "column, or diagonal to score a SLINGO."
      , sec "THE REELS"
      , legend "🃏" "JOKER — pick any open tile in that reel's column"
      , legend "🌟" "SUPER JOKER — pick any open tile on the card"
      , legend "🔄" "FREE SPIN — one spin back on the counter"
      , legend "🪙" ("COIN — +" <> ms coinPoints <> " points, no questions asked")
      , legend "😈" "DEVIL — halves your score on the spot"
      , legend "😇" "CHERUB — blocks the next devil, and keeps until needed"
      , sec "SCORING"
      , para $
          "Every marked tile is +" <> ms markPoints <> ". Every completed "
          <> "line is +" <> ms slingoPoints <> " — there are 12: five rows, "
          <> "five columns, two diagonals. Fill the whole card for +"
          <> ms fullCardPoints <> " plus +" <> ms spareSpinPoints
          <> " for every spin you didn't need."
      , sec "TABLE MANNERS"
      , para $
          "Space or Enter spins. Jokers pause the reels until you pick a "
          <> "tile — glowing tiles are fair game. When the spin counter "
          <> "hits zero, the red pen adds it all up."
      , sec "CLASSIC '94 RULES"
      , para $
          "The classic table plays by the original AOL scoring: +"
          <> ms classicMarkPoints <> " a number, +"
          <> ms classicSlingoPoints <> " a slingo, coins worth +"
          <> ms classicCoinPoints <> ". Only the center reel can go 🌟 "
          <> "super, and a super joker is always played first. The 😈 "
          <> "devil still halves your score — but about half the time a "
          <> "😇 cherub shoots it first. 🔄 free spins are held in hand "
          <> "to pay for spins 17–20, which cost 500 to 2,000 points. "
          <> "Landing 3, 4, or 5 jokers in one spin pays 1,000 / 2,500 / "
          <> "10,000, and a full card is worth up to 11,000 — the faster, "
          <> "the fatter."
      , H.button_ [ HP.class_ "btn", HE.onClick CloseHelp ] [ text "GOT IT" ]
      ]
  ]
  where
    sec s = H.div_ [ HP.class_ "helpSec" ] [ text s ]
    para s = H.p_ [ HP.class_ "helpP" ] [ text s ]
    legend g caption = H.div_ [ HP.class_ "legendRow" ]
      [ H.div_ [ HP.class_ "legendCell" ] [ text g ]
      , H.span_ [ HP.class_ "helpCap" ] [ text caption ]
      ]
-----------------------------------------------------------------------------
joinCls :: [MisoString] -> MisoString
joinCls = mconcat . map (<> " ")
-----------------------------------------------------------------------------
clsWhen :: Bool -> MisoString -> MisoString
clsWhen True c = c
clsWhen False _ = ""
