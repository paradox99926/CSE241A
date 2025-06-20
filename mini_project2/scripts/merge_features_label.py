import pandas as pd 
import os

dfFeatures = pd.read_csv("training.features.csv")
dfLabel = pd.read_csv("training.label.csv")

print(dfFeatures)
print(dfLabel)

dfMerged = dfFeatures.merge(dfLabel, on=['netName', 'util', 'cp'])
print(dfMerged)

outCsv = "training.csv"
outCsv = os.path.join("data", "training.csv")
dfMerged.to_csv("training.csv", index=False, float_format='%.3f')
print(sum(dfMerged["numVias"]))
print(outCsv + " is generated")
