import type { ItemId } from './types'

export const ITEM_META: Record<ItemId, { name: string; icon: string }> = {
  memo: { name: 'ルナのメモ', icon: '/art/icon-memo.png' },
  potato: { name: '星いも', icon: '/art/potato.png' },
  onion: { name: '月たまねぎ', icon: '/art/onion.png' },
  moonMilk: { name: '月牛乳', icon: '/art/icon-milk.png' },
  starSalt: { name: '星しお', icon: '/art/icon-salt.png' },
}

export const RECIPE_ITEMS: ItemId[] = [
  'memo',
  'potato',
  'onion',
  'moonMilk',
  'starSalt',
]
