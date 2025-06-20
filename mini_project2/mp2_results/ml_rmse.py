import pandas as pd
import numpy as np

def rmse(predictions, targets):
  return np.sqrt(((predictions - targets) ** 2).mean())

# dfTrain = pd.read_csv("training_rmse1_v20.csv")
# dfTrain = pd.read_csv("training_rmse2_v20.csv")
# dfTrain = pd.read_csv("training_rmse1_v21.csv")
dfTrain = pd.read_csv("training_rmse2_v21.csv")

dfInf = pd.read_csv("inference.csv")

trainVar = np.asarray(list(dfTrain['numVias']))
infVar = np.asarray(list(dfInf['numVias']))

rmse = rmse(trainVar, infVar)
print("RMSE: ", rmse)
