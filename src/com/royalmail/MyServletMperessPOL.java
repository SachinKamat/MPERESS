package com.royalmail;

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
 * Servlet implementation class MyServletMperessPOL
 */
@WebServlet("/MyServletMperessPOL")
public class MyServletMperessPOL extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Path CSV_TEMPLATE_PATH = Paths.get("src/Scripts/POL_SCAN.csv");
	private Path PTP_PATH_new = Paths.get("src/Scripts/generatePTPMessagePOL.awk");

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public MyServletMperessPOL() {
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
		String barcode = request.getParameter("barcode").toUpperCase();
		String eventcode = request.getParameter("eventCode").toUpperCase().trim();
		String date = request.getParameter("datePol");
		String time = request.getParameter("timePol");
		String fad = request.getParameter("fad");

//	      String locationid = request.getParameter("locationID").replaceAll("\\D+","");

		String generatePOL = "cmd.exe /C " + helper.GAWK_PATH.toAbsolutePath() + " -v TESTBARCODE=" + barcode
				+ " -v TESTEVENT=" + eventcode + " -v TESTDATE=" + date + " -v TESTTIME=" + time + " -v TESTFAD=" + fad
				+ " -v XMLPATH=" + helper.XML_PATH + " -v NORFH=false " + " -f " + PTP_PATH_new.toAbsolutePath() + " <"
				+ CSV_TEMPLATE_PATH.toAbsolutePath();

		System.out.println("generate " + generatePOL);

		try {
			Helper.runBatch(generatePOL);
			PageInstance.XML_PATH_for_Input = Paths.get("src/Scripts/TC99_4_POL-071C-JC092GB.xml");
			PageInstance.QueueName = "POL_POL.BK_CHARACTER.DATA_H";
			PageInstance.QueueManager = "MQREAD.SVRCONN/TCP/10.106.85.13(1414)";
			PageInstance.INPUT_FILE = Paths.get("src/Scripts/Paramfile_MQPUT_POL.txt");
			List<String>Bat_list=PageInstance.updateBatFile();
			helper.updateInputFile("pol");
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

	public void destroy() {
		/*
		 * leaving empty for now this can be used when we want to do something at the
		 * end of Servlet life cycle
		 */
	}

}