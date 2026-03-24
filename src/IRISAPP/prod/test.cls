Class IRISAPP.prod.test Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="IRISAPP.prod.test" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="MsgRouter" Category="" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="This handles message routing logic." LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">IRISAPP.prod.test.RoutingRule</Setting>
    <Setting Target="Host" Name="BadMessageHandler">BadMessageHandler</Setting>
  </Item>
  <Item Name="de HL7 ADT IHE PAM FR - TCP" Category="" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">HL7v25IHE:ADT_AXX</Setting>
    <Setting Target="Adapter" Name="Port">29001</Setting>
    <Setting Target="Host" Name="TargetConfigNames">MsgRouter</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="JobPerConnection">1</Setting>
    <Setting Target="Host" Name="DefCharEncoding">Native</Setting>
  </Item>
  <Item Name="de HL7 ADT IHE PAM FR - FICHIER" Category="" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="This is a default HL7 File Service." LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">MsgRouter</Setting>
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
  <Item Name="Demo.Temperature.TemperatureService" Category="temp" ClassName="Demo.Temperature.TemperatureService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="target">Demo.Temperature.TemperatureProcess</Setting>
    <Setting Target="Adapter" Name="CallInterval">30</Setting>
  </Item>
  <Item Name="Demo.Temperature.TemperatureProcess" Category="temp" ClassName="Demo.Temperature.TemperatureProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="target">Demo.Temperature.TemperatureOperation</Setting>
    <Setting Target="Host" Name="cities">Paris,Lille,Nice,Lyon,Toulouse</Setting>
  </Item>
  <Item Name="Demo.Temperature.TemperatureOperation" Category="temp" ClassName="Demo.Temperature.TemperatureOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
