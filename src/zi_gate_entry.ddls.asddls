@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface for gate entry'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_GATE_ENTRY 
as select from ZI_GATEENTRY_hdr as a
left outer join zdb_gatentry as b on a.Zgate = b.zgate
{
    key a.Zgate ,
    a.Plant ,
    a.Gateindt ,
    a.Gateoutdt ,
    b.base64_3,
    b.m_ind
}
