import { useChroma } from './chroma'

type SpriteBox = {
  src: string
  x: number
  y: number
  w: number
  h?: number
  className?: string
  cropHalf?: boolean
}

export function PixelStill({ src, x, y, w, h, className, cropHalf = false }: SpriteBox) {
  const keyed = useChroma(src, cropHalf)
  if (!keyed) return null
  return (
    <img
      className={`sprite pixelated ${className ?? ''}`}
      src={keyed}
      alt=""
      draggable={false}
      style={{
        left: `${x}%`,
        top: `${y}%`,
        width: `${w}%`,
        height: h ? `${h}%` : undefined,
      }}
    />
  )
}

/** One cropped character. Idle uses a gentle bob, never a two-frame blink. */
export function PixelSprite({ className, ...rest }: SpriteBox) {
  return <PixelStill {...rest} cropHalf className={`bob ${className ?? ''}`} />
}

export function Backdrop({ src }: { src: string }) {
  return <img className="art-bg pixelated" src={src} alt="" draggable={false} />
}

export function ChromaImg({ src, className }: { src: string; className?: string }) {
  const keyed = useChroma(src, false)
  if (!keyed) return null
  return <img className={className} src={keyed} alt="" draggable={false} />
}
