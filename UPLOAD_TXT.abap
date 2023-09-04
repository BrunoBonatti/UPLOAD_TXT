REPORT z_upload.

TABLES:sscrfields.                                                              "DECLARATION OF THE PUSHBUTTON TABLE


DATA: BEGIN OF ty_file OCCURS 0,                                                "DECLARATION OF INTERNAL TABLES AND VARIABLES.
        row TYPE string,
      END OF ty_file.


DATA: lt_lines TYPE TABLE OF string,
      lv_file  TYPE string,
      txt(3)   TYPE c VALUE 'txt'.

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-001.                "DECLARATION OF THE SELECTION PARAMETER AND PUSHBUTTON
  PARAMETERS : p_file TYPE localfile.
  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN PUSHBUTTON /50(12) TEXT-002 USER-COMMAND pb_click.

SELECTION-SCREEN END OF BLOCK part1.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.                                "FUNCTION CALL TO FIND THE FILE.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name = syst-cprog
    IMPORTING
      file_name    = p_file.



AT SELECTION-SCREEN ON BLOCK part1.                                             "SCREEN VALIDATION.

  FIND txt IN p_file IGNORING CASE .


  IF sy-subrc = 0 .
    lv_file = p_file.
    sscrfields-ucomm = 'PB_CLICK'.
    sscrfields-ucomm = 'ONLI'.
  ELSE.
    MESSAGE TEXT-003  TYPE 'I'.
    CLEAR p_file.
  ENDIF.


START-OF-SELECTION.



  CALL FUNCTION 'GUI_UPLOAD'                                                    "FUNCTION CALL TO UPLOAD A FILE
    EXPORTING
      filename                = lv_file
      filetype                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = lt_lines
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.


  IF sy-subrc <> 0.                                                             "ERROR HANDLING AND PRINTING
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ELSE.

    LOOP AT lt_lines INTO DATA(wa_lines)   .
      WRITE: / wa_lines.

    ENDLOOP.

  ENDIF.