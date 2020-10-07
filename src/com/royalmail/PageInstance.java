package com.royalmail;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

public class PageInstance {
	Path PTP_PATH = Paths.get("src/Scripts/generatePTPMessage15SK.awk");
	final Path GAWK_PATH = Paths.get("src/Scripts/gawk.exe");
	static Path XML_PATH_for_Input = Paths.get("src/Scripts/TC99_4_PDA-071C-JC092GB.xml");
	public static String QueueName = "PDAST.BIG.PTYSCAN.IN.03";
	public static String QueueManager = "MQSUPPORT.SVRCONN/TCP/10.106.85.21(1420)";
	final String XML_PATH = new File("src/Scripts/").getAbsolutePath().replace("\\", "\\\\");
	final static Path RFHUTIL_PATH = Paths.get("src/Scripts/RFHUtil/mqputsc.exe");
	public static Path INPUT_FILE = Paths.get("src/Scripts/Paramfile_MQPUT_PDA_PTY1.txt");
	final static Path Result_Directory_path = Paths.get("src/Scripts/Results");
	public static Path Barcode_Path = Paths.get("src/Scripts/Barcode_List.xlsx");
	final Path BAT_FILE = Paths.get("src/Scripts/run.bat");
	
	public static HashMap<String, String>MapForProductT24=new HashMap<String, String>();
	public static HashMap<String, String>MapForProductT48=new HashMap<String, String>();
	public static HashMap<String, String>MapForProductSDG=new HashMap<String, String>();
	public static HashMap<String, String>MapForProductINTL=new HashMap<String, String>();
	public static HashMap<String, String>CSVMapFor2D=new HashMap<String, String>();
	
	public static String BARCODE="";
	public static String UID="";
	
	 public static final Path BAT_Preadvice = Paths.get("src/Scripts/run_preadvice.bat");
	    public static final Path WINSCP_Install_DIR = Paths.get("C:\\Program Files (x86)\\WinSCP");
	    public static final Path WINSCP_LOG=Paths.get("src/Scripts/Winscp_output.log");
	    public static final Path WinSCR_upload_file = Paths.get("src/Scripts/winSCP_uploadScript.txt");
	    public static Path Output_PDF_file = Paths.get("src/Scripts/HelloWorld.pdf");
	    
	static List<String> Bat_Preadvice_list = Arrays.asList("@echo off","REM","CD \""+WINSCP_Install_DIR+"\"","\""+WINSCP_Install_DIR+"\\WinSCP.exe"+"\" /log=\""+WINSCP_LOG.toAbsolutePath()+"\" /ini=nul /script=\""+WinSCR_upload_file.toAbsolutePath()+"\"");

	static final String[] LocationName = { "GreenFord(002626)", "Chelmsford (002609)", "Inverness (002629)",
			"Southampton (002653)", "Glasgow (002624)", "Bristol (002604)", "South Midlands (004554)",
			"Northern Ireland Mail Centre(002599)" };
	static final String[] DOName = { "Northolt (001355)", "Hayes (001354)", "Sudbury (000274)", "Thurso (000654)",
			"Winchester (001192)", "Willesden (000914)", "Wishaw (000808)", "Thornbury (000135)",
			"Atherstone (000300)" };
	static final String[] RDcName = { "Princess Royal RDC (002673)", "Scottish RDC (002677)", "South West RDC (002675)",
			"Atherstone Xmas RDC (0018769)", "Atherstone RDC (0018815)" };
	static final String[] selectOption = { "DO", "IMC Mail Centre", "RDC" };

	public static List<String> updateBatFile() {
		List<String> Bat_list = Arrays.asList("@echo off", " TITLE=MQPUT - PDA_PTY 1", "REM",
				"set ResultsDirectory=%1\\MQputs",
				"if \"%1\"==\"\" set ResultsDirectory=" + Result_Directory_path.toAbsolutePath().toString(),
				"set datetime=",
				"for /f \"skip=1 delims=\" %%x in ('wmic os get localdatetime') do if not defined datetime set datetime=%%x",
				"set outputLog=%ResultsDirectory%\\PDA_PTY_1_%datetime:~0,8%_%datetime:~8,6%_mqputs.txt",
				"set MQSERVER=" + QueueManager, RFHUTIL_PATH.toAbsolutePath().toString() + " -f "
						+ INPUT_FILE.toAbsolutePath().toString() + " > %outputLog%",
				"exit");
		return Bat_list;
	}
	

	public static void updateInputFile(String Type) {
		try {
			List<String> list=null;
			if(Type.equalsIgnoreCase("pol")) {
				 list = Arrays.asList("[header]", "* Input parameters for MQPut2 program *",
						"** name of the queue and queue manager", "* to write messages to", "qname=" + QueueName,
						"qmgr=" + QueueManager, "* total number of messages to be written",
						"* the program will stop after this number of", "* messages has been written", "msgcount=1",
						"qdepth=500", "qmax=5000", "sleeptime=10", "thinktime=1000", "tune=0", "batchsize=1",
						"[filelist]", XML_PATH_for_Input.toAbsolutePath().toString());
			}else {
				list = Arrays.asList("[header]", "* Input parameters for MQPut2 program *",
						"** name of the queue and queue manager", "* to write messages to", "qname=" + QueueName,
						"qmgr=" + QueueManager, "* total number of messages to be written",
						"* the program will stop after this number of", "* messages has been written", "msgcount=1",
						"qdepth=500", "qmax=5000", "sleeptime=10", "thinktime=1000", "tune=0", "batchsize=1",
						"format= \"MQHRF2 \"", "priority=2", "persist=1", "msgtype=8", "encoding=546", "codepage=1208",
						"delimiter=\"#@%@#\"", "rfh=N", "RFH_CCSID=1208", "RFH_ENCODING=546", "RFH_NAME_CCSID=1208",
						"[filelist]", XML_PATH_for_Input.toAbsolutePath().toString());
			}
			System.out.println("list " + list);
			Files.write(INPUT_FILE.toAbsolutePath(), list);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
