import { artUrl } from '../game/assets'
import { Backdrop, PixelStill, PixelSprite } from './PixelSprite'
import { useGame } from '../state/GameState'

export function KitchenArt() {
  const { hasFlag, canCook } = useGame()
  return (
    <div className="art">
      <Backdrop src={artUrl('kitchen.png')} />
      <PixelSprite src={artUrl('shion-idle.png')} x={30} y={52} w={14} h={30} />
      {!hasFlag('lunaLeft') && (
        <PixelSprite src={artUrl('luna-idle.png')} x={44} y={50} w={16} h={24} />
      )}
      {hasFlag('lunaLeft') && (
        <PixelStill src={artUrl('icon-memo.png')} x={48} y={56} w={8} h={14} />
      )}
      {hasFlag('saltTaken') && (
        <PixelStill src={artUrl('salt-jar-empty.png')} x={80} y={32} w={12} h={20} />
      )}
      {canCook && <div className="cook-glow">つくれる！</div>}
    </div>
  )
}

export function StarRoadArt() {
  return (
    <div className="art">
      <Backdrop src={artUrl('star-road.png')} />
      <PixelSprite
        src={artUrl('shion-walk.png')}
        x={18}
        y={62}
        w={10}
        h={18}
        className="shion-on-road"
      />
    </div>
  )
}

export function MoonFieldArt() {
  const { hasItem } = useGame()
  return (
    <div className="art">
      <Backdrop src={artUrl('moon-field.png')} />
      {!hasItem('potato') && (
        <PixelStill src={artUrl('potato.png')} x={10} y={42} w={16} h={22} className="bob" />
      )}
      {!hasItem('onion') && (
        <PixelStill src={artUrl('onion.png')} x={32} y={40} w={14} h={20} className="bob delay" />
      )}
    </div>
  )
}

export function MoonCaveArt() {
  const { hasItem } = useGame()
  return (
    <div className="art">
      <Backdrop src={artUrl('moon-cave.png')} />
      {!hasItem('moonMilk') && (
        <PixelStill src={artUrl('moon-well.png')} x={36} y={46} w={26} h={32} className="bob" />
      )}
    </div>
  )
}
