//Author: Yan Chen
//Modified on: May 15th, 2024
import javax.swing.*;
public class Main {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                new DatabaseGUI();
            }
        });
    }
}