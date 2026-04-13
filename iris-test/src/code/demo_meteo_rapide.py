#!/usr/bin/env python3
"""
Script d'exemple rapide pour la démo météo IRIS
Version avec gestion d'erreurs de connexion améliorée
"""

import json

def demo_rapide():
    """Démonstration rapide des fonctionnalités météo"""
    
    print("🌤️  DÉMONSTRATION RAPIDE MÉTÉO-VEKTORS")
    print("=" * 45)
    
    try:
        # Tentative de connexion à IRIS
        import iris
        conn = iris.connect("localhost", 1972, "IRISAPP", "_SYSTEM", "SYS")
        cursor = conn.cursor()
        print("✓ Connecté à IRIS (IRISAPP)")
        
        # Vérifier si des données existent
        cursor.execute("SELECT COUNT(*) FROM app.meteo")
        count = cursor.fetchone()[0]
        
        if count == 0:
            print("⚠️  Aucune donnée trouvée.")
            print("💡 Solutions:")
            print("   1. Exécutez meteo_demo_objectscript.py")
            print("   2. Ou utilisez les commandes ObjectScript directement")
            return
        
        print(f"📊 {count} bulletins météo disponibles")
        
        # Exemple 1: Derniers bulletins par ville
        print("\n📋 Derniers bulletins par ville:")
        print("-" * 40)
        cursor.execute("""
            SELECT ville, temperature, condition_meteo, description_bulletin
            FROM app.meteo 
            WHERE date_bulletin IN (
                SELECT MAX(date_bulletin) 
                FROM app.meteo 
                GROUP BY ville
            )
            ORDER BY ville
            LIMIT 5
        """)
        
        for ville, temp, condition, desc in cursor.fetchall():
            print(f"🏙️  {ville:10} | {temp:5.1f}°C | {condition}")
            print(f"    📝 {desc[:50]}...")
        
        # Exemple 2: Recherche de villes avec temps similaire à Paris
        print(f"\n🔍 Villes avec météo similaire à Paris:")
        print("-" * 40)
        cursor.execute("""
            SELECT 
                ville,
                temperature,
                condition_meteo,
                VECTOR_COSINE(embedding_meteo, (
                    SELECT embedding_meteo 
                    FROM app.meteo 
                    WHERE ville = 'Paris' 
                    ORDER BY date_bulletin DESC 
                    LIMIT 1
                )) as similarite
            FROM app.meteo 
            WHERE ville != 'Paris'
            ORDER BY similarite DESC
            LIMIT 3
        """)
        
        for ville, temp, condition, sim in cursor.fetchall():
            print(f"🎯 {ville:10} | {temp:5.1f}°C | {condition:15} | Sim: {sim:.3f}")
        
        # Exemple 3: Statistiques rapides
        print(f"\n📈 Statistiques rapides:")
        print("-" * 25)
        cursor.execute("""
            SELECT 
                MIN(temperature) as temp_min,
                MAX(temperature) as temp_max,
                AVG(temperature) as temp_avg,
                COUNT(DISTINCT ville) as nb_villes
            FROM app.meteo
        """)
        
        temp_min, temp_max, temp_avg, nb_villes = cursor.fetchone()
        print(f"🌡️  Températures: {temp_min:.1f}°C ↔ {temp_max:.1f}°C (moy: {temp_avg:.1f}°C)")
        print(f"🏙️  Nombre de villes: {nb_villes}")
        
        conn.close()
        print("\n✨ Démonstration terminée!")
        
    except ImportError:
        print("❌ Module iris non disponible")
        print("💡 Installation requise: pip install intersystems-irispython")
        print("💡 Alternative: Utilisez meteo_demo_objectscript.py")
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        print("💡 Solutions:")
        print("   1. Vérifiez qu'IRIS est démarré")
        print("   2. Vérifiez que la table app.meteo existe")
        print("   3. Utilisez meteo_demo_objectscript.py")

if __name__ == "__main__":
    demo_rapide()