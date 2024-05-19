// Author: Yan Chen
// Modified on: May 15th, 2024
import javax.swing.*;
import javax.swing.table.DefaultTableModel;
import java.awt.*;
import java.awt.event.*;
import java.sql.*;

public class DatabaseGUI extends JFrame {
    private JTextArea queryInputField;
    private JTable queryResultTable;
    private JButton executeButton;
    private Connection connection;

    public DatabaseGUI() {
        // Initialize UI components
        queryInputField = new JTextArea(5, 20);
        queryResultTable = new JTable();
        executeButton = new JButton("Execute Query");

        // Layout
        setLayout(new BorderLayout());
        add(new JScrollPane(queryInputField), BorderLayout.NORTH);
        add(new JScrollPane(queryResultTable), BorderLayout.CENTER);
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
            String password = "";

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

            // Retrieve column names
            String[] columnNames = new String[columnCount];
            for (int i = 1; i <= columnCount; i++) {
                columnNames[i - 1] = metaData.getColumnName(i);
            }

            // Retrieve row data
            DefaultTableModel tableModel = new DefaultTableModel(columnNames, 0);
            while (resultSet.next()) {
                String[] rowData = new String[columnCount];
                for (int i = 1; i <= columnCount; i++) {
                    rowData[i - 1] = resultSet.getString(i);
                }
                tableModel.addRow(rowData);
            }

            // Display results in JTable
            queryResultTable.setModel(tableModel);
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
