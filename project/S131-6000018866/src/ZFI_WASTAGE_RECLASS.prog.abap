*-----------------------------------------------------------------------
************************************************************************
* Confidential and Proprietary
* Copyright Delivery Hero, Germany
* All Rights Reserved
************************************************************************
* Program Name        : ZFI_WASTAGE_RECLASS
* Created by          : P024736
* Created on          : 10.11.2025
* Program Description :
*  Program to automate month-end reclassification of full wastage
*  and refund orders from revenue GLs to wastage GL
*-----------------------------------------------------------------------
*Modification Log:
*Date      |Author        |TR#       |Description
*10.11.2025|P024736       |DD1K9A1691|Initial Creation
*16.04.2026|P024736       |DD3K900402|Change doc type to SX; add posting date param (6000018866)
*-----------------------------------------------------------------------
************************************************************************
REPORT zfi_wastage_reclass.

"Top Include
INCLUDE ZFI_WASTAGE_RECLASS_TOP.
*INCLUDE YFI_WASTAGE_RECLASS_TOP.
*INCLUDE zfi_wastage_reclass_top.

"Selection Screen Definition
INCLUDE ZFI_WASTAGE_RECLASS_SSC.
*INCLUDE YFI_WASTAGE_RECLASS_SSC.
*INCLUDE zfi_wastage_reclass_ssc.

"Program Event
INCLUDE ZFI_WASTAGE_RECLASS_EVT.
*INCLUDE YFI_WASTAGE_RECLASS_EVT.
*INCLUDE zfi_wastage_reclass_evt.
