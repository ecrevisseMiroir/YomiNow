import { createWorker, type Worker } from "tesseract.js"

export interface OcrWord {
  text: string
  confidence: number
  bbox: { x0: number; y0: number; x1: number; y1: number }
}

export interface OcrResult {
  text: string
  words: OcrWord[]
}

export type OcrProgress = (progress: number, status: string) => void

let workerPromise: Promise<Worker> | null = null
let progressCallback: OcrProgress | null = null

// Tesseract worker, WASM core, and jpn traineddata are self-hosted under
// public/ so the app works without CDN access (and offline once cached).
const base = import.meta.env.BASE_URL

function getWorker(): Promise<Worker> {
  if (!workerPromise) {
    workerPromise = createWorker(["jpn"], 1, {
      workerPath: `${base}tesseract/worker.min.js`,
      corePath: `${base}tesseract`,
      langPath: `${base}tessdata`,
      gzip: false,
      logger: (m) => {
        if (m.status === "recognizing text") {
          progressCallback?.(m.progress, m.status)
        }
      },
    })
  }
  return workerPromise
}

export async function recognizeJapanese(
  image: string,
  onProgress?: OcrProgress
): Promise<OcrResult> {
  progressCallback = onProgress ?? null
  onProgress?.(0, "loading OCR engine")
  const worker = await getWorker()

  const { data } = await worker.recognize(image, {}, { blocks: true, text: true })

  const words: OcrWord[] = (data.blocks ?? [])
    .flatMap((block) => block.paragraphs)
    .flatMap((paragraph) => paragraph.lines)
    .flatMap((line) => line.words)
    .map((word) => ({
      text: word.text.trim(),
      confidence: word.confidence,
      bbox: word.bbox,
    }))
    .filter((word) => word.text.length > 0)

  progressCallback = null
  return { text: data.text.trim(), words }
}
