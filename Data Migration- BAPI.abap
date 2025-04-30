REPORT ZPRG_BAPI1.

TYPES: BEGIN OF STR1,
  MATNR TYPE MATNR,
  MBRSH TYPE MBRSH,
  MTART TYPE MTART,
  MAKTX TYPE MAKTX,
  MEINS TYPE MEINS,
  ZZSYSTEM type ZDESYSTEM,
  ZZMTYPE type ZDEMTYPE,
  END OF STR1.

  DATA LT_DATA TYPE TABLE  OF STR1.
  DATA WA TYPE STR1.
  DATA: LV_FILE TYPE STRING.
  data ls_headdata type BAPIMATHEAD.
  data  ls_clientdata type BAPI_MARA.
  data  ls_clientdatax type bapi_marax.
  DATA lt_return type TABLE OF BAPIRET2.
  DATA LS_RETURN TYPE BAPIRET2.
  DATA LT_DESC TYPE TABLE OF BAPI_MAKT.
  DATA LS_DESC TYPE BAPI_MAKT.
  data ls_te_mara type BAPI_TE_MARA.
  data  ls_te_marax type BAPI_TE_MARAX.
  data lt_extensionIN type table of BAPIPAREX.
  data ls_extensionIN type BAPIPAREX.
  data lt_extensionINx type table of BAPIPAREXX.
  data  ls_extensionINx type BAPIPAREXX.



PARAMETERS: P_FILE TYPE LOCALFILE.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

  CALL FUNCTION 'F4_FILENAME'
   EXPORTING
*     PROGRAM_NAME        = SYST-CPROG
*     DYNPRO_NUMBER       = SYST-DYNNR
     FIELD_NAME          = ' '
   IMPORTING
     FILE_NAME           = P_FILE
            .

START-OF-SELECTION.


LV_FILE = P_FILE.

CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    FILENAME                      = LV_FILE
*   FILETYPE                      = 'ASC'
   HAS_FIELD_SEPARATOR           = 'X'
*   HEADER_LENGTH                 = 0
*   READ_BY_LINE                  = 'X'
*   DAT_MODE                      = ' '
*   CODEPAGE                      = ' '
*   IGNORE_CERR                   = ABAP_TRUE
*   REPLACEMENT                   = '#'
*   CHECK_BOM                     = ' '
*   VIRUS_SCAN_PROFILE            =
*   NO_AUTH_CHECK                 = ' '
* IMPORTING
*   FILELENGTH                    =
*   HEADER                        =
  TABLES
    DATA_TAB                      = LT_DATA
* CHANGING
*   ISSCANPERFORMED               = ' '
 EXCEPTIONS
   FILE_OPEN_ERROR               = 1
   FILE_READ_ERROR               = 2
   NO_BATCH                      = 3
   GUI_REFUSE_FILETRANSFER       = 4
   INVALID_TYPE                  = 5
   NO_AUTHORITY                  = 6
   UNKNOWN_ERROR                 = 7
   BAD_DATA_FORMAT               = 8
   HEADER_NOT_ALLOWED            = 9
   SEPARATOR_NOT_ALLOWED         = 10
   HEADER_TOO_LONG               = 11
   UNKNOWN_DP_ERROR              = 12
   ACCESS_DENIED                 = 13
   DP_OUT_OF_MEMORY              = 14
   DISK_FULL                     = 15
   DP_TIMEOUT                    = 16
   OTHERS                        = 17
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

loop at lt_data into wa.
ls_headdata-material = wa-matnr.
ls_headdata-IND_SECTOR = wa-mbrsh.
ls_headdata-MATL_TYPE = wa-mtart.
ls_headdata-BASIC_VIEW = 'X'.

ls_clientdata-BASE_UOM = wa-meins.
ls_clientdatax-base_UOM = 'X'.

LS_DESC-LANGU = SY-LANGU.
LS_DESC-MATL_DESC = WA-MAKTX.
APPEND LS_DESC TO LT_DESC.
CLEAR LS_DESC.


ls_te_mara-material = wa-matnr.
ls_te_mara-ZZSYSTEM = wa-ZZSYSTEM.
ls_te_mara-zzmtype = wa-zzmtype.

ls_te_marax-material = wa-matnr.
ls_te_marax-ZZSYSTEM = 'X'.
ls_te_marax-zzmtype = 'X'.

ls_extensionin-STRUCTURE = 'BAPI_TE_MARA'.
LS_EXTENSIONIN-VALUEPART1 = LS_TE_MARA.
APPEND LS_EXTENSIONIN TO LT_EXTENSIONIN.
CLEAR LS_EXTENSIONIN.

ls_extensioninX-STRUCTURE = 'BAPI_TE_MARA'.
LS_EXTENSIONINX-VALUEPART1 = LS_TE_MARA.
APPEND LS_EXTENSIONINX TO LT_EXTENSIONINX.
CLEAR LS_EXTENSIONINX.


CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
  EXPORTING
    HEADDATA                   = ls_headdata
   CLIENTDATA                 = ls_clientdata
   CLIENTDATAX                = ls_clientdatax
*   PLANTDATA                  =
*   PLANTDATAX                 =
*   FORECASTPARAMETERS         =
*   FORECASTPARAMETERSX        =
*   PLANNINGDATA               =
*   PLANNINGDATAX              =
*   STORAGELOCATIONDATA        =
*   STORAGELOCATIONDATAX       =
*   VALUATIONDATA              =
*   VALUATIONDATAX             =
*   WAREHOUSENUMBERDATA        =
*   WAREHOUSENUMBERDATAX       =
*   SALESDATA                  =
*   SALESDATAX                 =
*   STORAGETYPEDATA            =
*   STORAGETYPEDATAX           =
*   FLAG_ONLINE                = ' '
*   FLAG_CAD_CALL              = ' '
*   NO_DEQUEUE                 = ' '
*   NO_ROLLBACK_WORK           = ' '
 IMPORTING
   RETURN                     = lS_return
 TABLES
   MATERIALDESCRIPTION        = LT_DESC
*   UNITSOFMEASURE             =
*   UNITSOFMEASUREX            =
*   INTERNATIONALARTNOS        =
*   MATERIALLONGTEXT           =
*   TAXCLASSIFICATIONS         =
*   RETURNMESSAGES             =
*   PRTDATA                    =
*   PRTDATAX                   =
   EXTENSIONIN                =  lt_extensionIN
   EXTENSIONINX               =  lt_extensionINx
          .

APPEND LS_RETURN TO LT_RETURN.
CLEAR: LS_RETURN, LS_HEADDATA, LS_CLIENTDATA, LS_CLIENTDATAX, ls_te_mara, ls_te_marax.
REFRESH : LT_DESC, LT_EXTENSIONIN, LT_EXTENSIONINX.

ENDLOOP.

LOOP AT  LT_RETURN INTO LS_RETURN.
  WRITE: / LS_RETURN-MESSAGE.
ENDLOOP.