import requests
import base64
import json
import os

# Replace with your actual backend URL
BACKEND_URL = "http://localhost:8080"  # If running locally
# BACKEND_URL = "your-deployed-backend-url" # If deployed


def process_image(image_path, id_token, symbols=None):
    """
    Sends a single image to the backend for processing.
    """

    with open(image_path, "rb") as image_file:
        base64_image = base64.b64encode(image_file.read()).decode("utf-8")

    headers = {
        "Authorization": f"Bearer {id_token}",
        "Content-Type": "application/json",
    }


    data = {"image": base64_image, "symbols": symbols or []}

    response = requests.post(
        f"{BACKEND_URL}/api/process-image", headers=headers, json=data
    )
    response.raise_for_status() #raise HTTPError for bad responses (4xx or 5xx)

    return response.json()


def process_multiple_images(image_paths, id_token):
    """
    Sends multiple images to the backend for processing.
    """
    image_data_list = []
    for image_path in image_paths:
        with open(image_path, "rb") as image_file:
          base64_image = base64.b64encode(image_file.read()).decode('utf-8')
          image_data_list.append({"image": base64_image})


    headers = {
        "Authorization": f"Bearer {id_token}",
        "Content-Type": "application/json",
    }

    data = {"images": image_data_list}

    response = requests.post(
        f"{BACKEND_URL}/api/process-multiple-images", headers=headers, json=data
    )
    response.raise_for_status()

    return response.json()


if __name__ == "__main__":
  # Replace with a valid ID token (retrieve from your frontend authentication flow)
  id_token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjVkMTJhYjc4MmNiNjA5NjI4NWY2OWU0OGFlYTk5MDc5YmI1OWNiODYiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIxMDAxMzA3NDgyOTc2LTU3bmh2N3B2cXI5bm02NTdwNWw0djlkamEycGloM3Z2LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiYXVkIjoiMTAwMTMwNzQ4Mjk3Ni01N25odjdwdnFyOW5tNjU3cDVsNHY5ZGphMnBpaDN2di5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsInN1YiI6IjEwNDEyMDc1MTkzMjQ1NzkwOTc2NCIsImVtYWlsIjoiemhhby53ZW50YW8udmluY2VudEBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6IkZzaHBpX3VZNFBaY2x2MDBiY3pERmciLCJub25jZSI6InJpSDVqdlpwX0RJZzNJcVJXREhmZHl2YUY1c2R3c1VBOXVWMXpVZzdCQkkiLCJuYW1lIjoiVmluY2VudCBaaGFvIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hL0FDZzhvY0x6eEF5QV9JVHhuRkdnaE1Od2luQVprNVRQeWV5SDBXNGJONE9zbG5NQlFVbndpNU5BTXc9czk2LWMiLCJnaXZlbl9uYW1lIjoiVmluY2VudCIsImZhbWlseV9uYW1lIjoiWmhhbyIsImlhdCI6MTc0MDIzNTc4OCwiZXhwIjoxNzQwMjM5Mzg4fQ.WeOlr22xNsBBoUaVRVb0hMzMSBh8JWm1bWBeFJr2bQwzhF94zCDTXIaio6mN16yYryjc2FQ1wgNnFU3SeB0Ud-Dx8JAC3mi63AlZM7ilHQtlJ06XFMhoKxxLAbgudG_wlM2QTvAloI-QPc1JaVbKiuEWPFXb8bTO2E8ZDyzV9uolmI5babsjPy5PH2gsGb_y14IH2huNBHIBJ8zk2WzDyQ5k5QKUu1DATu1-7T0jZNmnNaFMwb95N8a2SEj0-GUjaBHtll62syjwZ_LCugqKrL7ws72jJG302gjBUqIefpLfr7oWuqpgHtqoJ1y-mxwAADFtrim5cVaeqY5xgstI5A"
  # Example Usage (Single Image)
  try:
      image_path = "./test_star.jpeg" 
      result = process_image(image_path, id_token, symbols=['A', 'B'])
      print("Single Image Result:", json.dumps(result, indent=2))



      #Example Usage (multiple images)
    #   image_paths = ["path/to/image1.jpg", "path/to/image2.png"]
    #   results = process_multiple_images(image_paths, id_token)
    #   print("Multiple Images Result:", json.dumps(results, indent=2))


  except requests.exceptions.RequestException as e:
      print(f"Error: {e}")
  except FileNotFoundError:
      print(f"Error: Image file not found ")
  except Exception as e:
        print(f"An unexpected error occurred: {e}")