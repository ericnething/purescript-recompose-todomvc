module Todo (init) where

import Prelude
import Control.Monad.Eff (Eff)
import DOM.HTML (window)
import DOM.HTML.Document (body)
import DOM.HTML.Types (htmlElementToNode, htmlDocumentToDocument)
import DOM.HTML.Window (document)
import DOM.Node.Document (createElement) as Document
import DOM.Node.Element (setAttribute)
import DOM.Node.Node (appendChild)
import DOM.Node.Types (elementToNode)
import Data.Maybe (Maybe, fromJust)
import Data.Nullable (toMaybe)
import Partial.Unsafe (unsafePartial)
import React (ReactComponent)
import React (createElement) as React
import ReactDOM (render)
import Todo.Components.App (ViewProps(ViewProps), view)
import Todo.State.Store (TodoEffects, createStore)

init :: Eff TodoEffects (Maybe ReactComponent)
init = do
  htmlDocument <- window >>= document
  htmlBody <- map (unsafePartial (fromJust <<< toMaybe)) $ body htmlDocument

  -- Create an element to house the application
  container <- Document.createElement "div" $ htmlDocumentToDocument htmlDocument
  setAttribute "id" "app" container

  -- Append it to the body
  appendChild (elementToNode container) (htmlElementToNode htmlBody)

  -- Kick off the store
  store <- createStore

  let props = ViewProps { store: store }
      element = React.createElement view props []

  -- Render the app to the container
  render element container
