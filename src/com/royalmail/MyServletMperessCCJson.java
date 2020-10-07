package com.royalmail;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class MyServletMperessCCJson
 */
@WebServlet(description = "ConsumerCollectionProject", urlPatterns = { "/MyServletMperessCCJson" })
public class MyServletMperessCCJson extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private Path CSV_TEMPLATE_PATH = Paths.get("src/Scripts/_CR595_PDA_CCJSON_0308151107.csv");
	private Path PTP_PATH_new = Paths.get("src/Scripts/generatePTPMessage15AB.awk");
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public MyServletMperessCCJson() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Helper helper = new Helper();

		// Setting up the content type of webpage
		response.setContentType("text/html");

		// Writing message to the web page
		String orderid = request.getParameter("orderId").trim();
		String eventid = request.getParameter("ordereventId").toUpperCase().trim();
		String date = request.getParameter("ccdatejson");
		String locationid = request.getParameter("cclocationjson").replaceAll("\\D+", "");
		String flocationid = request.getParameter("ccFLocationID");
		String taskid = request.getParameter("ccTaskId");
		List<String> Items=new ArrayList<String>();
		try {
			String barcode1=request.getParameter("Barcode1");
			String event1=request.getParameter("Event1");
			
			String barcode2=request.getParameter("Barcode2");
			String event2=request.getParameter("Event2");
			
			String barcode3=request.getParameter("Barcode3");
			String event3=request.getParameter("Event3");
			
			String barcode4=request.getParameter("Barcode4");
			String event4=request.getParameter("Event4");
			
			String barcode5=request.getParameter("Barcode5");
			String event5=request.getParameter("Event5");
		
			if (!barcode1.isEmpty()) {
				Items.add(" -v TESTBARCODE1="+barcode1+" -v TESTEVENT1="+event1);
			}
			if (!barcode2.isEmpty()) {
				Items.add(" -v TESTBARCODE2="+barcode2+" -v TESTEVENT2="+event2);
			}
			if (!barcode3.isEmpty()) {
				Items.add(" -v TESTBARCODE3="+barcode3+" -v TESTEVENT3="+event3);
			}
			if (!barcode4.isEmpty()) {
				Items.add(" -v TESTBARCODE4="+barcode4+" -v TESTEVENT4="+event4);
			}
			if (!barcode5.isEmpty()) {
				Items.add(" -v TESTBARCODE5="+barcode5+" -v TESTEVENT5="+event5);
			}
		}catch(Exception e) {
			e.printStackTrace();
		}

		String generateMPER = "cmd.exe /C " + helper.GAWK_PATH.toAbsolutePath() + " -v TESTORDERID=" + orderid
				+ " -v TESTORDEREVENT=" + eventid + " -v TESTDATE=" + date + " -v TASKID=" + taskid + " -v FLOCATIONID="
				+ flocationid + " -v LOCATIONID=" + locationid + " -v XMLPATH=" + helper.XML_PATH + " -f "
				+ PTP_PATH_new.toAbsolutePath() + " <" + CSV_TEMPLATE_PATH.toAbsolutePath();

		for(int i=0;i<Items.size();i++) {
			generateMPER=generateMPER+Items.get(i);
		}

		
		System.out.println("generate " + generateMPER);
		try {
			Helper.runBatch(generateMPER);
			PageInstance.XML_PATH_for_Input = Paths.get("src/Scripts/CC_4_PDA-CCJSON-JC092GB.json");
			PageInstance.QueueName = "PDAST.BIG.EVENTS.IN.01";
			PageInstance.QueueManager = "MQSUPPORT.SVRCONN/TCP/10.106.85.21(1420)";
			PageInstance.INPUT_FILE = Paths.get("src/Scripts/Paramfile_MQPUT_PDA_PTY1.txt");
			helper.updateInputFile("json");
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
