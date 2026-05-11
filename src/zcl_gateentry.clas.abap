CLASS zcl_gateentry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS get_pdf_64
      IMPORTING
                VALUE(io_gate) TYPE zi_gateentry_hdr-zgate
      RETURNING VALUE(pdf_64)  TYPE string..



    METHODS escape_xml
      IMPORTING
        iv_in         TYPE any
      RETURNING
        VALUE(rv_out) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS build_xml
      IMPORTING
        VALUE(io_gate) TYPE zi_gateentry_hdr-zgate
      RETURNING
        VALUE(rv_xml)  TYPE string.
ENDCLASS.



CLASS ZCL_GATEENTRY IMPLEMENTATION.


  METHOD escape_xml.

    rv_out = |{ iv_in }|.   " explicit conversion to STRING

    IF rv_out IS INITIAL.
      RETURN.
    ENDIF.

    " Replace must be done in order to avoid double-escaping
    REPLACE ALL OCCURRENCES OF '&' IN rv_out WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<' IN rv_out WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN rv_out WITH '&gt;'.
    REPLACE ALL OCCURRENCES OF '"' IN rv_out WITH '&quot;'.

  ENDMETHOD.


  METHOD get_pdf_64.

    DATA(lv_xml) = build_xml(
                     io_gate = io_gate ).


    IF lv_xml IS INITIAL.
      RETURN.
    ENDIF.


    CALL METHOD zadobe_call=>getpdf
      EXPORTING
        template = 'ZMM_GATE/ZMM_GATE'
        xmldata  = lv_xml
      RECEIVING
        result   = DATA(lv_result).


    IF lv_result IS NOT INITIAL.
      pdf_64 = lv_result.
    ENDIF.


  ENDMETHOD.


  METHOD build_xml.

  DATA : gateno TYPE STRING,
         vehno  TYPE STRING,
         oname TYPE STRING,
         drvlicno TYPE STRING,
         NETWT TYPE STRING,
         gateentrydate TYPE STRING,
         GATEINTIME TYPE STRING,
         GATEOUTEATE TYPE STRING,
         GATEOUTTIME TYPE STRING,
         gross TYPE STRING,
         TAREE TYPE STRING.





  select single *
  from ZI_GATEENTRY_hdr
  where Zgate = @io_gate
  into @data(lv_headdet).


  gateno = lv_headdet-Zgate.
  vehno = lv_headdet-Vehno.
  oname = lv_headdet-Oname.
  drvlicno = lv_headdet-Drvlicen.
  netwt = lv_headdet-Net.
  gateentrydate = |{ lv_headdet-Gateindt+6(2) }-{ lv_headdet-Gateindt+4(2) }-{ lv_headdet-Gateindt(4) }|.
  gateintime =  |{ lv_headdet-Gateinout+0(2) }:{ lv_headdet-Gateinout+2(2) }:{ lv_headdet-Gateinout+4(2) }|.
  gateouteate = |{ lv_headdet-Gateoutdt+6(2) }-{ lv_headdet-Gateoutdt+4(2) }-{ lv_headdet-Gateoutdt(4) }|.
  gateouttime = |{ lv_headdet-Gateoutout+0(2) }:{ lv_headdet-Gateoutout+2(2) }:{ lv_headdet-Gateoutout+4(2) }|.
  gross = lv_headdet-Gross.
  taree = lv_headdet-Tare.

   data(trans) = |{ lv_headdet-trans ALPHA = IN WIDTH = 10  }|.
  data(remark) = lv_headdet-Remark.


  select suppliername
  from I_Supplier
  where Supplier = @trans
  into @data(suppname).
  endSELECT.


  select * from
  ZI_GATEENTRY_ITM
  WHERE Zgate = @io_gate
  into table @data(it_item).

DATA(lv_newline) = cl_abap_char_utilities=>newline.

    DATA(lv_header) =
|<form1>| &&
|  <Header>| &&

|    <Subform1>| &&
|      <Tel>07104235068</Tel>| &&
|      <Fax></Fax>| &&
|      <internet>www.mpmindia.com</internet>| &&
|      <Email>info@mpmindia.com</Email>| &&
|      <Address_npm>MPM S-48 Hingna PlantNagpur-440016{ lv_newline }MaharashtraINDIA</Address_npm>| &&
|    </Subform1>| &&

|    <Subform2>| &&
|      <Subform7/>| &&
|    </Subform2>| &&

|    <Subform3>| &&
|      <gateentryno>{ gateno }</gateentryno>| &&
|      <vehno>{ vehno }</vehno>| &&
|      <drivername>{ oname }</drivername>| &&
|      <transname>{ suppname }</transname>| &&
|      <drivelicno>{ drvlicno }</drivelicno>| &&
|    </Subform3>| &&

|    <Subform3>| &&
|      <delnotetickno></delnotetickno>| &&
|      <delnotenetwigh></delnotenetwigh>| &&
|      <gateindate>{ gateentrydate }</gateindate>| &&
|      <gateintime>{ gateintime }</gateintime>| &&
|      <gateoutdate>{ gateouteate }</gateoutdate>| &&
|    <gateouttime>{ gateouttime }</gateouttime>| &&
|      <gatenetrydate>{ gateentrydate }</gatenetrydate>| &&
|    </Subform3>| &&

|    <Gstin_no></Gstin_no>| &&
|    <Supp_add></Supp_add>| &&

|    <Subform4>| &&
|      <grosswight>{ gross }</grosswight>| &&
|      <tarrewight>{ taree }</tarrewight>| &&
|      <netwight>{ netwt }</netwight>| &&
|      <PKGWGT>{ lv_headdet-pack }</PKGWGT>| &&
|    </Subform4>| &&

|    <Tablefom>| &&
|      <Table1>| &&
|        <HeaderRow/>| .

data : lv_row           TYPE string,
       lv_table TYPE STRING.

loop at it_item into data(wa_data).


 CLEAR lv_row.

 lv_row &&=
|        <Row1>| &&
|          <pono>{ wa_data-Ebeln }</pono>| &&
|          <poitem>{ |{ wa_data-Ebelp ALPHA = OUT }| }</poitem>| &&
|          <vendorcode>{ me->escape_xml( |{ wa_data-Vend ALPHA = OUT }|  ) }</vendorcode>| &&
|          <vendorname>{ me->escape_xml(  wa_data-Name  ) }</vendorname>| &&
|          <material>{ wa_data-Mat }</material>| &&
|          <matdesc>{ wa_data-Matdesc }</matdesc>| &&
|          <quan>{ wa_data-qty }</quan>| &&
|          <unit>{ wa_data-Uom }</unit>| &&
|        </Row1>| .

 lv_table = lv_table && lv_row.

 clear wa_data.

endLOOP.

lv_table  = lv_table &&
|      </Table1>| &&
|    </Tablefom>| &&

|  </Header>| &&

|  <Subform5>| &&
|    <Totalbef></Totalbef>| &&
|  </Subform5>| &&

|</form1>|.

    rv_xml = |{ lv_header }{ lv_table }|.

  ENDMETHOD.
ENDCLASS.
