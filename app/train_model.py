import pandas as pd
import joblib

from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import recall_score, accuracy_score, roc_auc_score

def train_model(data):
    data = pd.read_csv(data)

    database = data.drop("Unnamed: 0", axis=1)
    X= database.drop("genre", axis=1)
    y = database["genre"]

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    models=RandomForestClassifier(n_estimators=100, random_state=42)
    models.fit(X_train, y_train)
    y_pred = models.predict(X_test)

    accuracy = accuracy_score(y_test, y_pred)
    recall = recall_score(y_test, y_pred)
    prob=models.predict_proba(X_test)[:, 1]
    auc = roc_auc_score(y_test, prob)

    joblib.dump(models, "model.pkl")

    return {
        "accuracy": accuracy,
        "recall": recall,
        "auc": auc
    }

if __name__ == "__main__":
    metrics = train_model("../data/music_clean.csv")
    print(metrics)
