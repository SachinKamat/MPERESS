package com.royalmail;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;


import org.apache.poi.ss.usermodel.*;


import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Image;
import com.lowagie.text.pdf.Barcode128;
import com.lowagie.text.pdf.BarcodeDatamatrix;
import com.lowagie.text.pdf.BarcodeEAN;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfWriter;

import io.restassured.RestAssured;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;

public class Helper extends PageInstance {

	public static void runBatch(String Command) throws IOException, InterruptedException {
		Process p = Runtime.getRuntime().exec("cmd /c start /B " + Command);
		p.waitFor();
	}

	public static void runBatch(Path Command) throws IOException, InterruptedException {
		Process p = Runtime.getRuntime().exec("cmd /c start /B " + Command);
		p.waitFor();
	}

	public static void createBat(Path Path, List<String> Command) throws InterruptedException {
		try {

			Files.write(Path.toAbsolutePath(), Command);
			System.out.println("path " + Path.toAbsolutePath());
			runBatch(Path.toAbsolutePath());
		} catch (IOException ignored) {
		}
	}

	public void getTasks() {

	}

	public void processCSV() throws InterruptedException {
		createBat(BAT_Preadvice, Bat_Preadvice_list);

	}

	public Boolean createCSV(HashMap<String, String> CSVMAP) throws FileNotFoundException {
		DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
		DateTimeFormatter DATE = DateTimeFormatter.ofPattern("yyyy-MM-dd");
		DateTimeFormatter PreAdvice_Date = DateTimeFormatter.ofPattern("HH:mm:ss.SSS");
		File csvOutputFile = new File("src/Scripts/COSS"+CSVMAP.get("WIRENUMBER")+"_PreAdvice3_"
				+ ZonedDateTime.now().format(PreAdvice_Date).replaceAll("\\.", "").replaceAll(":", "") + ".csv");
		List<String[]> dataLines = new ArrayList<>();
		System.out.println(csvOutputFile + " " + csvOutputFile.getPath());
		dataLines.add(new String[] { "\"00\"", "\"03\"", "\"" + CSVMAP.get("FILETYPE") + "\"",
				"\"" + CSVMAP.get("ACCOUNT") + "\"", "\"MULTIPLE\"", "\"451\"", "\"\"", "\"\"", "\"\"", "\"LIVE\"",
				"\"" + ZonedDateTime.now().format(FORMATTER) + "+00:00\"", "\"" + CSVMAP.get("WIRENUMBER") + "\"",
				"\"\"", "\"" + CSVMAP.get("CHANNELID") + "\"" });
		dataLines.add(new String[] { "\"01\"", "\"03\"", "\"HEARTBEAT\"", "\"34 PARK ROAD\"", "\"\"", "\"\"", "\"\"",
				"\"\"", "\"CHELMSFORD\"", "\"CM1 2DW\"", "\"PHASE 3 F POSTER\"", "\"123456789012\"", "\"\"", "\"\"",
				"\"\"", "\"royalmail.support@neopost.co.uk\"", "\"" + CSVMAP.get("LOCATIONID") + "\"",
				"\"" + CSVMAP.get("POSTINGLOCATION") + "\"" });
		dataLines.add(new String[] { "\"02\"", "\"03\"", "\"\"", "\"" + CSVMAP.get("PRODUCT") + "\"", "\"\"", "\"\"",
				"\"\"", "\"" + CSVMAP.get("SENDERREFERENCE1") + "\"", "\"\"", "\"\"", "\"100\"", "\"1\"", "\"\"",
				"\"HEARTBEAT\"", "\"9\"", "\""+CSVMAP.get("SENDERADDRESS1")+"\"", "\"\"", "\""+CSVMAP.get("SENDERADDRESS2")+"\"", "\""+CSVMAP.get("SENDERPOSTCODE")+"\"",
				"\""+CSVMAP.get("SENDERNAME")+"\"", "\"5\"", "\"\"", "\"\"", "\"\"", "\"GB\"", "\"\"",
				"\"" + CSVMAP.get("UID") + "\"", "\"100\"", "\"1\"", "\"\"", "\"9\"", "\"\"", "\"3\"", "\"\"", "\"\"",
				"\"\"", "\"\"", "\"" + CSVMAP.get("BARCODE") + "\"", "\"0\"",
				"\"" + ZonedDateTime.now().format(DATE) + "\"", "\"" + ZonedDateTime.now().format(DATE) + "\"", "\"\"",
				"\"\"", "\"GBR\"", "\"" + CSVMAP.get("CONTRACTNUMBER") + "\"",
				"\"" + CSVMAP.get("SENDERREFERENCE") + "\"", "\"\"", "\"\"", "\"\"" });
		dataLines.add(new String[] { "\"03\"", "\"03\"", "\"" + CSVMAP.get("UID") + "\"", "\"98\"",
				"\"" + CSVMAP.get("MOBILE") + "\"" });
		dataLines.add(new String[] { "\"03\"", "\"03\"", "\"" + CSVMAP.get("UID") + "\"", "\"97\"",
				"\"" + CSVMAP.get("EMAIL") + "\"" });
		dataLines.add(new String[] { "\"09\"", "\"03\"", "\"06\"" });
		try (PrintWriter pw = new PrintWriter(csvOutputFile)) {
			dataLines.stream().map(Helper::convertToCSV).forEach(pw::println);
		}
		return true;
	}
	
	public Boolean createInternationalCSV(HashMap<String, String> CSVMAP) throws FileNotFoundException {
		
		DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
		DateTimeFormatter DATE = DateTimeFormatter.ofPattern("yyyy-MM-dd");
		DateTimeFormatter PreAdvice_Date = DateTimeFormatter.ofPattern("HH:mm:ss.SSS");
		
		File csvOutputFile = new File("src/Scripts/COSS"+CSVMAP.get("WIRENUMBER")+"_PreAdvice3_"
				+ ZonedDateTime.now().format(PreAdvice_Date).replaceAll("\\.", "").replaceAll(":", "") + ".csv");
		
		List<String[]> dataLines = new ArrayList<>();
		
		System.out.println(csvOutputFile + " " + csvOutputFile.getPath());
		
		//00 Header Record
		dataLines.add(new String[] { "\"00\"", "\"03\"", "\"" + CSVMAP.get("FILETYPE") + "\"",
				"\"" + CSVMAP.get("ACCOUNT") + "\"", "\"MULTIPLE\"", "\"451\"", "\"\"", "\"\"", "\"\"", "\"LIVE\"",
				"\"" + ZonedDateTime.now().format(FORMATTER) + "+00:00\"", "\"" + CSVMAP.get("WIRENUMBER") + "\"",
				"\"\"", "\"" + CSVMAP.get("CHANNELID") + "\"" });
		
		//01 Sender Record
		dataLines.add(new String[] { "\"01\"", "\"03\"", "\"Marhcetkrkhlk Lpc\"", "\"10 Ktirjor Hkef\"", "\"Arkgrpkkcrkg Vkt\"", "\"Mokbercgt Vthhr\"", "\"Atkp\"",
				 "\"" + CSVMAP.get("SENDERSCOUNTRY") + "\"", "\"Mokbercgt Vthhr\"", "\"TN2 3GP\"", "\"Marhcetkrkhlk Lpc\"", "\"75751 335 557\"", "\"\"", "\"\"",
				"\"\"", "\"rkrl@iarhcetkrkhlk.ilj\"", "\"" + CSVMAP.get("LOCATIONID") + "\"",
				"\"" + CSVMAP.get("POSTINGLOCATION") + "\"" });
		
		//02 Detail Record
		dataLines.add(new String[] { "\"02\"", "\"03\"", "\"\"", "\"" + CSVMAP.get("SERVICEID") + "\"", "\"\"", "\"\"",
				"\"\"", "\"" + CSVMAP.get("SENDERREFERENCE1") + "\"", "\"\"", "\"\"", "\"100\"", "\"1\"", "\"\"",
				"\"receipentname\"", "\""+CSVMAP.get("DELIVERYADDRESS1")+"\"", "\""+CSVMAP.get("DELIVERYADDRESS2")+"\"","\"\"","\""+CSVMAP.get("DELIVERYPOSTTOWN")+"\"",
				"\""+CSVMAP.get("DELIVERYPOSTCODE")+"\"",
				"\"receipentname\"", "\"5\"", "\"\"", "\"\"", "\"\"","\""+CSVMAP.get("DELIVERYCOUNTRY")+"\"", "\"\"",
				"\"" + CSVMAP.get("UID") + "\"", "\"0001500\"", "\"1\"", "\"\"", "\""+CSVMAP.get("FORMAT")+"\"", "\"\"", "\"3\"", "\"\"", "\"\"",
				"\"\"", "\"\"", "\"" + CSVMAP.get("BARCODE") + "\"", "\"6\"",
				"\"" + ZonedDateTime.now().format(DATE) + "\"", "\"" + ZonedDateTime.now().format(DATE) + "\"", "\"\"",
				"\"\"", "\""+CSVMAP.get("GAZETTEERCODE")+"\"", "\"\"","\"\"", "\"\"", "\"\"", "\"\"" });
		
		//03 Detail Supplement Record
		dataLines.add(new String[] { "\"03\"", "\"03\"", "\"" + CSVMAP.get("UID") + "\"", "\"" + CSVMAP.get("SUPPLEMENTCODE") + "\"",
				"\"" + CSVMAP.get("SUPPLEMENTDATA") + "\"" });
		
		//06 GENERIC INTERNATIONAL ITEM INFORMATION RECORD
		dataLines.add(new String[] {"\"06\"","\"03\"","\"\"","\""+CSVMAP.get("UID")+"\"","\"\"","\"1.500\"","\"\"","\"\"",
				"\"GBP\"","\"10200\"","\"\"","\"\"","\"\"","\"10200\"","\"" + CSVMAP.get("DDP") + "\"","\" \"","\"01892 779 110\"",
				"\"\"","\"284 9995 22\"","\"\"","\"\"","\"\"","\"\"","\"\"","\"\"","\"\"","\"\"","\"\"",
				"\"\"","\"6047270660\"","\"" + CSVMAP.get("SENDERSEORI") + "\"","\"\"","\"\"","\"\"","\"" + CSVMAP.get("CATEGORY") + "\"","\"" + CSVMAP.get("NATUREOFITEM") + "\"",
				"\"" + CSVMAP.get("IMPORTERTAXCODE") + "\"",
				"\"" + CSVMAP.get("TERMSOFDELIVERY") + "\"","\"\"","\"\"","\"\"","\"\"","\"\"","\"\"","\"" + CSVMAP.get("LOCALISEDRECIPIENTNAME") + "\"",
				"\"" + CSVMAP.get("LOCALISEDBUSINESSNAME") + "\"",
				"\"\"","\"\"","\"\"","\"" + CSVMAP.get("LOCALISEDPOSTTOWN") + "\"","\"\""});
		
		//07 ITEM UNIT RECORD
		dataLines.add(new String[] {"\"07\"","\"03\"","\"\"","\""+CSVMAP.get("UID")+"\"","\""+CSVMAP.get("QUANTITY")+"\"","\""+CSVMAP.get("DESCRIPTION")+"\"",
				"\""+CSVMAP.get("COUNTRYOFORIGIN")+"\"","\""+CSVMAP.get("VALUE")+"\"","\""+CSVMAP.get("WEIGHT")+"\"","\""+CSVMAP.get("TARIFF")+"\"","\"\"","\"\"",
				"\""+CSVMAP.get("EXTENDEDDESCRIPTION")+"\"",
				"\"\"","\"GBP\""});
		
		//09 Trailer Record
		//The last field here should equal the number of records in the file including the trailer.
		dataLines.add(new String[] { "\"09\"", "\"03\"", "\"07\"" });
		try (PrintWriter pw = new PrintWriter(csvOutputFile)) {
			dataLines.stream().map(Helper::convertToCSV).forEach(pw::println);
		}
		return true;
	}

	public static String convertToCSV(String[] data) {
		return Stream.of(data).map(Helper::escapeSpecialCharacters).collect(Collectors.joining(","));
	}

	private static String escapeSpecialCharacters(String data) {
		return data.replaceAll("\\R", " ");
	}

	public void setMap(String product) {
		if(product.contains("TPN01")) {
			product="TPN01";
		}
		if(product.contains("TPS01")) {
			product="TPS01";
		}
		switch (product) {
		case "TPN01":
			PageInstance.MapForProductT24.put("ACCOUNT", "0368482000");
			PageInstance.MapForProductT24.put("SENDERNAME", "");
			PageInstance.MapForProductT24.put("WIRENUMBER", "W7O5");
			PageInstance.MapForProductT24.put("CHANNELID", "32");
			PageInstance.MapForProductT24.put("PRODUCT", product);
			PageInstance.MapForProductT24.put("MOBILE", "07448017658");
			PageInstance.MapForProductT24.put("EMAIL", "sapna.negi@royalmail.com");
			PageInstance.MapForProductT24.put("SENDERREFERENCE1", "HEARTBEAT");
			PageInstance.MapForProductT24.put("SENDERREFERENCE", "Heartbeat");
			PageInstance.MapForProductT24.put("BARCODE", "TEST");
			PageInstance.MapForProductT24.put("UID", "TEST2");
			PageInstance.MapForProductT24.put("POSTINGLOCATION", "9000240524");
			PageInstance.MapForProductT24.put("LOCATIONID", "002599");
			PageInstance.MapForProductT24.put("FILETYPE", "RMBS");
			PageInstance.MapForProductT24.put("CONTRACTNUMBER", "461765TN");
			PageInstance.MapForProductT24.put("SENDERADDRESS1", "SPRINGFIELD PARK ROAD");
			PageInstance.MapForProductT24.put("SENDERADDRESS2", "Enniskillen");
			PageInstance.MapForProductT24.put("SENDERPOSTCODE", "BT744AE1A");

			break;
		case "TPS01":
			PageInstance.MapForProductT48.put("ACCOUNT", "0368482000");
			PageInstance.MapForProductT48.put("SENDERNAME", "");
			PageInstance.MapForProductT48.put("WIRENUMBER", "W7O5");
			PageInstance.MapForProductT48.put("CHANNELID", "32");
			PageInstance.MapForProductT48.put("PRODUCT", product);
			PageInstance.MapForProductT48.put("MOBILE", "07448017658");
			PageInstance.MapForProductT48.put("EMAIL", "sapna.negi@royalmail.com");
			PageInstance.MapForProductT48.put("SENDERREFERENCE1", "HEARTBEAT");
			PageInstance.MapForProductT48.put("SENDERREFERENCE", "Heartbeat");
			PageInstance.MapForProductT48.put("BARCODE", "TEST");
			PageInstance.MapForProductT48.put("UID", "TEST2");
			PageInstance.MapForProductT48.put("POSTINGLOCATION", "9000240524");
			PageInstance.MapForProductT48.put("LOCATIONID", "002599");
			PageInstance.MapForProductT48.put("FILETYPE", "RMBS");
			PageInstance.MapForProductT48.put("CONTRACTNUMBER", "461765TS");
			PageInstance.MapForProductT48.put("SENDERADDRESS1", "SPRINGFIELD PARK ROAD");
			PageInstance.MapForProductT48.put("SENDERADDRESS2", "Enniskillen");
			PageInstance.MapForProductT48.put("SENDERPOSTCODE", "BT744AE1A");
		case "SD101":
		case "SD401":
			PageInstance.MapForProductSDG.put("ACCOUNT", "0368482000");
			PageInstance.MapForProductSDG.put("SENDERNAME", "");
			PageInstance.MapForProductSDG.put("WIRENUMBER", "01G4");
			PageInstance.MapForProductSDG.put("CHANNELID", "09");
			PageInstance.MapForProductSDG.put("PRODUCT", product);
			PageInstance.MapForProductSDG.put("MOBILE", "07448017658");
			PageInstance.MapForProductSDG.put("EMAIL", "sapna.negi@royalmail.com");
			PageInstance.MapForProductSDG.put("SENDERREFERENCE1", "HEARTBEAT");
			PageInstance.MapForProductSDG.put("SENDERREFERENCE", "Heartbeat");
			PageInstance.MapForProductSDG.put("BARCODE", "TEST");
			PageInstance.MapForProductSDG.put("UID", "TEST2");
			PageInstance.MapForProductSDG.put("POSTINGLOCATION", "9000240524");
			PageInstance.MapForProductSDG.put("LOCATIONID", "002599");
			PageInstance.MapForProductSDG.put("FILETYPE", "RMBS");
			PageInstance.MapForProductSDG.put("CONTRACTNUMBER", "461765TN");
			PageInstance.MapForProductSDG.put("SENDERADDRESS1", "SPRINGFIELD PARK ROAD");
			PageInstance.MapForProductSDG.put("SENDERADDRESS2", "Enniskillen");
			PageInstance.MapForProductSDG.put("SENDERPOSTCODE", "BT744AE1A");

			break;
		case "INTL":
			
			//00 Header Record
			PageInstance.MapForProductINTL.put("FILETYPE", "RMBS"); //Field 3
			PageInstance.MapForProductINTL.put("ACCOUNT", "0127229000");//Field 4
			PageInstance.MapForProductINTL.put("WIRENUMBER", "MWAA");//Field 12
			PageInstance.MapForProductINTL.put("CHANNELID", "0B");//Field 14
	
			//01 Senders Records
			PageInstance.MapForProductINTL.put("SENDERSCOUNTRY","GB");// Field 8
			PageInstance.MapForProductINTL.put("LOCATIONID", "016075");// Field 17
			PageInstance.MapForProductINTL.put("POSTINGLOCATION", "9000240524");// Field 18
			
			//02 Details Record
			PageInstance.MapForProductINTL.put("SERVICEID", "MTB01");// Field 4
			PageInstance.MapForProductINTL.put("SENDERREFERENCE1", "101749977"); //Field 8
			PageInstance.MapForProductINTL.put("DELIVERYADDRESS1", "south wales");// Field 15
			PageInstance.MapForProductINTL.put("DELIVERYADDRESS2", ""); //Field 16
			PageInstance.MapForProductINTL.put("DELIVERYPOSTTOWN", "Aarons pass");// Field 18
			PageInstance.MapForProductINTL.put("DELIVERYPOSTCODE", "2850");// Field 19
			PageInstance.MapForProductINTL.put("DELIVERYCOUNTRY", "AUS");// Field 25
			PageInstance.MapForProductINTL.put("UID", "TEST2");// Field 27
			PageInstance.MapForProductINTL.put("FORMAT", "08");// Field 31
			PageInstance.MapForProductINTL.put("BARCODE", "TEST");// Field 38
			PageInstance.MapForProductINTL.put("GAZETTEERCODE", "AUS");// Field 44
//			PageInstance.MapForProductINTL.put("CONTRACTNUMBER", "");// Field 45
//			PageInstance.MapForProductINTL.put("SENDERREFERENCE", "");// Field 46
			
			//03 Detail Supplement Records
			PageInstance.MapForProductINTL.put("SUPPLEMENTCODE", "97"); //Field 4
			PageInstance.MapForProductINTL.put("SUPPLEMENTDATA", "ireinephuah@hotmail.com");// Field 5
			
			//06 Generic International Item Information Record
			PageInstance.MapForProductINTL.put("DDP", ""); //Field 15
			PageInstance.MapForProductINTL.put("SENDERSEORI", ""); //Field 31
			PageInstance.MapForProductINTL.put("CATEGORY", "O"); //Field 35
			PageInstance.MapForProductINTL.put("NATUREOFITEM", "2 BOXES OF SPORTS SHOES"); //Field 36
			PageInstance.MapForProductINTL.put("IMPORTERTAXCODE", ""); //Field 37
			PageInstance.MapForProductINTL.put("TERMSOFDELIVERY", "DAP"); //Field 38
			PageInstance.MapForProductINTL.put("LOCALISEDRECIPIENTNAME", "Getrkt Haoka"); //Field 45
			PageInstance.MapForProductINTL.put("LOCALISEDBUSINESSNAME", ""); //Field 46
			PageInstance.MapForProductINTL.put("LOCALISEDPOSTTOWN", "vatican city"); //Field 50
			
			//07 Item Unit Record
			PageInstance.MapForProductINTL.put("QUANTITY", "2"); //Field 5
			PageInstance.MapForProductINTL.put("DESCRIPTION", "2 x sport shoesdescription"); //Field 6
			PageInstance.MapForProductINTL.put("COUNTRYOFORIGIN", "GB"); //Field 7
			PageInstance.MapForProductINTL.put("VALUE", "776"); //Field 8
			PageInstance.MapForProductINTL.put("WEIGHT", "0.880"); //Field 9
			PageInstance.MapForProductINTL.put("TARIFF", "640520"); //Field 10
			PageInstance.MapForProductINTL.put("EXTENDEDDESCRIPTION", "soles made from cork"); //Field 13
			
			break;
		default:
			break;
		}

	}

	public Boolean ValidateBarcode(Integer SheetNumber) throws IOException {
		try {
			BARCODE = readFile(SheetNumber);
			RestAssured.baseURI = "http://10.106.111.211/mailpieces/" + BARCODE + "/details";
			RequestSpecification httpRequest = RestAssured.given().headers("X-RMG-Client-ID", "UAT", "Content-Type",
					"application/x-www-form-urlencoded");
			Response response = httpRequest.get();
			int statusCode = response.getStatusCode();
			if (statusCode == 404) {
				removeRow(SheetNumber);
				return true;
			} else {
				while (statusCode != 404) {
					removeRow(SheetNumber);
					BARCODE = readFile(SheetNumber);
					RestAssured.baseURI = "http://10.106.111.211/mailpieces/" + BARCODE + "/details";
					httpRequest = RestAssured.given().headers("X-RMG-Client-ID", "UAT", "Content-Type",
							"application/x-www-form-urlencoded");
					response = httpRequest.get();
					statusCode = response.getStatusCode();
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			removeRow(SheetNumber);
			return false;
		}
		removeRow(SheetNumber);
		return true;
	}

	 private Boolean ValidateUID(String product) throws IOException {
	        try {
	            UID = readFile(1);
	            if(product.contains("SD")) {
	            	UID=UID.replace("32", "0B");
	            }
	            RestAssured.baseURI = "http://10.106.111.211/mailpieces/" + UID + "/details";
	            RequestSpecification httpRequest = RestAssured.given().headers("X-RMG-Client-ID", "UAT", "Content-Type", "application/x-www-form-urlencoded");
	            Response response = httpRequest.get();
	            int statusCode = response.getStatusCode();
	            if (statusCode == 404) {
                    removeRow(1);
	                return true;
	            } else {
	                while (statusCode != 404) {
	                    removeRow(1);
	                    UID = readFile(1);
	                    if(product.contains("SD")) {
	    	            	UID=UID.replace("32", "0B");
	    	            }
	                    RestAssured.baseURI = "http://10.106.111.211/mailpieces/" + UID + "/details";
	                    httpRequest = RestAssured.given().headers("X-RMG-Client-ID", "UAT", "Content-Type", "application/x-www-form-urlencoded");
	                    response = httpRequest.get();
	                    statusCode = response.getStatusCode();
	                }
	            }
	        } catch (Exception e) {
	            e.printStackTrace();
	            removeRow(1);
	            return false;
	        }
	        removeRow(1);
	        return true;
	    }
	public void getBarcodeandUID(String product) throws IOException {
		switch (product) {
		case "TPN01":
			ValidateBarcode(0);
			break;
		case "TPS01":
			ValidateBarcode(2);
			break;
		case "TPS01-48":
			ValidateBarcode(3);
			break;
		case "TPN01-24":
			ValidateBarcode(4);
			break;
		case "SD401":
			ValidateBarcode(5);
			break;
		case "SD101":
			ValidateBarcode(6);
			break;
		case "MTA01":
			ValidateBarcode(7);
		default:
			break;
		}
		ValidateUID(product);
		
		System.out.println("Barcode "+BARCODE+" UID "+UID);
	}

	public static String readFile(int index) {
		try {
			FileInputStream file = new FileInputStream(new File("src/Scripts/Barcode_List.xlsx"));
			System.out.println(new File(".").getAbsoluteFile());
			// Create Workbook instance holding reference to .xlsx file
			XSSFWorkbook workbook = new XSSFWorkbook(file);
			// Get first/desired sheet from the workbook
			XSSFSheet sheet = workbook.getSheetAt(index);
			// Iterate through each rows one by one
			Iterator<Row> rowIterator = sheet.iterator();
			for (int i = 0; i < 1; i++) {
				Row row = rowIterator.next();
				// For each row, iterate through all the columns
				Iterator<Cell> cellIterator = row.cellIterator();

				while (cellIterator.hasNext()) {
					Cell cell = (Cell) cellIterator.next();
					// Check the cell type and format accordingly
					switch (cell.getCellType()) {
					case STRING:
						return cell.getStringCellValue();
					case NUMERIC:
						return String.valueOf(cell.getNumericCellValue());
					}

				}
			}
			file.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static void removeRow(int index) throws IOException {
		Workbook workbook = WorkbookFactory.create(new FileInputStream("src/Scripts/Barcode_List.xlsx"));
		Sheet worksheet = workbook.getSheetAt(index);
		worksheet.shiftRows(1, worksheet.getLastRowNum(), -1);
		workbook.write(new FileOutputStream("src/Scripts/Barcode_List.xlsx"));
		workbook.close();
	}
	public void generateBarcode(String BarcodeToProcess,String D2Barcode) throws UnsupportedEncodingException {
		 try
         {
                 Document document = new Document();
                 PdfWriter pdfWriter = PdfWriter.getInstance(document, new FileOutputStream("src/Scripts/HelloWorld.pdf"));
                  
                 document.open();
                 PdfContentByte pdfContentByte = pdfWriter.getDirectContent();
                  
                 Barcode128 barcode128 = new Barcode128();
                 barcode128.setCode(BarcodeToProcess);
                 barcode128.setCodeType(Barcode128.CODE128);
                 Image code128Image = barcode128.createImageWithBarcode(pdfContentByte, null, null);
                 code128Image.setAbsolutePosition(10, 700);
                 code128Image.scalePercent(100);
                 document.add(code128Image);

                 //BarcodeDatamatrix 
              // supported square barcode dimensions
                 int[] barcodeDimensions = {10, 12, 14, 16, 18, 20, 22, 24, 26, 32, 36, 40, 44, 48, 52, 64, 72, 80, 88, 96, 104, 120, 132, 144};

                 BarcodeDatamatrix barcode = new BarcodeDatamatrix();
                 barcode.setOptions(BarcodeDatamatrix.DM_AUTO);

                 // try to generate the barcode, resizing as needed.
                 for (int generateCount = 0; generateCount < barcodeDimensions.length; generateCount++) {
                     barcode.setWidth(barcodeDimensions[generateCount]);
                     barcode.setHeight(barcodeDimensions[generateCount]);
                     int returnResult = barcode.generate(D2Barcode);
                     if (returnResult == BarcodeDatamatrix.DM_NO_ERROR) {
                    	 if(generateCount>11) {
                    	 document.add(barcode.createImage());
                    	 break;
                    	 }
                     }
                 }

                 document.close();
         }
         catch (FileNotFoundException e)
         {
                 e.printStackTrace();
         }
         catch (DocumentException e)
         {
                 e.printStackTrace();
         }
 }

	public String create2DContent(String barcode, String uID) {
		String D2String="JGB 6209F2"+CSVMapFor2D.get("UID")+"00010001041119041119"+CSVMapFor2D.get("PRODUCT")+"  "+CSVMapFor2D.get("BARCODE")+"                                       "+CSVMapFor2D.get("SENDERPOSTCODE")+"GB EC1A1BB  EC1A1BB   "+CSVMapFor2D.get("SENDERREFERENCE1")+" "+CSVMapFor2D.get("SENDERREFERENCE")+"              ";
		int length_string = D2String.length();
		int diff=204-length_string;
		String blank="";
		for(int i=0; i<diff;i++) {
			blank=blank+" ";
		}
		D2String=D2String+blank;
		System.out.println(" 2DString "+D2String+ " length "+D2String.length());
		return D2String;
	}
	
}
