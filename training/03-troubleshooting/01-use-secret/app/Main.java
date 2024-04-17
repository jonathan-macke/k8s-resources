import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Main {

    public static void main(String[] args) throws Exception {
        // Database connection parameters
        String url = System.getenv("DB_URL"); 
        String username = System.getenv("DB_USER");
        String password = System.getenv("DB_PWD");

        Class.forName("org.postgresql.Driver");
        Connection connection = DriverManager.getConnection(url, username, password);
            
        if (connection != null) {
            System.out.println("Connected to the PostgreSQL database!");
                // You can perform database operations here
                // For example: execute queries, updates, etc.
                
            connection.close();
            Thread.sleep(360_000);
        } else {
            throw new Exception("Failed to make connection!");
        }
    }
}