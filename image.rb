require "opencv"

class Image
  include OpenCV

  def initialize(source_image_path: nil, data: nil)
    @source_image_path = source_image_path
    @data = data
  end

  def count
    source_image = if @source_image_path
                     CvMat.load(@source_image_path)
                   elsif @data
                     CvMat.decode_image(@data)
                   end
    lawn_rectangle = source_image.sub_rect(CvRect.new(630, 131, 1027, 167))

    detector = CvHaarClassifierCascade::load("./lib/haar_cascade_sets/haarcascade_fullbody.xml")

    detector.detect_objects(
      lawn_rectangle,
      flags: CV_HAAR_DO_CANNY_PRUNING,
      min_neighbors: 0,
    ).size
  end
end

