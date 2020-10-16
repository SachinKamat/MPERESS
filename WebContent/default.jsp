<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" type="text/css" href="css/Finalpage.css" />

</head>
<body>
	<button class="tablink" onclick="openPage('1D', this, 'green')"
		id="defaultOpen">PDA / STAR2 Scan</button>
	<!-- <button class="tablink" onclick="openPage('2D', this, 'green')">PDA
		2D Scan</button> -->
	<button class="tablink" onclick="openPage('Json', this, 'green')">PDA
		Json Inflight scan</button>
	<button class="tablink" onclick="openPage('ccJson', this, 'green')">PDA
		Order Level scan- Consumer Collection</button>
	<button class="tablink" onclick="openPage('Pol', this, 'green')">
		POL Scan</button>
	<button class="tablink" onclick="openPage('PA', this, 'green')">
		Click and Drop - EBAY VTN</button>
	<button class="tablink" onclick="openPage('INTLPA', this, 'green')">
		International Preadvice</button>
	<div id="mperess" align="center">MPERESS</div>
	<div id="mperess_text" align="center">"The Test Tool for Scanning
		Professionals"</div>

	<div id="PA" class="tabcontent">
		<form name="MyServletPACOSSqw" action="MyServletPACOSS" method="post"
			onsubmit="return validate();" target="_blank">

			<table id="1D-COSS" align="center">
				<tr>
					<td><label for="selectProductType">Select Product:</label></td>
					<td><select id="productTypeID" name="productTypeID">
							<option value="empty">Select Product</option>
							<option value="TPN01">RM Tracked 24 Non Signature</option>
							<option value="TPS01">RM Tracked 48 Non Signature</option>
							<option value="TPN01-24">RM Tracked 24 With Signature</option>
							<option value="TPS01-48">RM Tracked 48 With Signature</option>
							<option value="SD101">Special Delivery Guaranteed by 1PM</option>
							<option value="SD401">Special Delivery Guaranteed by 9AM</option>
					</select></td>
				</tr>
				<tr>
					<td><label for="vtn1" class="uvtn1" data-icon="p">
							Sender reference VTN1:</label></td>
					<td><input id="vtn1" name="vtn1" type="text"
						placeholder="eg. EBAY123ABG4" /></td>
				</tr>
				<tr>
					<td><label for="vtn" class="uvtn" data-icon="p">
							Sender reference VTN2:</label></td>
					<td><input id="vtn" name="vtn" type="text"
						placeholder="eg. EBAY123ABC4" /></td>
				</tr>
				<tr>
					<td><label for="senderAddress1" class="usenderAddress1"
						data-icon="p"> Address Line 1:</label></td>
					<td><input id="senderAddress1" name="senderAddress1"
						type="text" placeholder="eg. sender address line 1" /></td>

				</tr>
				<tr>
					<td><label for="senderAddress2" class="usenderAddress2"
						data-icon="p"> Address Line 2:</label></td>
					<td><input id="senderAddress2" name="senderAddress2"
						type="text" placeholder="eg. sender address line 2" /></td>

				</tr>
				<tr>
					<td><label for="senderPostCode" class="usenderPostCode"
						data-icon="p"> PostCode:</label></td>
					<td><input id="senderPostCode" name="senderPostCode"
						required="required" type="text" placeholder="eg. BT744AE1A" /></td>
				</tr>

				<tr>
					<td><label for="LocationID" class="uLocationID" data-icon="p">
							Location ID:</label></td>
					<td><input id="LocationID" name="LocationID"
						required="required" type="text" placeholder="eg. 002599" /></td>
				</tr>
				<tr>
					<td><label for="senderName" class="usenderName" data-icon="p">
							RecipientName:</label></td>
					<td><input id="senderName" name="senderName" type="text"
						placeholder="eg. Name" /></td>
				</tr>
				<tr>
					<td><label for="emailId" class="uemailId" data-icon="p">
							EmailId:</label></td>
					<td><input id="emailId" name="emailId" required="required"
						type="text" placeholder="eg. troyalmail@gmail.com" /></td>
				</tr>
				<tr>
					<td></td>
					<td><input type="submit" value="Generate + Submit Preadvice" /></td>
				</tr>

			</table>
			<div id="preadvice_text" align="center">**Preadvice processing
				will take maximum 10 minutes to process. Report immediately if PA
				failed.</div>
		</form>
	</div>

	<div id="1D" class="tabcontent">
		<form name="MyServletMperess1D" action="MyServletMperess"
			method="post">

			<table id="1D-table" align="center">
				<tr>
					<td><input type="checkbox" id="PFW" name="PFW" value="PFWtrue" /></td>
					<td><label for="PFW"> I want to use PWF barcode for my
							scan</label></td>
				</tr>
				<tr>
					<td><label for="barcode" class="ubarcode" data-icon="u">
							Barcode:</label></td>
					<td><input id="barcode" name="barcode" required="required"
						type="text" placeholder="TK200004405GB" /></td>
				</tr>
				<tr>
					<td><label for="eventid" class="ueventid" data-icon="p">
							EventID:</label></td>
					<td><input id="eventId" name="eventId" required="required"
						type="text" placeholder="eg. EVDAC" /></td>
				</tr>
				<tr>
					<td><label for="ldate" class="udate" data-icon="p">
							Date:</label></td>
					<td><input type="text" onload="getDate('date1d')"
						name="date1d" id="date1d"></td>
					<td><input id="date1dbutton" type="button" value="Update Time"
						onclick="getDate('date1d')" /></td>
				</tr>
				<tr>
					<td><label for="selectLocation">Select Location:</label></td>
					<td><select id="location"
						onchange="countryChange(this,'locationID');">
							<option value="empty">Select Location</option>
							<option value="DO">DO</option>
							<option value="IMC Mail Centre">IMC Mail Centre</option>
							<option value="RDC">RDC</option>
					</select></td>

				</tr>
				<tr>
					<td><label for="location">Location ID:</label></td>
					<td><select id="locationID" name="locationID">
							<option value="0">Location ID</option>
					</select></td>
				</tr>
				<tr>
					<td></td>
					<td><input type="submit" value="Perform Scan" /></td>
				</tr>
			</table>
			<div id="mperess1d_text" align="center">**Currently Dev in
				progress for 1st class/2nd Class product scans.</div>
		</form>
	</div>

	<div id="2D" class="tabcontent">
		<form name="MyServletMperess2D" action="MyServletMperess2D"
			method="post">

			<table id="1D-table" align="center">
				<tr>
					<td><label for="barcode" class="ubarcode" data-icon="u">
							Barcode:</label></td>
					<td><input id="barcode" name="barcode" required="required"
						type="text" placeholder="TK200004405GB" /></td>
				</tr>
				<tr>
					<td><label for="eventid" class="ueventid" data-icon="p">
							EventID:</label></td>
					<td><input id="eventId" name="eventId" required="required"
						type="text" placeholder="eg. EVDAC" /></td>
				</tr>
				<tr>
					<td><label for="ldate" class="udate" data-icon="p">
							Date:</label></td>
					<td><input type="text" onload="getDate()" id="date2d"
						name="date2d"></td>
					<td><input id="date2dbutton" type="button" value="Update Time"
						onclick="getDate('date2d')" /></td>
				</tr>
				<tr>
					<td><label for="productid" class="uproductid" data-icon="p">
							ProductID:</label></td>
					<td><input id="productID" name="productID" required="required"
						type="text" placeholder="eg. TPN01" /></td>
				</tr>
				<tr>
					<td><label for="uid" class="uuid" data-icon="p"> UID:</label></td>
					<td><input id="UID" name="UID" required="required" type="text"
						placeholder="eg. 0B0368482000190000002" /></td>
				</tr>
				<tr>
					<td><label for="destinationpostcode"
						class="destinationpostcode" data-icon="p"> Destination
							PostCode:</label></td>
					<td><input id="destinationId" name="destinationId"
						required="required" type="text" placeholder="eg. CM1 2DW" /></td>
				</tr>
				<tr>
					<td><label for="selectLocation">Select Location:</label></td>
					<td><select id="location2Dselect"
						onchange="countryChange(this,'location2D');">
							<option value="empty">Select Location</option>
							<option value="DO">DO</option>
							<option value="IMC Mail Centre">IMC Mail Centre</option>
							<option value="RDC">RDC</option>
					</select></td>

				</tr>
				<tr>
					<td><label for="location">Location ID:</label></td>
					<td><select id="location2D" name="locationID">
							<option value="0">Location ID</option>
					</select></td>
				</tr>
				<tr>
					<td></td>
					<td><input type="submit" value="Perform Scan" /></td>
				</tr>
			</table>

		</form>
	</div>

	<div id="Json" class="tabcontent">
		<form action="MyServletMperessJson" method="post">

			<table id="1D-table" align="center">
				<tr>
					<td><label for="barcode" class="ubarcode" data-icon="u">
							Barcode:</label></td>
					<td><input id="barcode" name="barcode" required="required"
						type="text" placeholder="TK200004405GB" /></td>
				</tr>
				<tr>
					<td><label for="eventid" class="ueventid" data-icon="p">
							EventID:</label></td>
					<td><input id="eventId" name="eventId" required="required"
						type="text" placeholder="eg. EVDAC" /></td>
				</tr>
				<tr>
					<td><label for="ldate" class="udate" data-icon="p">
							Date:</label></td>
					<td><input type="text" onload="getDate()" id="datejson"
						name="datejson"></td>
					<td><input id="dateJsonbutton" type="button"
						value="Update Time" onclick="getDate('datejson')" /></td>
				</tr>
				<tr>
					<td><label for="FLocationid" class="uFlocationid"
						data-icon="p"> Functional Location ID:</label></td>
					<td><input id="FLocationID" name="FLocationID"
						required="required" type="text" placeholder="eg. 3039" /></td>
				</tr>
				<tr>
					<td><label for="taskid" class="utaskid" data-icon="p">
							Task ID:</label></td>
					<td><input id="TaskId" name="TaskId" required="required"
						type="text" placeholder="eg. task id" /></td>
					<td><input id="taskidbutton" type="button" value="Get Task"
						onclick="getTask()" /></td>
				</tr>
				<tr>
					<td><label for="selectLocation">Select Location:</label></td>
					<td><select id="locationjsonselect"
						onchange="countryChange(this,'locationjson');">
							<option value="empty">Select Location</option>
							<option value="DO">DO</option>
							<option value="IMC Mail Centre">IMC Mail Centre</option>
							<option value="RDC">RDC</option>
					</select></td>

				</tr>
				<tr>
					<td><label for="location">Location ID:</label></td>
					<td><select id="locationjson" name="locationjson"
						contenteditable="true">
							<option value="0" contenteditable="true">Location ID</option>
					</select></td>
				</tr>
				<tr>
					<td></td>
					<td><input type="submit" value="Perform Scan" /></td>
				</tr>
			</table>

		</form>
	</div>
	<div id="ccJson" class="tabcontent">
		<form action="MyServletMperessCCJson" method="post">

			<table id="1D-table" align="center">
				<tr>
					<td><label for="orderid" class="uorderid" data-icon="u">
							OrderID:</label></td>
					<td><input id="orderId" name="orderId" required="required"
						type="text" placeholder="CC-W307-000001240" /></td>
				</tr>
				<tr>
					<td><label for="ordereventid" class="uordereventid"
						data-icon="p"> OrderEvent:</label></td>
					<td><input id="ordereventId" name="ordereventId"
						required="required" type="text" placeholder="eg. CFSCI" /></td>
				</tr>
				<tr>
					<td><label for="ldate" class="udate" data-icon="p">
							Date:</label></td>
					<td><input type="text" onload="getDate()" id="ccdatejson"
						name="ccdatejson"></td>
					<td><input id="ccdateJsonbutton" type="button"
						value="Update Time" onclick="getDate('ccdatejson')" /></td>
				</tr>
				<tr>
					<td><label for="FLocationid" class="uFlocationid"
						data-icon="p"> Functional Location ID:</label></td>
					<td><input id="ccFLocationID" name="ccFLocationID"
						required="required" type="text" placeholder="eg. 3039" /></td>
				</tr>
				<tr>
					<td><label for="taskid" class="utaskid" data-icon="p">
							Task ID:</label></td>
					<td><input id="ccTaskId" name="ccTaskId" required="required"
						type="text" placeholder="eg. task id" /></td>
					<!-- <td><input id="taskidbutton" type="button" value="Get Task"
						onclick="getTask()" /></td> -->
				</tr>
				<tr>
					<td><label for="selectLocation">Select Location:</label></td>
					<td><select id="cclocationjsonselect"
						onchange="countryChange(this,'cclocationjson');">
							<option value="empty">Select Location</option>
							<option value="DO">DO</option>
							<option value="IMC Mail Centre">IMC Mail Centre</option>
							<option value="RDC">RDC</option>
					</select></td>

				</tr>
				<tr>
					<td><label for="location">Location ID:</label></td>
					<td><select id="cclocationjson" name="cclocationjson"
						contenteditable="true">
							<option value="0" contenteditable="true">Location ID</option>
					</select></td>
				</tr>
				<tr>
					<td><label for="item">How many Items to collect?</label></td>
					<td><select id="itemselect" name="itemselect"
						onchange="ItemSelect(this,'ccBarcodes');">
							<option value="0">Select Items</option>
							<option value="1">1 item</option>
							<option value="2">2 items</option>
							<option value="3">3 items</option>
							<option value="4">4 items</option>
							<option value="5">5 items</option>
					</select></td>
				</tr>
				<tr align="center">
					<td><label for="itemdetails" class="uitemdetails"
						data-icon="p">Barcode/Event details of item/s:</label></td>
					<td>
						<table id="ccBarcodes">
						</table>
					</td>

				</tr>

				<tr>
					<td></td>
					<td><input type="submit" value="Perform Scan" /></td>
				</tr>
			</table>

		</form>
	</div>
	<div id="Pol" class="tabcontent">
		<form name="MyServletMperessPOL" action="MyServletMperessPOL"
			method="post">
			<div id="polTitle" class="title" align="center">POLSE</div>
			<!-- 			<div id="polTitle" align="center">POL</div> -->
			<table id="Pol-table" align="center">
				<tr>
					<td><label for="barcode" class="ubarcode" data-icon="u">
							Barcode:</label></td>
					<td><input id="barcode" name="barcode" required="required"
						type="text" placeholder="eg. TK200004405GB" /></td>
				</tr>
				<tr>
					<td><label for="eventcode" class="ueventcode" data-icon="p">
							Event Code:</label></td>
					<td><input id="eventCode" name="eventCode" required="required"
						type="text" placeholder="eg. I510" /></td>
				</tr>
				<tr>
					<td><label for="ldate" class="udate" data-icon="p">
							Date:</label></td>
					<td><input type="text" onload="getPolDate('datePol')"
						name="datePol" id="datePol"></td>
					<td><input id="datePolbutton" type="button"
						value="Update Date" onclick="getPolDate('datePol')" /></td>
				</tr>
				<tr>
					<td><label for="ltime" class="utime" data-icon="p">
							Time:</label></td>
					<td><input type="text" onload="getPolTime('timePol')"
						name="timePol" id="timePol"></td>
					<td><input id="timePolbutton" type="button"
						value="Update Time" onclick="getPolTime('timePol')" /></td>
				</tr>
				<tr>
					<td><label for="FAD">FAD Code:</label></td>
					<td><input type="text" id="fad" name="fad" value="115005"
						placeholder="eg. 115005" required="required"></td>
				</tr>
				<tr>
					<td></td>
					<td><input type="submit" value="Perform Scan" /></td>
				</tr>
			</table>

		</form>
	</div>
	<div id="INTLPA" class="tabcontent">
		<form name="MyServletINTLPAform" action="MyServletINTLPA"
			method="post" target="_blank">

			<table align="center">
				<tr>
					<td><label for="selectServiceID">Select Service:</label></td>
					<td><select id="serviceID" name="serviceID">
							<option value="empty">Select Service</option>
							<option value="MTB01">MTB01 - INTL BUS PARCELS TRACKED
								SIGNED ZONE SRT</option>
							<option value="OTC01">OTC01 - International Tracked &
								Signed On Account</option>
							<option value="OTD09">OTD09 - International Tracked &
								Signed On Account Extra Comp</option>
							<option value="MP701">MP701 - International Business
								Parcels Tracked Country Priced</option>
							<option value="MP101">MP101 - International Business
								Parcels Tracked Zone Sort</option>
							<option value="OTA09">OTA09 - International Tracked On
								Account</option>
							<option value="MTM01">MTM01 - International Business
								Mail Signed Zone Sort</option>
							<option value="MTN01">MTN01 - International Business
								Mail Signed Extra Compensation Zone Sort</option>
							<option value="MP501">MP501 - International Business
								Parcels Signed Zone Sort</option>
							<option value="OLA01">OLA01 - International Standard On
								Account</option>
							<option value="OLA09">OLA09 - International Standard On
								Account</option>
							<option value="MB101">MB101 - International Business
								Parcels Print Direct Priority</option>
					</select></td>
				</tr>
			</table>

			<table id="INTLPATable" align="center">

				<tr>
					<td><label for="barcode" class="ubarcode" data-icon="p">
							1D Barcode:</label></td>
					<td><input id="barcode" name="barcode" type="text"
						placeholder="eg. VR123456785GB" /></td>

					<td><label for="uniqueID" class="uuniqueID" data-icon="p">
							UID:</label></td>
					<td><input id="uniqueID" name="uniqueID" type="text"
						placeholder="eg. 0B01272290000000100FF" /></td>
				</tr>

				<tr>
					<td><label for="accNo" class="uaccNo" data-icon="p">
							Account Number:</label></td>
					<td><input id="accNo" name="accNo" type="text"
						placeholder="eg. 0127229000" /></td>

					<td><label for="channelId" class="uchannelId" data-icon="p">
							Channel ID:</label></td>
					<td><input id="channelID" name="channelID" type="text"
						placeholder="eg. 0B" /></td>
				</tr>

				<tr>
					<td><label for="postingLocation" class="upostingLocation"
						data-icon="p"> Posting Location:</label></td>
					<td><input id="postingLocation" name="postingLocation"
						type="text" placeholder="eg. 9000240524" /></td>
					<td><label for="senderCountry" class="usenderCountry"
						data-icon="p"> Sender's Country:</label></td>
					<td><input id="senderCountry" name="senderCountry" type="text"
						placeholder="eg. England" /></td>
				</tr>

				<tr>
					<td><label for="deliveryAddress1" class="udeliveryAddress1"
						data-icon="p"> Address Line 1:</label></td>
					<td><input id="deliveryAddress1" name="deliveryAddress1"
						type="text" placeholder="eg. delivery address line 1" /></td>
					<td><label for="deliveryPostTown" class="udeliveryPosttown"
						data-icon="p"> Delivery Post Town:</label></td>
					<td><input id="deliveryPostTown" name="deliveryPostTown"
						type="text" placeholder="eg. London" /></td>
				</tr>

				<tr>
					<td><label for="deliveryPostCode" class="udeliveryPostCode"
						data-icon="p"> Delivery PostCode:</label></td>
					<td><input id="deliveryPostCode" name="deliveryPostCode"
						type="text" placeholder="eg. BT744AE1A" /></td>
					<td><label for="deliveryCountry" class="udeliveryCountry"
						data-icon="p"> Delivery Country:</label></td>
					<td><input id="deliveryCountry" name="deliveryCountry"
						type="text" placeholder="eg. England" /></td>
				</tr>

				<tr>
					<td><label for="format" class="uformat" data-icon="p">
							Format:</label></td>
					<td><input id="format" name="format" type="text"
						placeholder="eg. 6" /></td>
					<td><label for="gazetteerCode" class="ugazetteerCode"
						data-icon="p"> Gazetteer Code:</label></td>
					<td><input id="gazetteerCode" name="gazetteerCode" type="text"
						placeholder="eg. 6" /></td>
				</tr>

				<tr>
					<td><label for="supplementCode" class="usupplementCode"
						data-icon="p"> Supplement Code:</label></td>
					<td><input id="supplementCode" name="supplementCode"
						type="text" placeholder="eg. 97" /></td>
					<td><label for="supplementData" class="usupplementData"
						data-icon="p"> Supplement Data:</label></td>
					<td><input id="supplementData" name="supplementData"
						type="text" placeholder="eg. example@email.com" /></td>
				</tr>

				<tr>
					<td><label for="ddpvalue" class="uddpvalue" data-icon="p">
							DDP Value of Tax and Duty:</label></td>
					<td><input id="ddpValue" name="ddpValue" type="text"
						placeholder="" /></td>
					<td><label for="sendersEORI" class="usendersEORI"
						data-icon="p"> Senders EORI Number:</label></td>
					<td><input id="sendersEORI" name="sendersEORI" type="text"
						placeholder="" /></td>
				</tr>

				<tr>
					<td><label for="category" class="ucategory" data-icon="p">
							Category/Nature of Item:</label></td>
					<td><input id="category" name="category" type="text"
						placeholder="eg. O" /></td>
					<td><label for="nature" class="unature" data-icon="p">
							Nature of Item:</label></td>
					<td><input id="nature" name="nature" type="text"
						placeholder="eg. 2 BOXES OF SPORTS SHOES" /></td>
				</tr>

				<tr>
					<td><label for="taxCode" class="utaxCode" data-icon="p">
							Importer Tax Code:</label></td>
					<td><input id="taxCode" name="taxCode" type="text"
						placeholder="" /></td>
					<td><label for="termsOfDelivery" class="utermsOfDelivery"
						data-icon="p"> Terms Of Delivery:</label></td>
					<td><input id="termsOfDelivery" name="termsOfDelivery"
						type="text" placeholder="eg. DDP" /></td>
				</tr>

				<tr>
					<td><label for="recipientName" class="urecipientName"
						data-icon="p"> Localised Recipient Name:</label></td>
					<td><input id="recipientName" name="recipientName" type="text"
						placeholder="eg. John Smith" /></td>
					<td><label for="businessName" class="ubusinessName"
						data-icon="p"> Localised Business Name:</label></td>
					<td><input id="businessName" name="businessName" type="text"
						placeholder="eg. Business Ltd" /></td>
				</tr>

				<tr>
					<td><label for="localPostTown" class="ulocalPostTown"
						data-icon="p"> Localised Post Town:</label></td>
					<td><input id="localPostTown" name="localPostTown" type="text"
						placeholder="eg. vatican city" /></td>
					<td><label for="quantityofUnits" class="uquantityofUnits"
						data-icon="p"> Quantity Of Units:</label></td>
					<td><input id="quantityOfUnits" name="quantityOfUnits"
						type="text" placeholder="eg. 2" /></td>
				</tr>

				<tr>
					<td><label for="unitDescription" class="uunitDescription"
						data-icon="p"> Unit Description:</label></td>
					<td><input id="unitDescription" name="unitDescription"
						type="text" placeholder="eg. 2 x sport shoes" /></td>
					<td><label for="unitCountry" class="uunitCountry"
						data-icon="p"> Unit's Country of Origin:</label></td>
					<td><input id="unitCountry" name="unitCountry" type="text"
						placeholder="eg. GB" /></td>
				</tr>

				<tr>
					<td><label for="unitValue" class="uunitValue" data-icon="p">
							Unit's Value:</label></td>
					<td><input id="unitValue" name="unitValue" type="text"
						placeholder="eg. 776" /></td>
					<td><label for="unitWeight" class="uunitWeight" data-icon="p">
							Unit's Weight (kg):</label></td>
					<td><input id="unitWeight" name="unitWeight" type="text"
						placeholder="eg. 0.880" /></td>
				</tr>

				<tr>
					<td><label for="tariff" class="utariff" data-icon="p">Tariff/Harmonisation
							Code:</label></td>
					<td><input id="tariff" name="tariff" type="text"
						placeholder="eg. 640520" /></td>
					<td><label for="extDescription" class="uextDescription"
						data-icon="p">Extended Unit Description:</label></td>
					<td><input id="extDescription" name="extDescription"
						type="text" placeholder="eg. soles made from cork" /></td>
				</tr>
<tr>
					<td><label for="sendersVAT" class="usendersVAT" data-icon="p">Sender's
							VAT number:</label></td>
					<td><input id="sendersVAT" name="sendersVAT" type="text"
						placeholder="" /></td>
				</tr>
				<tr>
					<td><label id="spacerlabel"> </label></td>
					<td><input id="submitButton" type="submit"
						value="Generate + Submit Pre-advice" /></td>
				</tr>
				<tr>
					<td><input onchange="selectionChanged(this)" type="checkbox" id="Download" name="Download" value="DownloadTrue" /></td>
					<td><label for="Download">Download Pre-advice file</label></td>
					
				</tr>
			</table>
			<div id="preadvice_text" align="center">* If you check the box to download the Pre-advice file, it will not be processed to BIG.</div>
			<div id="preadvice_text" align="center">**Pre-advice processing
				will take maximum 10 minutes to process. Report immediately if PA
				failed.</div>
		</form>
	</div>
	<script type="text/javascript">
		function selectionChanged(element){
						if(element.checked){
							submitButton.value = "Generate + Download Pre-advice";
						}
						else{
							submitButton.value = "Generate + Submit Pre-advice"
						}
		}
	
	
		function validate() {
			if (document.getElementById("LocationID").value.length != 6) {
				alert("Invalid length Location ID, must be 6 characters");
				return false;
			}
			return true;
		}
		var locationLists = new Array(4)
		locationLists["empty"] = [ "Select a Location" ];
		locationLists["DO"] = [ "Northolt (001355)", "Hayes (001354)",
				"Sudbury (000274)", "Thurso (000654)", "Winchester (001192)",
				"Willesden (000914)", "Wishaw (000808)", "Thornbury (000135)",
				"Atherstone (000300)", "OMAGH (000194)", "Uxbridge (001356)",
				"Antrim (000177)", "Newry (000169)", "Coleraine (000182)",
				"Belfast (002541)" ];
		locationLists["IMC Mail Centre"] = [ "GreenFord(002626)",
				"Chelmsford (002609)", "Inverness (002629)",
				"Southampton (002653)", "Glasgow (002624)", "Bristol (002604)",
				"South Midlands (004554)",
				"Northern Ireland Mail Centre(002599)" ];
		locationLists["RDC"] = [ "Princess Royal RDC (002673)",
				"Scottish RDC (002677)", "South West RDC (002675)",
				"Atherstone Xmas RDC (0018769)", "Atherstone RDC (0018815)" ];

		/* locationChange() is called from the onchange event of a select element. 
		 * param selectObj - the select object which fired the on change event. 
		 */
		function countryChange(selectObj, locationID) {
			// get the index of the selected option 
			var idx = selectObj.selectedIndex;
			// get the value of the selected option 
			var which = selectObj.options[idx].value;
			// use the selected option value to retrieve the list of items from the locationLists array 
			cList = locationLists[which];
			// get the country select element via its known id 
			var cSelect = document.getElementById(locationID);
			// remove the current options from the country select 
			var len = cSelect.options.length;
			while (cSelect.options.length > 0) {
				cSelect.remove(0);
			}
			var newOption;
			// create new options 
			for (var i = 0; i < cList.length; i++) {
				newOption = document.createElement("option");
				newOption.value = cList[i]; // assumes option string and value are the same 
				newOption.text = cList[i];
				// add the new option 
				try {
					cSelect.add(newOption); // this will fail in DOM browsers but is needed for IE 
				} catch (e) {
					cSelect.appendChild(newOption);
				}
			}
		}
		function getDate(selectObjdate) {
			var today = new Date();
			document.getElementById(selectObjdate).value = today.getFullYear()
					+ '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-'
					+ ('0' + today.getDate()).slice(-2) + 'T'
					+ today.getHours() + ':' + today.getMinutes() + ':'
					+ today.getSeconds() + 'Z';
		}
		function getPolDate(selectObjdate) {
			var today = new Date();
			document.getElementById(selectObjdate).value = today.getFullYear()
					+ ('0' + (today.getMonth() + 1)).slice(-2)
					+ ('0' + today.getDate()).slice(-2);
		}
		function getPolTime(selectObjtime) {
			var today = new Date();
			document.getElementById(selectObjtime).value = ''
					+ +("0" + today.getHours()).slice(-2)
					+ ("0" + today.getMinutes()).slice(-2)
					+ ("0" + today.getSeconds()).slice(-2);
		}
		function openPage(pageName, elmnt, color) {
			var i, tabcontent, tablinks;
			tabcontent = document.getElementsByClassName("tabcontent");
			for (i = 0; i < tabcontent.length; i++) {
				tabcontent[i].style.display = "none";
			}
			tablinks = document.getElementsByClassName("tablink");
			for (i = 0; i < tablinks.length; i++) {
				tablinks[i].style.backgroundColor = "";
			}
			document.getElementById(pageName).style.display = "block";
			elmnt.style.backgroundColor = color;
		}
		// Get the element with id="defaultOpen" and click on it
		document.getElementById("defaultOpen").click();

		function getTask() {
			//alert("MPERESS is waiting for Firewall to be open to get task details!! Till then please feed the task ID from http://tmloc-sita.rmgn.royalmailgroup.net/locations/<location>/tasks/v1?type=DC&actionMode=RFD");

			//response = given().headers("X-RMG-Client-Id","123").when().get("http://tmloc-sita.rmgn.royalmailgroup.net/locations/"+DOID+"/tasks/v1?type=CC&actionMode=CC&skipEntityData=false&startDate="+DateForOrder+"&endDate="+DateForOrder);
			var xhttp = new XMLHttpRequest();
			xhttp.onreadystatechange = function() {
				if (this.readyState == 4 && this.status == 200) {
					// Typical action to be performed when the document is ready:
					var response = xhttp.responseText;
					console.log("ok" + response);
				}
			};
			xhttp
					.open(
							"GET",
							"http://tmloc-sita.rmgn.royalmailgroup.net/locations/6445/tasks/v1?type=CC&actionMode=CC&skipEntityData=false",
							true);
			xhttp.setRequestHeader("X-RMG-Client-Id", "123");
			xhttp.send();
			document.getElementById("TaskId").value
		}

		/*Function For Consumer Collection Project
		 * param selectObj - the select object which fired the on change event. 
		 */
		function ItemSelect(selectObj, locationID) {
			var idx = selectObj.selectedIndex;
			var which = selectObj.options[idx].value;

			var node = document.getElementById(locationID);
			while (node.hasChildNodes()) {
				node.removeChild(node.lastChild);
			}
			for (var i = 0; i < which; i++) {
				var newtr = document.createElement("tr");
				var elementtr = document.createElement("td");
				var element = document.createElement("input");
				var elementtrvalue = document.createElement("td");
				var eventvalue = document.createElement("input");

				//Assign different attributes to the element.
				element.setAttribute("type", "text");
				element.setAttribute("value", "");
				element.setAttribute("name", "Barcode" + (i + 1));
				element.setAttribute("id", "Barcode" + (i + 1));
				element.setAttribute("placeholder", "TP000200378GB");
				element.setAttribute("required", "required");

				//Assign different attributes to the element.
				eventvalue.setAttribute("type", "text");
				eventvalue.setAttribute("name", "Event" + (i + 1));
				eventvalue.setAttribute("id", "Event" + (i + 1));
				eventvalue.setAttribute("placeholder", "EVCAD");
				eventvalue.setAttribute("required", "required");

				// 'foobar' is the div id, where new fields are to be added
				var foo = document.getElementById(locationID);
				//Append the element in page (in span).

				foo.appendChild(newtr);
				foo.appendChild(elementtr);
				foo.appendChild(element);
				foo.appendChild(elementtrvalue);
				foo.appendChild(eventvalue);
			}
		}
	</script>
</body>
