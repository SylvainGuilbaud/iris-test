/// Classe pour gérer les bulletins météo avec support des vektors
Class app.meteo Extends %Persistent [ ClassType = persistent, DdlAllowed, Final, Owner = {_SYSTEM}, ProcedureBlock, SqlRowIdPrivate, SqlTableName = meteo ]
{

/// Nom de la ville
Property ville As %Library.String(MAXLEN = 100) [ Required, SqlColumnNumber = 2 ];

/// Date du bulletin météo
Property dateBulletin As %Library.TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)}, SqlColumnNumber = 3 ];

/// Température en degrés Celsius
Property temperature As %Library.Numeric(SCALE = 2) [ SqlColumnNumber = 4 ];

/// Pourcentage d'humidité
Property humidite As %Library.Integer [ SqlColumnNumber = 5 ];

/// Pression atmosphérique en hPa
Property pression As %Library.Numeric(SCALE = 2) [ SqlColumnNumber = 6 ];

/// Vitesse du vent en km/h
Property ventVitesse As %Library.Numeric(SCALE = 2) [ SqlColumnNumber = 7 ];

/// Direction du vent
Property ventDirection As %Library.String(MAXLEN = 10) [ SqlColumnNumber = 8 ];

/// Condition météorologique (Ensoleillé, Nuageux, Pluie, etc.)
Property conditionMeteo As %Library.String(MAXLEN = 50) [ SqlColumnNumber = 9 ];

/// Description textuelle du bulletin
Property descriptionBulletin As %Library.String(MAXLEN = 500) [ SqlColumnNumber = 10 ];

/// Vekteur d'embedding pour les données météo (128 dimensions)
Property embeddingMeteo As %Library.Vector(DATATYPE = "DOUBLE", LEN = 128) [ SqlColumnNumber = 11 ];

Parameter USEEXTENTSET = 1;

/// Index DDL automatique
Index DDLBEIndex [ Extent, SqlName = "%%DDLBEIndex", Type = bitmap ];

/// Index sur la ville pour les recherches rapides
Index VilleIndex On ville [ SqlName = "VilleIdx" ];

/// Index sur la date pour les requêtes chronologiques
Index DateIndex On dateBulletin [ SqlName = "DateIdx" ];

/// Index sur la condition météo
Index ConditionIndex On conditionMeteo [ SqlName = "ConditionIdx" ];

/// Méthode pour insérer un bulletin météo avec vekteur
ClassMethod InsererBulletinMeteo(ville As %String, temperature As %Numeric, humidite As %Integer, pression As %Numeric, ventVitesse As %Numeric, ventDirection As %String, condition As %String, description As %String, embedding As %String) As %Status
{
    set bulletin = ..%New()
    set bulletin.ville = ville
    set bulletin.temperature = temperature
    set bulletin.humidite = humidite
    set bulletin.pression = pression
    set bulletin.ventVitesse = ventVitesse
    set bulletin.ventDirection = ventDirection
    set bulletin.conditionMeteo = condition
    set bulletin.descriptionBulletin = description
    
    // Convertir l'embedding JSON en vekteur - méthode simplifiée pour IRIS 2026.1
    if embedding '= "" {
        try {
            set bulletin.embeddingMeteo = ##class(%Library.Vector).%New(embedding)
        } catch ex {
            // Alternative: créer le vekteur directement via SQL
            &sql(SELECT TO_VECTOR(:embedding, 'DOUBLE') INTO :vectorData)
            if SQLCODE = 0 {
                set bulletin.embeddingMeteo = vectorData
            } else {
                write "Erreur création vekteur: ", SQLCODE, !
                return $$$ERROR($$$GeneralError, "Erreur création vekteur")
            }
        }
    }
    
    set status = bulletin.%Save()
    if $$$ISERR(status) {
        write "Erreur lors de la sauvegarde: ", $SYSTEM.Status.GetErrorText(status), !
    } else {
        write "Bulletin météo créé pour ", ville, " (ID: ", bulletin.%Id(), ")", !
    }
    
    return status
}

/// Méthode pour rechercher les bulletins similaires par vekteur
ClassMethod RechercherBulletinsSimilaires(villeReference As %String, limite As %Integer = 5) As %Status
{
    write "Recherche de bulletins similaires à ", villeReference, "...", !
    
    // Requête SQL avec similarité vectorielle
    set sql = "SELECT ville, temperature, humidite, conditionMeteo, "_
              "VECTOR_COSINE(embeddingMeteo, "_
              "(SELECT embeddingMeteo FROM app.meteo WHERE ville = ? ORDER BY dateBulletin DESC LIMIT 1)) as similarite "_
              "FROM app.meteo "_
              "WHERE ville != ? "_
              "ORDER BY similarite DESC "_
              "LIMIT ?"
    
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(sql)
    if $$$ISERR(status) {
        write "Erreur de préparation SQL: ", $SYSTEM.Status.GetErrorText(status), !
        return status
    }
    
    set result = statement.%Execute(villeReference, villeReference, limite)
    
    write "Bulletins les plus similaires:", !
    write "-----------------------------", !
    
    set rang = 1
    while result.%Next() {
        write rang, ". ", result.%Get("ville"), " - ", result.%Get("temperature"), "°C - ", 
              result.%Get("conditionMeteo"), " (Similarité: ", $FNUMBER(result.%Get("similarite"), "", 3), ")", !
        set rang = rang + 1
    }
    
    return $$$OK
}

/// Méthode pour rechercher par critères météo
ClassMethod RechercherParCriteres(tempMin As %Numeric = "", tempMax As %Numeric = "", condition As %String = "") As %Status
{
    set sql = "SELECT ville, dateBulletin, temperature, humidite, conditionMeteo FROM app.meteo WHERE 1=1"
    set params = []
    
    if tempMin '= "" {
        set sql = sql _ " AND temperature >= ?"
        set params($I(params)) = tempMin
    }
    
    if tempMax '= "" {
        set sql = sql _ " AND temperature <= ?"
        set params($I(params)) = tempMax
    }
    
    if condition '= "" {
        set sql = sql _ " AND conditionMeteo LIKE ?"
        set params($I(params)) = "%" _ condition _ "%"
    }
    
    set sql = sql _ " ORDER BY dateBulletin DESC LIMIT 10"
    
    set statement = ##class(%SQL.Statement).%New()
    set status = statement.%Prepare(sql)
    if $$$ISERR(status) return status
    
    // Exécuter avec les paramètres
    if params = 0 {
        set result = statement.%Execute()
    } elseif params = 1 {
        set result = statement.%Execute(params(1))
    } elseif params = 2 {
        set result = statement.%Execute(params(1), params(2))
    } else {
        set result = statement.%Execute(params(1), params(2), params(3))
    }
    
    write "Résultats de la recherche:", !
    write "-------------------------", !
    
    while result.%Next() {
        write result.%Get("ville"), " - ", $ZDATE(result.%Get("dateBulletin"), 3), " - ",
              result.%Get("temperature"), "°C - ", result.%Get("conditionMeteo"), !
    }
    
    return $$$OK
}

/// Méthode pour afficher les statistiques
ClassMethod AfficherStatistiques() As %Status
{
    write "Statistiques des données météo:", !
    write "===============================", !
    
    // Nombre total de bulletins
    &sql(SELECT COUNT(*) INTO :total FROM app.meteo)
    write "Total des bulletins: ", total, !
    
    // Température moyenne, min, max
    &sql(SELECT AVG(temperature), MIN(temperature), MAX(temperature) 
         INTO :tempMoy, :tempMin, :tempMax FROM app.meteo)
    write "Températures - Moy: ", $FNUMBER(tempMoy,"",1), "°C, Min: ", tempMin, "°C, Max: ", tempMax, "°C", !
    
    // Top 5 des villes avec le plus de bulletins
    write !
    write "Top 5 des villes:", !
    &sql(DECLARE c1 CURSOR FOR 
         SELECT ville, COUNT(*) as nb 
         FROM app.meteo 
         GROUP BY ville 
         ORDER BY nb DESC)
    &sql(OPEN c1)
    
    set rang = 1
    for {
        &sql(FETCH c1 INTO :ville, :nb)
        quit:SQLCODE'=0
        quit:rang>5
        write rang, ". ", ville, ": ", nb, " bulletins", !
        set rang = rang + 1
    }
    &sql(CLOSE c1)
    
    return $$$OK
}

/// Méthode pour générer des données météo fictives
ClassMethod GenererDonneesFictives(nombreBulletins As %Integer = 20) As %Status
{
    write "Génération de ", nombreBulletins, " bulletins météo fictifs...", !
    
    set villes = $LISTBUILD("Paris","Marseille","Lyon","Toulouse","Nice","Nantes","Strasbourg","Montpellier","Bordeaux","Lille")
    set conditions = $LISTBUILD("Ensoleillé","Nuageux","Pluie","Orage","Brouillard","Neige")
    
    for i = 1:1:nombreBulletins {
        set ville = $LIST(villes, $RANDOM($LISTLENGTH(villes)) + 1)
        set temperature = $RANDOM(40) - 10  // Entre -10 et 30°C
        set humidite = $RANDOM(80) + 20     // Entre 20 et 100%
        set pression = 1013 + $RANDOM(40) - 20  // Entre 993 et 1033 hPa
        set ventVitesse = $RANDOM(50)       // Entre 0 et 50 km/h
        set directions = $LISTBUILD("N","NE","E","SE","S","SW","W","NW")
        set ventDirection = $LIST(directions, $RANDOM($LISTLENGTH(directions)) + 1)
        set condition = $LIST(conditions, $RANDOM($LISTLENGTH(conditions)) + 1)
        set description = "Bulletin météo pour "_ville_": "_condition_", "_temperature_"°C."
        
        // Génération d'un vekteur d'embedding simple (128 dimensions)
        set embedding = "["
        for j = 1:1:128 {
            set valeur = $RANDOM(100) / 100  // Valeur aléatoire entre 0 et 1
            set embedding = embedding _ valeur
            if j < 128 set embedding = embedding _ ","
        }
        set embedding = embedding _ "]"
        
        set status = ..InsererBulletinMeteo(ville, temperature, humidite, pression, 
                                           ventVitesse, ventDirection, condition, description, embedding)
        
        if i # 5 = 0 {
            write "  → ", i, " bulletins générés...", !
        }
    }
    
    write "✓ Génération terminée!", !
    return $$$OK
}

Storage Default
{
<Data name="meteoDefaultData">
<Value name="1">
<Value>ville</Value>
</Value>
<Value name="2">
<Value>dateBulletin</Value>
</Value>
<Value name="3">
<Value>temperature</Value>
</Value>
<Value name="4">
<Value>humidite</Value>
</Value>
<Value name="5">
<Value>pression</Value>
</Value>
<Value name="6">
<Value>ventVitesse</Value>
</Value>
<Value name="7">
<Value>ventDirection</Value>
</Value>
<Value name="8">
<Value>conditionMeteo</Value>
</Value>
<Value name="9">
<Value>descriptionBulletin</Value>
</Value>
<Value name="10">
<Value>embeddingMeteo</Value>
</Value>
</Data>
<DataLocation>^app.meteoD</DataLocation>
<DefaultData>meteoDefaultData</DefaultData>
<ExtentLocation>^app.meteoS</ExtentLocation>
<IdLocation>^app.meteoD</IdLocation>
<Index name="ConditionIndex">
<Location>^app.meteoS.2</Location>
</Index>
<Index name="DDLBEIndex">
<Location>^app.meteoS.3</Location>
</Index>
<Index name="DateIndex">
<Location>^app.meteoS.4</Location>
</Index>
<Index name="IDKEY">
<Location>^app.meteoS.1</Location>
</Index>
<Index name="VilleIndex">
<Location>^app.meteoS.5</Location>
</Index>
<IndexLocation>^app.meteoI</IndexLocation>
<StreamLocation>^app.meteoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}