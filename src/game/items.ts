import type { ItemId } from './types'

export const ITEM_META: Record<ItemId, { name: string; glyph: string }> = {
  memo: { name: 'ルナのメモ', glyph: '☽' },
  potato: { name: '星いも', glyph: '★' },
  onion: { name: '月たまねぎ', glyph: '🌙' },
  moonMilk: { name: '月牛乳', glyph: '🥛' },
  starSalt: { name: '星しお', glyph: '✦' },
}

export const RECIPE_ITEMS: ItemId[] = [
  'memo',
  'potato',
  'onion',
  'moonMilk',
  'starSalt',
]
