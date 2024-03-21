module Main where

import Data.Foldable (foldl')
import Data.List (elemIndex, nub, sort, sortBy)
import Data.Maybe (fromJust, mapMaybe)
import Data.Ord (Down (..), comparing)

data Point = Pt {x, y, z :: Integer} deriving (Eq)

instance Ord Point where
  a <= b = z a < z b || (z a == z b && y a < y b) || (z a == z b && y a == y b && x a <= x b)

data Brick = Br {brickId :: Int, left, right :: Point} deriving (Eq)

instance Ord Brick where
  a <= b = right a < right b || (right a == right b && left a <= left b)

splitOnce :: Char -> String -> (String, String)
splitOnce char s =
  let (first, second) = splitAt (fromJust (elemIndex char s)) s
   in (first, tail second)

parsePoint :: String -> Point
parsePoint s =
  let (pX, remY) = splitOnce ',' s
      (pY, pZ) = splitOnce ',' remY
   in Pt (read pX) (read pY) (read pZ)

parseBrick :: Int -> String -> Brick
parseBrick brId s =
  let (bLeft, bRight) = splitOnce '~' s
   in Br brId (parsePoint bLeft) (parsePoint bRight)

move :: [Brick] -> Brick -> [Brick]
move bricks brick =
  let Br brId l r = brick
      zLeft = 1 + maximum (0 : (map (z . right) . filter (collides brick)) bricks)
      zRight = z r - z l + zLeft
   in Br brId (Pt (x l) (y l) zLeft) (Pt (x r) (y r) zRight) : bricks

settle :: [Brick] -> [Brick]
settle = sortBy (comparing Down) . foldl' move [] . sort

rangeFrom :: Int -> [Int]
rangeFrom i = i : rangeFrom (i + 1)

parse :: String -> IO [Brick]
parse = fmap (settle . zipWith parseBrick (rangeFrom 0) . lines) . readFile

collides :: Brick -> Brick -> Bool
collides (Br _ (Pt xmin1 ymin1 _) (Pt xmax1 ymax1 _)) (Br _ (Pt xmin2 ymin2 _) (Pt xmax2 ymax2 _)) =
  ymax1 >= ymin2 && ymax2 >= ymin1 && xmax1 >= xmin2 && xmax2 >= xmin1

blockedBy :: [Brick] -> [[Brick]]
blockedBy [] = []
blockedBy (brick : bricks) = filter (collides brick) bricks : blockedBy bricks

blockedByOne :: [Brick] -> Maybe Brick
blockedByOne [single] = Just single
blockedByOne (first : second : _) | z (right first) > z (right second) = Just first
blockedByOne _ = Nothing

part1 :: [Brick] -> Int
part1 bricks = length bricks - (length . nub . mapMaybe blockedByOne . blockedBy) bricks

part2 :: [Brick] -> Int
part2 bricks =
  let movedBricks brick = (filter (`notElem` bricks) . settle . filter (/= brick)) bricks
   in length (concatMap movedBricks bricks)

main :: IO ()
main = do
  bricks <- parse "twentysecond.txt"
  putStrLn ("Part 1: " ++ show (part1 bricks))
  putStrLn ("Part 2: " ++ show (part2 bricks))
