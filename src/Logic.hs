-----------------------------------------------------------------------------
-- | Pure slingo rules: card generation and reel rolls from a
-- deterministic randomness supply, line detection, and board helpers.
-----------------------------------------------------------------------------
module Logic where
-----------------------------------------------------------------------------
import           Data.List (find, intercalate, sortOn)
-----------------------------------------------------------------------------
import           Miso.String (MisoString, ms)
-----------------------------------------------------------------------------
import           Model
-----------------------------------------------------------------------------
-- * Geometry
-----------------------------------------------------------------------------
rowOf, colOf :: Int -> Int
rowOf i = i `div` 5
colOf i = i `mod` 5
-----------------------------------------------------------------------------
-- | The 12 scoring lines: rows 0-4, columns 5-9, diagonal 10, anti 11.
lineCells :: Int -> [Int]
lineCells l
  | l < 5     = [ l * 5 + c | c <- [0 .. 4] ]
  | l < 10    = [ r * 5 + (l - 5) | r <- [0 .. 4] ]
  | l == 10   = [ 0, 6, 12, 18, 24 ]
  | otherwise = [ 4, 8, 12, 16, 20 ]
-----------------------------------------------------------------------------
lineCount :: Int
lineCount = 12
-----------------------------------------------------------------------------
-- | Indices of fully marked lines.
completedLines :: [Bool] -> [Int]
completedLines mk = [ l | l <- [0 .. 11], all (mk !!) (lineCells l) ]
-----------------------------------------------------------------------------
-- * Card generation
-----------------------------------------------------------------------------
-- | Column @c@ draws from @15c+1 .. 15c+15@, bingo style.
columnRange :: Int -> [Int]
columnRange c = [ 15 * c + 1 .. 15 * c + 15 ]
-----------------------------------------------------------------------------
shuffleWith :: [Double] -> [a] -> [a]
shuffleWith keys xs = map snd (sortOn fst (zip keys xs))
-----------------------------------------------------------------------------
-- | Doubles needed by 'makeCard' and by one 'rollReels'.
cardSupply, spinSupply :: Int
cardSupply = 75
spinSupply = 10
-----------------------------------------------------------------------------
-- | 25 numbers, row-major: each column picks 5 from its range.
makeCard :: [Double] -> [Int]
makeCard supply = [ picks !! colOf i !! rowOf i | i <- [0 .. 24] ]
  where
    picks =
      [ take 5 (shuffleWith ks (columnRange c))
      | (c, ks) <- zip [0 .. 4] (chunksOf 15 supply)
      ]
-----------------------------------------------------------------------------
chunksOf :: Int -> [a] -> [[a]]
chunksOf _ [] = []
chunksOf n xs = take n xs : chunksOf n (drop n xs)
-----------------------------------------------------------------------------
-- * The reels
-----------------------------------------------------------------------------
-- | Roll the five reels: two doubles per reel, one for the symbol
-- class and one for the number pick. Odds: 65% number, 10% joker,
-- 3% super joker, 4% free spin, 8% coin, 6% devil, 4% cherub.
rollReels :: [Double] -> [Symbol]
rollReels supply =
  [ roll c cat pick
  | (c, [cat, pick]) <- zip [0 .. 4] (chunksOf 2 (take spinSupply supply))
  ]
  where
    roll c cat pick
      | cat < 0.65 = Number (15 * c + 1 + min 14 (floor (pick * 15) :: Int))
      | cat < 0.75 = Joker
      | cat < 0.78 = SuperJoker
      | cat < 0.82 = FreeSpin
      | cat < 0.90 = Coin
      | cat < 0.96 = Devil
      | otherwise  = Cherub
-----------------------------------------------------------------------------
-- | The 1994 reels: no cherub faces (the cherub is an event that saves
-- you from a landed devil), and only the center reel can go super.
-- Odds: 68% number, 12% joker (center: 8% joker, 4% super), 5% free
-- spin, 8% coin, 7% devil.
classicRollReels :: [Double] -> [Symbol]
classicRollReels supply =
  [ roll c cat pick
  | (c, [cat, pick]) <- zip [0 .. 4] (chunksOf 2 (take spinSupply supply))
  ]
  where
    roll c cat pick
      | cat < 0.68 = Number (15 * c + 1 + min 14 (floor (pick * 15) :: Int))
      | cat < 0.80 = if c == 2 && cat >= 0.76 then SuperJoker else Joker
      | cat < 0.85 = FreeSpin
      | cat < 0.93 = Coin
      | otherwise  = Devil
-----------------------------------------------------------------------------
-- * Classic scoring tables
-----------------------------------------------------------------------------
-- | Three or more jokers in one spin (super jokers count).
jokerBonus :: Int -> Int
jokerBonus n
  | n >= 5    = 10000
  | n == 4    = 2500
  | n == 3    = 1000
  | otherwise = 0
-----------------------------------------------------------------------------
-- | Clearing the whole card, graded by the spin it happened on.
fullCardBonus :: Int -> Int
fullCardBonus n
  | n <= 12   = 11000
  | n == 13   = 10000
  | n == 14   = 9000
  | n == 15   = 8500
  | n == 16   = 8000
  | n == 17   = 7500
  | n == 18   = 7000
  | n == 19   = 6500
  | otherwise = 6000
-----------------------------------------------------------------------------
-- | The last four spins must be bought (a held free spin pays instead).
spinFee :: Int -> Int
spinFee n
  | n >= 17 && n <= 20 = 500 * (n - 16)
  | otherwise          = 0
-----------------------------------------------------------------------------
-- * Variant-aware tuning
-----------------------------------------------------------------------------
markPointsV, slingoPointsV, coinPointsV :: Variant -> Int
markPointsV   Modern = markPoints
markPointsV   Classic = classicMarkPoints
slingoPointsV Modern = slingoPoints
slingoPointsV Classic = classicSlingoPoints
coinPointsV   Modern = coinPoints
coinPointsV   Classic = classicCoinPoints
-----------------------------------------------------------------------------
-- * Board helpers
-----------------------------------------------------------------------------
-- | Where number @n@ sits in column @c@ of the card, if anywhere.
findCell :: [Int] -> Int -> Int -> Maybe Int
findCell crd c n = find (\i -> colOf i == c && crd !! i == n) [0 .. 24]
-----------------------------------------------------------------------------
markCells :: [Int] -> [Bool] -> [Bool]
markCells is mk = [ b || i `elem` is | (i, b) <- zip [0 ..] mk ]
-----------------------------------------------------------------------------
-- | Open tiles a wild may mark.
eligible :: Wild -> [Bool] -> [Int]
eligible w mk = case w of
  ColWild c -> [ i | i <- open, colOf i == c ]
  AnyWild   -> open
  where
    open = [ i | (i, False) <- zip [0 ..] mk ]
-----------------------------------------------------------------------------
-- * Display helpers
-----------------------------------------------------------------------------
fmtScore :: Int -> MisoString
fmtScore n = ms (reverse (intercalate "," (chunksOf 3 (reverse (show n)))))
-----------------------------------------------------------------------------
bannerFor :: Int -> MisoString
bannerFor 1 = "SLINGO!"
bannerFor 2 = "DOUBLE SLINGO!"
bannerFor 3 = "TRIPLE SLINGO!"
bannerFor _ = "MEGA SLINGO!"
-----------------------------------------------------------------------------
-- | 0 to 5 stars for the final screen.
starsFor :: Int -> Int
starsFor s = length (takeWhile (<= s) [600, 1500, 2800, 4500, 7000])
-----------------------------------------------------------------------------
starsForV :: Variant -> Int -> Int
starsForV Modern s = starsFor s
starsForV Classic s =
  length (takeWhile (<= s) [8000, 16000, 28000, 45000, 70000])
