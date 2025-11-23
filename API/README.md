# ML Prediction API

FastAPI-based machine learning prediction service with linear regression.

## Features

✅ **FastAPI** framework with automatic OpenAPI documentation  
✅ **CORS middleware** for cross-origin requests  
✅ **Pydantic models** with data type enforcement and range constraints  
✅ **POST endpoint** `/predict` for predictions  
✅ **Swagger UI** documentation at `/docs`  

## API Endpoints

- `GET /` - Root endpoint
- `POST /predict` - Make predictions
- `GET /health` - Health check
- `GET /docs` - Swagger UI documentation

## Input Constraints

All features must be floats between -100 and 100:
- `feature1`: float (-100 to 100)
- `feature2`: float (-100 to 100) 
- `feature3`: float (-100 to 100)
- `feature4`: float (-100 to 100)

## Local Development

```bash
pip install -r requirements.txt
uvicorn main:app --reload
```

## Model loading

The API looks for a serialized scikit-learn model at `linear_regression_model.pkl` in the same folder.

- At startup the app will prefer to load the sklearn model object if the environment supports it.
- If the environment can't safely unpickle the sklearn object, the server will fall back to extracting
  the learned `coef_` and `intercept_` directly from the pickle file (safe, non-executing parsing).

Quick verification (uses the included virtualenv if present):

```bash
# from repo root
"API/.venv/bin/python3" API/test_load.py
```

If the extraction succeeds you'll see the extracted coefficients and a sample prediction. To run the API:

```bash
# activate venv (macOS / Linux)
source API/.venv/bin/activate
pip install -r API/requirements.txt
# then run server
uvicorn API.main:app --reload
```

## Deployment

Deploy to Render using the included `render.yaml` configuration.

## Example Request

```json
{
  "feature1": 1.5,
  "feature2": -2.0,
  "feature3": 0.5,
  "feature4": 3.2
}
```

## Example Response

```json
{
  "prediction": 7.85,
  "status": "success"
}
```