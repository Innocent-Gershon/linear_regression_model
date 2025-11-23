from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import numpy as np
from typing import List
import pickle
import sys
from pathlib import Path

app = FastAPI(
    title="Exam Score Prediction API",
    description="Linear Regression API for Student Exam Score Prediction",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic model with all exam score features
class ExamScorePredictionInput(BaseModel):
    hours_studied: int = Field(..., ge=1, le=44, description="Hours studied (1-44)")
    attendance: int = Field(..., ge=60, le=100, description="Attendance percentage (60-100)")
    previous_scores: int = Field(..., ge=50, le=100, description="Previous scores (50-100)")
    tutoring_sessions: int = Field(..., ge=0, le=8, description="Tutoring sessions (0-8)")
    parental_involvement_low: int = Field(..., ge=0, le=1, description="Parental involvement low (0 or 1)")
    parental_involvement_medium: int = Field(..., ge=0, le=1, description="Parental involvement medium (0 or 1)")
    access_to_resources_low: int = Field(..., ge=0, le=1, description="Access to resources low (0 or 1)")
    access_to_resources_medium: int = Field(..., ge=0, le=1, description="Access to resources medium (0 or 1)")
    extracurricular_activities_yes: int = Field(..., ge=0, le=1, description="Extracurricular activities (0 or 1)")
    motivation_level_low: int = Field(..., ge=0, le=1, description="Motivation level low (0 or 1)")
    internet_access_yes: int = Field(..., ge=0, le=1, description="Internet access (0 or 1)")
    family_income_low: int = Field(..., ge=0, le=1, description="Family income low (0 or 1)")
    family_income_medium: int = Field(..., ge=0, le=1, description="Family income medium (0 or 1)")
    teacher_quality_low: int = Field(..., ge=0, le=1, description="Teacher quality low (0 or 1)")
    teacher_quality_medium: int = Field(..., ge=0, le=1, description="Teacher quality medium (0 or 1)")
    peer_influence_positive: int = Field(..., ge=0, le=1, description="Peer influence positive (0 or 1)")
    learning_disabilities_yes: int = Field(..., ge=0, le=1, description="Learning disabilities (0 or 1)")
    parental_education_level_high_school: int = Field(..., ge=0, le=1, description="Parental education high school (0 or 1)")
    parental_education_level_postgraduate: int = Field(..., ge=0, le=1, description="Parental education postgraduate (0 or 1)")
    distance_from_home_moderate: int = Field(..., ge=0, le=1, description="Distance from home moderate (0 or 1)")
    distance_from_home_near: int = Field(..., ge=0, le=1, description="Distance from home near (0 or 1)")

class PredictionOutput(BaseModel):
    predicted_exam_score: float
    status: str

# Your trained model coefficients
# We'll attempt a safe, non-executing extraction of parameters from the
# pickle file below; avoid unpickling at import time to prevent environment
# dependent crashes. MODEL remains None unless explicitly loaded at runtime.
MODEL = None
MODEL_PATH = Path(__file__).parent / "linear_regression_model.pkl"

# If we couldn't load the sklearn object due to environment incompatibility,
# try to safely extract numeric parameters (coef_ and intercept_) directly
# from the pickle file without executing it. This uses pickletools to locate
# binary float buffers in the file and heuristically picks the block with the
# expected number of features as the coefficients and a single-float block as
# the intercept.
MODEL_COEFFICIENTS = None
MODEL_INTERCEPT = None
def _extract_params_from_pickle(pickle_path, expected_n_features=21):
    """Return (coef_array, intercept) or (None, None) if extraction fails."""
    try:
        import pickletools, struct
        data = Path(pickle_path).read_bytes()
        ops = list(pickletools.genops(data))
        float_blocks = []
        for opcode, arg, pos in ops:
            if opcode.name in ('SHORT_BINBYTES', 'BINBYTES'):
                b = arg
                ln = len(b)
                if ln % 8 != 0:
                    continue
                n = ln // 8
                # unpack as little-endian float64
                vals = struct.unpack('<' + 'd'*n, b)
                float_blocks.append((n, vals))

        # Heuristic: pick the block with length == expected_n_features as coef,
        # and a block with length==1 as intercept.
        coef = None
        intercept = None
        for n, vals in float_blocks:
            if n == expected_n_features and coef is None:
                coef = list(vals)
            elif n == 1 and intercept is None:
                intercept = float(vals[0])

        if coef is not None and intercept is not None:
            return (np.array(coef, dtype=float), float(intercept))
    except Exception as e:
        print(f"Safe extraction from pickle failed: {e}")
    return (None, None)

if MODEL is None and MODEL_PATH.exists():
    coef, intercept = _extract_params_from_pickle(MODEL_PATH, expected_n_features=21)
    if coef is not None:
        MODEL_COEFFICIENTS = coef
        MODEL_INTERCEPT = intercept
        print(f"Extracted coefficients (len={len(coef)}) and intercept from {MODEL_PATH}")
    else:
        print("Could not extract coefficients from pickle; no fallback coefficients available.")

def make_prediction(features: List[float]) -> float:
    """Make exam score prediction using the loaded model if available, otherwise fall back to parsed coefficients.

    Returns a float clamped to the same bounds as before.
    """
    features_array = np.array(features, dtype=float).reshape(1, -1)

    # Scale continuous features to the ranges likely used during training.
    # Assumptions (based on feature constraints):
    # - hours_studied: 1-44  -> scale by 44
    # - attendance: 60-100   -> percentage, scale by 100
    # - previous_scores: 50-100 -> percentage, scale by 100
    # - tutoring_sessions: 0-8 -> scale by 8
    # Binary features remain unchanged (0/1).
    scaled = features_array.flatten().astype(float)
    try:
        scaled[0] = scaled[0] / 44.0
        scaled[1] = scaled[1] / 100.0
        scaled[2] = scaled[2] / 100.0
        scaled[3] = scaled[3] / 8.0
    except Exception:
        # If scaling fails for any reason, fall back to unscaled features
        scaled = features_array.flatten().astype(float)

    # Prefer using the full sklearn model if it's been loaded
    if MODEL is not None:
        try:
            # If a full sklearn model is available, pass the scaled features.
            pred = MODEL.predict(scaled.reshape(1, -1))
            prediction = float(pred[0])
        except Exception as e:
            raise RuntimeError(f"Model prediction failed: {e}")
    else:
        # Fall back to coefficients extracted from the pickle (or hard-coded)
        if MODEL_COEFFICIENTS is None or MODEL_INTERCEPT is None:
            raise RuntimeError(f"No trained model or extracted coefficients available. Expected file at {MODEL_PATH}")
        # Use the scaled features for the linear calculation as well.
        prediction = float(np.dot(scaled, MODEL_COEFFICIENTS) + MODEL_INTERCEPT)

    # Clip prediction to percentage range 0.0 - 100.0
    return float(max(min(float(prediction), 100.0), 0.0))

@app.get("/")
async def root():
    return {
        "message": "Exam Score Prediction API", 
        "docs": "/docs",
        "features": 21,
        "target": "exam_score",
        "example_request": {
            "hours_studied": 20,
            "attendance": 85,
            "previous_scores": 75,
            "tutoring_sessions": 2,
            "parental_involvement_low": 0,
            "parental_involvement_medium": 1,
            "access_to_resources_low": 0,
            "access_to_resources_medium": 1,
            "extracurricular_activities_yes": 1,
            "motivation_level_low": 0,
            "internet_access_yes": 1,
            "family_income_low": 0,
            "family_income_medium": 1,
            "teacher_quality_low": 0,
            "teacher_quality_medium": 1,
            "peer_influence_positive": 1,
            "learning_disabilities_yes": 0,
            "parental_education_level_high_school": 1,
            "parental_education_level_postgraduate": 0,
            "distance_from_home_moderate": 1,
            "distance_from_home_near": 0
        }
    }

@app.post("/predict", response_model=PredictionOutput)
async def predict(input_data: ExamScorePredictionInput):
    try:
        print(f"Received data: {input_data}")
        
        features = [
            float(input_data.hours_studied),
            float(input_data.attendance),
            float(input_data.previous_scores),
            float(input_data.tutoring_sessions),
            float(input_data.parental_involvement_low),
            float(input_data.parental_involvement_medium),
            float(input_data.access_to_resources_low),
            float(input_data.access_to_resources_medium),
            float(input_data.extracurricular_activities_yes),
            float(input_data.motivation_level_low),
            float(input_data.internet_access_yes),
            float(input_data.family_income_low),
            float(input_data.family_income_medium),
            float(input_data.teacher_quality_low),
            float(input_data.teacher_quality_medium),
            float(input_data.peer_influence_positive),
            float(input_data.learning_disabilities_yes),
            float(input_data.parental_education_level_high_school),
            float(input_data.parental_education_level_postgraduate),
            float(input_data.distance_from_home_moderate),
            float(input_data.distance_from_home_near)
        ]
        
        print(f"Features array: {features}")
        prediction = make_prediction(features)
        print(f"Prediction result: {prediction}")
        
        return PredictionOutput(
            predicted_exam_score=round(prediction, 2),
            status="success"
        )
    
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        raise HTTPException(status_code=400, detail=f"Prediction error: {str(e)}")

@app.get("/health")
async def health_check():
    return {"status": "healthy"}