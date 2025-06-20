import pandas as pd
import numpy as np
from sklearn.preprocessing import RobustScaler
import xgboost as xgb
import pickle
import os

output_dir = '.'

# data = pd.read_csv(os.path.join(output_dir, 'training_rmse1_v20.csv'))
# data = pd.read_csv(os.path.join(output_dir, 'training_rmse2_v20.csv'))
# data = pd.read_csv(os.path.join(output_dir, 'training_rmse1_v21.csv'))
data = pd.read_csv(os.path.join(output_dir, 'training_rmse2_v21.csv'))



SELECTED_FEATURES = ['numPins', 'bboxPerim', 'bboxX', 'bboxY', 'bboxArea']

X = data[SELECTED_FEATURES]

scaler = pickle.load(open(os.path.join(output_dir, 'scaler.pkl'), 'rb'))
xgb_model = pickle.load(open(os.path.join(output_dir, 'xgb_model.pkl'), 'rb'))

X_scaled = scaler.transform(X)

predictions = np.clip(xgb_model.predict(X_scaled), 0, 112)

with open(os.path.join(output_dir, 'inference.csv'), 'w') as f:
    f.write("numVias\n")
    np.savetxt(f, predictions, delimiter=",", fmt='%.3f')

print(f"Inference results saved to 'inference.csv' with {len(predictions)} predictions")