{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Model.Health where

import           Data.Aeson.TH
import qualified Data.Time.Clock           as TM
import qualified Data.Time.LocalTime       as TM
import           Database.HDBC.Record
import           Database.HDBC.Session     (withConnectionCommit)
import           Database.Relational.Query as HRR
import           DataSource
import qualified Entity.Health             as E
import           GHC.Int
import           Language.SQL.Keyword

deriveJSON defaultOptions ''E.Healths

touchHealth :: IO E.Healths
touchHealth = do
  health <- getHealth
  _ <- updateHealth (E.id health)
  getHealth

getHealth :: IO E.Healths
getHealth = do
  conn <- connect
  healths <- runQuery' conn getHealthQuery ()
  return $ head healths

getHealthQuery :: Query () E.Healths
getHealthQuery = relationalQuery' (relation q) [LIMIT, word "1"]
  where
    q = do
      h <- query E.healths
      desc $ h ! E.time'
      return h

updateHealth :: Int64 -> IO Integer
updateHealth healthId = do
  utcTime <- currentUtcTime
  withConnectionCommit connect $ \conn -> runUpdate conn updateHealthQuery (utcTime, healthId)

updateHealthQuery :: Update (TM.LocalTime, Int64)
updateHealthQuery =
  derivedUpdate $ \proj -> do
    (phTime, ()) <- placeholder (\ph -> E.time' <-# ph)
    (phId, ()) <- placeholder (\ph -> wheres $ proj ! E.id' HRR..=. ph)
    return $ phTime >< phId

currentUtcTime :: IO TM.LocalTime
currentUtcTime = TM.utcToLocalTime TM.utc <$> TM.getCurrentTime
