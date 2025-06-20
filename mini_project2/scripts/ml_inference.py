import pandas as pd
import numpy as np
from scipy import stats 
from sklearn import linear_model

# to load model
import pickle

fileName = "linearRegression.sav"
reg = pickle.load(open(fileName, 'rb'))

df = pd.read_csv("training.csv" )

var = df[['bboxArea','bboxAr', 'numPins']]
label = df['numVias']

  # save inference CSV
with open('inference.csv', 'wb') as f:
  f.write(b"numVias\n") 
  np.savetxt(f, reg.predict(var), delimiter=",", fmt='%.3f')

