# Gestion des erreurs de l'opération DGLab

L'opération `PatientsIn_2Op_HL7ADT_MLLP_DGLabOld` transmet les messages reçus par le service HL7 du port `8010` vers la cible TCP `localhost:8011`.

## Cycle d'erreur TCP

Lorsque la cible est disponible, IRIS ouvre la connexion et transmet le message.

Lorsque la connexion existante est perdue, IRIS journalise généralement :

```text
Warning: Lost TCP connection to localhost:8011
Info: Disconnecting from localhost:8011
```

L'opération tente ensuite de se reconnecter. Si la cible n'accepte aucune connexion pendant `ConnectTimeout`, IRIS génère :

```text
ERROR <Ens>ErrOutConnectExpired:
TCP Connect timeout period (...) expired for localhost:8011
```

Cette erreur concerne la tentative de reconnexion. L'opération reste active et applique son mécanisme de retry ; le message pourra être transmis lorsque la cible redeviendra disponible.

## Paramètres concernés

```xml
<Setting Target="Adapter" Name="ConnectTimeout">10</Setting>
<Setting Target="Host" Name="RetryInterval">60</Setting>
<Setting Target="Host" Name="NoFailWhileDisconnected">1</Setting>
<Setting Target="Host" Name="AlertOnError">1</Setting>
<Setting Target="Host" Name="AlertRetryGracePeriod">300</Setting>
```

- `ConnectTimeout` définit la durée maximale d'une tentative de connexion.
- `RetryInterval` définit l'intervalle entre les tentatives de livraison.
- `NoFailWhileDisconnected` aide à tolérer la perte d'une connexion existante ; il ne transforme pas tous les échecs de reconnexion en warnings.
- `AlertOnError` contrôle la création d'une alerte séparée. À `0`, l'erreur technique reste néanmoins dans le journal.
- `AlertRetryGracePeriod` retarde l'alerte lorsqu'une erreur se répète pendant une période donnée.

## Gestion par `Ens.Alert`

`Ens.Alert` reçoit les alertes générées par les composants de la production et les traite avec une règle de routage. Il ne supprime pas l'erreur technique déjà écrite dans le journal et ne modifie pas le mécanisme de retry.

Une règle peut filtrer uniquement les alertes de cette opération :

```text
SourceConfigName = PatientsIn_2Op_HL7ADT_MLLP_DGLabOld
AlertText contient ErrOutConnectExpired
Action = DELETE
```

Cette action supprime uniquement l'alerte correspondante. Les autres alertes continuent d'être traitées par `Ens.Alert`.

Le contexte de la règle doit être `Ens.AlertRequest`, car les propriétés `SourceConfigName` et `AlertText` appartiennent au message d'alerte. Utiliser le contexte `EnsLib.MsgRouter.RoutingEngine` provoque une erreur `PROPERTY DOES NOT EXIST` sur `AlertText`.

## À retenir

- Une perte de connexion produit d'abord un warning.
- Un échec de reconnexion après `ConnectTimeout` produit une erreur `ErrOutConnectExpired`.
- `AlertOnError=0` masque l'alerte, mais pas l'erreur du journal.
- Une règle `Ens.Alert` ciblée peut supprimer uniquement les alertes de reconnexion de cette opération.
- La cible doit rester disponible ou être remplacée par un listener/proxy permanent si l'opération reste activée en permanence.
