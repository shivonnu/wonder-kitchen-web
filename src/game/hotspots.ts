import { SCENES } from './scenes'
import type { FlagId, Hotspot, ItemId, SceneId } from './types'

export function visibleHotspots(
  sceneId: SceneId,
  flags: FlagId[],
  items: ItemId[] = [],
): Hotspot[] {
  if (sceneId === 'title' || sceneId === 'cooking' || sceneId === 'ending') return []
  const scene = SCENES[sceneId]
  return scene.hotspots.filter((h) => {
    if (h.hideWhen && h.hideWhen.some((f) => flags.includes(f))) return false
    if (h.showWhen && !h.showWhen.every((f) => flags.includes(f))) return false
    if (h.hideWhenItem && h.hideWhenItem.some((id) => items.includes(id))) return false
    if (h.showWhenItem && !h.showWhenItem.every((id) => items.includes(id))) return false
    return true
  })
}
