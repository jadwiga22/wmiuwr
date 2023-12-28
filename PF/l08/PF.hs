module PF where

sort :: Ord a => [a] -> [a]
sort [] = []
sort [x] = [x]
sort (x:xs) = sort [y | y <- xs, y < x] ++ [x] ++ sort [y | y <- xs, y >= x]