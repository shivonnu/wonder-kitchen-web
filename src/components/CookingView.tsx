import { useState } from 'react'
import { artUrl } from '../game/assets'
import { COOK_STEPS } from '../game/recipe'
import { PixelSprite } from '../art/PixelSprite'
import { useGame } from '../state/GameState'

const TOOLS = [
  { id: 'potato', label: '星いも', icon: artUrl('potato.png') },
  { id: 'onion', label: '月たまねぎ', icon: artUrl('onion.png') },
  { id: 'knife', label: '包丁', icon: artUrl('icon-knife.png') },
  { id: 'pot', label: 'お鍋', icon: artUrl('icon-pot.png') },
  { id: 'milk', label: '月牛乳', icon: artUrl('icon-milk.png') },
  { id: 'fire', label: '火', icon: artUrl('icon-fire.png') },
  { id: 'salt', label: '星しお', icon: artUrl('icon-salt.png') },
] as const

export function CookingView() {
  const { goTo } = useGame()
  const [step, setStep] = useState(0)
  const [hint, setHint] = useState('材料を、ひとつずつ。失敗はないから、安心して。')
  const current = COOK_STEPS[step]
  const done = step >= COOK_STEPS.length

  const bubbling = step >= 5 && !done

  function onTool(id: string) {
    if (done) return
    if (id === current.target) {
      setHint(current.success)
      const next = step + 1
      setStep(next)
      if (next >= COOK_STEPS.length) {
        setTimeout(() => {
          goTo('ending', {
            speaker: 'しおん',
            text: 'あったかい……星が、お腹のなかで溶けていく。ありがとう。',
          })
        }, 1200)
      }
    } else {
      setHint(`今は「${current.prompt}」だよ。別の順番でも大丈夫、焦らなくていい。`)
    }
  }

  return (
    <div className="scene cooking">
      <img className="art-bg pixelated" src={artUrl('cooking.png')} alt="" draggable={false} />
      <div className="cook-stage">
        {bubbling && (
          <PixelSprite
            src={artUrl('bowl-cook-sheet.png')}
            x={38}
            y={18}
            w={24}
            h={32}
            className="cook-bowl"
          />
        )}
        {done && (
          <img
            className="bowl-img pixelated sparkle"
            src={artUrl('bowl-finished.png')}
            alt=""
            draggable={false}
          />
        )}
        <div className="cook-tools">
          {TOOLS.map((tool) => (
            <button
              key={tool.id}
              type="button"
              className={`tool ${!done && current.target === tool.id ? 'next' : ''}`}
              onClick={() => onTool(tool.id)}
            >
              <img src={tool.icon} alt="" />
              {tool.label}
            </button>
          ))}
        </div>
      </div>
      <div className="dialogue">
        <div className="speaker">{done ? 'しおん' : '料理'}</div>
        <p>{done ? '月あかりポタージュ、できたよ。' : `${current.prompt}。 ${hint}`}</p>
      </div>
    </div>
  )
}
