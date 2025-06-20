import os
import pickle

import numpy as np
import pandas as pd
from sklearn.model_selection import KFold
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import RobustScaler
import xgboost as xgb

np.random.seed(42)

def train_xgboost(X, y, n_estimators=300, max_depth=6, learning_rate=0.05,
                  subsample=0.8, colsample_bytree=0.8, reg_alpha=1.0, reg_lambda=20.0,
                  min_child_weight=3):
    xgb_model = xgb.XGBRegressor(
        random_state=42,
        n_estimators=n_estimators,
        max_depth=max_depth,
        learning_rate=learning_rate,
        subsample=subsample,
        colsample_bytree=colsample_bytree,
        reg_alpha=reg_alpha,
        reg_lambda=reg_lambda,
        min_child_weight=min_child_weight,
    )
    xgb_model.fit(X, y)
    return xgb_model

def evaluate_xgboost(xgb_model, X, y):
    kf = KFold(n_splits=5, shuffle=True, random_state=42)
    scores = []
    for train_idx, val_idx in kf.split(X):
        X_tr, X_val = X[train_idx], X[val_idx]
        y_tr, y_val = y.iloc[train_idx], y.iloc[val_idx]
        xgb_model.fit(X_tr, y_tr)
        xgb_pred = np.clip(xgb_model.predict(X_val), 0, 112)
        rmse = np.sqrt(mean_squared_error(y_val, xgb_pred))
        scores.append(rmse)
    print(f"XGBoost 5-Fold CV RMSE: {np.mean(scores):.4f} ± {np.std(scores):.4f}")

def main():
    output_dir = "."
    os.makedirs(output_dir, exist_ok=True)

    SELECTED_FEATURES = [
        "numPins",
        "bboxPerim",
        "bboxX",
        "bboxY",
        "bboxArea",
    ]

    data = pd.read_csv(os.path.join(output_dir, "training.csv"))
    X = data[SELECTED_FEATURES]
    y = data["numVias"]

    scaler = RobustScaler()
    X_scaled = scaler.fit_transform(X)
    with open(os.path.join(output_dir, "scaler.pkl"), "wb") as f:
        pickle.dump(scaler, f)

    xgb_model = train_xgboost(
        X_scaled, y,
        n_estimators=1000,
        max_depth=8,
        learning_rate=0.01,
        subsample=0.8,
        colsample_bytree=1.0,
        reg_alpha=1.0,
        reg_lambda=20.0,
        min_child_weight=5
    )

    evaluate_xgboost(xgb_model, X_scaled, y)

    with open(os.path.join(output_dir, "xgb_model.pkl"), "wb") as f:
        pickle.dump(xgb_model, f)

    print(f"Training complete. Model saved in {os.path.abspath(output_dir)}")

if __name__ == "__main__":
    main()
