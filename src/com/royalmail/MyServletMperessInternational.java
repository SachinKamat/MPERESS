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
 * Servlet implementation class MyServletMperessInternational
 */
@WebServlet("/MyServletMperessInternational")
public class MyServletMperessInternational extends HttpServlet {
	Path CSV_TEMPLATE_PATH = Paths.get("src/Scripts/_CR595_PDA_MPER_INT_308151108.csv");

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Helper helper = new Helper();

		// Setting up the content type of webpage
		response.setContentType("text/html");

		// Writing message to the web page
		String barcode = request.getParameter("barcode");
		String eventid = request.getParameter("eventId").toUpperCase().trim();
		String date = request.getParameter("date1d");
		String locationid = request.getParameter("locationID").replaceAll("\\D+", "");
		String generateMPER = "";
		String testsrc=request.getParameter("source");
		String receptacleid=request.getParameter("ReceptacleId");
		System.out.println("unchecked");
		CSV_TEMPLATE_PATH = Paths.get("src/Scripts/_CR595_PDA_MPER_INT_308151108.csv");
		helper.PTP_PATH = Paths.get("src/Scripts/generatePTPMessage15INT.awk");
		generateMPER = "cmd.exe /C " + helper.GAWK_PATH.toAbsolutePath() + " -v TESTERI="+receptacleid+" -v TESTSRC="+testsrc+" -v TESTBARCODE=" + barcode
				+ " -v TESTEVENT=" + eventid + " -v TESTDATE=" + date + " -v LOCATIONID=" + locationid + " -v XMLPATH="
				+ helper.XML_PATH + " -f " + helper.PTP_PATH.toAbsolutePath() + " <"
				+ CSV_TEMPLATE_PATH.toAbsolutePath();

		System.out.println("generate " + generateMPER);
		try {

			PageInstance.XML_PATH_for_Input = Paths.get("src/Scripts/TC99_4_PDA-071C-JC092GB.xml");
			PageInstance.QueueName = "PDAST.BIG.PTYSCAN.IN.03";
			PageInstance.QueueManager = "MQSUPPORT.SVRCONN/TCP/10.106.85.21(1420)";
			PageInstance.INPUT_FILE = Paths.get("src/Scripts/Paramfile_MQPUT_PDA_PTY1.txt");
			Helper.runBatch(generateMPER);
			helper.updateInputFile("1d");
			List<String> Bat_list = PageInstance.updateBatFile();
			Helper.createBat(helper.BAT_FILE, Bat_list);
			Helper.movefile(PageInstance.XML_PATH_for_Input, true);

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