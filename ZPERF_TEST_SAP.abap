*&---------------------------------------------------------------------*
*& Report  ZPERF_TEST_SAP
*&
*&---------------------------------------------------------------------*
*& Test program to demonstrate difference between ABAP and CDS
*& regarding performance questions. Please excuse questionable variable
*& naming practices.
*&---------------------------------------------------------------------*
REPORT zperf_test_sap.


TYPES:
  BEGIN OF ty_join,
    bukrs TYPE bkpf-bukrs,
    bukrs2 TYPE regup-bukrs,
    belnr TYPE bkpf-belnr,
    gjahr TYPE bkpf-gjahr,
    blart TYPE bkpf-blart,
    bldat TYPE bkpf-bldat,
    buzei TYPE bseg-buzei,
    koart TYPE bseg-koart,
    sgtxt TYPE bseg-sgtxt,
    zlsch TYPE regup-zlsch,
    bschl TYPE regup-bschl,
  END OF ty_join.

DATA: ls_join    TYPE ty_join,
      lt_join    TYPE STANDARD TABLE OF ty_join,
      tstart     TYPE i,
      tstop      TYPE i,
      trun       TYPE i,
      lt_join2   TYPE STANDARD TABLE OF ty_join,
      lv_counter TYPE i.

********* START SCENARIO 1 *********
"Start timer for CDS View
GET RUN TIME FIELD tstart.

SELECT * FROM ziperftest INTO TABLE @DATA(lt_itab).

"End timer and calculate elapsed for CDS
GET RUN TIME FIELD tstop.
trun = ( tstop - tstart ) / 1000.
DESCRIBE TABLE lt_itab LINES lv_counter.
WRITE: / 'Exec time - CDS:', trun, 'milliseconds', '- Number of records:', lv_counter.
********* END SCENARIO 1 *********

********* START SCENARIO 2 *********
"Start timer for AMDP Class
GET RUN TIME FIELD tstart.

zcl_amdp_perf_test=>amdp_method( IMPORTING et_tab = DATA(lt_tab) ).

"End timer and calculate elapsed for CDS
GET RUN TIME FIELD tstop.
trun = ( tstop - tstart ) / 1000.
DESCRIBE TABLE lt_tab LINES lv_counter.
WRITE: / 'Exec time - AMDP Class:', trun, 'milliseconds', '- Number of records:', lv_counter.
********* END SCENARIO 2 *********

********* END SCENARIO 3 *********
"Start timer for join to database view
GET RUN TIME FIELD tstart.

SELECT bkpf~bukrs, z_v_prf_tst~bukrs, bkpf~belnr, bkpf~gjahr, bkpf~blart, bkpf~bldat, bseg~buzei,
bseg~koart, bseg~sgtxt, z_v_prf_tst~zlsch, z_v_prf_tst~bschl BYPASSING BUFFER "Just in case buffering is active
                FROM ( bkpf LEFT JOIN bseg ON
                bkpf~bukrs = bseg~bukrs AND
                bkpf~belnr = bseg~belnr AND
                bkpf~gjahr = bseg~gjahr ) LEFT JOIN z_v_prf_tst
                ON bseg~bukrs = z_v_prf_tst~bukrs AND
                bseg~belnr = z_v_prf_tst~belnr AND
                bseg~gjahr = z_v_prf_tst~gjahr AND
                bseg~buzei = z_v_prf_tst~buzei
                INTO TABLE @lt_join2 WHERE
                bkpf~bukrs = '2010'.

"End timer and calculate elapsed for join to database view
GET RUN TIME FIELD tstop.
trun = ( tstop - tstart ) / 1000.
DESCRIBE TABLE lt_join2 LINES lv_counter.
WRITE: / 'Exec time - Standard SQL with DB view:', trun, 'milliseconds', '- Number of records:', lv_counter.
********* END SCENARIO 3 *********

********* END SCENARIO 4 *********
"Start timer for 'standard' SQL
GET RUN TIME FIELD tstart.

SELECT bkpf~bukrs, regup~bukrs, bkpf~belnr, bkpf~gjahr, bkpf~blart, bkpf~bldat, bseg~buzei,
bseg~koart, bseg~sgtxt, regup~zlsch, regup~bschl BYPASSING BUFFER "Just in case buffering is active
                FROM ( bkpf LEFT JOIN bseg ON
                bkpf~bukrs = bseg~bukrs AND
                bkpf~belnr = bseg~belnr AND
                bkpf~gjahr = bseg~gjahr ) LEFT JOIN regup
                ON bseg~bukrs = regup~bukrs AND
                bseg~belnr = regup~belnr AND
                bseg~gjahr = regup~gjahr AND
                bseg~buzei = regup~buzei
                INTO TABLE @lt_join2 WHERE
                bkpf~bukrs = '2010'.


"End timer and calculate elapsed for 'standard' SQL
GET RUN TIME FIELD tstop.
trun = ( tstop - tstart ) / 1000.
DESCRIBE TABLE lt_join2 LINES lv_counter.
WRITE: / 'Exec time - Standard SQL:', trun, 'milliseconds', '- Number of records:', lv_counter.
********* END SCENARIO 4 *********