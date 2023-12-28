{-# LANGUAGE FlexibleContexts, FlexibleInstances, FunctionalDependencies #-}
{-# OPTIONS_GHC -Wno-noncanonical-monad-instances #-}
{-# LANGUAGE LambdaCase #-}
import Control.Monad

class Monad m => TwoPlayerGame m s a b | m -> s a b where
    moveA :: s -> m a
    moveB :: s -> m b

data Score = AWins | Draw | BWins deriving Show
newtype PosGame = PosGame (Int, Int)
type AMove = PosGame
type BMove = PosGame
newtype Board = Board ([[Int]], Int) 

printRow :: [Int] -> [Char]
printRow = map (\case
    -1 -> 'X'
    1 -> 'O'
    0 -> '.'
    _ -> error "unknown character") 

instance Show Board where
    show (Board (b, n)) = 
        foldl (\acc row -> acc ++ printRow row ++ "\n") [] b

instance Read PosGame where
  readsPrec s str = [(PosGame x, rest) | (x,rest) <- readsPrec s str]


-- tic tac toe logic

rowMaxABSSum :: Board -> Int
rowMaxABSSum (Board (b, n)) = foldl (\ acc r -> max acc $ abs (sum r)) 0 b

nthColSum :: Int -> Board -> Int
nthColSum k (Board (b, n)) = foldl (\acc r -> acc + r!!k) 0 b

colMaxABSSum :: Board -> Int
colMaxABSSum board@(Board (b, n)) = 
    foldl (\acc k -> max acc $ abs (nthColSum k board)) 0 [0..(n-1)]

diagSum :: (Int -> Int) -> Board -> Int
diagSum elt (Board (b, n)) = 
    foldl (\acc rn -> acc + (b!!rn)!!elt rn) 0 [0..(n-1)]

diagLSum :: Board -> Int
diagLSum = diagSum id 

diagRSum :: Board -> Int
diagRSum board@(Board (b, n)) = diagSum (\x -> (n-1) - x) board

result :: Board -> Bool 
result board@(Board (b, n)) = 
    foldl (\a acc -> max acc (abs a)) 0 
    [rowMaxABSSum board, colMaxABSSum board, diagLSum board, diagRSum board] == n

replaceNth :: Int -> a -> [a] -> [a]
replaceNth n a xs = map 
    (\k -> if k == n then a else do xs!!k) [0..(length xs -1)]

changeBoard :: PosGame -> Int -> Board -> Maybe Board
changeBoard (PosGame (x, y)) player board@(Board (b, n)) = 
    if x < 0 || x >= n || y < 0 || y >= n then
        Nothing
    else do
        if (b!!x)!!y == 0 then
            Just $ Board (replaceNth x (replaceNth y player (b!!x)) b, n)
        else do
            Nothing

fullBoard :: Board -> Bool
fullBoard (Board (b,n)) = 
    all (all (0 /=)) b

-- changeBoard 1 1 Board ([[0,0,0],[0,0,0],[0,0,0]],3)


-- recursively playing rounds of the game
gameRound :: TwoPlayerGame m Board AMove BMove => Board -> m Score
gameRound bo = do
    a <- moveA bo
    let boarda = changeBoard a 1 bo in
        case boarda of
            Nothing -> return BWins
            Just boarda ->
                if result boarda then
                    return AWins
                else do
                    if fullBoard boarda then
                        return Draw
                    else do
                        b <- moveB boarda
                        let boardb = changeBoard b (-1) boarda in
                            case boardb of
                                Nothing -> return AWins
                                Just boardb ->
                                    if result boardb then
                                        return BWins
                                    else do
                                        gameRound boardb



-- task 2

newtype IOGame s a b x = IOGame { runIOGame :: IO x }

instance Functor (IOGame s a b) where
  fmap f m = m >>= return . f

instance Applicative (IOGame s a b) where
  pure = return
  (<*>) = ap

instance Monad (IOGame s a b) where
    return :: x -> IOGame s a b x
    return x = IOGame $ return x

    (>>=) :: IOGame s a b x -> (x -> IOGame s a b y) -> IOGame s a b y
    m@(IOGame {runIOGame = r}) >>= f = 
        IOGame $ do
            x <- r
            runIOGame $ f x

instance (Show s, Read a, Read b) => TwoPlayerGame (IOGame s a b) s a b where
    moveA :: Show s => s -> (IOGame s a b) a
    moveA board = IOGame $ do
        print board
        print "Player A move: (row,col)"
        readLn
    moveB :: Show s => s -> (IOGame s a b) b
    moveB board = IOGame $ do 
        print board
        print "Player B move: (row,col)"
        readLn

game :: TwoPlayerGame m Board AMove BMove => m Score
game = gameRound $ Board (replicate 3 $ replicate 3 0 , 3)


playGame ::(IOGame Board AMove BMove) Score -> IO ()
playGame (IOGame {runIOGame = r}) = do
    s <- r
    print s 

assert :: a -> Bool -> a
assert x False = error "assertion failed!"
assert x _  = x


testBoard1 :: Board
testBoard1 = Board ([[3,1,5], [5,6,10], [-3,-7,-20]], 3)

tests :: [Bool]
tests = [assert True $ rowMaxABSSum testBoard1 == 30,
         assert True $ colMaxABSSum testBoard1 == 5, 
         assert True $ nthColSum 0 testBoard1 == 5,
         assert True $ nthColSum 1 testBoard1 == 0,
         assert True $ nthColSum 2 testBoard1 == -5, 
         assert True $ diagLSum testBoard1 == -11,
         assert True $ diagRSum testBoard1 == 8,
         assert True $ replaceNth 1 'a' ['a', 'b', 'c'] == "aac"]

test :: Bool
test = and tests


-- changeBoard :: Move -> Integer -> Board -> Board
-- changeBoard None _ b = b
-- changeBoard Cross n b 
    







