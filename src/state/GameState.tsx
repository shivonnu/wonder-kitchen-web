import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import { RECIPE_ITEMS } from '../game/items'
import type {
  FlagId,
  Hotspot,
  HotspotAction,
  ItemId,
  SaveData,
  SceneId,
} from '../game/types'

const SAVE_KEY = 'hoshishio-save-v1'

const START_DIALOGUE = {
  speaker: 'しおん',
  text: '夜のキッチンだよ。気になるところを、どんどん触ってみて。',
}

function loadSave(): SaveData | null {
  try {
    const raw = localStorage.getItem(SAVE_KEY)
    if (!raw) return null
    return JSON.parse(raw) as SaveData
  } catch {
    return null
  }
}

function persist(data: SaveData) {
  localStorage.setItem(SAVE_KEY, JSON.stringify(data))
}

type GameContextValue = {
  scene: SceneId
  items: ItemId[]
  flags: FlagId[]
  dialogue: { speaker: string; text: string }
  fading: boolean
  hasItem: (id: ItemId) => boolean
  hasFlag: (id: FlagId) => boolean
  canCook: boolean
  startNew: () => void
  continueGame: () => void
  hasSave: boolean
  clickHotspot: (hotspot: Hotspot) => void
  goTo: (scene: SceneId, dialogue?: { speaker: string; text: string }) => void
  reset: () => void
}

const GameContext = createContext<GameContextValue | null>(null)

export function GameProvider({ children }: { children: ReactNode }) {
  const existing = loadSave()
  const [scene, setScene] = useState<SceneId>('title')
  const [items, setItems] = useState<ItemId[]>([])
  const [flags, setFlags] = useState<FlagId[]>([])
  const [dialogue, setDialogue] = useState(START_DIALOGUE)
  const [hasSave, setHasSave] = useState(Boolean(existing))
  const [fading, setFading] = useState(false)

  const changeScene = useCallback((next: SceneId) => {
    if (next === scene) return
    setFading(true)
    window.setTimeout(() => {
      setScene(next)
      setFading(false)
    }, 280)
  }, [scene])

  const snapshot = useCallback(
    (next: Partial<SaveData> & { scene: SceneId }) => {
      const data: SaveData = {
        scene: next.scene,
        items: next.items ?? items,
        flags: next.flags ?? flags,
        dialogue: next.dialogue ?? dialogue,
      }
      persist(data)
      setHasSave(true)
    },
    [items, flags, dialogue],
  )

  const hasItem = useCallback((id: ItemId) => items.includes(id), [items])
  const hasFlag = useCallback((id: FlagId) => flags.includes(id), [flags])

  const canCook = RECIPE_ITEMS.every((id) => items.includes(id))

  const applyActions = useCallback(
    (actions: HotspotAction[], currentItems: ItemId[], currentFlags: FlagId[]) => {
      let nextItems = [...currentItems]
      let nextFlags = [...currentFlags]
      let nextDialogue = dialogue
      let nextScene: SceneId | null = null

      for (const action of actions) {
        if (action.type === 'say') {
          nextDialogue = { speaker: action.speaker, text: action.text }
        }
        if (action.type === 'give') {
          if (!nextItems.includes(action.item)) nextItems.push(action.item)
          nextDialogue = { speaker: action.speaker, text: action.text }
          if (action.item === 'moonMilk' && !nextItems.includes('starSalt')) {
            nextDialogue = {
              speaker: action.speaker,
              text: `${action.text} 星しおはキッチンの壺にあるよ。『もどる』で畑へ戻ろう。`,
            }
          }
        }
        if (action.type === 'flag') {
          if (!nextFlags.includes(action.flag)) nextFlags.push(action.flag)
          nextDialogue = { speaker: action.speaker, text: action.text }
        }
        if (action.type === 'go') {
          nextScene = action.scene
          if (action.text) {
            nextDialogue = { speaker: action.speaker ?? 'しおん', text: action.text }
          }
        }
      }

      setItems(nextItems)
      setFlags(nextFlags)
      setDialogue(nextDialogue)
      if (nextScene) changeScene(nextScene)
      snapshot({
        scene: nextScene ?? scene,
        items: nextItems,
        flags: nextFlags,
        dialogue: nextDialogue,
      })
    },
    [changeScene, dialogue, scene, snapshot],
  )

  const clickHotspot = useCallback(
    (hotspot: Hotspot) => {
      if (hotspot.showWhen && !hotspot.showWhen.every((f) => flags.includes(f))) return
      if (hotspot.hideWhen && hotspot.hideWhen.some((f) => flags.includes(f))) return

      if (hotspot.requireItems) {
        const missing = hotspot.requireItems.filter((id) => !items.includes(id))
        if (missing.length) {
          const text = hotspot.missingText ?? 'まだ足りないものがあるみたい。'
          setDialogue({ speaker: 'しおん', text })
          snapshot({ scene, dialogue: { speaker: 'しおん', text } })
          return
        }
      }

      const giveActions = hotspot.actions.filter((a) => a.type === 'give') as Extract<
        HotspotAction,
        { type: 'give' }
      >[]
      if (
        giveActions.length &&
        giveActions.every((a) => items.includes(a.item)) &&
        hotspot.actions.every((a) => a.type !== 'go')
      ) {
        if (scene === 'moonCave') {
          const text = '月牛乳はもう持ってるよ。畑へもどろう。'
          setDialogue({ speaker: 'しおん', text })
          changeScene('moonField')
          snapshot({ scene: 'moonField', dialogue: { speaker: 'しおん', text } })
          return
        }
        setDialogue({ speaker: 'しおん', text: 'それは、もう持っているよ。' })
        return
      }

      applyActions(hotspot.actions, items, flags)
    },
    [applyActions, changeScene, flags, items, scene, snapshot],
  )

  const goTo = useCallback(
    (next: SceneId, nextDialogue?: { speaker: string; text: string }) => {
      if (nextDialogue) setDialogue(nextDialogue)
      changeScene(next)
      snapshot({ scene: next, dialogue: nextDialogue ?? dialogue })
    },
    [changeScene, dialogue, snapshot],
  )

  const startNew = useCallback(() => {
    localStorage.removeItem(SAVE_KEY)
    setItems([])
    setFlags([])
    setDialogue(START_DIALOGUE)
    setScene('kitchen')
    setHasSave(false)
    persist({
      scene: 'kitchen',
      items: [],
      flags: [],
      dialogue: START_DIALOGUE,
    })
    setHasSave(true)
  }, [])

  const continueGame = useCallback(() => {
    const saved = loadSave()
    if (!saved) return
    setItems(saved.items)
    setFlags(saved.flags)
    setDialogue(saved.dialogue)
    setScene(saved.scene === 'title' ? 'kitchen' : saved.scene)
  }, [])

  const reset = useCallback(() => {
    localStorage.removeItem(SAVE_KEY)
    setItems([])
    setFlags([])
    setDialogue(START_DIALOGUE)
    setScene('title')
    setHasSave(false)
  }, [])

  const value = useMemo(
    () => ({
      scene,
      items,
      flags,
      dialogue,
      fading,
      hasItem,
      hasFlag,
      canCook,
      startNew,
      continueGame,
      hasSave,
      clickHotspot,
      goTo,
      reset,
    }),
    [
      scene,
      items,
      flags,
      dialogue,
      fading,
      hasItem,
      hasFlag,
      canCook,
      startNew,
      continueGame,
      hasSave,
      clickHotspot,
      goTo,
      reset,
    ],
  )

  return <GameContext.Provider value={value}>{children}</GameContext.Provider>
}

export function useGame() {
  const ctx = useContext(GameContext)
  if (!ctx) throw new Error('useGame must be inside GameProvider')
  return ctx
}
