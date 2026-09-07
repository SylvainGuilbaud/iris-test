Class IRISAPP.prod.test Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="IRISAPP.prod.test" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Setting Target="Adapter" Name="ShutdownTimeout">5</Setting>
  <Setting Target="Adapter" Name="UpdateTimeout">4</Setting>
  <Item Name="de HL7 ADT IHE PAM FR - TCP" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">HL7v25IHE:ADT_AXX</Setting>
    <Setting Target="Adapter" Name="Port">29001</Setting>
    <Setting Target="Host" Name="TargetConfigNames">IHEPAM</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Host" Name="DefCharEncoding">Native</Setting>
  </Item>
  <Item Name="de HL7 ADT IHE PAM FR - FICHIER" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="This is a default HL7 File Service." LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">IHEPAM</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/data/HL7/archive</Setting>
    <Setting Target="Adapter" Name="FilePath">/data/HL7/in</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.HL7</Setting>
    <Setting Target="Adapter" Name="WorkPath">/data/HL7/work</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">HL7v25IHE:ADT_AXX</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="vers non IHE HL7v2 ADT - FICHIER" Category="" ClassName="EnsLib.HL7.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="This is a default HL7 File Operation." LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/data/HL7/out</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="Demo.Temperature.TemperatureProcess" Category="temp" ClassName="Demo.Temperature.TemperatureProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="target">Demo.Temperature.TemperatureOperation</Setting>
    <Setting Target="Host" Name="cities">Paris,Lille,Nice,Lyon,Toulouse,Nantes,Bordeaux,Marseille,Brest,Strasbourg,Montpellier,Clermont-Ferrand,Annecy,Le Mans,Angers,Tours,Orléans,Rennes,Poitiers,Amiens,Roubaix,Metz,Pau,Grenoble,Blois,Brest,La Baule</Setting>
  </Item>
  <Item Name="Demo.Temperature.TemperatureOperation" Category="temp" ClassName="Demo.Temperature.TemperatureOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="Demo.Temperature.TemperatureService" Category="" ClassName="Demo.Temperature.TemperatureService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">3600</Setting>
  </Item>
  <Item Name="de LIS ASTM E1394" Category="" ClassName="EnsLib.EDI.ASTM.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">LIS</Setting>
    <Setting Target="Adapter" Name="ArchivePath"></Setting>
    <Setting Target="Adapter" Name="FilePath">/data/ASTM-E1394/in/</Setting>
    <Setting Target="Adapter" Name="WorkPath"></Setting>
    <Setting Target="Adapter" Name="FileSpec">*.ast</Setting>
  </Item>
  <Item Name="LIS" Category="" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">IRISAPP.prod.LISRoutingRule</Setting>
    <Setting Target="Host" Name="RuleLogging">a</Setting>
  </Item>
  <Item Name="IHEPAM" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="This handles message routing logic." LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">IRISAPP.prod.IHEPAMRoutingRule</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
    <Setting Target="Host" Name="RuleLogging">a</Setting>
  </Item>
  <Item Name="Ens.Alert" Category="" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">IRISAPP.prod.AlertRule</Setting>
  </Item>
  <Item Name="vers LIS ASTM E1394" Category="" ClassName="EnsLib.EDI.ASTM.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/data/ASTM-E1394/out/</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="vers BASE PATIENT" Category="" ClassName="IRISAPP.operation.patientSQL" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="DSN">iris</Setting>
    <Setting Target="Adapter" Name="JGService">%JDBC Server</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="de LIS ASTM E1238" Category="" ClassName="HPRIM.EDI.E1238.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="DocSchemaCategory">HPRIM2.2</Setting>
    <Setting Target="Host" Name="TargetConfigNames">LIS</Setting>
    <Setting Target="Adapter" Name="FilePath">/data/ASTM-E1238/in/</Setting>
    <Setting Target="Adapter" Name="SemaphoreSpec">*.ok</Setting>
  </Item>
  <Item Name="vers LIS ASTM E1238" Category="" ClassName="HPRIM.EDI.E1238.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/data/ASTM-E1238/out/</Setting>
  </Item>
  <Item Name="de LIS ASTM E1394 - TCP" Category="" ClassName="EnsLib.EDI.ASTM.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Reception ASTM E1381/E1394 en TCP" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Port">29010</Setting>
    <Setting Target="Adapter" Name="AllowedIPAddresses"></Setting>
    <Setting Target="Host" Name="DocSchemaCategory">E1394:P</Setting>
    <Setting Target="Host" Name="ReplyMode">App</Setting>
    <Setting Target="Host" Name="TargetConfigNames">ASTM</Setting>
  </Item>
  <Item Name="Relay ASTM vers fichier+MLLP" Category="" ClassName="IRISAPP.operation.ASTMRelayWithAck" PoolSize="1" Enabled="true" Foreground="false" Comment="C.2 -&gt; O.12 + sortie fichier + emission MLLP + ACK applicatif" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="OutputPath">/data/ASTM-E1394/out/</Setting>
    <Setting Target="Host" Name="SendToMLLP">0</Setting>
    <Setting Target="Host" Name="MLLPHost">127.0.0.1</Setting>
    <Setting Target="Host" Name="MLLPPort">6662</Setting>
    <Setting Target="Host" Name="ConnectTimeout">5</Setting>
    <Setting Target="Host" Name="WaitForMLLPAck">1</Setting>
    <Setting Target="Host" Name="MLLPAckTimeout">5</Setting>
    <Setting Target="Host" Name="FailOnMLLPError">0</Setting>
  </Item>
  <Item Name="de ASTM E1394 MLLP" Category="" ClassName="EnsLib.EDI.ASTM.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Reception ASTM E1381/E1394 en TCP" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Port">6661</Setting>
    <Setting Target="Adapter" Name="AllowedIPAddresses"></Setting>
    <Setting Target="Host" Name="DocSchemaCategory">E1394:P</Setting>
    <Setting Target="Host" Name="ReplyMode">App</Setting>
    <Setting Target="Host" Name="TargetConfigNames"></Setting>
  </Item>
  <Item Name="ASTM" Category="" ClassName="EnsLib.MsgRouter.VDocRoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">IRISAPP.prod.ASTMRoutingRule</Setting>
  </Item>
  <Item Name="Ens.ProductionMonitorService" Category="" ClassName="Ens.ProductionMonitorService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="de LIS ASTM E1394 - FICHIER" Category="" ClassName="EnsLib.EDI.ASTM.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/data/ASTM-E1394/in/</Setting>
    <Setting Target="Host" Name="TargetConfigNames">ASTM</Setting>
  </Item>
  <Item Name="vers ASTM E1394 - FICHIER" Category="" ClassName="EnsLib.EDI.ASTM.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/data/ASTM-E1394/out/</Setting>
  </Item>
  <Item Name="de GAM ADT^A28 - TCP" Category="GAM-LAB" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="Reception ADT (ex: A28) depuis GAM en TCP/MLLP. AckMode=App: GAM recoit un ACK applicatif (AA/AE) apres traitement LAB; le rejet AR du LAB est journalise/alerte par l&apos;operation (OnReplyDocument), non restitue verbatim (limite standard)" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Port">29020</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">HL7v25IHE:ADT_AXX</Setting>
    <Setting Target="Host" Name="TargetConfigNames">routeur Lab</Setting>
    <Setting Target="Host" Name="AckMode">App</Setting>
    <Setting Target="Host" Name="UseAckCommitCodes">0</Setting>
    <Setting Target="Host" Name="DefCharEncoding">Native</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="routeur Lab" Category="GAM-LAB" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="Routage GAM -&gt; LAB" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">IRISAPP.prod.LabRoutingRule</Setting>
    <Setting Target="Host" Name="RuleLogging">a</Setting>
  </Item>
  <Item Name="vers Lab HL7 - TCP" Category="GAM-LAB" ClassName="IRISAPP.operation.LabHL7Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="Emission ADT vers le LAB. AR/CR: fail sans retry infini, ACK original restitue a GAM (cf. ReplyCodeActions)" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">127.0.0.1</Setting>
    <Setting Target="Adapter" Name="Port">6663</Setting>
    <Setting Target="Adapter" Name="StayConnected">30</Setting>
    <Setting Target="Adapter" Name="ConnectTimeout">5</Setting>
    <Setting Target="Adapter" Name="ResponseTimeout">15</Setting>
    <Setting Target="Adapter" Name="GetReply">1</Setting>
    <Setting Target="Host" Name="NoFailWhileDisconnected">1</Setting>
    <Setting Target="Host" Name="ReplyCodeActions">:?R=C,:?E=F,:~=F,:?A=C,:*=F,:I?=W,:T?=C</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="Lab simulateur (AR) - TCP" Category="GAM-LAB" ClassName="IRISAPP.service.LabSimulator" PoolSize="1" Enabled="true" Foreground="false" Comment="Simulateur LAB: renvoie un ACK negatif AR (ACK^A28^ACK) pour tester le flux de bout en bout" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Port">6663</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Host" Name="MessageSchemaCategory">HL7v25IHE:ADT_AXX</Setting>
    <Setting Target="Host" Name="DefCharEncoding">Native</Setting>
  </Item>
</Production>
}

}
