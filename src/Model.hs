-----------------------------------------------------------------------------
{-# LANGUAGE TemplateHaskell #-}
-----------------------------------------------------------------------------
-- | Core types for miso-slingo, with lenses via "Miso.Lens.TH".
-----------------------------------------------------------------------------
module Model where
-----------------------------------------------------------------------------
import           Data.IntSet (IntSet)
import qualified Data.IntSet as IS
-----------------------------------------------------------------------------
import           Miso.Lens.TH (makeLenses)
import           Miso.String (MisoString)
-----------------------------------------------------------------------------
-- | Which table you're seated at: the modern neon game, or a faithful
-- clone of the 1994 AOL classic (see 'Logic.classicRollReels' and the
-- classic tuning below).
data Variant = Modern | Classic
  deriving (Eq, Show)
-----------------------------------------------------------------------------
-- | One face of a slot reel.
data Symbol
  = Number Int -- ^ a number from the reel's column range
  | Joker      -- ^ wild: mark any open tile in this column
  | SuperJoker -- ^ wild: mark any open tile anywhere
  | FreeSpin   -- ^ one spin back
  | Coin       -- ^ instant points
  | Devil      -- ^ halves your score, unless a cherub guards
  | Cherub     -- ^ guards against the next devil
  deriving (Eq, Show)
-----------------------------------------------------------------------------
-- | A wild waiting for the player to pick a tile.
data Wild = ColWild Int | AnyWild
  deriving (Eq, Show)
-----------------------------------------------------------------------------
-- | What a reel window is showing.
data Reel = Blank | Whirl | Face Symbol
  deriving (Eq, Show)
-----------------------------------------------------------------------------
data Phase
  = Title
  | Playing
  | Over Bool -- ^ 'True' when the whole card was filled
  deriving (Eq, Show)
-----------------------------------------------------------------------------
-- | What the table is doing while 'Playing'.
data Stage = Idle | Spinning | Picking
  deriving (Eq, Show)
-----------------------------------------------------------------------------
data Model = Model
  { _variant   :: Variant
  , _card      :: [Int]      -- ^ 25 numbers, row-major
  , _marked    :: [Bool]     -- ^ 25 marks, row-major
  , _reels     :: [Reel]     -- ^ 5 reel windows
  , _pending   :: [Symbol]   -- ^ this spin's symbols, revealed one by one
  , _spins     :: Int        -- ^ spins left
  , _spinsUsed :: Int
  , _score     :: Int
  , _slingos   :: [Int]      -- ^ completed line indices (see 'lineCells')
  , _wilds     :: [Wild]     -- ^ wild picks owed to the player
  , _guards    :: Int        -- ^ cherubs in hand (modern only)
  , _freeHeld  :: Int        -- ^ free spins in hand (classic: fee waivers)
  , _cherubSave :: Bool      -- ^ classic: this spin's cherub is on duty
  , _devilsHit :: Int
  , _phase     :: Phase
  , _stage     :: Stage
  , _toast     :: MisoString -- ^ one-line commentary under the reels
  , _banner    :: Maybe MisoString -- ^ the big SLINGO! slam
  , _bannerAlt :: Bool       -- ^ parity remounts the slam animation
  , _popup     :: Maybe MisoString -- ^ classic devil/cherub cartoon
  , _popupAlt  :: Bool       -- ^ parity remounts the popup animation
  , _flash     :: [Int]      -- ^ tiles of freshly completed lines
  , _fresh     :: [Int]      -- ^ tiles marked since the last spin
  , _soundOn   :: Bool
  , _showHelp  :: Bool
  , _heldKeys  :: IntSet     -- ^ previous keyboard state, for edge detect
  } deriving (Eq, Show)
-----------------------------------------------------------------------------
makeLenses ''Model
-----------------------------------------------------------------------------
data Action
  = NoOp
  | Play Variant
  | CardReady [Int]
  | NewGame
  | Spin
  | Spun [Symbol] Bool -- ^ the spin's faces, and the cherub-save roll
  | StopReel Int
  | Resolve
  | PickCell Int
  | ToggleSound
  | ShowHelp
  | CloseHelp
  | Keys IntSet
-----------------------------------------------------------------------------
initialModel :: Model
initialModel = Model
  { _variant   = Modern
  , _card      = replicate 25 0
  , _marked    = replicate 25 False
  , _reels     = replicate 5 Blank
  , _pending   = []
  , _spins     = startSpins
  , _spinsUsed = 0
  , _score     = 0
  , _slingos   = []
  , _wilds     = []
  , _guards    = 0
  , _freeHeld  = 0
  , _cherubSave = False
  , _devilsHit = 0
  , _phase     = Title
  , _stage     = Idle
  , _toast     = "hit SPIN to start"
  , _banner    = Nothing
  , _bannerAlt = False
  , _popup     = Nothing
  , _popupAlt  = False
  , _flash     = []
  , _fresh     = []
  , _soundOn   = True
  , _showHelp  = False
  , _heldKeys  = IS.empty
  }
-----------------------------------------------------------------------------
-- * Tuning
-----------------------------------------------------------------------------
startSpins :: Int
startSpins = 20
-----------------------------------------------------------------------------
markPoints, slingoPoints, coinPoints, fullCardPoints, spareSpinPoints :: Int
markPoints      = 20
slingoPoints    = 200
coinPoints      = 50
fullCardPoints  = 1000
spareSpinPoints = 100
-----------------------------------------------------------------------------
-- Classic (1994 AOL) values, per the archived Encyclopedia Gamia
-- scoring table.
classicMarkPoints, classicSlingoPoints, classicCoinPoints :: Int
classicMarkPoints   = 200
classicSlingoPoints = 1000
classicCoinPoints   = 1000
-----------------------------------------------------------------------------
-- | How often the cherub shows up to shoot a landed devil.
classicCherubChance :: Double
classicCherubChance = 0.5
