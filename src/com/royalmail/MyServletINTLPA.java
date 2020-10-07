package com.royalmail;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class MyServletINTLPA
 */
@WebServlet(description = "Generate Preadvice for International", urlPatterns = { "/MyServletINTLPA" })
public class MyServletINTLPA extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public MyServletINTLPA() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		Helper helper = new Helper();
		
		HashMap<String, String> CSVMAP = new HashMap<String, String>();
		
		String Product = "INTL";
		
		String Barcode = request.getParameter("barcode");
		String UID = request.getParameter("uniqueID");
		String AccountNumber = request.getParameter("accNo");
		String ChannelID = request.getParameter("channelID");
		String PostingLocation = request.getParameter("postingLocation");
		String SendersCountry = request.getParameter("senderCountry");
		String ServiceID = request.getParameter("serviceID");
		String DeliveryAddress1 = request.getParameter("deliveryAddress1");
		String DeliveryPostTown = request.getParameter("deliveryPostTown");
		String DeliveryPostCode = request.getParameter("deliveryPostCode");
		String DeliveryCountry = request.getParameter("deliveryCountry");
		String Format = request.getParameter("format");
		String GazetteerCode =request.getParameter("gazetteerCode");
		String SupplementCode = request.getParameter("supplementCode");
		String SupplementData = request.getParameter("supplementData");
		String DDP = request.getParameter("ddpValue");
		String EORI = request.getParameter("sendersEORI");
		String Category = request.getParameter("category");
		String NatureOfItem = request.getParameter("nature");
		String TaxCode = request.getParameter("taxCode");
		String TermsOfDelivery = request.getParameter("termsOfDelivery");
		String RecipientName = request.getParameter("recipientName");
		String BusinessName = request.getParameter("businessName");
		String LocalPostTown =request.getParameter("localPostTown");
		String QuantityOfUnits = request.getParameter("quantityOfUnits");
		String UnitDescription = request.getParameter("unitDescription");
		String CountryOfOrigin =request.getParameter("unitCountry");
		String UnitValue = request.getParameter("unitValue");
		String UnitWeight = request.getParameter("unitWeight");
		String Tariff = request.getParameter("tariff");
		String extUnitDescString =request.getParameter("extDescription");
		
		helper.setMap(Product);
		CSVMAP = PageInstance.MapForProductINTL;
		System.out.println("MAP before put " + CSVMAP);
		
		CSVMAP.put("CHANNELID", ChannelID);
		CSVMAP.put("ACCOUNT", AccountNumber);
		CSVMAP.put("POSTINGLOCATION", PostingLocation);
		CSVMAP.put("SENDERSCOUNTRY", SendersCountry);
		CSVMAP.put("SERVICEID", ServiceID);
		CSVMAP.put("DELIVERYADDRESS1", DeliveryAddress1);
		CSVMAP.put("DELIVERYPOSTTOWN", DeliveryPostTown);
		CSVMAP.put("DELIVERYPOSTCODE", DeliveryPostCode);
		CSVMAP.put("DELIVERYCOUNTRY", DeliveryCountry);
		CSVMAP.put("FORMAT", Format);
		CSVMAP.put("GAZETTEERCODE", GazetteerCode);
		CSVMAP.put("SUPPLEMENTCODE", SupplementCode);
		CSVMAP.put("SUPPLEMENTDATA", SupplementData);
		CSVMAP.put("DDP", DDP);
		CSVMAP.put("SENDERSEORI", EORI);
		CSVMAP.put("CATEGORY", Category);
		CSVMAP.put("NATUREOFITEM", NatureOfItem);
		CSVMAP.put("IMPORTERTAXCODE", TaxCode);
		CSVMAP.put("TERMSOFDELIVERY", TermsOfDelivery);
		CSVMAP.put("LOCALISEDRECIPIENTNAME", RecipientName);
		CSVMAP.put("LOCALISEDBUSINESSNAME", BusinessName);
		CSVMAP.put("LOCALISEDPOSTTOWN", LocalPostTown);
		CSVMAP.put("QUANTITY", QuantityOfUnits);
		CSVMAP.put("DESCRIPTION", UnitDescription);
		CSVMAP.put("COUNTRYOFORIGIN", CountryOfOrigin);
		CSVMAP.put("VALUE", UnitValue);
		CSVMAP.put("WEIGHT", UnitWeight);
		CSVMAP.put("TARIFF", Tariff);
		CSVMAP.put("EXTENDEDDESCRIPTION", extUnitDescString);
		CSVMAP.put("BARCODE", Barcode);
		CSVMAP.put("UID", UID);
		
		System.out.println("MAP after put " + CSVMAP);
		helper.CSVMapFor2D = CSVMAP;
		helper.createInternationalCSV(CSVMAP);

		try {
			helper.processCSV();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

		String D2Content = helper.create2DContent(Barcode, UID);
		helper.generateBarcode(Barcode, D2Content);
		ServletOutputStream outs = response.getOutputStream();

		File file = new File("src/Scripts/HelloWorld.pdf");
		response.setContentType("application/octet-stream");
		String filename = Barcode + "_label.pdf";
		response.setHeader("Content-Disposition", "inline; filename=\"" + filename + "\"");

		BufferedInputStream bis = null;
		BufferedOutputStream bos = null;
		try {

			InputStream isr = new FileInputStream(file);
			bis = new BufferedInputStream(isr);
			bos = new BufferedOutputStream(outs);
			byte[] buff = new byte[2048];
			int bytesRead;
			// Simple read/write loop.
			while (-1 != (bytesRead = bis.read(buff, 0, buff.length))) {
				bos.write(buff, 0, bytesRead);
			}
		} catch (Exception e) {
			System.out.println("Exception ----- Message ---" + e);
		} finally {
			if (bis != null)
				bis.close();
			if (bos != null)
				bos.close();
		}

	}
	

}
