import { artUrl } from './assets'
import type { ItemId } from './types'

export const ITEM_META: Record<ItemId, { name: string; icon: string }> = {
  memo: { name: 'ルナのメモ', icon: artUrl('icon-memo.png') },
  potato: { name: '星いも', icon: artUrl('potato.png') },
  onion: { name: '月たまねぎ', icon: artUrl('onion.png') },
  moonMilk: { name: '月牛乳', icon: artUrl('icon-milk.png') },
  starSalt: { name: '星しお', icon: artUrl('icon-salt.png') },
}

export const RECIPE_ITEMS: ItemId[] = [
  'memo',
  'potato',
  'onion',
  'moonMilk',
  'starSalt',
]
