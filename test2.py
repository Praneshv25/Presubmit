import cv2
import numpy as np

annotations = [
    {
      "box_2d": [
        305,
        145,
        329,
        249
      ],
      "mistakes": "",
      "text": "y = mx + b"
    },
    {
      "box_2d": [
        350,
        146,
        374,
        281
      ],
      "mistakes": "Not 2",
      "text": "m = (4-2) / (2-0)"
    },
    {
      "box_2d": [
        402,
        146,
        425,
        249
      ],
      "mistakes": "",
      "text": "2 = m * 2 + b"
    },
    {
      "box_2d": [
        449,
        146,
        472,
        189
      ],
      "mistakes": "",
      "text": "b = 2"
    }
  ]

img = cv2.imread("test_star.jpeg")

img_height, img_width, channels = img.shape

# Annotation colors
box_color = (0, 255, 0) # Green
text_color = (0, 0, 0)  # Black

font = cv2.FONT_HERSHEY_SIMPLEX
font_scale = 2
font_thickness = 3

for annotation in annotations:
    text = annotation["text"]
    mistake = annotation["mistakes"]
    box_2d_scaled = annotation["box_2d"]

    # Convert scaled coordinates to pixel coordinates
    y_min_scaled, x_min_scaled, y_max_scaled, x_max_scaled = box_2d_scaled
    x_min = int((x_min_scaled) * img_width // 1000)
    y_min = int(y_min_scaled * img_height // 1000)
    x_max = int((x_max_scaled) * img_width // 1000)
    y_max = int(y_max_scaled * img_height // 1000)


    # Draw bounding box
    cv2.rectangle(img, (x_min, y_min), (x_max, y_max), box_color, 2)

    # Put text above the bounding box
    text_position = (x_max, y_min - 10 if y_min - 10 > 10 else y_min + 20) # Adjust text position to be above, or below if too close to top
    text_position_mistake = (x_max, y_min - 30 if y_min - 10 > 10 else y_min + 40) # Adjust text position to be above, or below if too close to top
    cv2.putText(img, text, text_position, font, font_scale, text_color, font_thickness, cv2.LINE_AA)
    cv2.putText(img, mistake, text_position_mistake, font, font_scale, text_color, font_thickness, cv2.LINE_AA)

# Display the image
cv2.imshow("Annotated Image", img)
cv2.waitKey(0)
cv2.destroyAllWindows()

# Save the annotated image (optional)
cv2.imwrite("annotated_image_scaled.jpg", img)