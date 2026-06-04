import pandas as pd
from sqlalchemy import create_engine
from datetime import datetime

# Paramètres de connexion
HOST = "localhost"
PORT = 10972
NAMESPACE = "IRISAPP"
USERNAME = "_SYSTEM"
PASSWORD = "SYS"

# Création de l'engine
engine = create_engine(
    f"iris://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{NAMESPACE}"
)

# Requête SQL
query = """
SELECT
ID, TimeLogged,Type,ConfigName, Job, MessageId, SessionId, SourceClass, SourceMethod, Text, Stack,StatusValue, TraceCat
FROM Ens_Util.Log
WHERE TimeLogged >= CURRENT_DATE
  AND TimeLogged < DATEADD('day', 1, CURRENT_DATE)
"""

# Lecture des données
df = pd.read_sql(query, engine)

filename = f"export_event_log_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.csv"

# Export CSV
df.to_csv(filename, sep=";", index=False, encoding="utf-8-sig")

print(f"{len(df)} lignes exportées vers {filename}")