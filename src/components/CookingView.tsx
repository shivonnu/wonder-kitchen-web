import { useMemo, useState } from 'react'
import { COOK_STEPS } from '../game/recipe'
import { useGame } from '../state/GameState'

const TOOLS = [
  { id: 'potato', label: '星いも', icon: '/art/potato.png' },
  { id: 'onion', label: '月たまねぎ', icon: '/art/onion.png' },
  { id: 'knife', label: '包丁', icon: '/art/icon-knife.png' },
  { id: 'pot', label: 'お鍋', icon: '/art/icon-pot.png' },
  { id: 'milk', label: '月牛乳', icon: '/art/icon-milk.png' },
  { id: 'fire', label: '火', icon: '/art/icon-fire.png' },
  { id: 'salt', label: '星しお', icon: '/art/icon-salt.png' },
] as const

export function CookingView() {
  const { goTo } = useGame()
  const [step, setStep] = useState(0)
  const [hint, setHint] = useState('材料を、ひとつずつ。失敗はないから、安心して。')
  const current = COOK_STEPS[step]
  const done = step >= COOK_STEPS.length

  const bowlSrc = useMemo(() => {
    if (step >= 8) return '/art/bowl-finished.png'
    if (step >= 5) return '/art/bowl-cooking.png'
    return '/art/bowl-empty.png'
  }, [step])

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
      <img className="art-bg" src="/art/cooking.png" alt="" draggable={false} />
      <div className="cook-stage">
        <img className="bowl-img" src={bowlSrc} alt="" draggable={false} />
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
