module PurerlExUnit.ModuleUtilities
  ( pureScriptModuleToErlangModule
  , pureScriptFileToPureScriptModule
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Maybe as Maybe
import Data.Newtype (wrap)
import Data.String (CodePoint, Pattern)
import Data.String as String
import Erl.Atom (Atom)
import Erl.Atom as Atom

pureScriptModuleToErlangModule :: String -> Atom
pureScriptModuleToErlangModule module' = do
  module'
    # stripPrefixIfPresent (wrap "Elixir.")
    # String.split (wrap ".")
    # map lowerCaseFirstLetter
    # String.joinWith "_"
    # (_ <> "@ps")
    # Atom.atom

pureScriptFileToPureScriptModule :: { prefix :: Maybe String } -> String -> String
pureScriptFileToPureScriptModule options path = do
  let prefix = Maybe.fromMaybe "" options.prefix

  path
    # stripPrefixIfPresent (wrap "src/")
    # stripPrefixIfPresent (wrap "test/")
    # stripSuffixIfPresent (wrap ".purs")
    # String.split (wrap "/")
    # String.joinWith "."
    # (prefix <> _)

stripPrefixIfPresent :: Pattern -> String -> String
stripPrefixIfPresent prefix s = do
  s # String.stripPrefix prefix # Maybe.fromMaybe s

stripSuffixIfPresent :: Pattern -> String -> String
stripSuffixIfPresent suffix s = do
  s # String.stripSuffix suffix # Maybe.fromMaybe s

lowerCaseFirstLetter :: String -> String
lowerCaseFirstLetter s = modifyFirstLetter lowerCaseLetter s

upperCaseFirstLetter :: String -> String
upperCaseFirstLetter s = modifyFirstLetter upperCaseLetter s

modifyFirstLetter :: (CodePoint -> CodePoint) -> String -> String
modifyFirstLetter f s =
  case String.uncons s of
    Just { head, tail } -> head # f # String.singleton # (_ <> tail)
    Nothing -> s

foreign import lowerCaseLetter :: CodePoint -> CodePoint
foreign import upperCaseLetter :: CodePoint -> CodePoint
