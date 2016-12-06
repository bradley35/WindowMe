import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.NoSuchProviderException;
import javax.mail.PasswordAuthentication;
import javax.mail.Store;
import javax.mail.Transport;
import javax.servlet.http.HttpServlet;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.*;
@ServerEndpoint(value = "/WindowMeClient")
public class WindowMeClientHandler  extends HttpServlet{
public static Map<Session, Map> sessions = new HashMap<Session, Map>();
public Connection con = null;
@OnOpen
public void start(Session session) throws IOException {
	sessions.put(session, new HashMap<String, Object>());
	sessions.get(session).put("Sending", false);
	session.getBasicRemote().sendText("NeedCaptcha");
	
}
public void message(Session session, String message) throws IOException{
	session.getBasicRemote().sendText("Message:"+message);
}
public boolean verifyCaptcha(String key) throws IOException{
	StringBuilder result = new StringBuilder();
	String data="secret=ENTER-SECRET-HERE&response="+key;
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
@OnClose
public void end(Session session){
	sessions.remove(session);
}
public WindowMeClientHandler() throws ClassNotFoundException, SQLException{
	Class.forName("com.mysql.jdbc.Driver");
	con=DriverManager.getConnection("jdbc:mysql://localhost/WindowMe?"+"user=WindowMeJava"+"&"+"password=ENTER PASSWORD HERE");
	
}


public void addRoom(Session session, String name, String code1) throws SQLException{
	PreparedStatement s=con.prepareStatement("INSERT INTO `"+(String)sessions.get(session).get("Username")+"` (ID, Name) VALUES (\""+code1+"\",\""+name+"\");");
	s.execute();
}
public void delRoom(Session session,String name) throws SQLException, IOException{
	//session.getBasicRemote().sendText("DELETE FROM "+(String)sessions.get(session).get("Username")+" WHERE ID=\""+name+"\";");
	PreparedStatement s=con.prepareStatement("DELETE FROM `"+(String)sessions.get(session).get("Username")+"` WHERE Name=\""+name+"\";");
	
	s.execute();
	
}
public void listRooms(Session session) throws SQLException, IOException{
	PreparedStatement s=con.prepareStatement("SELECT * FROM `"+(String)sessions.get(session).get("Username")+"`;");
ResultSet set=s.executeQuery();
	StringBuilder json=new StringBuilder("{ \"Array\": [");
	
	if(set.last()){
		set.first();
	json.append("{\"Name\": \""+set.getString("Name")+"\", \"ID\": \""+set.getString("ID")+"\"}");
while(set.next()){
	json.append(",{\"Name\": \""+set.getString("Name")+"\", \"ID\": \""+set.getString("ID")+"\"}");

}
	}
json.append("]}");
session.getBasicRemote().sendText(json.toString());
}
@OnMessage
public void processUpload(String string, boolean last,  Session session) throws IOException, SQLException{
	try{
	if(string.indexOf("Code: ")>-1){
		String code=string.substring(6);
		
		if(WindowMeServerHandler.images.containsKey(code)){
			session.getBasicRemote().sendText("Ready");
			sessions.get(session).put("Code", code);
			sessions.get(session).put("Sending", false);
			
		}else{
			session.getBasicRemote().sendText("Invalid");
		}
	}else if(string.equals("ready")||string.equals("saved")){
		sessions.get(session).put("Sending", true);
		session.getBasicRemote().sendText(WindowMeServerHandler.images.get((String)(sessions.get(session).get("Code"))));
		
		
	}
	else if(string.equals("List")){
		listRooms(session);
		
	}else if(string.indexOf("Add: ")>-1){
		String data=string.substring(5);
		String name=data.split(":")[0];
		String id=data.split(":")[1];
		addRoom(session, name, id);
		session.getBasicRemote().sendText("STORED");
	}else if(string.indexOf("Delete: ")>-1){
		String id=string.substring(8);
		delRoom(session, id);
		session.getBasicRemote().sendText("DELETED");
	}else if(string.indexOf("Login: ")>-1){
		String credentials=string.substring(7);
		String username=credentials.split(":")[0];
		username=username.replaceAll("[^A-Za-z0-9 ]", "");
		String password=credentials.split(":")[1];
		String captcha="NotARealCaptcha123";
		if(credentials.split(":").length>=3){
			captcha=credentials.split(":")[2];
		}
		
		
		if(verifyCaptcha(captcha)){
		
		PreparedStatement s=con.prepareStatement("SELECT * FROM Login WHERE BINARY Username=?;");
		s.setString(1, username);
		
		ResultSet set=s.executeQuery();
		set.last();
		
		if(set.getRow()==1){
		
			if(HashTest.checkPassword(password, set.getString("Password"))&&set.getString("Verification Code").equals("0")){
				session.getBasicRemote().sendText("Success");
				sessions.get(session).put("Username", Integer.toString(set.getInt("UserID")));
				sessions.get(session).put("UsernameName", set.getString("Username"));
			}else{
				session.getBasicRemote().sendText("BadCombo");
			}
		}else{
			session.getBasicRemote().sendText("BadCombo");
		}
		}else{
			session.getBasicRemote().sendText("BadCombo");
		}
	}else if(string.indexOf("Register: ")>-1){
		
		String[] credentials=string.substring(10).split(":");
		String username=credentials[0];
		String password=credentials[1];
		String passwordV=credentials[2];
		String name=credentials[3];
		String email=credentials[4];
		username=username.replaceAll("[^A-Za-z0-9 ]", "");
		if(credentials.length<6){
			session.getBasicRemote().sendText("Message:Plase fill in captcha");
			return;
		}
		String captcha=credentials[5];
		
		if(!password.equals(passwordV)){
			session.getBasicRemote().sendText("Message:Passwords dont match");
			return;
		}
		if(!verifyCaptcha(captcha)){
			session.getBasicRemote().sendText("Message:Plase fill in captcha");
			//return;
		}
		StringBuilder code=new StringBuilder();
		for(int i=0; i<100; i++){
		int randomEmailCode=new Random().nextInt(43);
		if(randomEmailCode>25){
			randomEmailCode+=6;
		}
		if(randomEmailCode==49){
			
		}else{
		code.append((char)(65+randomEmailCode));
		}
		}
		
		PreparedStatement s=con.prepareStatement("SELECT * FROM Login WHERE BINARY Username=?;");
		s.setString(1, username);
		ResultSet set=s.executeQuery();
		if(set.last()==false){
			PreparedStatement statement=con.prepareStatement("INSERT INTO Login (`Username`, `Password`, `Verification Code`) VALUES (?,?,?)");
			statement.setString(1, username);
			statement.setString(2, HashTest.hash(password));
			statement.setString(3, code.toString());
			statement.execute();
		
			String createEventSQL=
					"Create" + "\n"
					    + "EVENT `DeleteWithoutVerification:"+username+"`" + "\n"
					    + "ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 HOUR ON COMPLETION NOT PRESERVE ENABLE" + "\n"
					    + "DO" + "\n"
					        + "DELETE FROM `Login` WHERE `Username`=? AND `Verification Code`<>'0';";
			PreparedStatement statement2=con.prepareStatement(createEventSQL);
			statement2.setString(1, username);
			statement2.execute();
			//session.getBasicRemote().sendText("INSERT INTO Login (`Username`, `Password`, `Verification Code`) VALUES ('"+username+"','"+HashTest.hash(password)+"','"+code.toString()+"')");
			String url="https://bamapp.net:8443/WindowMe/CompleteRegistration?id="+code.toString()+"&username="+username;
			sendEmail(email, "Thanks for signing up for Window-Me\nTo complete your registration please click <a href='"+url+"'>here</a>.\nIf you did not sign up for WindowMe, you can ignore this email and the account will be deleted in 1 hour.");
			
			
			
			
			
			session.getBasicRemote().sendText("Message:Please check your email for a verification link. Don't forget to search junk.");
			
		}else{
			session.getBasicRemote().sendText("Message:Username is already taken");
			return;
		}
		
		
	}
	}catch(Exception e){
		session.getBasicRemote().sendText("Message:"+e.getMessage());	
	}
}
public static void sendEmail(String addresses, String message) throws MessagingException {
	
	String password="ENTER PASSWORD HERE";
	String username="donotreply@bamapp.net";
	 Properties props = new Properties();
    props.put("mail.smtp.host", "smtp.zoho.com");
    props.put("mail.smtp.socketFactory.port", "465");
    props.put("mail.smtp.socketFactory.class",
            "javax.net.ssl.SSLSocketFactory");
    props.put("mail.smtp.auth", "true");
    props.put("mail.smtp.port", "465"); 
	javax.mail.Session session=javax.mail.Session.getInstance(props, new javax.mail.Authenticator(){
		
		  @Override
          protected PasswordAuthentication getPasswordAuthentication() {
              return new PasswordAuthentication(username,password);
          }
		
	});
	Transport tr=session.getTransport("smtp");
	System.out.println("About to Conenct");
	tr.connect();
	
	System.out.println("Connected");
	MimeMessage mailMessage=new MimeMessage(session);
mailMessage.setFrom(new InternetAddress("donotreply@bamapp.net"));
mailMessage.setRecipients(Message.RecipientType.TO, InternetAddress.parse(addresses));
mailMessage.setSubject("WindowMe");
mailMessage.setText(message, "utf-8", "HTML");
Transport.send(mailMessage);
System.out.println("Sent Message");
	
}

}
