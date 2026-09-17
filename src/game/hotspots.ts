import { SCENES } from './scenes'
import type { FlagId, Hotspot, SceneId } from './types'

export function visibleHotspots(sceneId: SceneId, flags: FlagId[]): Hotspot[] {
  if (sceneId === 'title' || sceneId === 'cooking' || sceneId === 'ending') return []
  const scene = SCENES[sceneId]
  return scene.hotspots.filter((h) => {
    if (h.hideWhen && h.hideWhen.some((f) => flags.includes(f))) return false
    if (h.showWhen && !h.showWhen.every((f) => flags.includes(f))) return false
    return true
  })
}
