import { useMemo, useState } from 'react'
import { COOK_STEPS } from '../game/recipe'
import { useGame } from '../state/GameState'

const TOOLS = [
  { id: 'potato', label: '星いも' },
  { id: 'onion', label: '月たまねぎ' },
  { id: 'knife', label: '包丁' },
  { id: 'pot', label: 'お鍋' },
  { id: 'milk', label: '月牛乳' },
  { id: 'fire', label: '火' },
  { id: 'salt', label: '星しお' },
] as const

export function CookingView() {
  const { goTo } = useGame()
  const [step, setStep] = useState(0)
  const [hint, setHint] = useState('材料を、ひとつずつ。失敗はないから、安心して。')
  const current = COOK_STEPS[step]
  const done = step >= COOK_STEPS.length

  const bowlClass = useMemo(() => {
    if (step >= 8) return 'bowl finished'
    if (step >= 7) return 'bowl boiling'
    if (step >= 6) return 'bowl milky'
    if (step >= 5) return 'bowl veg'
    return 'bowl empty'
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
      <div className="cook-stage">
        <div className={bowlClass} />
        <div className="cook-tools">
          {TOOLS.map((tool) => (
            <button
              key={tool.id}
              type="button"
              className={`tool ${!done && current.target === tool.id ? 'next' : ''}`}
              onClick={() => onTool(tool.id)}
            >
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
