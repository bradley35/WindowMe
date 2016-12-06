import java.util.Base64;
import java.util.Random;

import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import javax.mail.MessagingException;

public class HashTest {

	public HashTest() {
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) throws MessagingException {
		// TODO Auto-generated method stub
//		String url="https://bamapp.net:8080/WindowMe/CompleteRegistration?id="+"CODE!@#12321#@!EDOC";
//		WindowMeClientHandler.sendEmail("bamay99@gmail.com", "Thanks for signing up for Window-Me\nTo complete your registration please click <a href='"+url+"'>here</a>\nIf you did not sign up for WindowMe, you can ignore this email and the account will be deleted in 1 hour.");
System.out.println(checkPassword("password", "XLNMGieAlXnXiLVpmhaWPDjDfhhTajUJHZQngglILgJWfYSSGBkOlIcQIITLVjlG|wtEk/cSvyT6xLWL6BDw+uoAxSXjMvGGxsHyLKhkEsa+EVKxkotV1qOMkyayrm6AvrnY9vdxmkGch+zauS35BMg=="));
//System.out.println(hash("password"));
	}
	
	public static String base64encode(byte[] bytes){
		return Base64.getEncoder().encodeToString(bytes);
	}
public static byte[] base64decode(String data){
		return Base64.getDecoder().decode(data);
	}
public static String hash(String salt, String password){
	try {
        SecretKeyFactory skf = SecretKeyFactory.getInstance( "PBKDF2WithHmacSHA512" );
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt.getBytes(), 50000, 512);
        SecretKey key = skf.generateSecret( spec );
        byte[] res = key.getEncoded( );
        return base64encode(res);

    } catch(Exception e ) {
    	System.out.println(e.getMessage());
    	return null;
        
    }
}
public static String hash(String password){
	//Generate salt
	StringBuilder code=new StringBuilder();
	for(int i=0; i<64; i++){
	int randomEmailCode=new Random().nextInt(42);
	if(randomEmailCode>25){
		randomEmailCode+=6;
	}
	code.append((char)(65+randomEmailCode));
	
	}
	String salt = code.toString();
	return salt+"|"+hash(salt, password);
}

public static boolean checkPassword(String check, String checkAgainst, String salt){
	return hash(salt, check).equals(checkAgainst);
}
public static boolean checkPassword(String check, String checkAgainst){
	return checkPassword(check, checkAgainst.split("\\|")[1], checkAgainst.split("\\|")[0]);
}

}
