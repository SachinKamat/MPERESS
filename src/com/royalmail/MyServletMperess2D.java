package com.royalmail;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class MyServletMperess2D
 */
@WebServlet("/MyServletMperess2D")
public class MyServletMperess2D extends HttpServlet {
	private Path CSV_TEMPLATE_PATH = Paths.get("src/Scripts/_CR595_PDA_MPER_0308151107_old.csv");
	// final Path CSV_TEMPLATE_PATH =
	// Paths.get("src/Scripts/_CR595_PDA_MPER_0308151107.csv");
	private Path PTP_PATH_new = Paths.get("src/Scripts/generatePTPMessage15AB_old.awk");
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public MyServletMperess2D() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// TODO Auto-generated method stub

		Helper helper = new Helper();

		// Setting up the content type of webpage
		response.setContentType("text/html");

		// Writing message to the web page
		String barcode = request.getParameter("barcode").trim();
		String eventid = request.getParameter("eventId").toUpperCase().trim();
		String date = request.getParameter("date2d");
		String locationid = request.getParameter("locationID").replaceAll("\\D+", "");
		String uid = request.getParameter("UID");
		String productid = request.getParameter("productID");
		String DestinationPostCode = request.getParameter("destinationId");
		String generateMPER = "cmd.exe /C " + helper.GAWK_PATH.toAbsolutePath() + " -v TESTBARCODE=" + barcode
				+ " -v TESTEVENT=" + eventid + " -v TESTDATE=" + date + " -v TESTUUID=" + uid + " -v PRODUCTID="
				+ productid + " -v LOCATIONID=" + locationid + " -v DESTINATIONPO=" + DestinationPostCode
				+ " -v XMLPATH=" + helper.XML_PATH + " -f " + PTP_PATH_new.toAbsolutePath() + " <"
				+ CSV_TEMPLATE_PATH.toAbsolutePath();

		System.out.println("generate " + generateMPER);
		try {
			Helper.runBatch(generateMPER);
			PageInstance.XML_PATH_for_Input = Paths.get("src/Scripts/TC99_4_PDA-071C-JC092GB.xml");
			PageInstance.QueueName = "PDAST.BIG.PTYSCAN.IN.03";
			PageInstance.QueueManager = "MQSUPPORT.SVRCONN/TCP/10.106.85.21(1420)";
			PageInstance.INPUT_FILE = Paths.get("src/Scripts/Paramfile_MQPUT_PDA_PTY1.txt");
			helper.updateInputFile("2d");
			List<String>Bat_list=PageInstance.updateBatFile();
			Helper.createBat(helper.BAT_FILE, Bat_list);

		} catch (IOException | InterruptedException ex) {
			ex.printStackTrace();
		}

		RequestDispatcher rd = request.getRequestDispatcher("default.jsp");
		rd.include(request, response);
		response.setContentType("text/html");
		PrintWriter pw = response.getWriter();
		pw.println("<script type=\"text/javascript\">");
		pw.println("alert('Success');");
		pw.println("</script>");
	}

}
