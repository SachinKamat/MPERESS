#!/bin/gawk -f
####################################################################################################
####################################################################################################
#  Script to generate test messages for PTP
#     These messages can include RFH2 header and ae suitable for input onto an MQ by any of the RFHUTILS programs.
#       however, at the moment, no MQMD header is generated so they can't be pushed onto queues by other approaches without creating an MQMD
#
#   Message generation is based on a csv with a header row naming the xml fields (case insensitive)
#     - sequence/presence of columns is not important- apart from needing the RFH2 related columns messagetype at least!
#    generation of MID, CTR, OEE files is basically nonsense - RFH header will be correct if parameters are correct but message content just reflects lines in the csv - only utility here is to create the RFH2 header
#        default, if message type is not recognised, is to generate an xml body - Ref column is used as part of output file name
#   - the csv parsing functions used are not wholly safe against embedded commas
#
#   only tested against gawk. There are gawk specifics in this script - system etc
#     Behaviour varies with these runstring parameters
#		NORFH	-	anything in this parameter stops production of RFH header
#       XMLPATH -	directory into which created files are written - defaults to ./xml
#
#  NB FS statement needed to handle csv - don't amend this
#
#   Jim Daley  18th February 2015
#
#   V0.0.1    20/02/2015	- first release
#	V0.0.2    22/02/2015	- updated to correct RN identified errors
#							added NORFH option and updated to match 20/2 CDM
#   V0.0.3	  26/02/2015	- corrected to generate platform independent RFH structure
#   V0.0.4    01/03/2015	- updates to match 27/02 CDM
#   V0.0.5    06/03/2015	- create xml subdirectory if it doesn't exist, 
#							align with 6/3/2015 CDM	
#							generate multiple url(s) if | is found in url string
#							remove dependence on column sequence/presence apart from those listed in function clear()
#   V0.0.6    14/03/2015	- updated in line with Release 3 of cdm  13/03
#							added DOFULL to generate all elements not in csv file 
#								generated values use a sequentially updated  'uniqueNo'
#							added timestamp generation for appropriate elements - based on uniquNo 
#							added support for OEE,MID - CTR can be generated but its structure not supported yet
#
#   V0.0.7    20/03/2015	- cut down generation for 'types' and addresses
#							defect fixes  - add Z to doCSVTS, make both RevenueProtectionStatus work the same way
#   V0.0.8    25/03/2015	- defect fixes doPostcode and cut down generation of unwanted tags
#   V0.0.9    28/04/2015	- amended to create ptp variant
#   V0.0.10   01/05/2015	- corrected after xsd validation of 0.9 output - note DOFULL is broken at this time
#   V0.0.11   06/05/2015	- defect fixes identified by NM
#   V1.0.12   07/05/2015	- added support for MMS format = output from blackbay/csc
#   V1.0.13   00/05/2015	- corrected RFH_SITEID and allowed multiple EventItem separated by |
#   V1.0.14   28/05/2015	- Defect fix #0012. Support for multiple RFH_TRACKINGNUMBER - use RFH_TrackingNumbers
#   V1.0.15   03/06/2015	- Defect fix #0013  Correct OneD barcode generation - script was looking for ONED instead of ONEDBARCODE - highVolume also missing an ""
#   V1.0.16   08/06/2015	- Defect fix 		Update MMS header generation to match CSC samples
#   V1.0.17   07/07/2015	- Defect fix		Corrected handling of internationalRegisteredBarcode - name used was truncated generating incorrect element
#   V1.0.28   28/07/2015	- Defect fix		Corrected handling of zulu timestamps
#   V1.0.29   03/10/2015	- UAT - large files so second adjustment (uniqueno) becomes huge - reset before creating the timestamps
#   V1.0.31   30/10/2015	- UAT - similarly for machine and MMS batches
#   V1.0.32   04/11/2015	- UAT - timestamp order for MMS batches corrected
#   V1.0.33   25/11/2015    - MPE - remove defaulting of machine values and add columns to spreadsheet
#                                 also change doElement to allow "/" as a special to create null tag (needed for SPIDData)
#                                 also allow DIMS of zero - legalincrement = -1 being the dont create indicator.
#   V1.0.34   26/11/2015    - Supress dims creation for other than machines (filetype 201)
#   V1.0.35   06/01/2016    - Allow for Multiple ruleSet5 and ruleSet6 with | separator
#                           - doDPSPostcode handles postcode based on message type
#   V1.0.36	  14/01/2016	- Previously royalMailSegemnt not populated if no UID. For EIB it's possible to have royalMailSegment without UID - so use UPUCoutry as test.
#                           - doImages changed to allow no perspective
#   V1.0.37	  25/02/2016 	- Fixed bug with batching MMS/Legacy PDA files
#   V1.0.38	  10/03/2016 	- Fixed bug with 7 character postcodes creating a suffix
#   V1.0.39	  23/03/2016	- Allow oneD to have just highVolumePostcode
#   V1.0.40	  10/05/2016	- Found XSD header note to use 0 instead of false and 1 instead of true - removed and fields defaulting to a boolean text value
#                           - Removed DOFULL
#   V1.0.41	  06/06/2016	- Remove defaulting using ++UniqueId
#   V1.0.42	  21/06/2016	- Problem with consignmentDomestic
#   V1.0.43   13/07/2016      - Latitude/longitude not set correctly
#   V1.0.44   28/07/2016      - Include start of CR0294 IEDE
#   V1.0.45   18/04/2017    - Allow XSD v1.4 to add mperSeg in RFH. Also remove ptp- from test data filesnames.
#   V1.0.46   07/06/2017    - PSM machine only uses 4 cameras
#   V1.0.47   31/08/2017    - Remove defaulting of barcodeCreationDate
#   V1.0.50   13/09/2017    - Remove ONEFILE references
#   V2.0.51   14/09/2017    - Allow for xsd v1.5 including raw/container etc
#   V2.0.52   03/10/2017    - RMGLocation one of 5 types now
#
#######################################################################################################
#
BEGIN	{ 
   FS="^\"|\",\"|\"$"

   if ( length( XMLPATH ) > 0 )    # output directory for file(s) default to 'xml'
   { outputPath = XMLPATH }
   else
   { outputPath = "xml" }

   system("mkdir " outputPath)
   outputPath = outputPath "/"

   xmlFile = outputPath "messages.xml"

   nl = "\n"
   recordCount = 0  		# used only to stop first time use of delimiter in single file output

   if ( length( NORFH ) > 0 )
   NORFH = "false" # do not generate RFH2 header

   delimiter = ""

   hdr[1] = "" 			# array of header positions - used to map tags to column name position
   savedHdr[1] = "" 	# save the headers for OEE, MID file output
   num_fields = 0  		# zero based no of fields in csv line - populated by csv parse functions
   uniqueNo = 0 		# used to populate interlinked elements with a sequence
   MMSREFERENCE = ""
   lastMMSREFERENCE = ""
   #deflt2 = substr(deflt, 0, 19) # yyyy-mm-ddThh:mm:ss
   TESTDATE1=substr(TESTDATE, 0, 10) #change precison of date time for this field
}

#######################################################################
#
function trim(str) {
   sub(/^[ \t]+/,"",str);  # remove leading whitespaces
   sub(/[ \t]+$/,"",str);  # remove trailing whitespaces
   return str;
}

#######################################################################
#
# create cross reference to upper cased column headingsso we don't care about column sequence
function parseHeader()
{
   parseLine()
   for ( i=0; i <= num_fields; i++ )
   {
      savedHdr[i] = csv[i]
      hdr[ toupper(csv[i]) ] = i
   }
   
}

#######################################################################
#
# clear RFH2 header values and REF - used in filename
#
function clear()
{

   MESSAGETYPE=""
   REF=""
   SOURCE=""
   RFH_SITEID=""
   RFH_TRACKINGNUMBER=""
   RFH_TRACKINGNUMBERS=""
   MACHINESNAME=""
   MMSREFERENCE=""
   MESSAGEFORMAT=""
}

#######################################################################
#
# break the input "csv" line up into the csv[] array
#
function parseLine()
{
   clear()
   num_fields = parse_csv($0, csv, ",", "\"", "\"", "\\n", 1);
   
   MESSAGETYPE = csv[ hdr["MESSAGETYPE"] ]
   REF = csv[ hdr["REF"] ]
   SOURCE = csv[ hdr["SOURCE"] ]
   MESSAGEFORMAT = csv[ hdr["MESSAGEFORMAT"] ]


   # RFH_TRACKINGNUMBERS is there to support option of multiple UPUTrackingNumber in header
  # RFH_TRACKINGNUMBERS = csv[ hdr["RFH_TRACKINGNUMBERS"] ]
   RFH_TRACKINGNUMBERS = TESTBARCODE
   if(MESSAGEFORMAT=="CCJSON")
   {
   RFH_TRACKINGNUMBERS=TESTBARCODE1
   }
   if ( length(RFH_TRACKINGNUMBERS) == 0 )
      RFH_TRACKINGNUMBERS = csv[ hdr["RFH_TRACKINGNUMBER"] ]
   printf RFH_TRACKINGNUMBERS
   RFH_SITEID = csv[ hdr["RFH_SITEID"] ]
   MACHINESNAME = csv[ hdr["MACHINESNAME"] ]
   MMSREFERENCE = csv[ hdr["MMSREFERENCE"] ]
}

#######################################################################
#
## create a binary value - count defines the word length in bytes
#   used in generating the RFH2 header
#
   function printBin(Value, Count) {
   RFHlength = ""
   for (; Count > 0; Count--)
   {
      RFHlength = RFHlength sprintf("%c", Value%256)
      Value /= 256
   }
   return RFHlength
}

#######################################################################
#
#
# write a simple xml element 
function doElement( tag,datatype,value, xmlFile )
{
   if(MESSAGEFORMAT=="JSON")
   {
   if (datatype=="null")
   {
   if(value=="null")
					{
					printf "\t\"%s\":%s\,\n",tag,value >> xmlFile
					}
   }
   
   else if (datatype=="")
				{
					if(value=="")
					{
					if(tag=="SignatureSVG")
					{
					printf "\t\"%s\":%s\n",tag,value >> xmlFile
					}
					else
					{
									
					printf "\t\"%s\":\"%s\"\,\n",tag,value >> xmlFile
				
					}
					}
					else if ( value != "" ) # don't write element if no value passed
					{
					if(tag=="SignatureSVG")
					{
					printf "\t\"%s\":%s\n",tag,value >> xmlFile
					}
					else
					{
					if(tag=="TaskId")
					{
					printf "\t\"%s\":\"%s\"\n",tag,value >> xmlFile
					}
					else
					{	
						printf "\t\"%s\":\"%s\"\,\n",tag,value >> xmlFile	  
					}
					}
				}
				}
				else if(datatype=="INT")
				{
					if(value=="")
					{
					printf "\t\"%s\":\,\n",tag >> xmlFile
					}
					else if ( value != "" ) # don't write element if no value passed
					{
						printf "\t\"%s\":%s\,\n",tag,value >> xmlFile	  
					}
				}else if(datatype=="BOOL")
				{
					if(value=="")
					{
					printf "\t\"%s\":false,\n",tag,value >> xmlFile
					}
					else if ( value != "" ) # don't write element if no value passed
					{
						if(value=="false")
						value="false"
						printf "\t\"%s\":%s\,\n",tag,value >> xmlFile	  
					}
				}
				}
		else if(MESSAGEFORMAT=="CCJSON")
   {
   if (datatype=="null")
   {
   if(value=="null")
   {
   						if(tag=="SubEntityItems")
						{
						printf "\t\"%s\":",tag >> xmlFile
						}
						else
						{
						printf "\t\"%s\":%s\,\n",tag,value >> xmlFile
						}
	}
   }
   
   else if (datatype=="")
				{
					if(value=="")
					{		
						if(tag=="SignatureSVG")
						{
						printf "\t\"%s\":%s\n",tag,value >> xmlFile
						}
						else
						{			
						printf "\t\"%s\":\"%s\"\,\n",tag,value >> xmlFile
						}
					}
					else if ( value != "" ) # don't write element if no value passed
					{
						
						if(tag=="SignatureSVG")
						{
						printf "\t\"%s\":%s\n",tag,value >> xmlFile
						}
						else
						{
						if(tag=="ReceiveTime")
						{
						printf "\t\"%s\":\"%s\"\n",tag,value >> xmlFile
						}
						else
						{	
						printf "\t\"%s\":\"%s\"\,\n",tag,value >> xmlFile	  
						}
					}
				}
				}
				else if(datatype=="INT")
				{
					if(value=="")
					{
					printf "\t\"%s\":\,\n",tag >> xmlFile
					}
					else if ( value != "" ) # don't write element if no value passed
					{
						printf "\t\"%s\":%s\,\n",tag,value >> xmlFile	  
					}
				}else if(datatype=="BOOL")
				{
					if(value=="")
					{
					printf "\t\"%s\":false\n",tag,value >> xmlFile
					}
					else if ( value != "" ) # don't write element if no value passed
					{
						if(value=="false")
						value="false"
						printf "\t\"%s\":%s\n",tag,value >> xmlFile	  
					}
				}
				}
}


#######################################################################
#
function STAROUTWARD( xmlFile )
{
        
		doCSVElement( "Levelh","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransmissionTypeh","", "", xmlFile )
		doCSVElement( "SoftwareVersionofScanner","", "", xmlFile )
		doCSVElement( "DataVersionOfScanner","", "", xmlFile )
		doCSVElement( "DeviceUnitIdentity","", "", xmlFile )
		doCSVElement( "OfficeUserIdentity","", "", xmlFile )
		doCSVElement( "DateOfTransmission","", "", xmlFile )
		doCSVElement( "TimeOfTransmission","", "", xmlFile )
		doCSVElement( "OfficeCode","", "", xmlFile )
		doCSVElement( "FullOfficeName","", "", xmlFile )
		doCSVElement( "Break","", "", xmlFile )
		doCSVElement( "Leveli","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransactionTypei","", "", xmlFile )
		doCSVElement( "IdentifierContainerBarcode","", "", xmlFile )
		doCSVElement( "Destination","", "", xmlFile )
		doCSVElement( "DateOfInput","", "", xmlFile )
		doCSVElement( "TimeOfInput","", "", xmlFile )
		doCSVElement( "Break","", "", xmlFile )
		doCSVElement( "Leveld","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransactionTyped","", "", xmlFile )
		doCSVElement( "IdentifierItemBarcode","", "", xmlFile )
		doCSVElement( "DateOfInput","", "", xmlFile )
		doCSVElement( "TimeOfInput","", "", xmlFile )
		doCSVElement( "Break","", "", xmlFile )
		doCSVElement( "Levelf","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransactionTypef","", "", xmlFile )
		doCSVElement( "RecordCount","", "", xmlFile )

   
}

#######################################################################
#
function STARINWARD( xmlFile )
{
        doCSVElement( "Levelh","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransmissionTypeh","", "", xmlFile )
		doCSVElement( "SoftwareVersionofScanner","", "", xmlFile )
		doCSVElement( "DataVersionOfScanner","", "", xmlFile )
		doCSVElement( "DeviceUnitIdentity","", "", xmlFile )
		doCSVElement( "OfficeUserIdentity","", "", xmlFile )
		doCSVElement( "DateOfTransmission","", "", xmlFile )
		doCSVElement( "TimeOfTransmission","", "", xmlFile )
		doCSVElement( "OfficeCode","", "", xmlFile )
		doCSVElement( "FullOfficeName","", "", xmlFile )
		doCSVElement( "Break","", "", xmlFile )

		doCSVElement( "Leveli","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransactionTypei","", "", xmlFile )
		doCSVElement( "IdentifierContainerBarcode","", "", xmlFile )
		doCSVElement( "Destination","", "", xmlFile )
		doCSVElement( "DateOfInput","", "", xmlFile )
		doCSVElement( "TimeOfInput","", "", xmlFile )
		doCSVElement( "Break","", "", xmlFile )

		doCSVElement( "Leveld","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransactionTyped","", "", xmlFile )
		doCSVElement( "IdentifierItemBarcode","", "", xmlFile )
		doCSVElement( "DateOfInput","", "", xmlFile )
		doCSVElement( "TimeOfInput","", "", xmlFile )
		doCSVElement( "Break","", "", xmlFile )

		doCSVElement( "Levelf","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransactionTypef","", "", xmlFile )
		doCSVElement( "RecordCount","", "", xmlFile )

   
}

#######################################################################
#
function STARRFD( xmlFile )
{
        doCSVElement( "Levelh","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransmissionTypeh","", "", xmlFile )
		doCSVElement( "SoftwareVersionofScanner","", "", xmlFile )
		doCSVElement( "DataVersionOfScanner","", "", xmlFile )
		doCSVElement( "DeviceUnitIdentity","", "", xmlFile )
		doCSVElement( "OfficeUserIdentity","", "", xmlFile )
		doCSVElement( "DateOfTransmission","", "", xmlFile )
		doCSVElement( "TimeOfTransmission","", "", xmlFile )
		doCSVElement( "OfficeCode","", "", xmlFile )
		doCSVElement( "FullOfficeName","", "", xmlFile )
		doCSVElement( "Break","", "", xmlFile )
		
		doCSVElement( "Leveli","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransactionTypei","", "", xmlFile )
		doCSVElement( "IdentifierContainerBarcode","", "", xmlFile )
		#doCSVElement( "Destination","", "", xmlFile )
		doCSVElement( "DateOfInput","", "", xmlFile )
		#doCSVElement( "TimeOfInput","", "", xmlFile )
		doCSVElement( "Break","", "", xmlFile )
		
		doCSVElement( "Leveld","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransactionTyped","", "", xmlFile )
		doCSVElement( "IdentifierItemBarcode","", "", xmlFile )
		doCSVElement( "DateOfInput","", "", xmlFile )
		doCSVElement( "TimeOfInput","", "", xmlFile )
		doCSVElement( "Break","", "", xmlFile )
		
		doCSVElement( "Levelf","", "", xmlFile )
		doCSVElement( "Stream","", "", xmlFile )
		doCSVElement( "TransactionTypef","", "", xmlFile )
		doCSVElement( "RecordCount","", "", xmlFile )

   
}
#POL SECTION
#######################################################################
#
function POLTNTHEAD(xmlFile)
{
   printf "<TNTHEAD>%s",nl >> xmlFile
      doCSVElement("H_RTI","", "", xmlFile)
      doCSVElement("H_FT","", "", xmlFile)
      doCSVElement("H_DD","", "", xmlFile)
      doCSVElement("H_DT","", "", xmlFile)
    printf "</TNTHEAD>%s",nl >> xmlFile
}
#######################################################################
#
function POLTNTSEND(xmlFile)
{
   printf "<TNTSEND>%s",nl >> xmlFile
      doCSVElement("S_RTI","", "", xmlFile)
      doCSVElement("S_SN","", "", xmlFile)
      doCSVElement("S_SA1","", "", xmlFile)
      doCSVElement("S_SPC","", "", xmlFile)
    printf "</TNTSEND>%s",nl >> xmlFile
}

#######################################################################
#
function POLTNTADHOC(xmlFile)
{
   printf "<TNTADHOC>%s",nl >> xmlFile
      doCSVElement("A_RTI","", "", xmlFile)
      doCSVElement("A_TT","", "", xmlFile)
      doCSVElement("A_IC","", "", xmlFile)
      doCSVElement("A_LOC","", "", xmlFile)
      doCSVElement("A_ED","", "", xmlFile)
      doCSVElement("A_ET","", "", xmlFile)
      doCSVElement("A_FAD","", "", xmlFile)
      doCSVElement("A_LOC","", "", xmlFile)
	printf "</TNTADHOC>%s",nl >> xmlFile
}

#######################################################################
#
function POLTNTTRAIL(xmlFile)
{
   printf "<TNTTRAIL>%s",nl >> xmlFile
      doCSVElement("T_RTI","", "", xmlFile)
      doCSVElement("T_CNT","", "", xmlFile)
	printf "</TNTTRAIL>%s",nl >> xmlFile
}

#######################################################################
#
function POLTNTDOC(xmlFile)
{
   printf "<TNTDOC>%s",nl >> xmlFile
      doCSVElement("TXNID","", "", xmlFile)
	  POLTNTHEAD(xmlFile)
	  POLTNTSEND(xmlFile)
	  POLTNTADHOC(xmlFile)
      POLTNTTRAIL(xmlFile)
	printf "</TNTDOC>%s",nl >> xmlFile
}
#######################################################################
#
function POLTNT_REQ(xmlFile)
{
   printf "<?xml version=\"1.0\"?>%s",nl >> xmlFile
   printf "<TNT_REQ>%s",nl >> xmlFile
      doCSVElement("VER","", "", xmlFile)
	  POLTNTDOC(xmlFile)
	printf "</TNT_REQ>%s",nl >> xmlFile
}
#######################################################################
#
function inflightJSON( xmlFile )
{
	MS_DATETIME = csv[ hdr["MS_DATETIME"] ]
	MS_DATETIME=TESTDATE
   printf nl"{%s",nl >> xmlFile #add opening bracket
		doElement("Barcode","", TESTBARCODE, xmlFile)
		doCSVElement("BusinessUnit","", "", xmlFile)
		#doCSVElement("ReturnsCustomerId","", "", xmlFile)
		doCSVElement("MessageId","", "", xmlFile)
		doCSVElement("DeviceId","", "", xmlFile)
		doCSVElement("UserId","", "", xmlFile)
		doElement("ObiId", "",LOCATIONID, xmlFile)
		doCSVElement("Latitude", "INT","", xmlFile)
		doCSVElement("Longitude", "INT","", xmlFile)
		doCSVElement("Altitude", "INT","", xmlFile)
		doElement("EventCode", "",TESTEVENT, xmlFile)
		doCSVTSElement("ScanTime", "", MS_DATETIME, xmlFile)
		doCSVTSElement("ReceiveTime", "", MS_DATETIME, xmlFile)
		doCSVTSElement("SubmissionTime", "", MS_DATETIME, xmlFile)
		doCSVElement("ManualEntry", "BOOL","", xmlFile)
		doCSVElement("UniqueItemNumber", "","", xmlFile)
		doCSVElement("UpuTrackingNumber", "","", xmlFile)
		doElement("FunctionalLocationId", "INT",FLOCATIONID, xmlFile)
		doCSVElement("EventReason", "INT","", xmlFile)
		doCSVElement("WorkProcessCode", "INT","", xmlFile)
		doElement("TaskId", "",TASKID, xmlFile)
		printf "}%s",nl >> xmlFile #add closing bracket
   }
   
#######################################################################
#
function ccJSON( xmlFile )
{
	MS_DATETIME = csv[ hdr["MS_DATETIME"] ]
	MS_DATETIME=TESTDATE
   printf nl"{%s",nl >> xmlFile #add opening bracket
		doElement("EntityId","", TESTORDERID, xmlFile)
		doCSVElement("BusinessUnit","", "", xmlFile)
		doCSVElement("EntityType","INT", "", xmlFile)
		doCSVElement("MessageId","", "", xmlFile)
		doCSVElement("DeviceId","", "", xmlFile)
		doCSVElement("UserId","", "", xmlFile)
		doElement("ObiId", "",LOCATIONID, xmlFile)
		doElement("FunctionalLocationId", "INT",FLOCATIONID, xmlFile)
		doElement("TaskId", "",TASKID, xmlFile)
		doCSVElement("Latitude", "INT","", xmlFile)
		doCSVElement("Longitude", "INT","", xmlFile)
		doCSVElement("Altitude", "INT","", xmlFile)
		doCSVTSElement("SubmissionTime", "", MS_DATETIME, xmlFile)
		doElement("SubEntityItems","null", "null", xmlFile)
		printf nl"[",nl >> xmlFile #add opening bracket
		printf nl"{%s",nl >> xmlFile #add opening bracket
		
		if(length( TESTBARCODE1 ) > 0)
		{
		doElement("Barcode","", TESTBARCODE1, xmlFile)
		doElement("ItemIdentifier", "",TESTBARCODE1, xmlFile)
		doCSVElement("ItemEntityType","INT", "", xmlFile)
		doElement("EventCode", "",TESTEVENT1, xmlFile)
		doCSVTSElement("ScanTime", "", MS_DATETIME, xmlFile)
		doCSVElement("ManualEntry", "BOOL","", xmlFile)
		}
		if(length( TESTBARCODE2 ) > 0)
		{
		printf nl"},%s",nl >> xmlFile #add opening bracket
		printf nl"{%s",nl >> xmlFile #add opening bracket
		doElement("Barcode","", TESTBARCODE2, xmlFile)
		doElement("ItemIdentifier", "",TESTBARCODE2, xmlFile)
		doCSVElement("ItemEntityType","INT", "", xmlFile)
		doElement("EventCode", "",TESTEVENT2, xmlFile)
		doCSVTSElement("ScanTime", "", MS_DATETIME, xmlFile)
		doCSVElement("ManualEntry", "BOOL","", xmlFile)
		}
		if(length( TESTBARCODE3 ) > 0)
		{
		printf nl"},%s",nl >> xmlFile #add opening bracket
		printf nl"{%s",nl >> xmlFile #add opening bracket
		doElement("Barcode","", TESTBARCODE3, xmlFile)
		doElement("ItemIdentifier", "",TESTBARCODE3, xmlFile)
		doCSVElement("ItemEntityType","INT", "", xmlFile)
		doElement("EventCode", "",TESTEVENT3, xmlFile)
		doCSVTSElement("ScanTime", "", MS_DATETIME, xmlFile)
		doCSVElement("ManualEntry", "BOOL","", xmlFile)
		}
		if(length( TESTBARCODE4 ) > 0)
		{
		printf nl"},%s",nl >> xmlFile #add opening bracket
		printf nl"{%s",nl >> xmlFile #add opening bracket
		doElement("Barcode","", TESTBARCODE4, xmlFile)
		doElement("ItemIdentifier", "",TESTBARCODE4, xmlFile)
		doCSVElement("ItemEntityType","INT", "", xmlFile)
		doElement("EventCode", "",TESTEVENT4, xmlFile)
		doCSVTSElement("ScanTime", "", MS_DATETIME, xmlFile)
		doCSVElement("ManualEntry", "BOOL","", xmlFile)
		}
		if(length( TESTBARCODE5 ) > 0)
		{
		printf nl"},%s",nl >> xmlFile #add opening bracket
		printf nl"{%s",nl >> xmlFile #add opening bracket
		doElement("Barcode","", TESTBARCODE5, xmlFile)
		doElement("ItemIdentifier", "",TESTBARCODE5, xmlFile)
		doCSVElement("ItemEntityType","INT", "", xmlFile)
		doElement("EventCode", "",TESTEVENT5, xmlFile)
		doCSVTSElement("ScanTime", "", MS_DATETIME, xmlFile)
		doCSVElement("ManualEntry", "BOOL","", xmlFile)
		}
		
		printf nl"}",nl >> xmlFile #add opening bracket
		printf nl"],%s",nl >> xmlFile #add opening bracket
		doElement("EventCode", "",TESTORDEREVENT, xmlFile)
		doCSVElement("ActionType", "","Doorstep", xmlFile)
		doCSVTSElement("ReceiveTime", "", MS_DATETIME, xmlFile)
		printf "}%s",nl >> xmlFile #add closing bracket
   }
#######################################################################
#
# dynamic version of doElement - looks for upper case tag in CSV array
#  - if nothing found,  & default has a value then use that
#    let doElement decide whether to actually output anything 
#
function doCSVElement( tag,datatype,deflt, xmlFile )
{
if(MESSAGEFORMAT=="JSON" || MESSAGEFORMAT=="CCJSON")
{
 value = csv[ hdr[ toupper(tag) ] ]
   if ( value == "" )
      value = deflt
   doElement(tag,datatype, value, xmlFile)
}
else if(MESSAGEFORMAT=="TXT")
{
   value = csv[ hdr[ toupper(tag) ] ]
   if ( value == "" )
      value = deflt
   doElement(tag,"",value, xmlFile)
}
else
{
   value = csv[ hdr[ toupper(tag) ] ]
   if ( value == "" )
      value = deflt
   doElement(tag,"",value, xmlFile)
}
}
#######################################################################
#
# dynamic version of doElement - with prefix - looks for upper case tag in CSV array
#  - if nothing found,  & default has a value then use that
#    let doElement decide whether to actually output anything 
#
function doPfxCSVElement( tag, prefix, deflt, xmlFile )
{
   valueStr = prefix tag
   value =  csv[ hdr[ toupper( valueStr )] ]
   if ( value == "" )
      value = deflt
   doElement(tag,"",value, xmlFile)
}

#######################################################################
#
# as above but space padding to length
function doPaddedCSVElement( tag, deflt, xmlFile, pad )
{
   value = csv[ hdr[ toupper(tag) ] ]
   if ( value == "" )
      value = deflt
   l = length(value)
   if ( l < pad )
      value = value substr("                ",1,pad-l)
   doElement(tag,"",value, xmlFile)
}

#######################################################################
#
# timestamp version of do CSVElement
#  - in this case deflt means "generate" a timestamp based on today and uniqueno to produce hrs/mins
#
function doCSVTSElement( tag, prefix, deflt, xmlFile )
{
# 2015-07-13T08:45:00+01:00 or 2015-07-13T08:45:00+00:00 are allowed in MS_DATETIME

   value = csv[ hdr[ prefix toupper(tag) ] ]
   trailer = ""
   if ( value == "" )
      if ( length(deflt) > 0 )
      {
         if ( match( toupper(deflt), "Z") == 0 )
            dozulu = 0
         else 
            dozulu = 1 # it has a Z
         
         if (dozulu == 0)
            trailer = substr(deflt,20, 6) # +0x:00
         else
            trailer = "Z"

         deflt2 = substr(deflt, 0, 19) # yyyy-mm-ddThh:mm:ss
         
         gsub(/[^0-9]/," ",deflt2)   # strip non numeric to make timestamp suitable for mktime
         seconds = (++uniqueNo)   # add different seconds increment for each timestamp in this file (reset to 0 for each record)
         
         timeVal = mktime(deflt2) + seconds
         value = strftime("%FT%T",timeVal)
      }
   doElement(tag,"", value trailer, xmlFile)
}


#######################################################################
#
#  Kludge to write out RFH header 
#   use of 'printBin' is to make RFH header generation platform independent
#   
function doRFH( xmlFile )
{
# Header constants - note we overwrite length when we know it
#        
   version = printBin(2,4)
   RFHHeaderStart = "RFH " version # Identifier and Version

   # we should have the length next in a 32 bit word but we won't know it until we've created the <usr> folder
   # so we do do the header in two parts and interpose the length when we know it

   # write the 'words' that comprise the rest of the RFH header structure
   encoding = printBin(546,4) # Encoding of numbers etc  546 - littleEndian?
   msgCCSID = printBin(1208,4) # ccsid of message data - 1208 - utf-8
   format =  "\x20\x20\x20\x20\x20\x20\x20\x20" 
   flags = printBin(0,4) # flags  0
   ccsid = printBin(1208,4) # ccsid  1208 utf-8

   # now create the bit of the header structure after the length
   RFHHeader = encoding msgCCSID format flags ccsid

   # mcd and jms folders
   #length word and padding to 4 bytes on these folders is fixed -  we're not amending the folder contents
   mcdlen = printBin(32,4)
   RFH2mcd = mcdlen "<mcd><Msd>jms_bytes</Msd></mcd>\x20"
   jmslen = printBin(12,4)
   RFH2jms = jmslen "<jms></jms>\x20"

   # usr folder - dynamic
   RFH2usr = "<usr>"
   if ( length(MESSAGETYPE) > 0 )
      RFH2usr = RFH2usr "<MessageType>" MESSAGETYPE "</MessageType>"
   if ( length(SOURCE) > 0 )
      RFH2usr = RFH2usr "<Source>" SOURCE "</Source>"
   if ( length(RFH_TRACKINGNUMBERS) > 0 )
   {
      split(RFH_TRACKINGNUMBERS, upus, "|" )
      for ( u in upus )
      {
         RFH2usr = RFH2usr "<UPUTrackingNumber>" upus[u] "</UPUTrackingNumber>"
      }
   }
   if ( length(RFH_SITEID) > 0 )
      RFH2usr = RFH2usr "<siteIdentifier>" RFH_SITEID "</siteIdentifier>"
   RFH2usr = RFH2usr "</usr>"

   # Translate chars we don't want in usr folder (Ampersand, quotes, apostrophes - angle brackets are fine)
   gsub(/&/,"\\&amp;",RFH2usr)
   gsub(/\"/,"\\&quot;",RFH2usr)
   gsub(/'/,"\\&apos;",RFH2usr)      

   # pad usr folder to 4 byte words 
   lRFH2usr = length( RFH2usr ) % 4
   if ( lRFH2usr > 0 )
      RFH2usr = RFH2usr substr("    ",1,4 - lRFH2usr)

   # write length word for RFH2usr section  
   RFH2usrLength = printBin( length(RFH2usr),4)
  
   # now work out the length of the whole RFH2 header  - 36 bytes is the fixed length of the header including its length
   #   + 4 is to adjust for the word containing the RFH2 <usr> folder length
   #totalLength = 36 + 4 + length( RFH2mcd RFH2jms RFH2usr )
   totalLength = 36 + 4 + length(RFH2usr )
   RFHLength = printBin(totalLength,4)

if(MESSAGEFORMAT=="XML" && REF=="TC99_4_PDA-071C-JC092GB")
{
   printf RFHHeaderStart RFHLength RFHHeader RFH2mcd RFH2jms RFH2usrLength RFH2usr  >> xmlFile
}
else if(MESSAGEFORMAT=="JSON" || MESSAGEFORMAT=="CCJSON")
{ 
 printf RFHHeaderStart RFHLength RFHHeader RFH2usrLength RFH2usr  >> xmlFile
}
else
{
printf "Do Nothing"
}
}

#######################################################################
#
function doPTPHeader( xmlFile )
{


		printf "%s%s","<?xml version=\"1.0\" encoding=\"UTF-8\"?>",nl >> xmlFile
		printf "%s%s","<ptp\:MPE xmlns\:dt=\"http\://www.royalmailgroup.com/cm/rmDatatypes/V1\"",nl >> xmlFile
		printf "%s%s","xmlns\:ptp=\"http\://www.royalmailgroup.com/cm/ptpMailPiece/V1\" xmlns\:xsi=\"http\://www.w3.org/2001/XMLSchema-instance\"",nl >> xmlFile
		printf "%s%s","xsi\:schemaLocation=\"http\://www.royalmailgroup.com/cm/ptpMailPiece/V1 ptpMailPiece.xsd\">",nl >> xmlFile
	
	
}

#######################################################################
# mandatory - one of the location elements must be present
function RMGLocation( prefix, xmlFile )
{
    location =  csv[ hdr[prefix "FUNCTIONALLOCATIONID"] ]
    site =  csv[ hdr[prefix "SITEID"] ]
	polbranch = csv[ hdr[prefix "POLBRANCHID"] ]
	pfwwloc = csv[ hdr[prefix "PFWWLOCATIONID"] ]
	rmgttoffice = csv[ hdr[prefix "RMGTTOFFICEID"] ]
	
	if ( length(location) > 0 || length(site) > 0 || length(polbranch) > 0 || length(pfwwloc) > 0 || length(rmgttoffice) > 0 )
	{
		printf "<RMGLocation>%s",nl >> xmlFile
		
		if ( length(location) > 0 )
         doElement("functionalLocationId","", location, xmlFile)

		if ( length(site) > 0 )
			doElement("siteId","", site, xmlFile)
			
		if ( length(polbranch) > 0 )
         doElement("POLBranchId","", polbranch, xmlFile)
		 
		if ( length(pfwwloc) > 0 )
         doElement("PFWWLocationId","", pfwwloc, xmlFile)
		 
		if ( length(rmgttoffice) > 0 )
         doElement("RMGTTOfficeId","", rmgttoffice, xmlFile)
			
		printf "</RMGLocation>%s",nl >> xmlFile
	} 
}

#######################################################################
#
function runtimeMachineParameters(xmlFile)
{
   printf "<runtimeMachineParameters>%s",nl >> xmlFile
   doCSVElement("machineId","", "", xmlFile)
   RMGLocation( "MR_", xmlFile )
   printf "</runtimeMachineParameters>%s",nl >> xmlFile
}

#######################################################################
#
function operationalMailstream(xmlFile)
{
   printf "<operationalMailstream>%s",nl >> xmlFile
   doCSVElement("infeedOperationalMailstream","", "", xmlFile)
   doCSVElement("IOMCode","", "", xmlFile)
   printf "</operationalMailstream>%s",nl >> xmlFile
}

#######################################################################
# Perspective made optional
# So Y = with perspective N = without

function doImages( img, xmlFile )
{

   for ( i=1; i<= 6; i++)
   {
      printf "<img>%s",nl >> xmlFile
      url = sprintf( "http://image%s-%s.img/%s/",xmlFile,img,i )
	  if (i >= 5)
      {
	     url = "No Image Information"
      }
      doElement("imageUrl","", url, xmlFile)
#      if (img == "Y")
#      {
#         doElement("perspective","",i, xmlFile)
#      }
      printf "</img>%s",nl >> xmlFile
   }
}

#######################################################################
#
function controlSystem(xmlFile)
{
   uniqueNo = 0 # reset to 0 so for large files the time doesnt stretch to hours

   CS_DATETIME = csv[ hdr["CS_DATETIME"] ]
   printf "<controlSystem>%s",nl >> xmlFile
   doCSVElement("PSMMailPieceId","", "", xmlFile)
   # Allow entry of a single CS_Datetime - or individual times
   if  ( length (CS_DATETIME) > 0 )
   {
      doCSVTSElement( "feedingTimestamp", "", CS_DATETIME, xmlFile)
      doCSVTSElement( "sortToOutputTimestamp", "", CS_DATETIME, xmlFile)
   }
	else
   {
	  doCSVElement( "feedingTimestamp","", "", xmlFile)
      doCSVElement( "sortToOutputTimestamp","", "", xmlFile)
   }
   doCSVElement( "tariffCode","", "", xmlFile)
   doCSVElement( "DSAMissortIndicator","", "", xmlFile)
   doCSVElement( "rejectReason","", "", xmlFile)
   doCSVElement( "infeedId","", "", xmlFile)
   doCSVElement( "inductId","", "", xmlFile)
   doCSVElement( "tunnelId","", "", xmlFile)
   doCSVElement( "intendedOutputId","", "", xmlFile)
   doCSVElement( "actualOutputId","", "", xmlFile)
   doCSVElement( "mailPieceRecirculationCount","", "", xmlFile)
   doCSVElement( "mailPieceRecirculationLimit","", "", xmlFile)
   doCSVElement( "infeedStatusList","", "", xmlFile)
   doCSVElement( "inductStatusList","", "", xmlFile)
   doCSVElement( "tunnelStatusList","", "", xmlFile)
   doCSVElement( "PSAStatus","", "", xmlFile)
   doCSVElement( "outputsDisabledStatusList","", "", xmlFile)
   doCSVElement( "mailPieceOOSIndicator","", "", xmlFile)
   doCSVElement( "revenueProtectionStatus","", "", xmlFile)
   doCSVElement( "trackedEventCode","", "", xmlFile)
   #doElement( "trackedEventCode","", TESTEVENT, xmlFile)
   doCSVElement( "chuteId","", "", xmlFile)
   doCSVElement( "rejectIndicator","", "", xmlFile)
   doCSVElement( "trackedIndicator","", "", xmlFile)
   doCSVElement( "containerType","", "", xmlFile)
   doCSVElement( "containerId","", "", xmlFile)
   if  ( length (CS_DATETIME) > 0 )
      doCSVTSElement( "sortDeliveryConfirmTimestamp", "", CS_DATETIME, xmlFile)
	else
      doCSVElement( "sortDeliveryConfirmTimestamp", "", xmlFile)
   printf "</controlSystem>%s",nl >> xmlFile
}

#######################################################################
#
# We use the 'legalincrement' value to allow the 'legal for trade' values to differ from the measured values - without entering discrete values for each
#  arbitrary choice of blank height to suppress the whole message
#
function dims(xmlFile)
{

   if ( csv[ hdr["LEGALINCREMENT"] ] >= 0 )
   {
      LEGALINCREMENT = csv[ hdr["LEGALINCREMENT"] ]
      printf "<dims>%s",nl >> xmlFile
      doDimension("length",csv[ hdr["LENGTH"] ],"mm", xmlFile)
      doDimension("height",csv[ hdr["HEIGHT"] ],"mm", xmlFile)
      doDimension("width",csv[ hdr["WIDTH"] ],"mm", xmlFile)
      doCSVElement("weight","", "", xmlFile)
      doDimension("lengthLFT",csv[ hdr["LENGTH"] ] + LEGALINCREMENT,"mm", xmlFile)
      doDimension("heightLFT",csv[ hdr["HEIGHT"] ] + LEGALINCREMENT,"mm", xmlFile)
      doDimension("widthLFT",csv[ hdr["WIDTH"] ] + LEGALINCREMENT,"mm", xmlFile)
      doCSVElement("weightLFT","", csv[ hdr["WEIGHT"] ] + LEGALINCREMENT, xmlFile)
      img = csv[ hdr["ISIGNATURESVG"] ]
      if ( length(img) > 0 )
         doImages( img, xmlFile )
      doCSVElement("cameraPerspective","","", xmlFile)
      printf "</dims>%s",nl >> xmlFile
   }
}

#######################################################################
#
function doDimension(tag, value, UoM, xmlFile)
{
   printf "<%s>%s",tag,nl >> xmlFile
      doElement("UoMCode","",UoM,xmlFile)
      if (length(value) < 1)
         value = ++uniqueNo
      doElement("value","",value,xmlFile)
   printf "</%s>%s",tag,nl >> xmlFile
}

#######################################################################
#
function SP(xmlFile)
{
   printf "<SP>%s",nl >> xmlFile
      doCSVElement("SPDescription","", "", xmlFile)
      doCSVElement("SPId","", "", xmlFile)
      doCSVElement("sortOutcomeCode","", "", xmlFile)
      doCSVElement("sortSelectionDestinationCode","", "", xmlFile)
      doCSVElement("processingFunctionCode","", "", xmlFile)
   printf "</SP>%s",nl >> xmlFile
}

#######################################################################
#
function SPIDData(xmlFile)
{
   SPIDPost = csv[ hdr["SPID_POSTCODE"] ] 
   SPIDCode = csv[ hdr["SPID_MAILCLASSCODE"] ] 
   SPIDRevenue = csv[ hdr["SPID_REVENUEPROTECTIONSTATUS"] ] 
   SPIDMissort = csv[ hdr["SPID_DSAMISSORTINDICATOR"] ] 

   printf "<SPIDData>%s",nl >> xmlFile
      doElement("postcode","", SPIDPost, xmlFile)
      doElement("mailClassCode","", SPIDCode, xmlFile)
      doElement("revenueProtectionStatus","", SPIDRevenue, xmlFile)
      doElement("DSAMissortIndicator","", SPIDMissort, xmlFile)
	  doMulti("ruleSet5", "", xmlFile)
	  doMulti("ruleSet6", "", xmlFile)
   printf "</SPIDData>%s",nl >> xmlFile
}

#######################################################################
#
function SPConfiguration(xmlFile)
{
   printf "<SPConfiguration>%s",nl >> xmlFile
      doCSVElement("deliveredBy","", "", xmlFile)
   printf "</SPConfiguration>%s",nl >> xmlFile
}

#######################################################################
#
function machineRecord(xmlFile)
{
   printf "<machineRecord>%s",nl >> xmlFile
      runtimeMachineParameters(xmlFile)
      controlSystem(xmlFile)
      SP(xmlFile)
      operationalMailstream(xmlFile)
      SPIDData(xmlFile)
      SPConfiguration(xmlFile)
   printf "</machineRecord>%s",nl >> xmlFile
}
#######################################################################
#
function doHeader( prefix, xmlFile )
{
   printf "<header>%s",nl >> xmlFile
	doPfxCSVElement("senderId", "IS_", "", xmlFile)
	doPfxCSVElement("senderQualificationCode", "IS_", "", xmlFile)
	doPfxCSVElement("recipientId", "IS_", "", xmlFile)
	doPfxCSVElement("recipientQualificationCode", "IS_", "", xmlFile)
	doCSVTSElement("preparationTimestamp", "IS_", "", xmlFile)
	doPfxCSVElement("interchangeControlReference", "IS_", "", xmlFile)
	doPfxCSVElement("messageReferenceNumber", "IS_", "", xmlFile)
   printf "</header>%s",nl >> xmlFile
}

#######################################################################
#
function doItemDetails( prefix, xmlFile )
{
    printf "<itemDetails>%s",nl >> xmlFile
   	doPfxCSVElement( "nextProcessingPointId", "ID_", "", xmlFile)
   	doPfxCSVElement( "nextProcessingPointTypeCode", "ID_", "", xmlFile)
   	doPfxCSVElement( "nextProcessingPointPostcode", "ID_", "", xmlFile)
   	doPfxCSVElement( "itemDeliveryTypeCode", "ID_", "", xmlFile)
   	doPfxCSVElement( "itemOriginCountryCode", "ID_", "", xmlFile)
   	doPfxCSVElement( "itemOriginOperatorCode", "ID_", "", xmlFile)
   	doPfxCSVElement( "itemDestinationId", "ID_", "", xmlFile)
   	doPfxCSVElement( "exportCancellationReasonCode", "ID_", "", xmlFile)
   	doPfxCSVElement( "pickupPointId", "ID_", "", xmlFile)
   	doPfxCSVElement( "itemDestinationCountryCode", "ID_", "", xmlFile)
   	doPfxCSVElement( "collectionPostcode", "ID_", "", xmlFile)
   	doPfxCSVElement( "networkEntryLocationTypeCode", "ID_", "", xmlFile)
   	doPfxCSVElement( "postageAmount", "ID_", "", xmlFile)
   	doPfxCSVElement( "postageCurrencyCode", "ID_", "", xmlFile)
   	doPfxCSVElement( "mailSubClassCode", "ID_", "", xmlFile)
   printf "</itemDetails>%s",nl >> xmlFile
}

#######################################################################
#
function doSender( prefix, xmlFile )
{
    printf "<sender>%s",nl >> xmlFile
   	doPfxCSVElement( "contactName", prefix, "", xmlFile)
   	doPfxCSVElement( "contactEmail", prefix, "", xmlFile)
   	doPfxCSVElement( "contactTelephone", prefix, "", xmlFile)
    doAddress( "address", prefix ,xmlFile)
   printf "</sender>%s",nl >> xmlFile
}

#######################################################################
#
function doRecipient( prefix, second, xmlFile )
{
    printf "<recipient>%s",nl >> xmlFile
   	doPfxCSVElement( "contactName", prefix, "", xmlFile)
   	doPfxCSVElement( "contactEmail", prefix, "", xmlFile)
   	doPfxCSVElement( "contactTelephone", prefix, "", xmlFile)
   	doPfxCSVElement( "contactLanguageCode", prefix, "", xmlFile)
    doAddress( "address", prefix, xmlFile)
    doAddress( "alternativeAddress", second, xmlFile)
   printf "</recipient>%s",nl >> xmlFile
}

#######################################################################
#
function doOOED( prefix, xmlFile )
{
   printf "<officeOfExchangeDespatch>%s",nl >> xmlFile
   	doPfxCSVElement( "outwardOfficeOfExchangeCode", prefix, "", xmlFile)
   	doPfxCSVElement( "despatchNumberId", prefix, "", xmlFile)
   	doPfxCSVElement( "exportReceptacleId", prefix, "", xmlFile)
   	doPfxCSVElement( "itemReasonForReturnCode", prefix, "", xmlFile)
   	doPfxCSVElement( "exportFlowOrigin", prefix, "", xmlFile)
   	doPfxCSVElement( "transitItemArrivalDirectionCode", prefix, "", xmlFile)
   	doPfxCSVElement( "exportCustomsOfficeId", prefix, "", xmlFile)
   	doPfxCSVElement( "exportCancellationReasonCode", prefix, "", xmlFile)
   	doPfxCSVElement( "exportCustomsRetentionReasonCode", prefix, "", xmlFile)
   	doPfxCSVElement( "exportCustomsReleaseStatusCode", prefix, "", xmlFile)
   	doPfxCSVElement( "despatchOfficeCode", prefix, "", xmlFile)
   	doPfxCSVElement( "importTerminationReasonCode", prefix, "", xmlFile)
   	doPfxCSVElement( "importTerminationActionCode", prefix, "", xmlFile)
   	doPfxCSVElement( "sortingOfficeReference", prefix, "", xmlFile)
   printf "</officeOfExchangeDespatch>%s",nl >> xmlFile
}

#######################################################################
#
function doOOER( prefix, xmlFile )
{
   printf "<officeOfExchangeReceive>%s",nl >> xmlFile
   	doPfxCSVElement( "inwardOfficeOfExchangeCode", prefix, "", xmlFile)
   	doPfxCSVElement( "outwardOfficeOfExchangeCode", prefix, "", xmlFile)
   	doPfxCSVElement( "receivedDespatchId", prefix, "", xmlFile)
   	doPfxCSVElement( "importReceptacleId", prefix, "", xmlFile)
   	doPfxCSVElement( "arrivalStatusCode", prefix, "", xmlFile)
   	doPfxCSVElement( "importCustomsOfficeId", prefix, "", xmlFile)
   	doPfxCSVElement( "importCustomsFacilityTypeCode", prefix, "", xmlFile)
   	doPfxCSVElement( "importCustomsRetentionReasonCode", prefix, "", xmlFile)
   	doPfxCSVElement( "importCustomsReleaseStatusCode", prefix, "", xmlFile)
   	doPfxCSVElement( "dutiableIndicatorCode", prefix, "", xmlFile)
   	doPfxCSVElement( "transitArrivalItemDirectionCode", prefix, "", xmlFile)
   	doPfxCSVElement( "sortingOfficeReference", prefix, "", xmlFile)
   printf "</officeOfExchangeReceive>%s",nl >> xmlFile
}

#######################################################################
#
function doDelivery( prefix, xmlFile )
{
   printf "<delivery>%s",nl >> xmlFile
   	doPfxCSVElement( "deliveryOfficeId", prefix, "", xmlFile)
   	doPfxCSVElement( "unsuccessfulDeliveryActionCode", prefix, "", xmlFile)
   	doPfxCSVElement( "unsuccessfulDeliveryReasonCode", prefix, "", xmlFile)
   	doPfxCSVElement( "itemRefusalNameSignatory", prefix, "", xmlFile)
   	doPfxCSVElement( "attemptedDeliveryLocation", prefix, "", xmlFile)
   	doPfxCSVElement( "deliveryLocation", prefix, "", xmlFile)
	addressUsageCode = csv[ hdr[ prefix toupper("addressUsageCode") ] ]
	if (length(addressUsageCode)> 0)
		doAddress( "address", prefix, xmlFile)
	else
	    doCollectionPoint( prefix, xmlFile)

   	doPfxCSVElement( "signatureName", prefix, "", xmlFile)
   	doPfxCSVElement( "recipientAddresseeRelationshipCode", prefix, "", xmlFile)
   	doPfxCSVElement( "deliveryOfficeHeldCode", prefix, "", xmlFile)
   	doPfxCSVElement( "deliveryOfficeActionCode", prefix, "", xmlFile)
   printf "</delivery>%s",nl >> xmlFile
}

#######################################################################
#
function doCollectionPoint( prefix, xmlFile)
{
   printf "<collectionPoint>%s",tag, nl >> xmlFile
   	doPfxCSVElement( "collectionPointID", prefix, "", xmlFile)
   	doPfxCSVElement( "collectionPointPostcode", prefix, "", xmlFile)
   	doPfxCSVElement( "collectionPointTypeCode", prefix, "", xmlFile)
   printf "</collectionPoint>%s",tag, nl >> xmlFile
}

#######################################################################
#
function doCustomer( prefix, xmlFile )
{
    printf "<customer>%s",nl >> xmlFile
   	doPfxCSVElement( "customerAccountId", "IC_", "", xmlFile)
   	doPfxCSVElement( "customerChargingArrangementCode", "IC_", "", xmlFile)
   printf "</customer>%s",nl >> xmlFile
}

#######################################################################
#
function mailPieceBarcode( xmlFile )
{
	  printf "<mailPieceBarcode>%s",nl >> xmlFile
      royalMailSegment(xmlFile)
      channelSegment(xmlFile)
      doCSVElement("POLBranchId","", "", xmlFile)
      channelBusinessSegment(xmlFile)
      channelEIBSegment(xmlFile)
      PFWWBarcode(xmlFile)
      GLSBarcode(xmlFile)
      internationalRegisteredBarcode(xmlFile)
      oneD(xmlFile)
      doCSVElement("ANSIGrade","", "", xmlFile)
      doCSVElement("returnsCustomerId","", "", xmlFile)
	  printf "</mailPieceBarcode>%s",nl >> xmlFile
 
}

function mailPieceIdentifier( xmlFile )
{
		printf "<mailPieceIdentifier>%s",nl >> xmlFile
		doID("primaryIdentifier", "PI_", xmlFile)
		doID("linkedIdentifier","LI_", xmlFile)
		printf "</mailPieceIdentifier>%s",nl >> xmlFile
}

#######################################################################
#
function royalMailSegment( xmlFile )
{
   upucountry = csv[ hdr["UPUCOUNTRY"] ]
   if ( length( upucountry ) < 1 ) return

   printf " <royalMailSegment>%s",nl >> xmlFile
      doPaddedCSVElement("UPUCountry", "", xmlFile,4)
      doCSVElement("informationCode","", "", xmlFile)
      doCSVElement("versionId","", "", xmlFile)
      doCSVElement("mailItemFormatCode","", "", xmlFile)
      doCSVElement("mailClassCode","", "", xmlFile)
      doCSVElement("mailTypeCode","", "", xmlFile)
   printf " </royalMailSegment>%s",nl >> xmlFile
}

#######################################################################
#
function channelSegment ( xmlFile )
{
   uniqueitemid = csv[ hdr["UNIQUEITEMID"] ]
   if ( length( uniqueitemid ) < 1 ) return

   printf " <channelSegment>%s",nl >> xmlFile
      #doCSVElement( "uniqueItemId","", "", xmlFile )
	  doElement( "uniqueItemId","", TESTUUID, xmlFile )
      doCSVElement( "mailPieceWeight","", "", xmlFile )
      doCSVElement( "weightCode","", "", xmlFile )
      doCSVElement( "pricePaid","", "", xmlFile )
      #doCSVElement( "barcodeCreationDate","", "", xmlFile )
      doElement( "barcodeCreationDate","", TESTDATE1, xmlFile )
	  #doCSVElement( "intendedShipmentDate","", "", xmlFile )
	  doElement( "intendedShipmentDate","", TESTDATE1, xmlFile )
      #doCSVElement( "productId","", "", xmlFile )
	  doElement( "productId","", PRODUCTID, xmlFile )
      doCSVElement( "mailPieceCode","", "", xmlFile )
     # doCSVElement( "UPUTrackingNumber","", "", xmlFile )
	  doElement( "UPUTrackingNumber","", TESTBARCODE, xmlFile )
      doBuildingNoAddress("address","CS_",xmlFile)
      doDPSPostcode("destinationPostcodeDPS", "", xmlFile)
      if ( length( DESTINATIONCOUNTRY ) > 0 )
	  {
		doPaddedCSVElement( "destinationCountry", "", xmlFile, 3 )
	  }
      doDPSPostcode("returnToSenderPostcode", "", xmlFile)
      doCSVElement( "requiredAtDeliveryCode","", "", xmlFile )
   printf "  </channelSegment>%s",nl >> xmlFile
}

#######################################################################
#
# XSD1.1 expected 9 chars - 7 with right padding plus the suffix in 8 and 9
# XSD1.2 expected 9 chars - both 7+2 (PDA) and 9 (PSM) formats expected
# V1.0.35 So split handling based on messageType = 201

function doDPSPostcode( element, prefix, xmlFile)
{
   dps = csv[ hdr[ prefix toupper(element) ] ]
   ldps = length(dps)
   if ( ldps > 0 )
   {
      printf "<%s>%s",element,nl >> xmlFile
         if (MESSAGETYPE == "201")
         {
            doCSVElement( "postcode","", dps, xmlFile )
         }
         else
         {
            if ( ldps > 7 )
            {
               doCSVElement( "postcode","", substr(dps,1,ldps-2), xmlFile )
               doCSVElement( "postcodeSuffix","", substr(dps, ldps-1,2), xmlFile )
            }
            else
            {
               doCSVElement( "postcode","", dps, xmlFile )
            }
         }
      printf "</%s>%s",element,nl >> xmlFile
   }
}
#######################################################################
#
function channelPOLSegment( xmlFile )
{
   value = csv[ hdr["POLBRANCHID"] ]
   if ( length(value) > 0 ) 
   {
      printf "  <channelPOLSegment>%s",nl >> xmlFile
         doCSVElement( "POLBranchId","", "", xmlFile )
      printf "  </channelPOLSegment>%s",nl >> xmlFile
   }
}

#######################################################################
#
function channelBusinessSegment( xmlFile )
{
   value = csv[ hdr["DESPATCHPOSTCODE"] ]
   if ( length(value) > 0 ) 
   {
      printf "  <channelBusinessSegment>%s",nl >> xmlFile
         doDPSPostcode( "despatchPostCode", "", xmlFile )
         doMulti( "customerReferenceComment", "", xmlFile )
      printf "  </channelBusinessSegment>%s",nl >> xmlFile
   }
}

#######################################################################
#
function channelEIBSegment( xmlFile )
{
   value = csv[ hdr["ITEMID"] ]
   if ( length(value) > 0 ) 
   {
      printf "  <channelEIBSegment>%s",nl >> xmlFile
         doCSVElement( "itemId","", "", xmlFile )
         doCSVElement( "dieId","", "", xmlFile )
         doCSVElement( "supplyChainId","", "", xmlFile )
         doCSVElement( "licenceId","", "", xmlFile )
         doCSVElement( "productGroupCode","", "", xmlFile )
         doCSVElement( "tariffVersion","", "", xmlFile )
         doCSVElement( "tariffRate","", "", xmlFile )
         doCSVElement( "mailingDate","", "", xmlFile )
         doCSVElement( "channelCode","", "", xmlFile )
         doDPSPostcode( "businessReplyPostcodeDPS", "", xmlFile )
         if ( length(csv[ hdr["HASHENCODING"] ]) > 0 )
         {
            printf "  <securitySegment>%s",nl >> xmlFile
               doCSVElement( "hashEncoding","", "", xmlFile )
               doCSVElement( "keyId","", "", xmlFile )
            printf "  </securitySegment>%s",nl >> xmlFile
         }
         doCSVElement( "returnToSenderCode", "", xmlFile )
         comment = csv[ hdr["EIB_CRCOMMENT"] ]
         if ( length(comment) > 0 )
            doElement( "customerReferenceComment","", comment, xmlFile )
         doCSVElement( "format","", "", xmlFile )
      printf "  </channelEIBSegment>%s",nl >> xmlFile
   }
}

#######################################################################
#
function PFWWBarcode(xmlFile)
{
   pvalue = csv[ hdr["CONSIGNMENTDOMESTIC"] ]
   if ( length( pvalue ) > 0 )
   {
      printf "<PFWWBarcode>%s",nl >> xmlFile
         doCSVElement( "consignmentDomestic", "","", xmlFile )
      printf "</PFWWBarcode>%s",nl >> xmlFile
   }
}

#######################################################################
#
function GLSBarcode(xmlFile)
{
   value = csv[ hdr["PRIMARYBARCODE"] ]
   if ( length( value ) > 0 )
   {
      printf "<GLSBarcode>%s",nl >> xmlFile
         doCSVElement( "primaryBarcode","", "", xmlFile )
         doCSVElement( "secondaryBarcode","", "", xmlFile )
      printf "</GLSBarcode>%s",nl >> xmlFile
   }
}

#######################################################################
#
function internationalRegisteredBarcode(xmlFile)
{
   INTERNATIONALREGISTEREDBARCODE = csv[ hdr["INTERNATIONALREGISTEREDBARCODE"] ]
   if ( length( INTERNATIONALREGISTEREDBARCODE ) > 0 )
   {
      doCSVElement( "internationalRegisteredBarcode", "","", xmlFile )
   }
}

#######################################################################
#
function oneD(xmlFile)
{
   ONED = csv[ hdr["ONEDBARCODE"] ]
   HVP = csv[hdr["HIGHVOLUMEPOSTCODE"] ]
   
   if (( length( ONED ) > 0 ) || (length( HVP ) > 0 ))
   {
      printf "<oneD>%s",nl >> xmlFile
         #doCSVElement( "oneDBarcode","", "", xmlFile )
		 doElement( "oneDBarcode","", TESTBARCODE, xmlFile )
         doCSVElement( "highVolumePostcode","", "", xmlFile )
      printf "</oneD>%s",nl >> xmlFile
   }
}

#######################################################################
#
function doID( wrapper, prefix, xmlFile )
{
      valueStr =  csv[ hdr[prefix "UNIQUEIDSTRING"] ]
      if ( length(valueStr) > 0 )
	  {
	     printf "<%s>%s",wrapper,nl >> xmlFile
         doElement("uniqueIDString","", valueStr, xmlFile)
		 
		valueStr =  csv[ hdr[prefix "UNIQUEIDTYPE"] ]
		if ( length(valueStr) > 0 )
			doElement("uniqueIDType","", valueStr, xmlFile)
		printf "</%s>%s",wrapper,nl >> xmlFile
	}
}

#######################################################################
#
function doBase64Image( tag, xmlFile )
{
   #data:image/png;base64,
   printf "<%s>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</%s>%s",tag,tag,nl >> xmlFile
}

#######################################################################
#
function doSVG( element, height, xmlFile )
{
   printf "<%s>%s",element, nl >> xmlFile
   printf "<svg height=\"%s\" width=\"231\">%s",height, nl >> xmlFile
   printf "<polyline style=\"fill:none; stroke:#000000; stroke-width:1\" points=\"64,88 65,89 \"/>%s", nl >> xmlFile
   printf "<polyline style=\"fill:none; stroke:#000000; stroke-width:1\" points=\"81,64 78,60 84,65 90,67 96,67 \"/>%s", nl >> xmlFile
   printf "<polyline style=\"fill:none; stroke:#000000; stroke-width:1\" points=\"18,67 18,73 18,83 18,89 20,76 21,64 20,40 23,28 37,25 52,29 60,35 56,41 40,42 24,48 20,54 27,67 37,75 46,83 53,92 19,75 20,79 35,87 48,89 60,85 70,75 74,66 70,41 64,25 58,19 59,27 64,49 71,70 76,81 82,79 80,55 77,35 73,18 76,30 82,55 85,72 90,87 93,94 89,86 80,71 72,57 74,62 78,70 86,71 91,63 97,37 98,16 106,9 104,19 99,35 96,48 96,59 101,65 112,67 123,70 149,75 168,77 192,79 214,80 224,80 229,89 195,89 146,92 90,102 59,112 \"/>%s", nl >> xmlFile
   printf "<polyline style=\"fill:none; stroke:#000000; stroke-width:1\" points=\"200,41 205,39 220,34 \"/>%s", nl >> xmlFile
   printf "<polyline style=\"fill:none; stroke:#000000; stroke-width:1\" points=\"123,72 128,65 133,61 133,79 160,4 \"/>%s", nl >> xmlFile
   printf "</svg>%s", nl >> xmlFile
   printf "</%s>%s",element, nl >> xmlFile
}

#######################################################################
#
function manualScan( xmlFile )
{
   MS_DATETIME = csv[ hdr["MS_DATETIME"] ]
   
   printf TESTDATE
   
   uniqueNo = 0 # reset to 0 so for large files the time doesnt stretch to hours
   
   TESTDATE2 = TESTDATE1"T08:41:18+00:00"
   printf "<manualScan>%s",nl >> xmlFile
      doCSVElement("routeOrWalkNumber","", "", xmlFile)
      doCSVElement("messageId","", "", xmlFile)
      doCSVElement("trackEventId","", "", xmlFile)
      doCSVElement("deviceId","", "", xmlFile)
      doCSVElement("userId","", "", xmlFile)
      RMGLocation( "MS_", xmlFile )
      doGeoSpatial("scanLocation","SC_",xmlFile)
      #doCSVElement("trackedEventCode","", "", xmlFile)
	  doElement( "trackedEventCode","", TESTEVENT, xmlFile)
	  MS_DATETIME=TESTDATE
      if  ( length (MS_DATETIME) > 0 )
		 doCSVTSElement("scanTimestamp", "", MS_DATETIME, xmlFile)
		 #doElement("scanTimestamp","", TESTDATE2, xmlFile)
	  else
	     doCSVElement("scanTimestamp","", "", xmlFile)
      doCSVElement("scanComment","", "", xmlFile)
      if  ( length (MS_DATETIME) > 0 )
		 doCSVTSElement("eventTimestamp", "", MS_DATETIME, xmlFile)
		 #doElement("eventTimestamp","", TESTDATE, xmlFile)
	  else
	     doCSVElement("eventTimestamp","", "", xmlFile)
      if  ( length (MS_DATETIME) > 0 )
		 doCSVTSElement("transmissionTimestamp", "", MS_DATETIME, xmlFile)
	  else
	     doCSVElement("transmissionTimestamp","", "", xmlFile)
      if  ( length (MS_DATETIME) > 0 )
		 doCSVTSElement("transmissionCompleteTimestamp", "", MS_DATETIME, xmlFile)
	  else
	     doCSVElement("transmissionCompleteTimestamp","", "", xmlFile)
      if  ( length (MS_DATETIME) > 0 )
		 doCSVTSElement("eventReceivedTimestamp", "", MS_DATETIME, xmlFile)
	  else
	  doCSVElement("eventReceivedTimestamp", "","", xmlFile)
      doCSVElement("eventReason","", "", xmlFile)
      doCSVElement("manualScanIndicator","", "", xmlFile)
      doCSVElement("workProcessCode","", "", xmlFile)  
      doCSVElement("neighbourName","", "", xmlFile)
      doAddress( "neighbourAddress", "NA_", xmlFile )
      doGeoSpatial("safePlaceLocation","SP_",xmlFile)

	  # v1.5
	  doCSVElement("ImageURI","", "", xmlFile)

      doCSVElement("signatureName","", "", xmlFile)
      
      signatureImage = csv[ hdr["SIGNATUREIMAGE"] ]
      if ( length(signatureImage) > 0 )
         doBase64Image( "signatureImage", xmlFile )
   
      svgHeight = csv[ hdr["SVGHEIGHT"] ]
      if ( svgHeight > 0 )
         doSVG("signatureSVG", svgHeight, xmlFile)

	  # v1.5
	  doCSVElement("itemCount","", "", xmlFile)
      doCSVElement("RMGTTWalkCode","", "", xmlFile)
      doCSVElement("RMGTTOriginCustomerNumber","", "", xmlFile)
	  doCSVElement("RMGTTDestinationCode","", "", xmlFile)

   printf "</manualScan>%s",nl >> xmlFile
}

#######################################################################
#
function rawScanData ( xmlFile )
{
   rawBarcodeText = csv[ hdr["RAWBARCODETEXT"] ]
   mailPieceRecord = csv[ hdr["MAILPIECERECORD"] ]
   
   if ( length(rawBarcodeText) > 0 || length(mailPieceRecord) > 0  )
   {   
		printf "<rawScanData>%s",nl >> xmlFile
	  
		if ( length(rawBarcodeText) > 0 )
			doRawBarcodeText( xmlFile )

		if ( length(mailPieceRecord) > 0 )
		{
			doMailPieceRecord( xmlFile )
		}
		printf "</rawScanData>%s",nl >> xmlFile
   }
}

#######################################################################
#
function internationalScan ( xmlFile )
{
   MS_DATETIME = csv[ hdr["MS_DATETIME"] ]
   
   uniqueNo = 0 # reset to 0 so for large files the time doesnt stretch to hours
   
   printf "<internationalScan>%s",nl >> xmlFile
   
      doPfxCSVElement( "trackedEventCode", "IS_", "", xmlFile)
      doCSVTSElement( "eventTimestamp", "IS_", "", xmlFile)
      doPfxCSVElement( "eventSource", "IS_", "", xmlFile)
      doPfxCSVElement( "originatingTrackedEventCode", "IS_", "", xmlFile)
      RMGLocation( "IS_", xmlFile)
      doPfxCSVElement( "locationReference", "IS_", "", xmlFile)
      doHeader( "IS_", xmlFile)
      doItemDetails( "ID_", xmlFile)
	  doSender( "ISA_", xmlFile)
      doCustomer( "IC_", xmlFile)
	  doRecipient( "IDA_", "IAA_", xmlFile)
      doOOED( "IOD_", xmlFile)
	  doOOER( "IOR_", xmlFile)
      doDelivery( "ID_", xmlFile)
   printf "</internationalScan>%s",nl >> xmlFile
}

#######################################################################
#
function containerScan( xmlFile )
{
# ContainerScan
   CS_DATETIME = csv[ hdr["CS_EVENTTIMESTAMP"] ]
   uniqueNo = 0 # reset to 0 so for large files the time doesnt stretch to hours
   printf "<containerScan>%s",nl >> xmlFile   
      doPfxCSVElement("trackedEventCode", "CS_", "", xmlFile)
      doPfxCSVElement("deviceId", "CS_", "", xmlFile)
      doPfxCSVElement("userId", "CS_", "", xmlFile)
	  RMGLocation("CL_", xmlFile)
	  doGeoSpatial("scanLocation", "CS_", xmlFile)
	  doCSVTSElement("eventTimestamp", "", CS_DATETIME, xmlFile)
	  doID("containerItem", "CI_", xmlFile)
   printf "</containerScan>%s",nl >> xmlFile

}

#######################################################################
#
function billOnScan( xmlFile )
{
# Bill on Scan
   printf "<billOnScan>%s",nl >> xmlFile
      doPfxCSVElement("trackedEventCode", "BO_", "", xmlFile)
	  doCSVTSElement("eventTimestamp", "BO_", "", xmlFile)
      doPfxCSVElement("originatingTrackedEventCode", "BO_", "", xmlFile)
      doPfxCSVElement("requestType", "BO_", "", xmlFile)
      doPfxCSVElement("salesOrderId", "BO_", "", xmlFile)
      doPfxCSVElement("preAdviceFileName", "BO_", "", xmlFile)
      doPfxCSVElement("customerAccountId", "BO_", "", xmlFile)
      doPfxCSVElement("postingLocationId", "BO_", "", xmlFile)
      doPfxCSVElement("productCode", "BO_", "", xmlFile)
      doPfxCSVElement("contractCode", "BO_", "", xmlFile)
      doPfxCSVElement("serviceOccurrence", "BO_", "", xmlFile)
      doPfxCSVElement("surchargeReason", "BO_", "", xmlFile)
      doPfxCSVElement("reasonDescription", "BO_", "", xmlFile)
   printf "</billOnScan>%s",nl >> xmlFile
}

#######################################################################
#
function estimatedDeliveryWindow( xmlFile )
{
# EDW
   printf "<estimatedDeliveryWindowSegment>%s",nl >> xmlFile
      doPfxCSVElement("trackedEventCode", "ED_", "", xmlFile)
	  doCSVTSElement("eventTimestamp", "ED_", "", xmlFile)
      doPfxCSVElement("originatingTrackedEventCode", "ED_", "", xmlFile)
      doCSVTSElement("startOfEstimatedWindow", "ED_", "", xmlFile)
      doPfxCSVElement("lengthOfEstimatedWindow", "ED_", "", xmlFile)
      doPfxCSVElement("estimatedWindowConfidence", "ED_", "", xmlFile)
      doPfxCSVElement("calculationSource", "ED_", "", xmlFile)
      doPfxCSVElement("reasonDescription", "ED_", "", xmlFile)
      doDPSPostcode("EDWPostcodeDPS", "ED_", xmlFile)
   printf "</estimatedDeliveryWindowSegment>%s",nl >> xmlFile
}

#######################################################################
#
function notification( xmlFile )
{
# Notification
   printf "<notificationSegment>%s",nl >> xmlFile
      doPfxCSVElement("trackedEventCode", "NS_", "", xmlFile)
	  doCSVTSElement("eventTimestamp", "NS_", "", xmlFile)
      doPfxCSVElement("notificationDestination", "NS_", "", xmlFile)
      doPfxCSVElement("notficationDestinationType", "NS_", "", xmlFile)
      doPfxCSVElement("notificationMessageID", "NS_", "", xmlFile)
      doPfxCSVElement("originatingTrackedEventCode", "NS_", "", xmlFile)
      doPfxCSVElement("reasonDescription", "NS_", "", xmlFile)
      doPfxCSVElement("notificationRecipientType", "NS_", "", xmlFile)
   printf "</notificationSegment>%s",nl >> xmlFile
}

#######################################################################
#
function doGeoSpatial( parent, prefix, xmlFile )
{
#	This is optional tag - so allow it not to appear if all elements are absent

    GDSCODE=""
	POSITIONCODE=""
	ALTITUDE=""
	LONGITUDE=""
	LATITUDE=""
	
	GDSCODE =  csv[ hdr[prefix "GDSCODE"] ]
    POSITIONCODE =  csv[ hdr[prefix "POSITIONCODE"] ]
	ALTITUDE =  csv[ hdr[prefix "ALTITUDE"] ]
	LONGITUDE =  csv[ hdr[prefix "LONGITUDE"] ]
	LATITUDE =  csv[ hdr[prefix "LATITUDE"] ]
	
	if (length(GDSCODE) > 0 || length(POSITIONCODE) > 0 || length(ALTITUDE) > 0 || length(LONGITUDE) > 0 || length(LATITUDE) > 0)
	{
		printf "<%s>%s", parent, nl >> xmlFile
		if ( length(GDSCODE) > 0 )
			doElement("gdsCode","", GDSCODE, xmlFile)
		if ( length(POSITIONCODE) > 0 )
			doElement("positionCode","", POSITIONCODE, xmlFile)
		if ( length(ALTITUDE) > 0 )
			doElement("altitude","", ALTITUDE, xmlFile)
		if ( length(LONGITUDE) > 0 )
			doElement("longitude","", LONGITUDE, xmlFile)
		if ( length(LATITUDE) > 0 )
			doElement("latitude","", LATITUDE, xmlFile)
		printf "</%s>%s", parent, nl >> xmlFile
   }
}
#######################################################################
#
function doBuildingNoAddress( parent, pfix, xmlFile )
{
	# Within the channelSegemnt there is an address consisting of two elements
	BUILDINGNAME = csv[ hdr[pfix "BUILDINGNAME"] ]
	BUILDINGNUMBER = csv[ hdr[pfix "BUILDINGNUMBER"] ]
	if ( length (BUILDINGNUMBER) > 0 || length (BUILDINGNAME) > 0 )
	{
		printf "<%s>%s",parent,nl >> xmlFile
			doPfxCSVElement("buildingName", pfix, "", xmlFile)
			doPfxCSVElement("buildingNumber", pfix, "", xmlFile)
		printf "</%s>%s",parent,nl >> xmlFile
	}
}

#######################################################################
#
function doAddress( parent, pfix, xmlFile )
{
   # Within label there is an address consisting of fourteen elements - check for any of first 5 - 5th being start of address
   ele1 = csv[ hdr[pfix "ADDRESSUSAGECODE"] ]
   ele2 = csv[ hdr[pfix "DOMESTICINDICATOR"] ]
   ele3 = csv[ hdr[pfix "BUILDINGNAME"] ]
   ele4 = csv[ hdr[pfix "BUILDINGNUMBER"] ]
   ele5 = csv[ hdr[pfix "ADDRESSLINE1"] ]

   if ((length(ele1) > 0 ) || (length(ele2) > 0) || (length(ele3) > 0) || (length(ele4) > 0) || (length(ele5) > 0))
   {
      printf "<%s>%s",parent,nl >> xmlFile
      if ( length(ele1) > 0 )
		 doMulti("addressUsageCode", pfix, xmlFile)

      if ( length(ele2) > 0 )
         doPfxCSVElement("domesticIndicator", pfix, "", xmlFile)

      if ( length(ele3) > 0 )
         doPfxCSVElement("buildingName", pfix, "", xmlFile)

	  if ( length(ele4) > 0 )
         doPfxCSVElement("buildingNumber", pfix, "", xmlFile)
			
      if ( length(ele5) > 0 )
	  {
         doPfxCSVElement("addressLine1", pfix, "", xmlFile)
         doPfxCSVElement("addressLine2", pfix, "", xmlFile)
         doPfxCSVElement("addressLine3", pfix, "", xmlFile)
         doPfxCSVElement("addressLine4", pfix, "", xmlFile)
         doPfxCSVElement("addressLine5", pfix, "", xmlFile)
         doPfxCSVElement("stateOrProvince", pfix, "", xmlFile)
         doPfxCSVElement("postTown", pfix, "", xmlFile)
         doPfxCSVElement("county", pfix, "", xmlFile)
         doPfxCSVElement("postcode", pfix, "", xmlFile)
         doPfxCSVElement("country", pfix, "", xmlFile)
	  }
      printf "</%s>%s",parent,nl >> xmlFile
   }
}
#######################################################################
#
function doLabel( xmlFile )
{
   senderName = csv[ hdr["LS_CONTACTNAME"] ]
   recipientName = csv[ hdr["LR_CONTACTNAME"] ]

   if ((length(senderName) > 0 ) || (length(recipientName) > 0 ))
   {
      printf "<label>%s",nl >> xmlFile
         if ( length(senderName) > 0 )
		 {
			printf "<sender>%s",nl >> xmlFile
			doPfxCSVElement("contactName", "LS_", "", xmlFile)
			doPfxCSVElement("contactEmail", "LS_", "", xmlFile)
			doPfxCSVElement("contactTelephone", "LS_", "", xmlFile)
			doAddress( "address", "LS_", xmlFile )
			printf "</sender>%s",nl >> xmlFile
		 }
		 
         if ( length(recipientName) > 0 )
		 {
			printf "<recipient>%s",nl >> xmlFile
			doPfxCSVElement("contactName", "LR_", "", xmlFile)
			doPfxCSVElement("contactEmail", "LR_", "", xmlFile)
			doPfxCSVElement("contactTelephone", "LR_", "", xmlFile)
			doPfxCSVElement("contactLanguageCode", "LR_", "", xmlFile)
			doAddress( "address", "LR_", xmlFile )
			doAddress( "alternativeAddress", "LA_", xmlFile )
			printf "</recipient>%s",nl >> xmlFile
		 }
       printf "</label>%s",nl >> xmlFile
   }
}

#######################################################################
#
function mailPiece( xmlFile )
{
   PRIMARYIDENTIFIER = csv[ hdr["PI_UNIQUEIDSTRING"] ]
   
   printf "<mailPiece>%s",nl >> xmlFile
   
   if ( length(PRIMARYIDENTIFIER) > 0 )
      mailPieceIdentifier( xmlFile )
   else
      mailPieceBarcode( xmlFile )

   if ( MESSAGETYPE == "201")
   {
		dims( xmlFile )
		doCSVElement("postageDue","", "", xmlFile)
		doCSVElement("trueVolume","", "", xmlFile)
		doLabel(xmlFile)
   }
   if ( MESSAGETYPE == "201" || MESSAGETYPE == "CONT" )
      doCSVElement("containerType","", "", xmlFile)
   
      
   printf "</mailPiece>%s",nl >> xmlFile
}

#######################################################################
#
function mailPieceEvent( xmlFile )
{
	if(MESSAGEFORMAT=="XML")
	{
	    if (REF!="TC99_4_POL-071C-JC092GB")
		mailPiece( xmlFile )
	}
   if ( length( MESSAGETYPE ) > 0 )
   {
      if ( MESSAGETYPE == "CONT" )
	  {
         containerScan( xmlFile )
	  }
      else
	  if ( MESSAGETYPE == "NOTIF" )
	  {
         notification( xmlFile )
	  }
      else
	  if ( MESSAGETYPE == "BOS" )
	  {
         billOnScan( xmlFile )
	  }
      else
	  if ( MESSAGETYPE == "EDW" )
	  {
         estimatedDeliveryWindow( xmlFile )
	  }
      else
	  if ( MESSAGETYPE == "IEDE" )
	  {
         internationalScan( xmlFile )
	  }
	  else
	  {
         machineRecord( xmlFile )
	  }
   }
  
    if(MESSAGEFORMAT=="CCJSON")
   {
		ccJSON( xmlFile )
   }
   else if(MESSAGEFORMAT=="JSON")
   {
		inflightJSON( xmlFile )
   }
   else if(MESSAGEFORMAT=="XML")
   {
	  if (REF=="TC99_4_POL-071C-JC092GB")
			POLTNT_REQ(xmlFile)
	  else
			manualScan( xmlFile )
   }
   else if(MESSAGEFORMAT=="TXT" && REF=="TC99_4_STAR2_OUTWARD-JC092GB")
   {
		STAROUTWARD(xmlFile)
   }
    else if(MESSAGEFORMAT=="TXT" && REF=="TC99_4_STAR2_INWARD-JC092GB")
	{
		STARINWARD(xmlFile)
	}
    else if(MESSAGEFORMAT=="TXT" && REF=="TC99_4_STAR2_RFD-JC092GB")
	{
		STARRFD(xmlFile)
	}
   if(MESSAGEFORMAT=="XML")
   {
   if (REF!="TC99_4_POL-071C-JC092GB")
   rawScanData( xmlFile )
   }
} 


#######################################################################
#
function doPTPFooter(xmlFile)
{
   printf "%s%s","</ptp:MPE>",nl >> xmlFile
}

#######################################################################
#
function doMMSHeader( xmlFile )
{
   printf "%s%s","<?xml version=\"1.0\" encoding=\"UTF-8\"?>",nl >> xmlFile
   printf "<MMS xmlns\:xsi=\"http\://www.w3.org/2001/XMLSchema-instance\" xmlns\:xsd=\"http://www.w3.org/2001/XMLSchema\">%s",nl >> xmlFile
   lastxmlFile = xmlFile
   lastMMSReference = MMSREFERENCE
}

#######################################################################
#
function MMS( xmlFile )
{

   SCANTIMESTAMP = csv[ hdr[ "SCANTIMESTAMP" ] ]
   printf "<Event>%s",nl >> xmlFile
      doCSVElement("EventId","","",xmlFile)
      doCSVElement("UserId","","",xmlFile)
      doCSVElement("SiteId","","",xmlFile)
      doCSVElement("RMGTT_Id","","",xmlFile)
      doCSVElement("DeviceId","","",xmlFile)
      uniqueNo = 1
      doCSVTSElement("CreatedTimestamp", "", SCANTIMESTAMP,xmlFile)
      uniqueNo = 3
      doCSVTSElement("TransferTimestamp", "", SCANTIMESTAMP,xmlFile)
      uniqueNo = 4
      doCSVTSElement("EventTimestamp", "", SCANTIMESTAMP,xmlFile)
      uniqueNo = 2
      doCSVTSElement("HHSentTimestamp", "", SCANTIMESTAMP,xmlFile)
      doCSVElement("Latitude","","",xmlFile)
      doCSVElement("Longitude","","",xmlFile)
      doEventDetail( xmlFile )
   printf "</Event>%s",nl >> xmlFile
}

#######################################################################
#
function doEventDetail( xmlFile )
{
   printf "<EventDetail>%s",nl >> xmlFile
      doCSVElement("RouteOrWalkNumber","","",xmlFile)
      doCSVElement("WorkProcessId","","",xmlFile)
      doDeliveryItemScan(xmlFile)
   printf "</EventDetail>%s",nl >> xmlFile
}

#######################################################################
#
function doDeliveryItemScan( xmlFile )
{
   printf "<DeliveryItemScan>%s",nl >> xmlFile
      doEventItem( xmlFile )
      doCSVElement("EventSignatory","","",xmlFile)
      svgHeight = csv[ hdr[ "SVGHEIGHT" ] ]
      if ( length(svgHeight) > 0 )
         doSVG("EventSignature", svgHeight, xmlFile)
   printf "</DeliveryItemScan>%s",nl >> xmlFile
}

#######################################################################
#
function doEventItem( xmlFile )
{
   items[1] = ""
   all = csv[ hdr[ "ITEMUID" ] ]

   split(all, items, "|" )
   for ( i in items )
   {
      printf "<EventItem>%s",nl >> xmlFile
         doElement("ItemUId","",items[i],xmlFile)
         uniqueNo = 1
         doCSVTSElement("ScanTimestamp","", "",xmlFile)
         doCSVElement("RMGCode","","",xmlFile)
         doCSVElement("ManualScannedFlag","","",xmlFile)
      printf "</EventItem>%s",nl >> xmlFile
   }
}

#######################################################################
#
function doRawBarcodeText ( xmlFile )
{
   #<mailPieceRecord machineID="100" vendor="100" version="1">text</mailPieceRecord>
   rbt[1] = ""
   allRBT = csv[ hdr[ "RAWBARCODETEXT" ] ]
   rbtCount=0
   if ( length(allRBT) > 0 )
   {
      split(allRBT, rbt, "|" )
      for ( rbtCount in rbt )
      {
	  	# the attributes follow the text with a ~ separator - done this way as rawbarcodetext can have multiple entries
		rbtpart[1]=""
		rbtpart[2]=""
		split (rbt[rbtCount], rbtpart, "~")
		printf "<rawBarcodeText %s>%s</rawBarcodeText>%s",rbtpart[2],rbtpart[1],nl >> xmlFile
      }
   }
}

#######################################################################
#
function doMailPieceRecord ( xmlFile )
{
   allMPR = csv[ hdr[ "MAILPIECERECORD" ] ]
   if ( length(allMPR) > 0 )
   {
		# the attributes follow the text with a ~ separator - done this way as rawbarcodetext can have multiple entries - mpr only has the one
		mprpart[1]=""
		mprpart[2]=""
		split (allMPR, mprpart, "~")
		printf "<mailPieceRecord %s>%s</mailPieceRecord>%s",mprpart[2],mprpart[1],nl >> xmlFile
   }
}


#######################################################################
#
function doMulti( parent, pfix, xmlFile )
{
   multiArray[1] = ""
   elementMulti = parent
   if (length(pfix) > 0)
      elementMulti = pfix elementMulti
   elementMulti = toupper(elementMulti)
   
   allMulti = csv[ hdr[ elementMulti ] ]
   multiCount=0
   if ( length(allMulti) > 0 )
   {
      split(allMulti, multiArray, "|" )
      for ( multiCount in multiArray )
      {
         printf "<%s>%s</%s>%s", parent, multiArray[multiCount], parent, nl >> xmlFile
      }
   }
}
 
#######################################################################
#
function doMMSFooter( MMSRef, xmlFile )
{
   if ( length(xmlFile) > 0 )
   {
      if ( length(MMSRef) > 0 ) 
      {
         doElement("MMSReference","",MMSRef, xmlFile )
         printf "</MMS>%s",nl >> xmlFile
      }
   }
}

#######################################################################
# csv handling functions
#######################################################################
#######################################################################
#!/usr/bin/awk -f
#**********************************************************************
#
# This file is in the public domain.
#
# For more information email LoranceStinson+csv@gmail.com.
# Or see http://lorance.freeshell.org/csv/
#
# Parse a CSV string into an array.
# The number of fields found is returned.
# In the event of an error a negative value is returned and csverr is set to
# the error. See below for the error values.
#
# Parameters:
# string  = The string to parse.
# csv     = The array to parse the fields into.
# sep     = The field separator character. Normally ,
# quote   = The string quote character. Normally "
# escape  = The quote escape character. Normally "
# newline = Handle embedded newlines. Provide either a newline or the
#           string to use in place of a newline. If left empty embedded
#           newlines cause an error.
# trim    = When true spaces around the separator are removed.
#           This affects parsing. Without this a space between the
#           separator and quote result in the quote being ignored.
#
# These variables are private:
# fields  = The number of fields found thus far.
# pos     = Where to pull a field from the string.
# strtrim = True when a string is found so we know to remove the quotes.
#
# Error conditions:
# -1  = Unable to read the next line.
# -2  = Missing end quote.
# -3  = Missing separator.
#
# Notes:
# The code assumes that every field is preceded by a separator, even the
# first field. This makes the logic much simpler, but also requires a
# separator be prepended to the string before parsing.
#**************************************************************************
function parse_csv(string,csv,sep,quote,escape,newline,trim, fields,pos,strtrim) {
    # Make sure there is something to parse.
    if (length(string) == 0) return 0;
    string = sep string; # The code below assumes ,FIELD.
    fields = 0; # The number of fields found thus far.
    while (length(string) > 0) {
        # Remove spaces after the separator if requested.
        if (trim && substr(string, 2, 1) == " ") {
            if (length(string) == 1) return fields;
            string = substr(string, 2);
            continue;
        }
        strtrim = 0; # Used to trim quotes off strings.
        # Handle a quoted field.
        if (substr(string, 2, 1) == quote) {
            pos = 2;
            do {
                pos++
                if (pos != length(string) &&
                    substr(string, pos, 1) == escape &&
                    (substr(string, pos + 1, 1) == quote ||
                     substr(string, pos + 1, 1) == escape)) {
                    # Remove escaped quote characters.
                    string = substr(string, 1, pos - 1) substr(string, pos + 1);
                } else if (substr(string, pos, 1) == quote) {
                    # Found the end of the string.
                    strtrim = 1;
                } else if (newline && pos >= length(string)) {
                    # Handle embedded newlines if requested.
                    if (getline == -1) {
                        csverr = "Unable to read the next line.";
                        return -1;
                    }
                    string = string newline $0;
                }
            } while (pos < length(string) && strtrim == 0)
            if (strtrim == 0) {
                csverr = "Missing end quote.";
                return -2;
            }
        } else {
            # Handle an empty field.
            if (length(string) == 1 || substr(string, 2, 1) == sep) {
                csv[fields] = "";
                fields++;
                if (length(string) == 1)
                    return fields;
                string = substr(string, 2);
                continue;
            }
            # Search for a separator.
            pos = index(substr(string, 2), sep);
            # If there is no separator the rest of the string is a field.
            if (pos == 0) {
                csv[fields] = substr(string, 2);
                fields++;
                return fields;
            }
        }
        # Remove spaces after the separator if requested.
        if (trim && pos != length(string) && substr(string, pos + strtrim, 1) == " ") {
            trim = strtrim
            # Count the number fo spaces found.
            while (pos < length(string) && substr(string, pos + trim, 1) == " ") {
                trim++
            }
            # Remove them from the string.
            string = substr(string, 1, pos + strtrim - 1) substr(string,  pos + trim);
            # Adjust pos with the trimmed spaces if a quotes string was not found.
            if (!strtrim) {
                pos -= trim;
            }
        }
        # Make sure we are at the end of the string or there is a separator.
        if ((pos != length(string) && substr(string, pos + 1, 1) != sep)) {
            csverr = "Missing separator.";
            return -3;
        }
        # Gather the field.
        csv[fields] = substr(string, 2 + strtrim, pos - (1 + strtrim * 2));
        fields++;
        # Remove the field from the string for the next pass.
        string = substr(string, pos + 1);
    }
    return fields;
}
#
# dummy fumction to put the excel contents as a csv message body
#
function doFile( xmlFile )
{
   startColumn = hdr["RFH_TRACKINGNUMBER"] +1
   if ( startColumn < num_fields )
   {
      printf "%s",savedHdr[startColumn] >> xmlFile
      for ( i=startColumn+1; i < num_fields; i++ )
      printf ",%s",savedHdr[i] >> xmlFile
        printf "%s",nl  >> xmlFile
      
      do
      {
         printf "%s",csv[startColumn] >> xmlFile
         for ( i=startColumn+1; i < num_fields; i++ )
         printf ",%s",csv[i] >> xmlFile
         printf "%s",nl  >> xmlFile
         if ( getline > 0 )
            parseLine()
         else
            break
      } while ( 1 == 1)
   }
}


#######################################################################################################################
#
# This is the input loop - line by line of the csv
#
#######################################################################################################################
#######################################################################################################################
	{
	# first line expected to be low number of group headers followed by column headers
	# so skip until we see Message type - note this is case sensitive at the moment
	do
		{
		if (index($0,"MessageType") > 0 ) break
		} while ( getline > 0 )
		
	parseHeader()
	
#DEBUG THE ARRAYS
#print "HEADER"
#for (var in hdr)
#{
#if (length(hdr[var]) != 0 ) print var, hdr[var]
#}

	while ( getline > 0 ) 
		{
		parseLine()
		
#DEBUG THE ARRAYS
#print "BODY"		
#for (var in csv)
#{
#if (length(csv[var]) != 0 ) print var, csv[var]
#}

		if ( REF > 0 )
			{
				if ( REF == "TC99_4_PDA-071C-JC092GB" || REF == "TC99_4_PSM-071C-JC092GB" || REF == "TC99_4_VOL-071C-JC092GB"|| REF=="TC99_4_POL-071C-JC092GB")   
				xmlFile = outputPath REF ".xml"
				else if ( REF == "TC99_4_PDA-JSON-JC092GB" )
				xmlFile = outputPath REF ".json"
				else if ( REF == "CC_4_PDA-CCJSON-JC092GB" )
				xmlFile = outputPath REF ".json"
				else if ( REF == "TC99_4_STAR2_INWARD-JC092GB" || REF=="TC99_4_STAR2_OUTWARD-JC092GB"|| REF=="TC99_4_STAR2_RFD-JC092GB")
				xmlFile = outputPath REF ".txt"
				
				if ( xmlFile != lastxmlFile )
					{
					printf "" > xmlFile
					if ( length ( NORFH ) == 0)
						if(MESSAGEFORMAT=="XML" || MESSAGEFORMAT=="JSON" || MESSAGEFORMAT=="CCJSON")
						doRFH(xmlFile)
					}
	
			if ( MESSAGETYPE == 14 )  #  MID
				{
				printf "%sMID%s",nl,nl >> xmlFile
				doFile(xmlFile)
				}
			else if ( MESSAGETYPE == 17 )  #  CTR
				{
				printf "%sCTR%s",nl,nl >> xmlFile
				doFile(xmlFile)
				}
			else if ( MESSAGETYPE == 22 )  #  OEE
				{
				printf "%sOEE%s",nl,nl >> xmlFile
				doFile(xmlFile)
				}
			else if ( MESSAGETYPE == "MMS" )  #  MMS
				{
				if ( length(lastMMSReference) > 0 )
					{
					if ( lastMMSReference != MMSREFERENCE )
						{
						doMMSFooter( lastMMSReference, lastxmlFile )
					#	printf "" > xmlFile
						doMMSHeader(xmlFile)
						}		
					}
				else
					{
					doMMSHeader(xmlFile)
					}
					
				MMS(xmlFile)
				}
			else    #  should be type 201 and CONT/IEDE/Notif/BOS/EDW
				{
				if(MESSAGEFORMAT=="XML")
				{
				 if (REF != "TC99_4_POL-071C-JC092GB")
				 doPTPHeader(xmlFile)
				}
				mailPieceEvent(xmlFile)
				
				if(MESSAGEFORMAT=="XML")
				{
				if (REF != "TC99_4_POL-071C-JC092GB")
				doPTPFooter(xmlFile)
				}
				}
			recordCount++
			}
		
		}
	}
	
END	{
		doMMSFooter( MMSREFERENCE, xmlFile)
	}
