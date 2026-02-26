import pandas as pd
import joblib
import matplotlib.pyplot as plt

from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import recall_score, accuracy_score, roc_auc_score, precision_score, roc_curve

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
    precision = precision_score(y_test, y_pred)

    joblib.dump(models, "model.pkl")

    with open("metrics.txt", "w") as f:
        f.write(f"Acurácia: {accuracy}\nRecall: {recall}\nAUC: {auc} \n Precision: {precision}")

    plt.figure(figsize=(10, 6))
    plt.plot()

    # 2. Criar o plot
    fpr, tpr, _ = roc_curve(y_test, prob)
    plt.figure(figsize=(8, 6))
    plt.plot(fpr, tpr, color='darkorange', lw=2, label=f'ROC curve (area = {auc:.2f})')
    plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('Receiver Operating Characteristic (ROC)')
    plt.legend(loc="lower right")

    # 3. Salvar como imagem para o CML ler
    plt.savefig("auc_plot.png")

if __name__ == "__main__":
    metrics = train_model("../data/music_clean.csv")
    print(metrics)
