export type SceneId =
  | 'title'
  | 'kitchen'
  | 'starRoad'
  | 'moonField'
  | 'moonCave'
  | 'cooking'
  | 'ending'

export type ItemId = 'memo' | 'potato' | 'onion' | 'moonMilk' | 'starSalt'

export type FlagId =
  | 'metShion'
  | 'lunaLeft'
  | 'gotMemo'
  | 'windowOpen'
  | 'saltTaken'

export type HotspotAction =
  | { type: 'say'; speaker: string; text: string }
  | { type: 'give'; item: ItemId; speaker: string; text: string }
  | { type: 'flag'; flag: FlagId; speaker: string; text: string }
  | { type: 'go'; scene: SceneId; speaker?: string; text?: string }

export type Hotspot = {
  id: string
  label: string
  x: number
  y: number
  w: number
  h: number
  hideWhen?: FlagId[]
  showWhen?: FlagId[]
  hideWhenItem?: ItemId[]
  showWhenItem?: ItemId[]
  requireItems?: ItemId[]
  missingText?: string
  actions: HotspotAction[]
}

export type SceneDef = {
  id: Exclude<SceneId, 'title' | 'cooking' | 'ending'>
  title: string
  art: 'kitchen' | 'starRoad' | 'moonField' | 'moonCave'
  hotspots: Hotspot[]
}

export type SaveData = {
  scene: SceneId
  items: ItemId[]
  flags: FlagId[]
  dialogue: { speaker: string; text: string }
}
