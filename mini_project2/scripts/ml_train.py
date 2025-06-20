import pandas as pd
from scipy import stats 
from sklearn import linear_model

# to save model
import pickle


df = pd.read_csv("training.csv")

# build ML model using scipy LinearRegression
reg = linear_model.LinearRegression()
var = df[['bboxArea','bboxAr', 'numPins']]
label = df['numVias']

reg.fit(var, label)
# print("trained coeff:", reg.coef_)
# print(reg.score(var, label))

# save ML model
fileName = "linearRegression.sav"
pickle.dump(reg, open(fileName, "wb"))
