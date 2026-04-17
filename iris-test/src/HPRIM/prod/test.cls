Class HPRIM.prod.test Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="HPRIM.prod.test" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="HPRIM in" Category="" ClassName="HPRIM.EDI.E1238.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/data/HPRIM/in/</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.hpr</Setting>
    <Setting Target="Adapter" Name="SemaphoreSpec">*.ok</Setting>
    <Setting Target="Host" Name="TargetConfigNames">routeurHPRIM</Setting>
    <Setting Target="Host" Name="DocSchemaCategory">HPRIM2.2</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/data/HPRIM/archive</Setting>
    <Setting Target="Adapter" Name="WorkPath">/data/HPRIM/work</Setting>
  </Item>
  <Item Name="HPRIM out" Category="" ClassName="HPRIM.EDI.E1238.Operation.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Filename">%f_%Q.hpr</Setting>
    <Setting Target="Adapter" Name="FilePath">/data/HPRIM/out</Setting>
    <Setting Target="Host" Name="FileOK">1</Setting>
    <Setting Target="Host" Name="SearchTableClass">EnsLib.EDI.E1238.SearchTable</Setting>
    <Setting Target="Adapter" Name="Overwrite">1</Setting>
    <Setting Target="Host" Name="OKSpec">ok</Setting>
    <Setting Target="Host" Name="ASegmentsEnabled">1</Setting>
    <Setting Target="Host" Name="MaxSegmentSize">220</Setting>
  </Item>
  <Item Name="routeurHPRIM" Category="" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">HPRIM.prod.routeurHPRIMRoutingRule</Setting>
    <Setting Target="Host" Name="FailureTimeout">-1</Setting>
  </Item>
  <Item Name="vers HPRIM FTP" Category="" ClassName="HPRIM.EDI.E1238.Operation.FTPOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="FTPServer">IRISHealth-ftp</Setting>
    <Setting Target="Adapter" Name="Credentials">ftp</Setting>
    <Setting Target="Adapter" Name="FilePath">./ftp/out</Setting>
    <Setting Target="Adapter" Name="FTPPort"></Setting>
  </Item>
  <Item Name="vers HPRIM TCP" Category="" ClassName="HPRIM.EDI.E1238.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="SearchTableClass">HPRIM.EDI.E1238.SearchTable</Setting>
    <Setting Target="Host" Name="PartnerService">HPRIMTCPService</Setting>
  </Item>
  <Item Name="vers ASTM TCP" Category="" ClassName="EnsLib.EDI.ASTM.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="PartnerService">ASTMTCPService</Setting>
  </Item>
  <Item Name="HPRIMTCPService" Category="" ClassName="HPRIM.EDI.E1238.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">routeurHPRIM</Setting>
    <Setting Target="Host" Name="DocSchemaCategory">HPRIM2.2</Setting>
    <Setting Target="Host" Name="ReplyMode">App</Setting>
    <Setting Target="Host" Name="GenerateSuperSessionID">1</Setting>
  </Item>
  <Item Name="ASTMTCPService" Category="" ClassName="EnsLib.EDI.ASTM.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Port"></Setting>
    <Setting Target="Host" Name="TargetConfigNames">router</Setting>
    <Setting Target="Host" Name="ReplyMode">App</Setting>
    <Setting Target="Adapter" Name="AllowedIPAddresses">AllowedIPAddresses=!IRISHealth</Setting>
  </Item>
  <Item Name="router" Category="" ClassName="EnsLib.EDI.MsgRouter.SegmentedRoutingEngine" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">ASTM.router</Setting>
  </Item>
  <Item Name="Ens.Activity.Operation.Local" Category="" ClassName="Ens.Activity.Operation.Local" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
