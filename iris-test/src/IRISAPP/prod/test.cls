Class IRISAPP.prod.test Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="IRISAPP.prod.test" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
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
    <Setting Target="Host" Name="cities">Paris,Lille,Nice,Lyon,Toulouse,Nantes,Bordeaux,Marseille,Brest,Strasbourg,Montpellier,Clermont-Ferrand,Annecy,Le Mans,Angers,Tours,Orléans,Rennes,Poitiers,Amiens,Roubaix,Metz,Pau</Setting>
  </Item>
  <Item Name="Demo.Temperature.TemperatureOperation" Category="temp" ClassName="Demo.Temperature.TemperatureOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="Demo.Temperature.TemperatureService" Category="" ClassName="Demo.Temperature.TemperatureService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">20</Setting>
  </Item>
  <Item Name="get commandes from MSSQL" Category="" ClassName="EnsLib.SQL.Service.GenericService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="DSN">mssql</Setting>
    <Setting Target="Adapter" Name="JGService">%JDBC Server</Setting>
    <Setting Target="Adapter" Name="Query"><![CDATA[select id,customer_id,order_date,total_amount,status from dbo.commande
where total_amount > ?
and status = ?]]></Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Host" Name="TargetConfigNames">commandes</Setting>
    <Setting Target="Adapter" Name="Parameters"><![CDATA[&montant,&status]]></Setting>
  </Item>
  <Item Name="commandes" Category="" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">IRISAPP.prod.commandesRoutingRule</Setting>
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
</Production>
}

}
