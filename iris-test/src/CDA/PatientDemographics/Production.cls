Class CDA.PatientDemographics.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="CDA.PatientDemographics.Production" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description>Flux fichier CDA-R2 vers SDA puis persistance Demo.PatientDemographics.</Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="CDA-R2 fichier entrant" Category="CDA" ClassName="EnsLib.File.PassthroughService" PoolSize="1" Enabled="true" Foreground="false" Comment="Lit les fichiers XML CDA-R2 et les transmet comme Ens.StreamContainer." LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="TargetConfigNames">CDA.PatientDemographics.Process</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="CallInterval">2</Setting>
    <Setting Target="Adapter" Name="FilePath">/data/CDA-R2/in</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.xml</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/data/CDA-R2/archive</Setting>
    <Setting Target="Adapter" Name="WorkPath">/data/CDA-R2/work</Setting>
  </Item>
  <Item Name="CDA.PatientDemographics.Process" Category="CDA" ClassName="CDA.PatientDemographics.Process" PoolSize="1" Enabled="true" Foreground="false" Comment="Transforme le CDA-R2 en SDA, applique la DTL puis appelle l'opération de persistance." LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="CDAtoSDAXSLT">/data/CDA-R2/XSLT/CCDA-to-SDA.xsl</Setting>
  </Item>
  <Item Name="CDA.PatientDemographics.Operation" Category="CDA" ClassName="CDA.PatientDemographics.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="Persiste le message Demo.Msg.PatientDemographics dans Demo.PatientDemographics." LogTraceEvents="true" Schedule="">
  </Item>
</Production>
}

}