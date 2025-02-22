from google import genai

from PIL import Image

client = genai.Client(api_key="AIzaSyC4mQlm2o71oVYpHzSakJRmcsiwF5mR0_I")

image = Image.open('./test_question2.jpeg')
image = image.resize((int(image.width / 2), int(image.height / 2)))

prompt = [
    "Identify the dominant shape in the image's top-left corner. Select one: star, square, triangle, diamond.",
    image
]


def find_upload_spot():
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt,
    )

    return response.text

print(find_upload_spot())