package com.royalmail;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.HashMap;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.lowagie.text.Image;
import com.lowagie.text.pdf.BarcodeEAN;

/**
 * Servlet implementation class MyServletPACOSS
 */
@WebServlet("/MyServletPACOSS")
public class MyServletPACOSS extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public MyServletPACOSS() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletresponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletresponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		Helper helper = new Helper();
		// response.setContentType("text/html");
		String Product = request.getParameter("productTypeID");

		String VTN = request.getParameter("vtn");
		String VTN1 = request.getParameter("vtn1");
		String SENDERADDRESS1 = request.getParameter("senderAddress1");
		String SENDERADDRESS2 = request.getParameter("senderAddress2");
		String SENDERPOSTCODE = request.getParameter("senderPostCode");
		String SENDERNAME = request.getParameter("senderName");
		String EMAILID = request.getParameter("emailId");
		String LOCATIONID = request.getParameter("LocationID");
		System.out.println("Product " + Product);
		System.out.println(Product + VTN + SENDERADDRESS1 + SENDERADDRESS2 + SENDERPOSTCODE);
		HashMap<String, String> CSVMAP = new HashMap<String, String>();

		switch (Product) {
		case "TPN01":
			helper.setMap(Product);
			helper.getBarcodeandUID(Product);
			CSVMAP = PageInstance.MapForProductT24;
			System.out.println("MAP before put " + CSVMAP);
			break;
		case "TPS01":
			helper.setMap(Product);
			helper.getBarcodeandUID(Product);
			CSVMAP = PageInstance.MapForProductT48;
			System.out.println("MAP before put " + CSVMAP);
			break;
		case "TPS01-48":
			helper.setMap(Product);
			helper.getBarcodeandUID(Product);
			CSVMAP = PageInstance.MapForProductT48;
			System.out.println("MAP before put " + CSVMAP);
			break;
		case "SD101":
			helper.setMap(Product);
			helper.getBarcodeandUID(Product);
			CSVMAP = PageInstance.MapForProductSDG;
			System.out.println("MAP before put " + CSVMAP);
			break;
		case "SD401":
			helper.setMap(Product);
			helper.getBarcodeandUID(Product);
			CSVMAP = PageInstance.MapForProductSDG;
			System.out.println("MAP before put " + CSVMAP);
			break;
		case "TPN01-24":
			helper.setMap(Product);
			helper.getBarcodeandUID(Product);
			CSVMAP = PageInstance.MapForProductT24;
			System.out.println("MAP before put " + CSVMAP);
			break;
		default:
			break;
		}
		if (!VTN.isEmpty()) {
			CSVMAP.put("SENDERREFERENCE", VTN);
		}
		if (!VTN1.isEmpty()) {
			CSVMAP.put("SENDERREFERENCE1", VTN1);
		}

		CSVMAP.put("SENDERPOSTCODE", SENDERPOSTCODE);
		CSVMAP.put("SENDERADDRESS1", SENDERADDRESS1);
		CSVMAP.put("SENDERADDRESS2", SENDERADDRESS2);
		CSVMAP.put("LOCATIONID", LOCATIONID);
		CSVMAP.put("SENDERNAME", SENDERNAME);
		CSVMAP.put("EMAIL", EMAILID);
		CSVMAP.put("BARCODE", PageInstance.BARCODE);
		CSVMAP.put("UID", PageInstance.UID);
		System.out.println("MAP after put " + CSVMAP);
		helper.CSVMapFor2D = CSVMAP;
		helper.createCSV(CSVMAP);

		try {
			helper.processCSV();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

		String Barcode = PageInstance.BARCODE;
		String UID = PageInstance.UID;

		String D2Content = helper.create2DContent(Barcode, UID);
		helper.generateBarcode(Barcode, D2Content);
		ServletOutputStream outs = response.getOutputStream();

		File file = new File("src//Scripts//HelloWorld.pdf");
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
	// response.setHeader("Content-Disposition", "inline;filename="
	// +"HelloWorld.pdf");

}
