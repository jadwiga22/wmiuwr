-- task 9 - monads -------------------------
{-# LANGUAGE FlexibleContexts, FlexibleInstances, FunctionalDependencies #-}
{-# LANGUAGE LambdaCase #-}
{-# OPTIONS_GHC -Wno-noncanonical-monad-instances #-}

import Control.Monad
import Control.Monad.State.Lazy


class Monad m => TapeMonad m a | m -> a where
    tapeGet :: m a
    tapePut :: a -> m ()
    moveLeft :: m ()
    moveRight :: m ()

data BF
    = MoveR -- >
    | MoveL -- <
    | Inc -- +
    | Dec -- -
    | Output -- .
    | Input -- ,
    | While [BF] -- [ ]
    deriving Show


coerceEnum :: (Enum a, Enum b) => a -> b
coerceEnum = toEnum . fromEnum


-- returns pair of lists: (left for input, output)
evalBFAux :: TapeMonad m Integer => [BF] -> [Char] -> m ([Char], [Char])
evalBFAux [] cs = return (cs, [])
evalBFAux (b:bf) cs = case b of
    MoveR -> do
        moveRight
        evalBFAux bf cs
    MoveL -> do
        moveLeft
        evalBFAux bf cs
    Inc -> do
        t <- tapeGet
        tapePut (t+1)
        evalBFAux bf cs
    Dec -> do
        t <- tapeGet
        tapePut (t-1)
        evalBFAux bf cs
    Input ->
        case cs of
            [] -> error "empty input!"
            (c:cs) -> do
                tapePut $ coerceEnum c
                evalBFAux bf cs
    Output -> do
        t <- tapeGet
        res <- evalBFAux bf cs
        return (fst res, coerceEnum t : snd res)
    While [bfs] -> do
        t <- tapeGet
        if t == 0 then
            evalBFAux bf cs
        else do
            (i,o)   <- evalBFAux [bfs] cs
            (i',o') <- evalBFAux (b:bf) i
            return (i', o ++ o')


evalBF :: TapeMonad m Integer => [BF] -> [Char] -> m [Char]
evalBF bf cs = do
    (i,o) <- evalBFAux bf cs
    return o

type Tape = ([Integer], [Integer])
instance TapeMonad (State ([Integer], [Integer])) Integer where
    tapeGet = do
        (s1, s2) <- get
        case s2 of
            [] -> error "empty tape!"
            y:s2 -> return y
    tapePut x = do
        (s1, s2) <- get
        case s2 of
            [] -> put (s1, [])
            y:s2 -> put (s1, x:s2)

    moveLeft = do
        (s1, s2) <- get
        case s1 of
            [] -> put (s1, s2)
            s:s1 -> put (s1, s:s2)
    moveRight = do
        (s1, s2) <- get
        case s2 of
            [] -> put (s1, s2)
            s:s2 -> put (s:s1, s2)

startTape :: ([Integer], [Integer])
startTape = (repeat 0, repeat 0)

runBF :: [BF] -> [Char] -> [Char]
runBF bf cs = evalState (evalBF bf cs) startTape

bf1 :: [BF]
bf1 = [Input,Inc,Output]

bf2 :: [BF]
bf2 = [Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Output,MoveR,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Output,MoveR,Input,Output,MoveR]

-- runBF bf1 "a"
-- runBF bf2 "f"
