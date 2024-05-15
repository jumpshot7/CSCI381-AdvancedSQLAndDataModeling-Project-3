//Author: Yan Chen
//Modified on: May 15th, 2024
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.sql.*;

public class DatabaseGUI extends JFrame {
    private JTextArea queryInputField;
    private JTextArea queryResultArea;
    private JButton executeButton;
    private Connection connection;

    public DatabaseGUI() {
        // Initialize UI components
        queryInputField = new JTextArea(10,10);
        queryResultArea = new JTextArea(100, 100);
        executeButton = new JButton("Execute Query");

        // Layout
        setLayout(new BorderLayout());
        add(queryInputField, BorderLayout.NORTH);
        add(new JScrollPane(queryResultArea), BorderLayout.CENTER);
        add(executeButton, BorderLayout.SOUTH);

        // Add action listener to the button
        executeButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                executeQuery(queryInputField.getText());
            }
        });

        // Set up the frame
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setTitle("Database Query Executor");
        pack();
        setVisible(true);

        // Connect to the database
        connectToDatabase();
    }

    private void connectToDatabase() {
        try {
            // Assuming a MySQL database. Change the URL, username, and password accordingly.
            String url = "jdbc:sqlserver://localhost:1433;encrypt=true;trustServerCertificate=true";
            String user = "SA";
            String password = "Chengyuan@216612";

            // Register JDBC driver and open a connection
            connection = DriverManager.getConnection(url, user, password);
        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(this, "Failed to connect to the database", "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void executeQuery(String query) {
        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {

            // Process the result set
            ResultSetMetaData metaData = resultSet.getMetaData();
            int columnCount = metaData.getColumnCount();
            StringBuilder resultBuilder = new StringBuilder();

            // Retrieve column names
            for (int i = 1; i <= columnCount; i++) {
                resultBuilder.append(metaData.getColumnName(i)).append("\t");
            }
            resultBuilder.append("\n");

            // Retrieve row data
            while (resultSet.next()) {
                for (int i = 1; i <= columnCount; i++) {
                    resultBuilder.append(resultSet.getString(i)).append("\t");
                }
                resultBuilder.append("\n");
            }

            // Display results
            queryResultArea.setText(resultBuilder.toString());
        } catch (SQLException sqle) {
            sqle.printStackTrace();
            JOptionPane.showMessageDialog(this, "Failed to execute query", "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                new DatabaseGUI();
            }
        });
    }
}
