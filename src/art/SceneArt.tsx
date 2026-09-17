import { useGame } from '../state/GameState'

type SpriteProps = {
  src: string
  x: number
  y: number
  w: number
  h: number
  className?: string
}

function Sprite({ src, x, y, w, h, className }: SpriteProps) {
  return (
    <img
      className={`sprite ${className ?? ''}`}
      src={src}
      alt=""
      draggable={false}
      style={{
        left: `${x}%`,
        top: `${y}%`,
        width: `${w}%`,
        height: `${h}%`,
      }}
    />
  )
}

function Backdrop({ src }: { src: string }) {
  return <img className="art-bg" src={src} alt="" draggable={false} />
}

export function KitchenArt() {
  const { hasFlag, canCook } = useGame()
  return (
    <div className="art">
      <Backdrop src="/art/kitchen.png" />
      <Sprite src="/art/shion.png" x={26} y={54} w={14} h={32} className="round-sprite" />
      {!hasFlag('lunaLeft') && (
        <Sprite src="/art/luna.png" x={42} y={48} w={16} h={24} className="round-sprite" />
      )}
      {hasFlag('lunaLeft') && (
        <Sprite src="/art/icon-memo.png" x={46} y={56} w={10} h={16} className="round-sprite" />
      )}
      {hasFlag('saltTaken') && (
        <Sprite
          src="/art/salt-jar-empty.png"
          x={82}
          y={32}
          w={12}
          h={22}
          className="round-sprite"
        />
      )}
      {canCook && <div className="cook-glow">つくれる！</div>}
    </div>
  )
}

export function StarRoadArt() {
  return (
    <div className="art">
      <Backdrop src="/art/star-road.png" />
    </div>
  )
}

export function MoonFieldArt() {
  const { hasItem } = useGame()
  return (
    <div className="art">
      <Backdrop src="/art/moon-field.png" />
      {!hasItem('potato') && (
        <Sprite src="/art/potato.png" x={8} y={46} w={18} h={24} className="round-sprite" />
      )}
      {!hasItem('onion') && (
        <Sprite src="/art/onion.png" x={52} y={48} w={16} h={22} className="round-sprite" />
      )}
    </div>
  )
}

export function MoonCaveArt() {
  const { hasItem } = useGame()
  return (
    <div className="art">
      <Backdrop src="/art/moon-cave.png" />
      {!hasItem('moonMilk') && (
        <Sprite src="/art/moon-well.png" x={36} y={48} w={26} h={32} className="round-sprite" />
      )}
    </div>
  )
}
