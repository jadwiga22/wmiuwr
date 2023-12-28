import Data.Char
import GHC.IO.Handle (isEOF)

echoLower :: IO ()
echoLower = do
    done <- isEOF
    if done then
        return ()
    else do
        c <- getChar
        putChar $ toLower c 
        echoLower