from google import genai
from pydantic import BaseModel, TypeAdapter
import os
from dotenv import load_dotenv
import cv2

from PIL import Image


load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
client = genai.Client(api_key=GEMINI_API_KEY)

class Annotation(BaseModel):
    text: str
    box_2d: list[int]
    mistakes: str
    
class SubmissionData(BaseModel):
    symbol: str
    annotations: list[Annotation]


def process_submission(image, symbols=False):
    prompt = [
        """
        Find mistakes in this person's work
        """, 
        image
    ]

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt,
    )


    prompt = [
        f"""
        {response.text}
        
        For the annotations field, return a bounding box for each of the section of math in this image. Include any mistakes about the math in these sections, if no mistakes just have an empty string.
        {f"For the symbol field, identify which of the following symbols is in the top corner {symbols}, if none are there leave field empty" if symbols else "" }
        """, 
        image,
        """
        in the format [ymin, xmin, ymax, xmax]. 
        """
    ]

    response = client.models.generate_content(
        model="gemini-1.5-pro",
        contents=prompt,
        config={
            'response_mime_type': 'application/json',
            'response_schema': SubmissionData,
        },
    )

    print(response.text)
    
    submissionData: SubmissionData = response.parsed
    
    return submissionData

if __name__ == "__main__":
    image = Image.open('./test_star.jpeg')
    image = image.resize((int(image.width / 1.5), int(image.height / 1.5)))
    process_submission(image, symbols=["star", "square", "circle"])