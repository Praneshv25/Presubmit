from functools import wraps
from typing import Callable
from flask import Flask, request, jsonify
from dotenv import load_dotenv
from flask_cors import CORS
from mrgemmy import process_submission
from pydantic import BaseModel
from google.oauth2 import id_token
from google.auth.transport import requests
import base64
import io
from PIL import Image
import os


app = Flask(__name__)
load_dotenv()
cors = CORS(app)
GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")  # Replace with your project ID

class Annotation(BaseModel):
    text: str
    box_2d: list[int]
    mistakes: str

class SubmissionData(BaseModel):
    symbol: str
    annotations: list[Annotation]
    
class SingleImageData(BaseModel):
    image: str
    symbols: list[str] = []
    
class MultiImageData(BaseModel):
    images: list[SingleImageData]
    
def authenticate(func: Callable) -> Callable:
    @wraps(func)  # Preserves function metadata
    def wrapper(*args, **kwargs):
        # print("insidewrapper")
        try:
            # print(request.headers)
            auth_header = request.headers.get("Authorization")
            if not auth_header:
                raise ValueError("Missing Authorization header")
            
            # print(auth_header)
                
            id_token_str = auth_header.split("Bearer ")[1]
            # print(id_token_str)
            
            id_info = id_token.verify_oauth2_token(
                id_token_str, requests.Request(), GOOGLE_CLIENT_ID
            )
            
            # print(id_info)

            if id_info["iss"] not in [
                "accounts.google.com",
                "https://accounts.google.com",
            ]:
                raise ValueError("Wrong issuer.")

            return func(*args, **kwargs)

        except ValueError as e:
            return jsonify({"error": str(e)}), 401

    return wrapper

@app.route("/")
def hello_world():
    return "<p>Presubmit backend!</p>"


@app.post("/api/process-image")
@authenticate
def process_image():
    # print("got request")
    try:
        request_data = SingleImageData.model_validate_json(request.data) 
        
        print("image len", len(request_data.image))

        image_data = base64.b64decode(request_data.image)
        
        image_file = Image.open(io.BytesIO(image_data))

        symbols = request_data.symbols

        results = process_submission(image_file, symbols) # type: ignore
        return jsonify(results.model_dump()), 200

    except ValueError as e:
        print("value exception", e)
        return jsonify({"error": str(e)}), 401
    except Exception as e:
        print("unknown exception", e)
        return jsonify({"error": "Image processing failed", "details": str(e)}), 500
    
@app.post("/api/process-multiple-images")
@authenticate
def process_multiple_images():
    try:
        request_data = MultiImageData.model_validate_json(request.data)
        results = []

        for image_data in request_data.images:
            try:
                image_bytes = base64.b64decode(image_data.image)
                image = Image.open(io.BytesIO(image_bytes))
                
                # Process the single image (assuming process_submission takes a single image)
                single_image_results = process_submission(image, image_data.symbols) #type: ignore

                results.append({
                    "image": image_data.image, # Could return a unique ID instead
                    "annotations": single_image_results #type: ignore
                })
            except Exception as e:
              results.append({
                  "image": image_data.image,
                  "error": str(e)
                })

        return jsonify(results), 200

    except ValueError as e:
        return jsonify({"error": str(e)}), 401
    except Exception as e:
        return jsonify({"error": "Image processing failed", "details": str(e)}), 500



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
