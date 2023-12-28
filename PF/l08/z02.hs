{-# LANGUAGE InstanceSigs #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use <&>" #-}
{-# HLINT ignore "Use >=>" #-}
{-# LANGUAGE LambdaCase #-}
{-# OPTIONS_GHC -Wno-noncanonical-monad-instances #-}
{-# HLINT ignore "Use when" #-}

import qualified Data.Char as DC
import GHC.TopHandler (runIO)
import GHC.IO.Handle (isEOF)
import Control.Monad ( ap, foldM )

-- task 2 ----------------------------------

data StreamTrans i o a
    = Return a
    | ReadS (Maybe i -> StreamTrans i o a)
    | WriteS o (StreamTrans i o a)
    -- deriving Show

nextStep :: Maybe Char -> StreamTrans Char Char ()
nextStep Nothing  = Return () 
nextStep (Just x) = WriteS (DC.toLower x) toLower

toLower :: StreamTrans Char Char ()
toLower = ReadS nextStep

runIOStreamTrans :: StreamTrans Char Char a -> IO a
runIOStreamTrans (Return a)   = return a
runIOStreamTrans (ReadS cont) = do
    done <- isEOF
    if done then
        runIOStreamTrans (cont Nothing)
    else do
        c <- getChar
        runIOStreamTrans $ cont (Just c)
runIOStreamTrans (WriteS o s) = do 
    putChar o
    runIOStreamTrans s

-- runIOStreamTrans toLower 


-- task 3 ----------------------------------

listTrans :: StreamTrans i o a -> [i] -> ([o], a)
listTrans (Return a) _        = ([], a)
listTrans (ReadS cont) []     = listTrans (cont Nothing) []
listTrans (ReadS cont) (x:xs) = listTrans (cont (Just x)) xs
listTrans (WriteS o s) xs     = 
    let (os, a) = listTrans s xs in
        (o:os, a)

-- take 3 $ fst $ listTrans toLower ['A'..]
-- take 3 $ fst $ listTrans toLower (repeat 'A')


-- task 4 ----------------------------------

-- [a] - list of items from output, waiting to be redirected
runCycleAux :: [a] -> StreamTrans a a b -> b
runCycleAux _ (Return b)   = b
runCycleAux xs (WriteS o s) = runCycleAux (xs ++ [o]) s
runCycleAux [] (ReadS cont) = runCycleAux [] $ cont Nothing
runCycleAux (x:xs) (ReadS cont) = 
    runCycleAux xs $ cont (Just x)

runCycle :: StreamTrans a a b -> b
runCycle = runCycleAux []

-- testt = WriteS 42 $ ReadS $ Return 
-- testt = ReadS $ const $ WriteS 42 $ Return ()
-- runCycle testt


-- task 5 ----------------------------------

(|>|) :: StreamTrans i m a -> StreamTrans m o b -> StreamTrans i o b
(|>|) (WriteS o s1) (ReadS cont) = 
    s1 |>| cont (Just o)
(|>|) s1 (Return b) = 
    Return b
(|>|) s1 (WriteS o s2) = 
    WriteS o (s1 |>| s2)
(|>|) (ReadS c1) s = 
    ReadS (\ c -> c1 c |>| s)
(|>|) (Return a) (ReadS cont) = 
    (|>|) (Return a) (cont Nothing)

-- runIOStreamTrans (toLower |>| toLower )


-- task 6 ----------------------------------

catchOutputAux :: [o] -> StreamTrans i o a -> StreamTrans i b (a, [o])
catchOutputAux os (Return a)   = Return (a, os)
catchOutputAux os (WriteS o s) = catchOutputAux (os ++ [o]) s
catchOutputAux os (ReadS cont) = 
    ReadS $ catchOutputAux os . cont

catchOutput :: StreamTrans i o a -> StreamTrans i b (a, [o])
catchOutput = catchOutputAux []


-- task 9 - monads -------------------------

instance Functor (StreamTrans i o) where
  fmap :: (a -> b) -> StreamTrans i o a -> StreamTrans i o b
  fmap f m = m >>= return . f

instance Applicative (StreamTrans i o) where
  pure :: a -> StreamTrans i o a
  pure = return
  (<*>) :: StreamTrans i o (a -> b) -> StreamTrans i o a -> StreamTrans i o b
  (<*>) = ap

instance Monad (StreamTrans i o) where
  return :: a -> StreamTrans i o a
  return = Return

  (>>=) :: StreamTrans i o a -> (a -> StreamTrans i o b) -> StreamTrans i o b
  (Return a) >>= f   = f a
  (WriteS o s) >>= f = WriteS o $ s >>= f
  (ReadS cont) >>= f = ReadS (\ c -> cont c >>= f)
    

-- task 7 - brainfuck abstract syntax -----------

data BF
    = MoveR -- >
    | MoveL -- <
    | Inc -- +
    | Dec -- -
    | Output -- .
    | Input -- ,
    | While [BF] -- [ ]
    deriving Show

next :: Bool -> StreamTrans Char BF ()
next = ReadS . parseTokenBF

-- bool : do we have open bracket?
parseTokenBF :: Bool -> Maybe Char -> StreamTrans Char BF ()
parseTokenBF b Nothing    = 
    if b then error "unclosed bracket"
    else return ()
parseTokenBF b (Just '>') = WriteS MoveR $ next b
parseTokenBF b (Just '<') = WriteS MoveL $ next b
parseTokenBF b (Just '+') = WriteS Inc $ next b
parseTokenBF b (Just '-') = WriteS Dec $ next b
parseTokenBF b (Just '.') = WriteS Output $ next b
parseTokenBF b (Just ',') = WriteS Input $ next b
parseTokenBF b (Just '[') = do
    bf <- catchOutput (next True)
    WriteS (While $ snd bf) $ next b
parseTokenBF False (Just ']') = error "unexpected ]"
parseTokenBF True (Just ']')  = return ()
parseTokenBF b _ = next b


brainfuckParser :: StreamTrans Char BF ()
brainfuckParser = next False

-- fst $ listTrans brainfuckParser "<[+[<>+[--]abc]>+s,.]"


-- task 8 - brainfuck interpreter -----------

type Tape = ([Integer], [Integer])

coerceEnum :: (Enum a, Enum b) => a -> b
coerceEnum = toEnum . fromEnum


evalBF :: Tape -> BF -> StreamTrans Char Char Tape
evalBF (xs, y:ys) MoveR = return (y:xs, ys)
evalBF (xs, y:ys) Inc = return (xs, (y+1):ys)
evalBF (xs, y:ys) Dec = return (xs, (y-1):ys)
evalBF (xs, y:ys) Output = 
    WriteS (coerceEnum y) $ return (xs, y:ys)
evalBF (xs, y:ys) Input = 
    ReadS (\case 
        Nothing -> return (xs, y:ys)
        Just a -> return (xs, coerceEnum a:ys))
evalBF (xs,y:ys) (While bf) = 
    if y == 0 then return (xs,y:ys)
    else do 
        tape <- evalBFBlock (xs, y:ys) bf 
        evalBF tape (While bf)
evalBF (x:xs, ys) MoveL = 
    return (xs, x:ys)
evalBF (xs, ys) _ = return (xs,ys)


evalBFBlock :: Tape -> [BF] -> StreamTrans Char Char Tape
evalBFBlock = foldM evalBF 


runBF :: [BF] -> StreamTrans Char Char ()
runBF [] = return ()
runBF xs = do
    tape <- evalBFBlock (repeat 0, repeat 0) xs 
    return ()

-- test

printStringBF :: [Char] -> [Char]
printStringBF = 
    concatMap (\c -> replicate (coerceEnum c) '+' ++ "." ++ replicate (coerceEnum c) '-')

bfHelloWorld :: [Char]
bfHelloWorld = printStringBF "Hello world!\n"

bf1 :: [Char]
bf1 = "+[+>>]."

bf2 :: [Char]
bf2 = replicate 97 '+' ++ ".>" ++ replicate 98 '+' ++ ".>,.>"

bf3 :: [Char]
bf3 = ",+." 

main :: IO ()
main = do
    runIOStreamTrans (runBF (fst . listTrans brainfuckParser $ bfHelloWorld))


-- runIOStreamTrans (runBF (fst . (listTrans brainfuckParser) $ bf1))
-- runIOStreamTrans (runBF (fst . (listTrans brainfuckParser) $ bf2))
-- runIOStreamTrans (runBF (fst . (listTrans brainfuckParser) $ bf3))
-- runIOStreamTrans (runBF (fst . (listTrans brainfuckParser) $ bfHelloWorld))


-- debugging ------------------------------

printTape :: Tape -> IO ()
printTape (xs, ys) = print (take 10 xs, take 10 ys)

test :: Tape -> [BF] -> Tape
test tape bf = 
    let (xs, ys) = snd (listTrans (evalBFBlock tape bf) []) in
        (take 10 xs, take 10 ys)

printStreamTrans :: Show o => StreamTrans i o Tape -> IO ()
printStreamTrans (Return a) = printTape a
printStreamTrans (ReadS cont) = do
    print "ReadS"
    printStreamTrans $ cont Nothing
printStreamTrans (WriteS o s) = do
    print "WriteS"
    print o
    printStreamTrans s

test1 :: [Char] -> IO ()
test1 bf = printStreamTrans  $ evalBFBlock (repeat 0, repeat 0) (fst . listTrans brainfuckParser $ bf)

-- printStreamTrans  $ evalBFBlock (repeat 0, repeat 0) (fst . (listTrans brainfuckParser) $ "+[+>>]."))
-- test (repeat 0, repeat 0) (fst . (listTrans brainfuckParser) $ "+[+>]")