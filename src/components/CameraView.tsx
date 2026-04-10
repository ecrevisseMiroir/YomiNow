import { useEffect } from "react"
import { Camera } from "lucide-react"
import { useCamera } from "@/hooks/useCamera"

interface CameraViewProps {
  onCapture: (imageData: string) => void
}

export function CameraView({ onCapture }: CameraViewProps) {
  const { videoRef, isActive, error, start, capture } = useCamera()

  useEffect(() => {
    start()
  }, [start])

  const handleCapture = () => {
    const imageData = capture()
    if (imageData) {
      onCapture(imageData)
    }
  }

  return (
    <div className="relative flex flex-1 flex-col items-center justify-center bg-black">
      {error ? (
        <div className="flex flex-col items-center gap-4 p-8 text-center">
          <p className="text-red-400">{error}</p>
          <button
            onClick={start}
            className="rounded-lg bg-primary px-6 py-3 text-sm font-medium text-white"
          >
            Retry
          </button>
        </div>
      ) : (
        <>
          <video
            ref={videoRef}
            autoPlay
            playsInline
            muted
            className="h-full w-full object-cover"
          />

          {isActive && (
            <div className="absolute bottom-0 left-0 right-0 flex justify-center pb-10">
              <button
                onClick={handleCapture}
                className="flex h-18 w-18 items-center justify-center rounded-full border-4 border-white bg-white/20 backdrop-blur-sm transition-transform active:scale-90"
                aria-label="Take photo"
              >
                <Camera className="h-8 w-8 text-white" />
              </button>
            </div>
          )}
        </>
      )}
    </div>
  )
}
