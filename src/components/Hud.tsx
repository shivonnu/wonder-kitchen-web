import { ITEM_META } from '../game/items'
import { SCENES } from '../game/scenes'
import { useGame } from '../state/GameState'
import type { SceneId } from '../game/types'

const BACK: Partial<Record<SceneId, SceneId>> = {
  starRoad: 'kitchen',
  moonField: 'starRoad',
  moonCave: 'moonField',
}

export function Hud() {
  const { scene, items, reset, canCook, goTo } = useGame()
  if (scene === 'title' || scene === 'ending') return null
  const title =
    scene === 'cooking'
      ? '料理'
      : scene in SCENES
        ? SCENES[scene as keyof typeof SCENES].title
        : ''

  return (
    <header className="hud">
      <div className="place">{title}</div>
      <ul className="inventory">
        {items.length === 0 && <li className="empty">もちものなし</li>}
        {items.map((id) => (
          <li key={id} title={ITEM_META[id].name}>
            <span>{ITEM_META[id].glyph}</span>
            {ITEM_META[id].name}
          </li>
        ))}
      </ul>
      {BACK[scene] && (
        <button type="button" className="ghost" onClick={() => goTo(BACK[scene]!)}>
          もどる
        </button>
      )}
      {canCook && scene !== 'cooking' && (
        <button
          type="button"
          className="primary-mini"
          onClick={() =>
            goTo('cooking', { speaker: 'しおん', text: 'そろったね。つくってみよう。' })
          }
        >
          料理をはじめる
        </button>
      )}
      <button type="button" className="ghost" onClick={reset}>
        やめる
      </button>
    </header>
  )
}
