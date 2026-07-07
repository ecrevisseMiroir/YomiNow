import { useEffect, useRef, useState } from "react"
import { RotateCcw, ScanText, X } from "lucide-react"
import { recognizeJapanese, type OcrResult, type OcrWord } from "@/lib/ocr"

interface ImageViewProps {
  imageData: string
  onRetake: () => void
}

type OcrStatus = "processing" | "done" | "error"

export function ImageView({ imageData, onRetake }: ImageViewProps) {
  const [status, setStatus] = useState<OcrStatus>("processing")
  const [progress, setProgress] = useState(0)
  const [result, setResult] = useState<OcrResult | null>(null)
  const [selectedWord, setSelectedWord] = useState<OcrWord | null>(null)
  const [showFullText, setShowFullText] = useState(false)
  const [imageSize, setImageSize] = useState<{ w: number; h: number } | null>(null)
  const ranRef = useRef(false)

  useEffect(() => {
    if (ranRef.current) return
    ranRef.current = true

    recognizeJapanese(imageData, (p) => setProgress(p))
      .then((res) => {
        setResult(res)
        setStatus("done")
      })
      .catch((err) => {
        console.error("OCR failed:", err)
        setStatus("error")
      })
  }, [imageData])

  return (
    <div className="relative flex flex-1 flex-col bg-black">
      <div className="flex flex-1 items-center justify-center overflow-hidden p-2">
        <div className="relative">
          <img
            src={imageData}
            alt="Captured"
            className="max-h-[80vh] max-w-full object-contain"
            onLoad={(e) =>
              setImageSize({
                w: e.currentTarget.naturalWidth,
                h: e.currentTarget.naturalHeight,
              })
            }
          />

          {status === "done" &&
            imageSize &&
            result?.words.map((word, i) => {
              const { x0, y0, x1, y1 } = word.bbox
              const isSelected = selectedWord === word
              return (
                <button
                  key={i}
                  onClick={() => setSelectedWord(isSelected ? null : word)}
                  className={`absolute rounded-sm border transition-colors ${
                    isSelected
                      ? "border-emerald-400 bg-emerald-400/40"
                      : "border-sky-400/70 bg-sky-400/20 hover:bg-sky-400/35"
                  }`}
                  style={{
                    left: `${(x0 / imageSize.w) * 100}%`,
                    top: `${(y0 / imageSize.h) * 100}%`,
                    width: `${((x1 - x0) / imageSize.w) * 100}%`,
                    height: `${((y1 - y0) / imageSize.h) * 100}%`,
                  }}
                  aria-label={word.text}
                />
              )
            })}
        </div>
      </div>

      {status === "processing" && (
        <div className="absolute inset-x-0 top-0 flex flex-col items-center gap-2 bg-black/70 p-4 backdrop-blur-sm">
          <p className="text-sm text-white">Detecting Japanese text…</p>
          <div className="h-1.5 w-64 overflow-hidden rounded-full bg-zinc-700">
            <div
              className="h-full bg-sky-400 transition-all"
              style={{ width: `${Math.round(progress * 100)}%` }}
            />
          </div>
        </div>
      )}

      {status === "error" && (
        <div className="absolute inset-x-0 top-0 bg-red-950/80 p-4 text-center backdrop-blur-sm">
          <p className="text-sm text-red-300">
            OCR failed. Check your connection and try again.
          </p>
        </div>
      )}

      {status === "done" && result && result.words.length === 0 && (
        <div className="absolute inset-x-0 top-0 bg-black/70 p-4 text-center backdrop-blur-sm">
          <p className="text-sm text-zinc-300">No Japanese text detected.</p>
        </div>
      )}

      {selectedWord && (
        <div className="absolute inset-x-0 bottom-28 mx-auto w-fit max-w-[90%] rounded-xl bg-zinc-900/95 px-6 py-4 text-center shadow-lg backdrop-blur-sm">
          <p className="text-2xl font-medium text-white">{selectedWord.text}</p>
          <p className="mt-1 text-xs text-zinc-400">
            confidence {Math.round(selectedWord.confidence)}% · dictionary coming soon
          </p>
        </div>
      )}

      {showFullText && result && (
        <div className="absolute inset-x-4 top-4 max-h-[50vh] overflow-y-auto rounded-xl bg-zinc-900/95 p-4 shadow-lg backdrop-blur-sm">
          <div className="mb-2 flex items-center justify-between">
            <p className="text-xs font-medium uppercase tracking-wide text-zinc-400">
              Detected text
            </p>
            <button onClick={() => setShowFullText(false)} aria-label="Close">
              <X className="h-4 w-4 text-zinc-400" />
            </button>
          </div>
          <p className="whitespace-pre-wrap text-sm text-white">
            {result.text || "(empty)"}
          </p>
        </div>
      )}

      <div className="absolute bottom-0 left-0 right-0 flex justify-center gap-3 pb-10">
        <button
          onClick={onRetake}
          className="flex items-center gap-2 rounded-full bg-zinc-800/80 px-6 py-3 text-sm font-medium text-white backdrop-blur-sm transition-transform active:scale-95"
        >
          <RotateCcw className="h-4 w-4" />
          Retake
        </button>

        {status === "done" && result && result.text.length > 0 && (
          <button
            onClick={() => setShowFullText((v) => !v)}
            className="flex items-center gap-2 rounded-full bg-zinc-800/80 px-6 py-3 text-sm font-medium text-white backdrop-blur-sm transition-transform active:scale-95"
          >
            <ScanText className="h-4 w-4" />
            Text
          </button>
        )}
      </div>
    </div>
  )
}
