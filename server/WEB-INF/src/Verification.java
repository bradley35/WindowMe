import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.websocket.server.ServerEndpoint;
@WebServlet(name="Verification",urlPatterns={"/CompleteRegistration"})
public class Verification extends HttpServlet{
	public Connection con = null;
	public Verification() throws ClassNotFoundException, SQLException {
		// TODO Auto-generated constructor stub
		
	}
	
	@Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException{
		try {
			Class.forName("com.mysql.jdbc.Driver");
			con=DriverManager.getConnection("jdbc:mysql://localhost/WindowMe?"+"user=WindowMeJava"+"&"+"password=5Hp6ryfYc6bNayeI");
		String id=req.getParameter("id");
		String username=req.getParameter("username");
			//resp.getWriter().println(id);
			PreparedStatement statement=con.prepareStatement("SELECT * FROM `Login` WHERE `Verification Code`=? AND `Username`=?;");
			statement.setString(1, id);
			statement.setString(2, username);
			ResultSet set=statement.executeQuery();
			set.last();
			
			if(set.getRow()==1){
				//resp.getWriter().println("GOOD");
				String userID=Integer.toString(set.getInt("UserID"));
				
				resp.sendRedirect("http://bamapp.net:8080/WindowMe/NavBar.html?email=Verified");
				PreparedStatement state=con.prepareStatement("UPDATE `Login` SET `Verification Code`='0' WHERE `Verification Code`=? AND `Username`=?");
				state.setString(1, id);
				state.setString(2, username);
				state.execute();
				PreparedStatement state2=con.prepareStatement("CREATE TABLE `"+userID+"` (`ID` varchar(20) NOT NULL,`Name` varchar(50) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
			state2.execute();
			}else{
				resp.sendRedirect("http://bamapp.net:8080/WindowMe/NavBar.html?email=Fail");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			resp.getWriter().println(e.getMessage());
		}
		
		
		
	}

}
