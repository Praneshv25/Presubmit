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


app = Flask(__name__)
load_dotenv()
cors = CORS(app, resources={r"/api/*": {"origins": "*"}})
GOOGLE_CLIENT_ID = "YOUR_GOOGLE_CLOUD_PROJECT_ID"  # Replace with your project ID


class Annotation(BaseModel):
    text: str
    box_2d: list[int]
    mistakes: str


class SubmissionData(BaseModel):
    symbol: str
    annotations: list[Annotation]

class RequestData(BaseModel):
    image: str #base64 encoded image
    symbols: list[str]

@app.route("/")
def hello_world():
    return "<p>Presubmit backend!</p>"


@app.post("/api/process-image")
def process_image():
    try:
        id_token_str = request.headers.get("Authorization").split("Bearer ")[1]
        id_info = id_token.verify_oauth2_token(id_token_str, requests.Request(), GOOGLE_CLIENT_ID)

        id_info = id_token.verify_oauth2_token(
            id_token_str, requests.Request(), GOOGLE_CLIENT_ID
        )

        if id_info["iss"] not in [
            "accounts.google.com",
            "https://accounts.google.com",
        ]:
            raise ValueError("Wrong issuer.")

        request_data = RequestData.model_validate_json(request.data) 

        image_data = base64.b64decode(request_data.image)
        image_file = Image.open(io.BytesIO(image_data))

        symbols = request_data.symbols

        results = process_submission(image_file, symbols) # type: ignore
        submission_data = SubmissionData(symbol="detected_symbol", annotations=results)
        return jsonify(submission_data.model_dump()), 200

    except ValueError as e:
        return jsonify({"error": str(e)}), 401
    except Exception as e:
        return jsonify({"error": "Image processing failed", "details": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)