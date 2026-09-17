export type CookStep = {
  id: string
  prompt: string
  target: string
  success: string
}

export const COOK_STEPS: CookStep[] = [
  {
    id: 'board-potato',
    prompt: '星いもをまな板へ置いて',
    target: 'potato',
    success: 'いもがまな板にのった。まだ星のかたち。',
  },
  {
    id: 'cut-potato',
    prompt: '包丁で星いもを切って',
    target: 'knife',
    success: 'こんにゃくみたいに、やわらかく切れた。',
  },
  {
    id: 'board-onion',
    prompt: '月たまねぎをまな板へ',
    target: 'onion',
    success: '三日月の層が光っている。',
  },
  {
    id: 'cut-onion',
    prompt: 'たまねぎも切って',
    target: 'knife',
    success: '塩の香りがふわっとした。涙は出ないみたい。',
  },
  {
    id: 'pot-veg',
    prompt: '切った野菜を鍋へ',
    target: 'pot',
    success: '鍋の底で、星くずがちょっとはねた。',
  },
  {
    id: 'pour-milk',
    prompt: '月牛乳を注いで',
    target: 'milk',
    success: '白い湯気が、夜空みたいに立ちのぼる。',
  },
  {
    id: 'light-fire',
    prompt: '火をつけて',
    target: 'fire',
    success: '小さな青い炎。島の火は、いつも少し冷たい。',
  },
  {
    id: 'salt',
    prompt: '仕上げに星しおをひとふり',
    target: 'salt',
    success: '粒がスープの表面で、短い星になった。',
  },
]
