import { useState } from "react"
import { CameraView } from "@/components/CameraView"
import { ImageView } from "@/components/ImageView"

function App() {
  const [capturedImage, setCapturedImage] = useState<string | null>(null)

  if (capturedImage) {
    return (
      <ImageView
        imageData={capturedImage}
        onRetake={() => setCapturedImage(null)}
      />
    )
  }

  return <CameraView onCapture={setCapturedImage} />
}

export default App
