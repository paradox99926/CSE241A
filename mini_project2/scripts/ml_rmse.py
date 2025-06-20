import pandas as pd
import numpy as np

def rmse(predictions, targets):
  return np.sqrt(((predictions - targets) ** 2).mean())

# merge three *.csv into one pandas dataframe 
dfTrain = pd.read_csv("training.csv")
dfInf = pd.read_csv("inference.csv")

trainVar = np.asarray(list(dfTrain['numVias']))
infVar = np.asarray(list(dfInf['numVias']))

rmse = rmse(trainVar, infVar)
print("RMSE: ", rmse)
