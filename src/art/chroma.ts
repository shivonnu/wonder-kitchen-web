import { useEffect, useState } from 'react'

const cache = new Map<string, string>()

function processSprite(src: string, cropHalf: boolean): Promise<string> {
  const key = `${src}|${cropHalf ? 'half' : 'full'}`
  const hit = cache.get(key)
  if (hit) return Promise.resolve(hit)
  return new Promise((resolve) => {
    const img = new Image()
    img.decoding = 'async'
    img.onload = () => {
      const srcCanvas = document.createElement('canvas')
      srcCanvas.width = img.naturalWidth
      srcCanvas.height = img.naturalHeight
      const srcCtx = srcCanvas.getContext('2d')
      if (!srcCtx) {
        resolve(src)
        return
      }
      srcCtx.drawImage(img, 0, 0)
      const data = srcCtx.getImageData(0, 0, srcCanvas.width, srcCanvas.height)
      const px = data.data
      for (let i = 0; i < px.length; i += 4) {
        const r = px[i]
        const g = px[i + 1]
        const b = px[i + 2]
        if (r > 150 && b > 150 && g < 140 && r + b > g * 2 + 80) px[i + 3] = 0
      }
      srcCtx.putImageData(data, 0, 0)

      const out = document.createElement('canvas')
      const ctx = out.getContext('2d')
      if (!ctx) {
        resolve(src)
        return
      }
      if (cropHalf) {
        const w = Math.max(1, Math.floor(srcCanvas.width / 2))
        out.width = w
        out.height = srcCanvas.height
        ctx.drawImage(srcCanvas, 0, 0, w, srcCanvas.height, 0, 0, w, srcCanvas.height)
      } else {
        out.width = srcCanvas.width
        out.height = srcCanvas.height
        ctx.drawImage(srcCanvas, 0, 0)
      }

      out.toBlob((blob) => {
        if (!blob) {
          resolve(src)
          return
        }
        const url = URL.createObjectURL(blob)
        cache.set(key, url)
        resolve(url)
      })
    }
    img.onerror = () => resolve(src)
    img.src = src
  })
}

export function useChroma(src: string, cropHalf = false) {
  const [url, setUrl] = useState<string | null>(null)
  useEffect(() => {
    let cancelled = false
    void processSprite(src, cropHalf).then((next) => {
      if (!cancelled) setUrl(next)
    })
    return () => {
      cancelled = true
    }
  }, [src, cropHalf])
  return url
}
