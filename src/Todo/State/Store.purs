module Todo.State.Store
  ( Action(..)
  , State
  , TodoEffects
  , TodoStore
  , ReactPropType
  , EventHandler
  , storePropTypes
  , storeContext
  , withStoreContext
  , initialState
  , update
  , createStore
  ) where

import Prelude
import Control.Monad.Eff (Eff)
import DOM (DOM)
import Manifold (Store, StoreEffects, runStore)
import React.Recompose (HigherOrderComponent, withContext, getContext)
import Signal.Channel (CHANNEL)
import Todo.State.Todos (Action, State, initialState, update) as Todos

data Action = TodosAction Todos.Action

newtype State = State { todos :: Todos.State }

type TodoEffects = StoreEffects (dom :: DOM)

type TodoStore = Store Action TodoEffects State

type EventHandler value = forall props eff. { store :: TodoStore | props } ->
  value -> Eff ( channel :: CHANNEL | eff ) Unit

foreign import data ReactPropType :: *
foreign import storePropType :: ReactPropType

storePropTypes :: { store :: ReactPropType }
storePropTypes = { store: storePropType }

storeContext :: forall props. HigherOrderComponent { | props } { store :: TodoStore | props }
storeContext = getContext storePropTypes

withStoreContext :: forall props. HigherOrderComponent
  { store :: TodoStore | props } { store :: TodoStore | props }
withStoreContext = withContext storePropTypes mapStoreToContext
  where mapStoreToContext = \p -> { store: p.store }

initialState :: State
initialState = State { todos: Todos.initialState }

update :: Action -> State -> State
update (TodosAction action) (State state) = State $
  state { todos = Todos.update action state.todos }

createStore :: Eff TodoEffects (Store Action TodoEffects State)
createStore = runStore update initialState
