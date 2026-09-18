import { KitchenArt, MoonCaveArt, MoonFieldArt, StarRoadArt } from '../art/SceneArt'
import { visibleHotspots } from '../game/hotspots'
import { useGame } from '../state/GameState'
import type { SceneId } from '../game/types'
import type { ComponentType } from 'react'

const ART: Record<
  Exclude<SceneId, 'title' | 'cooking' | 'ending'>,
  ComponentType
> = {
  kitchen: KitchenArt,
  starRoad: StarRoadArt,
  moonField: MoonFieldArt,
  moonCave: MoonCaveArt,
}

export function SceneView() {
  const { scene, flags, items, clickHotspot, dialogue } = useGame()
  if (scene === 'title' || scene === 'cooking' || scene === 'ending') return null
  const Art = ART[scene]
  const spots = visibleHotspots(scene, flags, items)

  return (
    <div className="scene">
      <Art />
      {spots.map((spot) => (
        <button
          key={spot.id}
          type="button"
          className="hotspot"
          style={{
            left: `${spot.x}%`,
            top: `${spot.y}%`,
            width: `${spot.w}%`,
            height: `${spot.h}%`,
          }}
          aria-label={spot.label}
          onClick={() => clickHotspot(spot)}
        />
      ))}
      <div className="dialogue">
        <div className="speaker">{dialogue.speaker}</div>
        <p>{dialogue.text}</p>
      </div>
    </div>
  )
}
