# Objet : comportement de l'opération DGLab en cas d'indisponibilité de la cible

Bonjour,

Voici un résumé du comportement de l'opération `PatientsIn_2Op_HL7ADT_MLLP_DGLabOld` lorsque la cible TCP située sur `localhost:8011` se déconnecte ou devient indisponible.

## Fonctionnement de l'opération

Le flux est le suivant :

```text
Service HL7 entrant sur le port 8010
        -> file de l'opération
        -> connexion TCP vers localhost:8011
        -> envoi du message HL7/MLLP
```

Lorsque la cible est disponible, IRIS ouvre la connexion et transmet le message.

Lorsque la connexion existante est perdue, IRIS journalise normalement :

```text
Warning: Lost TCP connection to localhost:8011
Info: Disconnecting from localhost:8011
```

L'opération conserve ensuite son fonctionnement et tente de se reconnecter.

Si une nouvelle tentative de connexion n'aboutit pas avant l'expiration de `ConnectTimeout`, IRIS génère :

```text
ERROR <Ens>ErrOutConnectExpired:
TCP Connect timeout period (...) expired for localhost:8011
```

Cette erreur signifie que la tentative de reconnexion a échoué. Elle ne signifie pas nécessairement que le message est perdu : l'opération continue normalement son mécanisme de retry et la livraison dépend de la disponibilité ultérieure de la cible.

## Rôle des paramètres

### `ConnectTimeout`

Durée maximale d'une tentative de connexion TCP.

```xml
<Setting Target="Adapter" Name="ConnectTimeout">10</Setting>
```

Une valeur élevée réduit la fréquence des erreurs visibles, mais une tentative peut rester bloquée plus longtemps.

### `RetryInterval`

Intervalle entre deux tentatives de livraison.

```xml
<Setting Target="Host" Name="RetryInterval">60</Setting>
```

Une valeur de 60 secondes permet de retenter régulièrement sans générer des tentatives trop rapprochées.

### `NoFailWhileDisconnected`

```xml
<Setting Target="Host" Name="NoFailWhileDisconnected">1</Setting>
```

Ce paramètre aide IRIS à tolérer la perte d'une connexion déjà établie et à poursuivre les retries. Il ne transforme toutefois pas tous les échecs de nouvelle connexion `ErrOutConnectExpired` en warnings.

### `AlertOnError`

```xml
<Setting Target="Host" Name="AlertOnError">1</Setting>
```

Ce paramètre contrôle la génération d'une alerte séparée. La valeur `0` supprime l'alerte, mais ne supprime pas l'erreur technique du journal.

### `AlertRetryGracePeriod`

Pour éviter une alerte immédiate lors d'une indisponibilité courte, on peut définir une période de grâce :

```xml
<Setting Target="Host" Name="AlertRetryGracePeriod">300</Setting>
```

Dans cet exemple, l'alerte n'est générée qu'après environ cinq minutes d'échec persistant. Les erreurs techniques individuelles peuvent néanmoins rester visibles dans le journal.

## Recommandation

Pour une cible externe dont la disponibilité n'est pas garantie, la configuration recommandée est :

```xml
<Setting Target="Adapter" Name="IPAddress">localhost</Setting>
<Setting Target="Adapter" Name="Port">8011</Setting>
<Setting Target="Adapter" Name="ConnectTimeout">10</Setting>
<Setting Target="Host" Name="RetryInterval">60</Setting>
<Setting Target="Host" Name="NoFailWhileDisconnected">1</Setting>
<Setting Target="Host" Name="AlertOnError">1</Setting>
<Setting Target="Host" Name="AlertRetryGracePeriod">300</Setting>
```

Cette configuration permet de :

- conserver l'opération activée en permanence ;
- conserver les messages en attente de livraison ;
- retenter la connexion toutes les 60 secondes ;
- attendre jusqu'à 10 secondes pour chaque tentative ;
- éviter les alertes immédiates en cas d'indisponibilité temporaire ;
- déclencher une alerte uniquement si l'indisponibilité persiste.

## Règle `Ens.Alert`

Il n'est pas recommandé de supprimer ou de modifier la règle de routage `Ens.Alert` pour résoudre ce problème. Cette règle peut être utilisée par d'autres composants de la production. Sa suppression ne change pas la cause de `ErrOutConnectExpired` et pourrait empêcher d'autres alertes importantes.

`AlertOnError=0` peut être utilisé si l'on souhaite supprimer les alertes pour cette opération, mais les erreurs de connexion continueront d'apparaître dans le journal.

## Point d'attention pour les tests

Si le test démarre un listener temporaire sur le port `8011` puis l'arrête, l'opération de production continuera logiquement à tenter de se reconnecter. Les erreurs `ErrOutConnectExpired` après l'arrêt du listener sont donc attendues.

Pour un test sans erreurs de reconnexion, il faut soit :

- laisser le listener disponible pendant toute la durée de vie de l'opération ;
- utiliser un proxy ou un listener permanent sur le port `8011` ;
- accepter que les erreurs reflètent l'indisponibilité réelle de la cible.

Cordialement,
