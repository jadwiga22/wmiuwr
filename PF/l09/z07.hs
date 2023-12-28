{-# LANGUAGE FlexibleContexts, FlexibleInstances, FunctionalDependencies #-}
{-# LANGUAGE LambdaCase #-}
{-# OPTIONS_GHC -Wno-noncanonical-monad-instances #-}

import Control.Monad
import Control.Monad.State.Lazy
import Control.Monad.Cont


class (Monad m) => BFMonad m where
    -- tapes 
    tapeGet :: m Integer
    tapePut :: Integer -> m ()
    moveLeft :: m ()
    moveRight :: m ()

    -- reading from input
    readInp :: m Char

    -- printing to ouput
    printOut :: Char -> m ()

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


evalBF :: BFMonad m => [BF] -> m ()
evalBF [] = return ()
evalBF (b:bf) = case b of
    MoveR -> do
        moveRight
        evalBF bf
    MoveL -> do
        moveLeft
        evalBF bf
    Inc -> do
        t <- tapeGet
        tapePut (t+1)
        evalBF bf 
    Dec -> do
        t <- tapeGet
        tapePut (t-1)
        evalBF bf 
    Input -> do
        c <- readInp
        tapePut $ coerceEnum c
        evalBF bf
    Output -> do
        t <- tapeGet
        printOut $ coerceEnum t
        evalBF bf 
    While bfs -> do
        t <- tapeGet
        if t == 0 then
            evalBF bf 
        else do
            evalBF bfs
            evalBF (b:bf)

newtype IOState s x = IOState { unIOState :: s -> IO (s, x) }

instance Functor (IOState s) where
  fmap f m = m >>= return . f

instance Applicative (IOState s) where
  pure = return
  (<*>) = ap

instance Monad (IOState s) where
    return :: x -> IOState s x
    return x = IOState (\ s -> return (s, x))

    (>>=) :: IOState s x -> (x -> IOState s y) -> IOState s y
    m >>= f = 
        IOState $ \s -> do
            (s, x) <- unIOState m s
            (unIOState $ f x) s


instance BFMonad (IOState ([Integer], [Integer])) where
    tapeGet = IOState $ \ (s1, s2) -> do
        case s2 of
            [] -> error "empty tape!"
            y:s2 -> return ((s1, y:s2), y)
    tapePut x = IOState $ \ (s1, s2) -> do
        case s2 of
            [] -> return  ((s1, s2), ())
            y:s2 -> return ((s1, x:s2), ())

    moveLeft = IOState $ \ (s1, s2) -> do
        case s1 of
            [] -> return ((s1, s2), ())
            s:s1 -> return ((s1, s:s2), ())
    moveRight = IOState $ \ (s1, s2) -> do
        case s2 of
            [] -> return ((s1, s2), ())
            s:s2 -> return ((s:s1, s2), ())

    readInp = IOState $ \ s -> do
        c <- getChar
        return (s, c)

    printOut c = IOState $ \ s -> do
        putChar c
        return (s, ()) 

startTape :: ([Integer], [Integer])
startTape = (repeat 0, repeat 0)

runBF :: [BF] -> IO ()
runBF bf = fmap snd $ (unIOState $ evalBF bf) startTape

bf1 :: [BF]
bf1 = [Input,Inc,Output]

bf2 :: [BF]
bf2 = [Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Output,MoveR,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Inc,Output,MoveR,Input,Output,MoveR]

-- -- runBF bf1 
-- -- runBF bf2 
