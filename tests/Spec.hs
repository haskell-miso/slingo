-----------------------------------------------------------------------------
-- | Native correctness tests: line geometry, card generation, reel
-- rolls, and the board helpers.
-----------------------------------------------------------------------------
module Main where
-----------------------------------------------------------------------------
import           Control.Monad (forM_, unless)
import           Data.IORef
import           Data.List (nub, sort)
import           System.Exit (exitFailure)
-----------------------------------------------------------------------------
import           Logic
import           Model
-----------------------------------------------------------------------------
main :: IO ()
main = do
  failures <- newIORef (0 :: Int)
  let check name ok = do
        putStrLn ((if ok then "  ok  " else " FAIL ") <> name)
        unless ok (modifyIORef failures (+ 1))

  -- lines ---------------------------------------------------------------
  check "12 lines of 5 cells, all on the card"
    (all (\l -> length (lineCells l) == 5
             && all (\i -> i >= 0 && i < 25) (lineCells l))
         [0 .. lineCount - 1])
  check "rows and columns partition the card"
    (sort (concatMap lineCells [0 .. 4]) == [0 .. 24]
      && sort (concatMap lineCells [5 .. 9]) == [0 .. 24])
  check "the center sits on four lines"
    (length [ l | l <- [0 .. 11], 12 `elem` lineCells l ] == 4)
  check "the diagonals cross at the center"
    (lineCells 10 == [0, 6, 12, 18, 24] && lineCells 11 == [4, 8, 12, 16, 20])

  -- card generation ------------------------------------------------------
  forM_ [1 .. 5 :: Int] $ \seed -> do
    let crd = makeCard (lcg seed)
        name s = "seed " <> show seed <> ": " <> s
    check (name "card has 25 cells") (length crd == 25)
    check (name "columns draw from their bingo ranges")
      (all (\i -> crd !! i `elem` columnRange (colOf i)) [0 .. 24])
    check (name "no column repeats a number")
      (all (\c -> let col = [ crd !! i | i <- [0 .. 24], colOf i == c ]
                  in length (nub col) == 5)
           [0 .. 4])

  -- reel rolls -----------------------------------------------------------
  check "rolled numbers stay in their column's range"
    (and [ n `elem` columnRange c
         | seed <- [1 .. 40]
         , (c, Number n) <- zip [0 ..] (rollReels (lcg seed))
         ])
  check "every spin fills five reels"
    (all (\seed -> length (rollReels (lcg seed)) == 5) [1 .. 40 :: Int])
  check "the class thresholds pick the right symbols"
    (rollReels (cycle [0.0, 0.0]) == [ Number (15 * c + 1) | c <- [0 .. 4] ]
      && rollReels (cycle [0.70, 0.5]) == replicate 5 Joker
      && rollReels (cycle [0.76, 0.5]) == replicate 5 SuperJoker
      && rollReels (cycle [0.80, 0.5]) == replicate 5 FreeSpin
      && rollReels (cycle [0.85, 0.5]) == replicate 5 Coin
      && rollReels (cycle [0.92, 0.5]) == replicate 5 Devil
      && rollReels (cycle [0.99, 0.5]) == replicate 5 Cherub)

  -- classic reels --------------------------------------------------------
  check "classic spins fill five reels with numbers in range"
    (all (\seed -> let syms = classicRollReels (lcg seed)
                   in length syms == 5
                        && and [ n `elem` columnRange c
                               | (c, Number n) <- zip [0 ..] syms ])
         [1 .. 40 :: Int])
  check "classic reels never show a cherub"
    (all (\seed -> Cherub `notElem` classicRollReels (lcg seed)) [1 .. 60])
  check "only the center reel goes super"
    (and [ c == 2
         | seed <- [1 .. 60]
         , (c, SuperJoker) <- zip [0 ..] (classicRollReels (lcg seed))
         ]
      && classicRollReels (cycle [0.78, 0.5])
           == [Joker, Joker, SuperJoker, Joker, Joker])
  check "the classic class thresholds pick the right symbols"
    (classicRollReels (cycle [0.0, 0.0]) == [ Number (15 * c + 1) | c <- [0 .. 4] ]
      && classicRollReels (cycle [0.70, 0.5]) == replicate 5 Joker
      && classicRollReels (cycle [0.82, 0.5]) == replicate 5 FreeSpin
      && classicRollReels (cycle [0.90, 0.5]) == replicate 5 Coin
      && classicRollReels (cycle [0.95, 0.5]) == replicate 5 Devil)

  -- classic scoring ------------------------------------------------------
  check "multi-joker bonus pays 1,000 / 2,500 / 10,000"
    (map jokerBonus [0 .. 5] == [0, 0, 0, 1000, 2500, 10000])
  check "full-card bonus follows the published table"
    (map fullCardBonus [5, 12, 13, 14, 15, 16, 17, 18, 19, 20]
      == [11000, 11000, 10000, 9000, 8500, 8000, 7500, 7000, 6500, 6000])
  check "spins 17-20 cost 500 to 2,000, the rest are free"
    (map spinFee [1, 16, 17, 18, 19, 20] == [0, 0, 500, 1000, 1500, 2000])
  check "variant tuning matches the classic values"
    (markPointsV Classic == 200
      && slingoPointsV Classic == 1000
      && coinPointsV Classic == 1000
      && markPointsV Modern == markPoints)
  check "classic star thresholds climb"
    (starsForV Classic 0 == 0 && starsForV Classic 8000 == 1
      && starsForV Classic 27999 == 2 && starsForV Classic 70000 == 5
      && starsForV Modern 7000 == starsFor 7000)

  -- board helpers --------------------------------------------------------
  let none = replicate 25 False
      full = replicate 25 True
      row0 = replicate 5 True ++ replicate 20 False
  check "an empty card completes nothing" (null (completedLines none))
  check "a full card completes all 12 lines"
    (completedLines full == [0 .. 11])
  check "one marked row is one slingo" (completedLines row0 == [0])
  check "markCells marks exactly the asked cells"
    (let mk = markCells [3, 17] none
     in [ i | (i, True) <- zip [0 ..] mk ] == [3, 17])
  check "a column wild only offers its column"
    (eligible (ColWild 2) row0 == [ i | i <- [5 .. 24], colOf i == 2 ])
  check "an any wild offers every open tile"
    (eligible AnyWild row0 == [5 .. 24])
  check "a wild on a full card offers nothing"
    (null (eligible AnyWild full) && null (eligible (ColWild 0) full))
  check "findCell agrees with the card"
    (let crd = makeCard (lcg 7)
     in all (\i -> findCell crd (colOf i) (crd !! i) == Just i) [0 .. 24]
          && findCell crd 0 (16 :: Int) == Nothing)

  -- display helpers ------------------------------------------------------
  check "fmtScore groups thousands"
    (fmtScore 0 == "0" && fmtScore 999 == "999"
      && fmtScore 1000 == "1,000" && fmtScore 1234567 == "1,234,567")
  check "star thresholds climb"
    (starsFor 0 == 0 && starsFor 600 == 1 && starsFor 2799 == 2
      && starsFor 7000 == 5)

  n <- readIORef failures
  if n == 0
    then putStrLn "\nAll tests passed."
    else do
      putStrLn ("\n" <> show n <> " test(s) failed.")
      exitFailure
-----------------------------------------------------------------------------
-- | Deterministic supply in [0, 1).
lcg :: Int -> [Double]
lcg seed =
  map (\x -> fromIntegral x / 2147483648)
      (drop 1 (iterate step (seed * 7919 + 13)))
  where
    step x = (1103515245 * x + 12345) `mod` 2147483648
