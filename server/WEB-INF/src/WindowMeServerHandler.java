import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.awt.image.WritableRaster;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;
import java.util.concurrent.atomic.AtomicInteger;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.imageio.ImageIO;
import javax.net.ssl.HttpsURLConnection;
import javax.servlet.http.HttpServlet;
//import org.apache.catalina.websocket.WebSocketServlet;
import javax.websocket.server.ServerEndpoint;

import org.apache.catalina.tribes.util.Arrays;

@ServerEndpoint(value = "/WindowMe")
public class WindowMeServerHandler extends HttpServlet{
private static AtomicInteger counter = new AtomicInteger(1000);
	public WindowMeServerHandler() throws IOException{

		
		
	}

	public static volatile Map<String, String> images= new HashMap<String, String>();
	public static volatile Map<String, String> codes= new HashMap<String, String>();
	public static volatile Map<Session, String> sessions= new HashMap<Session, String>();
	private byte[] c=new byte[0];
	@OnOpen
	public void start(Session session) {

	}
	@OnClose
	public void end(Session session){
		sessions.remove(session);
	}
	public String newCodeOne(String code2, Session session, String humanVerification){
		int code1=counter.incrementAndGet();
		
		String code1s=Base64.getEncoder().encodeToString(String.valueOf(code1).getBytes());
		code1s=code1s.replace("=", "");
//		if(sessions.get(session)!=null){
//			images.remove(sessions.get(session));
//			codes.remove(sessions.get(session));
//		}
		codes.put(code1s, code2);
		return code1s;
	}
	public String newCodeOne(String code2, Session session){
		int code1=counter.incrementAndGet();
		
		String code1s=Base64.getEncoder().encodeToString(String.valueOf(code1).getBytes());
		code1s=code1s.replace("=", "");
//		if(sessions.get(session)!=null){
//			images.remove(sessions.get(session));
//			codes.remove(sessions.get(session));
//		}
		codes.put(code1s, code2);
		return code1s;
	}
	boolean humanVerified=false;
	int count=0;
	public boolean verifyCaptcha(String key, Session session) throws IOException{
		StringBuilder result = new StringBuilder();
		String data="secret=EnterSecretHere&response="+key;
        String type="application/x-www-form-urlencoded";

        URL u = new URL("https://www.google.com/recaptcha/api/siteverify");

        HttpURLConnection conn = (HttpURLConnection) u.openConnection();
        conn.setDoOutput(true);

        conn.setRequestMethod("POST");
        conn.setRequestProperty( "Content-Type", type );
        conn.setRequestProperty( "Content-Length", String.valueOf(data.length()));	

        OutputStream os = conn.getOutputStream();

        os.write(data.getBytes());	

        BufferedReader rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
      
        String line;

        while ((line = rd.readLine()) != null) {
           result.append(line);

        }
        rd.close();
		
		
		return (result.toString().substring(14, 18).equals("true"));
		
	}
	@OnMessage
	public void processUpload(String string, boolean last,  Session session) throws IOException{
		try{
	if(!humanVerified){
		try{
		humanVerified=verifyCaptcha(string, session);
		}catch(Exception e){
			session.getBasicRemote().sendText(e.getMessage());
		}
		session.getBasicRemote().sendText("Ready to go");
	}
		
		
		
		
		if(humanVerified){
		if(string.indexOf("Code: ")>-1){
			String string2=string.substring(6);
		String[] codesS=string2.split(":");
		String code1=codesS[0];
		String code2=codesS[1];
		
		if(codes.get(code1)!=null){
			if(codes.get(code1).equals(code2)){
				sessions.put(session, code1);
				session.getBasicRemote().sendText("200");
				
				
			}else{
				session.getBasicRemote().sendText("NO");
				//session.close();
			}
		}else{
			session.getBasicRemote().sendText("NO");
			//session.close();
		}
		}
		else if(string.indexOf("NewCodeWith: ")>-1){
			if(count!=0){
			String code2=string.substring(13).split(":")[0];
			String ver=string.substring(13).split(":")[1];
			session.getBasicRemote().sendText("NewCode: "+newCodeOne(code2, session, ver));
			}else{
				String code2=string.substring(13);
				session.getBasicRemote().sendText("NewCode: "+newCodeOne(code2, session));
				count+=1;
			}
		}
		}else{
			session.close();
		}
		}
		catch(Exception e){
			session.getBasicRemote().sendText(e.getMessage());	
		}
		}
	
	
	
	@OnMessage
	public void processUpload(byte[] b, boolean last, Session session) throws IOException {
		if(sessions.get(session)==null){
			session.getBasicRemote().sendText("Please Authenticate");
			session.close();
		}else{
	byte[] oldC=c.clone();
	c=new byte[c.length+b.length];
	System.arraycopy(oldC, 0, c, 0, oldC.length);
	System.arraycopy(b, 0, c, oldC.length, b.length);
	if(last){
		
		//session.getBasicRemote().sendText("200");
	
	images.put(sessions.get(session), Base64.getEncoder().encodeToString(c));
	c=new byte[0];
	
	}
	}
	}

}
